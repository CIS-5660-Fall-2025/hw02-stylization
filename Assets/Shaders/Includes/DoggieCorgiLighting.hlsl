void GetMainLight2_float(float3 WorldPos, out float3 Color, out float3 Direction, out float DistanceAtten, out float ShadowAtten)
{
#ifdef SHADERGRAPH_PREVIEW
    Direction = normalize(float3(0.5, 0.5, 0));
    Color = float3(0.5, 0.5, 0);
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


// void ComputeAdditionalLighting2_float(float3 WorldPosition, float3 WorldNormal,
//     float2 Thresholds, float3 RampedDiffuseValues,
//     out float3 Color, out float Diffuse)
// {
//     Color = float3(0, 0, 0);
//     Diffuse = 0;

// #ifndef SHADERGRAPH_PREVIEW

//     int pixelLightCount = GetAdditionalLightsCount();
    
//     for (int i = 0; i < pixelLightCount; ++i)
//     {
//         Light light = GetAdditionalLight(i, WorldPosition);
//         float4 tmp = unity_LightIndices[i / 4];
//         uint light_i = tmp[i % 4];

//         half shadowAtten = light.shadowAttenuation * AdditionalLightRealtimeShadow(light_i, WorldPosition, light.direction);
        
//         half NdotL = saturate(dot(WorldNormal, light.direction));
//         half distanceAtten = light.distanceAttenuation;

//         half thisDiffuse = distanceAtten * shadowAtten * NdotL;
        
//         half rampedDiffuse = 0;
        
//         if (thisDiffuse < Thresholds.x)
//         {
//             rampedDiffuse = RampedDiffuseValues.x;
//         }
//         else if (thisDiffuse < Thresholds.y)
//         {
//             rampedDiffuse = RampedDiffuseValues.y;
//         }
//         else
//         {
//             rampedDiffuse = RampedDiffuseValues.z;
//         }

        
//         if (light.distanceAttenuation <= 0)
//         {
//             rampedDiffuse = 0.0;
//         }

//         Color += max(rampedDiffuse, 0) * light.color.rgb;
//         Diffuse += rampedDiffuse;
//     }
    
//     if (Diffuse <= 0.3)
//     {
//         Color = float3(0, 0, 0);
//         Diffuse = 0;
//     }
    
// #endif
// }


void ChooseColor2_float(float3 Highlight, 
                    float3 Midtone, 
                    float3 Shadow,
                     float Diffuse,
                      float2 Thresholds,
                       out float3 OUT)
{
        float minimum = min(Thresholds.x, Thresholds.y);
        float maximum = max(Thresholds.x, Thresholds.y);

       
    if (Diffuse > max(Thresholds.x, Thresholds.y))
    {
        OUT = Highlight;
    } else {
        float t = Diffuse - minimum / (maximum - minimum); 
        OUT = Midtone + Midtone * t + (1 - t) * Shadow; // lerp the shadow and midtones

    }
}
