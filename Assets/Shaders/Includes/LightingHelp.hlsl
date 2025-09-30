void GetMainLight_float(float3 WorldPos, out float3 Color, out float3 Direction, out float DistanceAtten, out float ShadowAtten)
{
#ifdef SHADERGRAPH_PREVIEW
    Direction = normalize(float3(0.5, 0.5, 0));
    Color = 1;
    DistanceAtten = 1;
    ShadowAtten = 1;
#else
#if SHADOWS_SCREEN
        float4 clipPos = TransformWorldToClip(WorldPos);
        float4 shadowCoord = ComputeScreenPos(clipPos);
#else
    float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
#endif

    Light mainLight = GetMainLight(shadowCoord);
    Direction = mainLight.direction;
    Color = mainLight.color;
    DistanceAtten = mainLight.distanceAttenuation;
    ShadowAtten = mainLight.shadowAttenuation;
#endif
}

void ComputeAdditionalLighting_float(float3 WorldPosition, float3 WorldNormal,
    float2 Thresholds, float3 RampedDiffuseValues,
    out float3 Color, out float Diffuse)
{
    Color = float3(0, 0, 0);
    Diffuse = 0;

#ifndef SHADERGRAPH_PREVIEW

    int pixelLightCount = GetAdditionalLightsCount();
    
    for (int i = 0; i < pixelLightCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPosition);
        float4 tmp = unity_LightIndices[i / 4];
        uint light_i = tmp[i % 4];

        half shadowAtten = light.shadowAttenuation * AdditionalLightRealtimeShadow(light_i, WorldPosition, light.direction);
        
        half NdotL = saturate(dot(WorldNormal, light.direction));
        half distanceAtten = light.distanceAttenuation;

        half thisDiffuse = distanceAtten * shadowAtten * NdotL;
        
        half rampedDiffuse = 0;
        
        if (thisDiffuse < Thresholds.x)
        {
            rampedDiffuse = RampedDiffuseValues.x;
        }
        else if (thisDiffuse < Thresholds.y)
        {
            rampedDiffuse = RampedDiffuseValues.y;
        }
        else
        {
            rampedDiffuse = RampedDiffuseValues.z;
        }

        
        if (light.distanceAttenuation <= 0)
        {
            rampedDiffuse = 0.0;
        }

        Color += max(rampedDiffuse, 0) * light.color.rgb;
        Diffuse += rampedDiffuse;
    }
    
    if (Diffuse <= 0.3)
    {
        Color = float3(0, 0, 0);
        Diffuse = 0;
    }
    
#endif
}

inline float softstep(float x, float t, float w)
{
    return (w > 0.0) ? smoothstep(t - w, t + w, x) : step(t, x);
}

void ChooseColor_float(
    float3 Highlight, float3 MidTone, float3 Shadow,
    float Diffuse,
    float Threshold1, float Threshold2,
    float Feather12,
    float Feather23,
    out float3 OUT)
{
    float s1 = softstep(Diffuse, Threshold1, max(0.0, Feather12));
    float s2 = softstep(Diffuse, Threshold2, max(0.0, Feather23));

    float wShadow    = 1.0 - s1;
    float wHighlight = s2;
    float wMid       = saturate(1.0 - wShadow - wHighlight);

    OUT = Shadow * wShadow + MidTone * wMid + Highlight * wHighlight;
}


inline float3 srgb_to_linear(float3 c) {
    return pow(c, 2.2);
}
inline float3 linear_to_srgb(float3 c) {
    return pow(saturate(c), 1.0/2.2);
}

inline float3 rgb_to_oklab(float3 c_lin) {
    float l = 0.41222147*c_lin.r + 0.53633254*c_lin.g + 0.05144599*c_lin.b;
    float m = 0.21190350*c_lin.r + 0.68069950*c_lin.g + 0.10739696*c_lin.b;
    float s = 0.08830246*c_lin.r + 0.28171884*c_lin.g + 0.62997870*c_lin.b;

    l = pow(l, 1.0/3.0);
    m = pow(m, 1.0/3.0);
    s = pow(s, 1.0/3.0);

    return float3(
        0.21045426*l + 0.79361778*m - 0.00407205*s,
        1.97799850*l - 2.42859220*m + 0.45059370*s,
        0.02590404*l + 0.78277177*m - 0.80867577*s
    );
}

inline float3 oklab_to_rgb(float3 L_ab) {
    float L = L_ab.x, a = L_ab.y, b = L_ab.z;

    float l = L + 0.3963377774*a + 0.2158037573*b;
    float m = L - 0.1055613458*a - 0.0638541728*b;
    float s = L - 0.0894841775*a - 1.2914855480*b;

    l = l*l*l;
    m = m*m*m;
    s = s*s*s;

    return float3(
        +4.0767416621*l - 3.3077115913*m + 0.2309699292*s,
        -1.2684380046*l + 2.6097574011*m - 0.3413193965*s,
        -0.0041960863*l - 0.7034186147*m + 1.7076147010*s
    );
}

void ToonHighlightShadow_float(
    float3 baseSRGB,
    float  hiLift,
    float  shDrop,
    float  satCurve,
    out float3 hiSRGB,
    out float3 shSRGB)
{
    float3 baseLin = srgb_to_linear(baseSRGB);
    float3 lab     = rgb_to_oklab(baseLin);

    float  C = sqrt(lab.y*lab.y + lab.z*lab.z);
    float2 hueAxis = (C > 1e-6) ? float2(lab.y, lab.z) / C : float2(0.0, 0.0);

    float Lh = saturate(lab.x + hiLift);
    float Ch = C * (1.0 - 0.5 * saturate(satCurve) * C);

    float Ls = saturate(lab.x * (1.0 - shDrop));
    float Cs = C * (1.0 + 0.6 * saturate(satCurve) * (1.0 - C));

    float3 lab_hi = float3(Lh, hueAxis * Ch);
    float3 lab_sh = float3(Ls, hueAxis * Cs);

    float3 hiLin = oklab_to_rgb(lab_hi);
    float3 shLin = oklab_to_rgb(lab_sh);

    hiSRGB = linear_to_srgb(hiLin);
    shSRGB = linear_to_srgb(shLin);
}

void MirrorRepeatUV_float(float2 uv, float2 tiling, out float2 uvMirrored)
{
    float2 u = uv * tiling;
    // triangle wave = abs(frac(x)*2 - 1)
    uvMirrored = abs(frac(u) * 1.7 - 1.0);
}
