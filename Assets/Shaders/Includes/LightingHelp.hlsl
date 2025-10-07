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
{ // Thresholds.x < Thresholds.y is assumed
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

        // half thisDiffuse = distanceAtten * shadowAtten * NdotL;
            half thisDiffuse = NdotL;

        
        half rampedDiffuse = thisDiffuse;

        
        if (thisDiffuse < Thresholds.x)
        { // lerp x and 0
            float t = pow(thisDiffuse / Thresholds.x, 2);
            rampedDiffuse = RampedDiffuseValues.x * t;
        }
        else if (thisDiffuse < Thresholds.y)
        { // lerp x and y
            float t = pow((thisDiffuse - Thresholds.x) / (Thresholds.y - Thresholds.x), 2);
            rampedDiffuse = RampedDiffuseValues.x * (1 - t) + RampedDiffuseValues.y * t;
        }
        else
        { // z with y
            float t = pow((thisDiffuse - Thresholds.y) / (1.0001 - Thresholds.y), 2);

            rampedDiffuse = RampedDiffuseValues.z * (1 - t) + RampedDiffuseValues.y * t;
        }

        
        // if (light.distanceAttenuation <= 0)
        // {
        //     rampedDiffuse = 0.0;
        // }

        Color += max(rampedDiffuse, 0) * light.color.rgb;
        Diffuse += rampedDiffuse;

        // if (Diffuse <= 0.9)
        // {
        //     // lerp
        //     half t = Diffuse / 0.3;
        //     Color = float3(0, 0, 0) * (t + 1) + t * max(rampedDiffuse, 0) * light.color.rgb;
        //     Diffuse = 0;
        // }

    }
    
    
    
#endif
}

void ComputeRimLighting_float(float3 WorldPos, float Diffuse, float3 WorldNormal, float3 InColor, float Threshold, out float3 OutColor) {
  
    OutColor = float3(1,1,1);
    
    if (Diffuse > Threshold)
    {
        OutColor = InColor;
    }

}

void ChooseColor_float(float3 Highlight, float3 Midtone, float3 Shadow, float Diffuse, float2 Thresholds, out float3 OUT)
{
    float minimum = min(Thresholds.x, Thresholds.y);
    float maximum = max(Thresholds.x, Thresholds.y);

       
    if (Diffuse > maximum)
    {
        OUT = Highlight;
    } else {
        float t = clamp(Diffuse , 0, maximum) / maximum;
        float gain_t = t;
        // if (t < minimum) {
        //     gain_t = pow(t , log(1.0 - minimum / maximum) / log(0.5));
        // }
        // else {
        //     gain_t = 1 - pow(t , log(1.0 - minimum / maximum) / log(0.5));

        // }
        float gain_1_t = pow(1.0 - gain_t, minimum * 10);

        OUT = Midtone * gain_t + gain_1_t * Shadow; // lerp the shadow and midtones
    }
}

void TwoColor_float(float3 Highlight, float Diffuse, float Threshold, out float3 OUT)
{
    if (Diffuse < Threshold)
    {
        OUT = float3(0.0,0.0,0.0);
    }
    else
    {
        OUT = Highlight;
    }
    
}