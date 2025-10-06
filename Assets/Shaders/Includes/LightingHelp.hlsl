void GetMainLight_float(float3 WorldPos, out float3 Color, out float3 Direction, out float DistanceAtten, out float ShadowAtten) {
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

#ifndef SG_ADDITIONAL_LIGHTS_INCLUDED
#define SG_ADDITIONAL_LIGHTS_INCLUDED


void ComputeAdditionalLighting_float(
    float3 WorldPosition,
    float3 WorldNormal,
    float2 Thresholds,
    float3 RampedDiffuseValues,
    out float3 Color,
    out float Diffuse)
{
    Color = 0;
    Diffuse = 0;

#ifndef SHADERGRAPH_PREVIEW
    int addCount = GetAdditionalLightsCount();

    [loop]
        for (int i = 0; i < addCount; i++)
        {
            Light L = GetAdditionalLight(i, WorldPosition);

            float ndotl = dot(WorldNormal, L.direction);
            float halfLambert = saturate(ndotl * 0.5 + 0.5);

            float thisDiffuse = L.distanceAttenuation * halfLambert;


            float ramped =
                (thisDiffuse < Thresholds.x) ? RampedDiffuseValues.x :
                (thisDiffuse < Thresholds.y) ? RampedDiffuseValues.y :
                RampedDiffuseValues.z;

            if (L.distanceAttenuation <= 0) ramped = 0;

            Color += max(ramped, 0) * L.color.rgb;
            Diffuse += ramped;
        }
#endif
}

void ComputeAdditionalLighting_half(
    half3 WorldPosition,
    half3 WorldNormal,
    half2 Thresholds,
    half3 RampedDiffuseValues,
    out half3 Color,
    out half Diffuse)
{
    float3 C; float D;
    ComputeAdditionalLighting_float(WorldPosition, WorldNormal, Thresholds, RampedDiffuseValues, C, D);
    Color = (half3)C;
    Diffuse = (half)D;
}

#endif




void ChooseColor_float(float3 Highlight, float3 Shadow, float Diffuse, float Threshold, out float3 OUT)
{
    if (Diffuse < Threshold)
    {
        OUT = Shadow;
    }
    else
    {
        OUT = Highlight;
    }
}

// Three-step toon: Shadow / Mid / Highlight via two thresholds (t1 < t2)
void ChooseColor3_float(
    float3 Highlight, float3 Mid, float3 Shadow,
    float Diffuse, float t1, float t2,
    out float3 OUT)
{
    if (t1 > t2) { float tmp = t1; t1 = t2; t2 = tmp; }

    if (Diffuse < t1)
        OUT = Shadow;
    else if (Diffuse < t2)
        OUT = Mid;
    else
        OUT = Highlight;
}



void ChooseColor3Smooth_float(
    float3 Highlight, float3 Mid, float3 Shadow,
    float Diffuse, float t1, float t2, float w1, float w2,
    out float3 OUT)
{
    if (t1 > t2) { float tmp = t1; t1 = t2; t2 = tmp; }


    if (Diffuse < t1)
        OUT = Shadow;
    else if (Diffuse < t2)
        OUT = Mid;
    else
        OUT = Highlight;

    // Soft mix near t1: Shadow and Mid
    if (w1 > 0.0)
    {
        float a1 = smoothstep(t1 - 0.5 * w1, t1 + 0.5 * w1, Diffuse);
        float3 sm12 = lerp(Shadow, Mid, a1);
        if (Diffuse > (t1 - w1) && Diffuse < (t1 + w1)) OUT = sm12;
    }

    // Soft mix near t2: Mid and Highlight
    if (w2 > 0.0)
    {
        float a2 = smoothstep(t2 - 0.5 * w2, t2 + 0.5 * w2, Diffuse);
        float3 sm23 = lerp(Mid, Highlight, a2);
        if (Diffuse > (t2 - w2) && Diffuse < (t2 + w2)) OUT = sm23;
    }
}



void GaussianBlurRamp_Tiled_float(
    float2 uv,
    UnityTexture2D rampTex,
    float2 tiling,
    float radius, float resolution,
    float hstep, float vstep,
    out float3 blurredRGB)
{
    float2 uvT = uv * tiling;


    const float w4 = 0.0162162162;
    const float w3 = 0.0540540541;
    const float w2 = 0.1216216216;
    const float w1 = 0.1945945946;
    const float w0 = 0.2270270270;

    float blur = radius / max(resolution, 1e-5) / 4.0;
    float2 d = float2(hstep, vstep) * blur;

#define SAMPLE(uvv) SAMPLE_TEXTURE2D(rampTex.tex, rampTex.samplerstate, (uvv))

    float3 s_m4 = SAMPLE(uvT + (-4.0) * d).rgb;
    float3 s_m3 = SAMPLE(uvT + (-3.0) * d).rgb;
    float3 s_m2 = SAMPLE(uvT + (-2.0) * d).rgb;
    float3 s_m1 = SAMPLE(uvT + (-1.0) * d).rgb;
    float3 s_0 = SAMPLE(uvT).rgb;
    float3 s_p1 = SAMPLE(uvT + (1.0) * d).rgb;
    float3 s_p2 = SAMPLE(uvT + (2.0) * d).rgb;
    float3 s_p3 = SAMPLE(uvT + (3.0) * d).rgb;
    float3 s_p4 = SAMPLE(uvT + (4.0) * d).rgb;

    blurredRGB =
        s_m4 * w4 + s_m3 * w3 + s_m2 * w2 + s_m1 * w1
        + s_0 * w0
        + s_p1 * w1 + s_p2 * w2 + s_p3 * w3 + s_p4 * w4;
}





inline float hash21(float2 p) {
    p = frac(p * float2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return frac(p.x * p.y);
}




void InkFromShadowFactor_float(
    float3 WorldPos,
    float  ShadowFactor,    
    float  NoiseAmp,        
    float  NoiseFreqA,     
    float  NoiseFreqB,     
    float3 InColor,       
    float3 OutColor,        
    float  InMin, float InMax,
    float  OutMin, float OutMax,
    float  Hardness,       
    out float  SStyled,    
    out float3 ShadowCol)   
{
  
    float s = saturate(pow(ShadowFactor, max(1e-3, Hardness)));


    float tIn = smoothstep(InMin, InMax, s);  
    float tOut = smoothstep(OutMin, OutMax, s);  

    float bandMask = tIn * (1.0 - tOut);          


    float fw = fwidth(s);
    float c1 = 0.5 * (InMin + InMax);
    float c2 = 0.5 * (OutMin + OutMax);
    float m1 = 1.0 - smoothstep(0, (InMax - InMin) + fw, abs(s - c1));
    float m2 = 1.0 - smoothstep(0, (OutMax - OutMin) + fw, abs(s - c2));
    bandMask = max(bandMask, max(m1, m2));       


    float nA = hash21(WorldPos.xz * NoiseFreqA);
    float nB = hash21(WorldPos.xz * NoiseFreqB);
    float n = (nA + nB) * 0.5 * 2.0 - 1.0;           
    s = saturate(s + NoiseAmp * n * bandMask);


    tIn = smoothstep(InMin, InMax, s);
    tOut = smoothstep(OutMin, OutMax, s);

    float3 col = lerp(InColor, OutColor, tIn);    
    col = lerp(col, 1.0.xxx, tOut);               
    ShadowCol = col;
    SStyled = s;
}



inline float TriPlanarR(UnityTexture2D t, float3 nWS, float3 pWS)
{
    float3 w = abs(nWS); w = w / (w.x + w.y + w.z + 1e-6);
    float rZ = SAMPLE_TEXTURE2D_LOD(t.tex, t.samplerstate, pWS.xy, 0).r;
    float rY = SAMPLE_TEXTURE2D_LOD(t.tex, t.samplerstate, pWS.xz, 0).r;
    float rX = SAMPLE_TEXTURE2D_LOD(t.tex, t.samplerstate, pWS.yz, 0).r;
    return rX * w.x + rY * w.y + rZ * w.z;
}


void InkFromShadowFactorMap_float(
    float3 WorldPos,             
    float3 NormalWS,             
    float  ShadowFactor,          
    UnityTexture2D rampTex,       
    float  ScaleA,               
    float  ScaleB,                
    float  NoiseAmp,             
    float3 InColor,               
    float3 OutColor,              
    float  InMin, float InMax,    
    float  OutMin, float OutMax,  
    float  Hardness,              
    out float  SStyled,           
    out float3 ShadowCol)        
{


    float s = saturate(pow(ShadowFactor, max(1e-3, Hardness)));


    float tIn = smoothstep(InMin, InMax, s);
    float tOut = smoothstep(OutMin, OutMax, s);
    float band = tIn * (1.0 - tOut);

    float nA = TriPlanarR(rampTex, NormalWS, WorldPos * ScaleA);
    float nB = TriPlanarR(rampTex, NormalWS, WorldPos * ScaleB);
    float n = (nA + nB) * 0.5 * 2.0 - 1.0;

    s = saturate(s + NoiseAmp * n * band);
    SStyled = s;

    tIn = smoothstep(InMin, InMax, s);
    tOut = smoothstep(OutMin, OutMax, s);

    float3 col = lerp(InColor, OutColor, tIn);
    col = lerp(col, 1.0.xxx, tOut);
    ShadowCol = col;

}

void InkShadowOffset_float(
    float3 WorldPos,          
    float3 NormalWS,         
    UnityTexture2D noiseTex,  
    float ScaleA, float ScaleB,  
    float Strength,              
    out float3 WorldPosOffset,   
    out float  NoiseVal)        
{
   
    float3 pivotWS = mul(UNITY_MATRIX_M, float4(0, 0, 0, 1)).xyz;

    float3 pA = (WorldPos - pivotWS) / 100.0 * ScaleA;
    float3 pB = (WorldPos - pivotWS) / 100.0 * ScaleB;

    float a = TriPlanarR(noiseTex, NormalWS, pA) * 0.5;
    float b = TriPlanarR(noiseTex, NormalWS, pB) * 0.5;
    float n = (a + b) * 2.0 - 1.0;        

    float3 offset = float3(n, 0, n) * Strength; 
    WorldPosOffset = WorldPos + offset;
    NoiseVal = n;
}


void InkShadowColor_float(
    float  s,
    float3 InColor, float3 OutColor,   
    float  InMin, float InMax,           
    float  OutMin, float OutMax,         
    out float3 ShadowColor)
{
    s = saturate(s);
    float tIn = smoothstep(InMin, InMax, s);
    float tOut = smoothstep(OutMin, OutMax, s);

    float3 col = lerp(InColor, OutColor, tIn);  
    ShadowColor = lerp(col, 1.0.xxx, tOut);     
}
