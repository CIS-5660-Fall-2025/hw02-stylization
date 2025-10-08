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
    float2 Thresholds, float3 RampedDiffuseValues, float DiffuseOffset,
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
        
        half NdotL = saturate(dot(WorldNormal, light.direction) + DiffuseOffset);
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

void ChooseColor_float(float3 Highlight, float3 Midtone, float3 Shadow, float Diffuse, float LoThreshold, float HiThreshold, float Smoothness, out float3 OUT)
{
    Smoothness += 0.0001;
    
    float shadowMult = smoothstep(LoThreshold+Smoothness*.5, LoThreshold-Smoothness*.5, Diffuse);
    float midtoneMult = smoothstep(LoThreshold-Smoothness*.5, LoThreshold+Smoothness*.5, Diffuse) * smoothstep(HiThreshold+Smoothness*.5, HiThreshold-Smoothness*.5, Diffuse);
    float highlightMult = smoothstep(HiThreshold-Smoothness*.5, HiThreshold+Smoothness*.5, Diffuse);

    OUT =
        shadowMult * Shadow +
        midtoneMult * Midtone +
        highlightMult * Highlight;
}

void ChooseSpecularColor_float(float Specular, float3 Midtone, float3 Highlight, float LoThreshold, float HiThreshold, out float3 COL) {
    float3 midtone = Midtone * step(LoThreshold, Specular) * step(Specular, HiThreshold);
    float3 highlight = Highlight * (1.-step(Specular,HiThreshold));

    COL = midtone + highlight;
}

void SampleBoxField_float(float2 UV, float BoxSize, float FieldValue, out float Opacity) {
    UV += 100.;
    float2 p = UV;

    p = fmod(p, BoxSize) - BoxSize*.5;
    p = abs(p);
    float exists = step(max(p.x,p.y), BoxSize*.5*FieldValue);

    Opacity = exists;
}