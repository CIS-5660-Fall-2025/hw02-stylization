// Unity uses light direction as the direction towards the light
// Shadow atten = 0 means completely in shadow

void GetMainLight_float(float3 WorldPos, float3 WorldNormal, float3 WorldCameraPosition,
    float2 DiffuseThresholds, float3 RampedDiffuseValues,
    float SpecularThreshold, float2 RampedSpecularValues,
    out float3 Color, out float ShadowAtten, out float Diffuse, out float Specular)
{
#ifdef SHADERGRAPH_PREVIEW
    Color = 1;
    ShadowAtten = 1;
    Diffuse = 1;
    Specular = 1;
#else
#if SHADOWS_SCREEN
        float4 clipPos = TransformWorldToClip(WorldPos);
        float4 shadowCoord = ComputeScreenPos(clipPos);
#else
    float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
#endif


    Light mainLight = GetMainLight(shadowCoord);
    half NdotL = saturate(dot(WorldNormal, mainLight.direction));
    Diffuse = mainLight.distanceAttenuation * mainLight.shadowAttenuation * NdotL;

    if(Diffuse < DiffuseThresholds.x){
        Diffuse = RampedDiffuseValues.x;
    }
    else if(Diffuse < DiffuseThresholds.y){
        Diffuse = RampedDiffuseValues.y;
    }
    else{
        Diffuse = RampedDiffuseValues.z;
    }

    float3 reflectedLight = reflect(-mainLight.direction, WorldNormal);
    float3 toEye = normalize(WorldCameraPosition - WorldPos);
    Specular = mainLight.distanceAttenuation * mainLight.shadowAttenuation * pow(max(dot(toEye, reflectedLight), 0), 32);

    if(Specular < SpecularThreshold){
        Specular = RampedSpecularValues.x;
    }
    else{
        Specular = RampedSpecularValues.y;
    }

    Color = (Diffuse + Specular) * mainLight.color;
    ShadowAtten = mainLight.shadowAttenuation;
#endif
}

void ComputeAdditionalLighting_float(float3 WorldPosition, float3 WorldNormal, float3 WorldCameraPosition,
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

void ChooseColor_float(float3 Highlight, float3 Midtone, float3 Shadow, float Diffuse, float2 Thresholds, out float3 OUT)
{
    OUT = float3(0, 0, 0);
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
