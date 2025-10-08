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

void ComputeAdditionalLighting_float(
    float3 WorldPosition, float3 WorldNormal,
    float2 Thresholds, float3 RampedDiffuseValues,
    float Shininess, float3 SpecColor,
    out float3 DiffuseColor, out float3 SpecularColor, out float Diffuse)
{
    DiffuseColor = 0;
    SpecularColor = 0;
    Diffuse = 0;

#ifndef SHADERGRAPH_PREVIEW

    int pixelLightCount = GetAdditionalLightsCount();
    float3 viewDir = normalize(_WorldSpaceCameraPos - WorldPosition);

    for (int i = 0; i < pixelLightCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPosition);
        float4 tmp = unity_LightIndices[i / 4];
        uint light_i = tmp[i % 4];

        half shadowAtten = light.shadowAttenuation * AdditionalLightRealtimeShadow(light_i, WorldPosition, light.direction);
        half distanceAtten = light.distanceAttenuation;

        half NdotL = saturate(dot(WorldNormal, light.direction));
        half thisDiffuse = distanceAtten * shadowAtten * NdotL;

        // ramped diffuse (stylized)
        half rampedDiffuse = 0;
        if (thisDiffuse < Thresholds.x) rampedDiffuse = RampedDiffuseValues.x;
        else if (thisDiffuse < Thresholds.y) rampedDiffuse = RampedDiffuseValues.y;
        else rampedDiffuse = RampedDiffuseValues.z;

        if (shadowAtten * NdotL == 0 || distanceAtten <= 0)
            rampedDiffuse = 0;

        DiffuseColor += max(rampedDiffuse, 0) * light.color.rgb;
        Diffuse += rampedDiffuse;

        float3 halfDir = normalize(light.direction + viewDir);
        float NdotH = saturate(dot(WorldNormal, halfDir));
        float spec = pow(NdotH, Shininess);

        SpecularColor += spec * SpecColor * light.color.rgb * shadowAtten * distanceAtten;
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
