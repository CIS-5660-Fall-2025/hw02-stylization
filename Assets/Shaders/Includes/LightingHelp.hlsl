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
    
    if (Diffuse <= 0.15)
    {
        Color = float3(0, 0, 0);
        Diffuse = 0;
    }
    
#endif
}

void ChooseColor_float(float3 Highlight, float3 Midtone, float3 Shadow, float Diffuse, float2 Thresholds, out float3 OUT)
{
    if (Diffuse < Thresholds.x)
    {
        OUT = Shadow;
    }
    else if (Diffuse < Thresholds.y)
    {
        OUT = Midtone;
    }
    else
    {
        OUT = Highlight;
    }
}

void ChooseTriColor_float(float3 Highlight, float3 Shadow, float Diffuse, float3 Midtone, float Threshold, float Threshold2, out float3 OUT)
{
    if (Diffuse < Threshold)
    {
        OUT = Shadow;
    }
    else if (Diffuse < Threshold2)
    {
        OUT = Midtone;
    }
    else
    {
        OUT = Highlight;
    }
}

void ChooseTriColorSmooth_float(float3 Highlight, float3 Shadow, float Diffuse, float3 Midtone, float Threshold, float Threshold2, float Smoothness, out float3 OUT)
{

    float t0 = smoothstep(Threshold - Smoothness, Threshold + Smoothness, Diffuse);
    float3 shadowToMidtone = lerp(Shadow, Midtone, t0);

    float t1 = smoothstep(Threshold2 - Smoothness, Threshold2 + Smoothness, Diffuse);

    OUT = lerp(shadowToMidtone, Highlight, t1);
}



void addStripes_float(float shadowAtten, float3 Shadow, float3 Currtone, float stripes, out float3 OUT)
{
    
    float3 shadowMask = 0.;
    if (shadowAtten < 0.1)
    {
        shadowMask = (1. - stripes);
    }
    
    // float3 shadowMask = (1. - stripes) * (1. - shadowAtten);
    
    OUT = Currtone * (1. - shadowMask) + Shadow * shadowMask;
    
    /*
    if (shadowAtten < 0.3)
    {
        OUT = Shadow * (stripes) + Currtone * (1. - stripes);
    }
    else
    {
        OUT = Currtone;
    }
*/

}

void addShadow_float(float shadowStrength, float shadowAtten, float3 Shadow, float3 Currtone, float stripes, out float3 OUT)
{
    
    float3 shadowMask = 0.;
    if (shadowAtten < shadowStrength)
    {
        shadowMask = (1. - stripes);
    }
    
    // float3 shadowMask = (1. - stripes) * (1. - shadowAtten);
    
    OUT = Currtone * (1. - shadowMask) + Shadow * shadowMask;
    
    /*
    if (shadowAtten < 0.3)
    {
        OUT = Shadow * (stripes) + Currtone * (1. - stripes);
    }
    else
    {
        OUT = Currtone;
    }
*/

}
