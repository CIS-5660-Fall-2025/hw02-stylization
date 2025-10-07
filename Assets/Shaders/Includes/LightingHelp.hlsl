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


#if 1
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
        
        
        if (shadowAtten * NdotL == 0)
        {
            rampedDiffuse = 0;

        }
        
        if (light.distanceAttenuation <= 0)
        {
            rampedDiffuse = 0.0;
        }

        Color += max(rampedDiffuse, 0) * light.color.rgb;
        Diffuse += rampedDiffuse;
    }
#endif
}
#else
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
#endif

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

void ChooseColorBig_float(float3 Shade0, float3 Shade1, float3 Shade2, float3 Shade3, float3 Shade4, float3 Shade5, float Diffuse, float4 Thresholds, float Thresholds2, out float3 OUT)
{
    if (Diffuse < Thresholds.x)
    {
        float t = Diffuse/Thresholds.x;
        OUT = Shade5 * (1-t) + Shade4 * t;
    }
    else if (Diffuse < Thresholds.y)
    {
        float t = (Diffuse-Thresholds.x)/(Thresholds.y-Thresholds.x);
        OUT = Shade4 * (1-t) + Shade3 * t;
    }
    else if (Diffuse < Thresholds.z)
    {
        float t = (Diffuse-Thresholds.y)/(Thresholds.z-Thresholds.y);
        OUT = Shade3 * (1-t) + Shade2 * t;
    }
    else if (Diffuse < Thresholds.w)
    {
        float t = (Diffuse-Thresholds.z)/(Thresholds.w-Thresholds.z);
        OUT = Shade2 * (1-t) + Shade1 * t;
    }
    else if (Diffuse < Thresholds2) {
        float t = (Diffuse-Thresholds.w)/(Thresholds2-Thresholds.w);
        OUT = Shade1 * (1-t) + Shade0 * t;
    }
    else
    {
        OUT = Shade0;
    }
}





// TODO kinda getting what I want but not 100% satisfied. unsure if I wanna include distance
// TODO perhaps want to make this from a gradient into more of a textured look
// TODO maybe take in the view direction in here and change calculation to just be scaling each color based on that light's direction relative it the point dotted with view angle? (i.e. make light straight behind object have more rim light effect)
void ComputeRimLighting_float(float3 WorldPosition, float3 WorldNormal,
    float2 Thresholds, float3 RampedDiffuseValues, bool useWorldLight, bool useDistanceAttenuation, bool useRamping,
    out float3 Color, out float Diffuse)
{
    Color = float3(0, 0, 0);
    Diffuse = 0;

#ifndef SHADERGRAPH_PREVIEW

    int pixelLightCount = GetAdditionalLightsCount();
    
    #if SHADOWS_SCREEN
        float4 clipPos = TransformWorldToClip(WorldPosition);
        float4 shadowCoord = ComputeScreenPos(clipPos);
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(WorldPosition);
    #endif

    if (useWorldLight) {
        Light light = GetMainLight(shadowCoord);
        half shadowAtten = light.shadowAttenuation;
        
        half NdotL = saturate(1.f - abs(dot(WorldNormal, light.direction)));
        half distanceAtten = light.distanceAttenuation;

        // half thisDiffuse = NdotL * distanceAtten;
        half thisDiffuse = (useDistanceAttenuation ? distanceAtten : 1.f) * shadowAtten * NdotL;
        
        half rampedDiffuse = 0;
        if (useRamping) {
            
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
            
        } else {
            rampedDiffuse = thisDiffuse;
        }
        // rampedDiffuse = thisDiffuse;
        
        // if (shadowAtten * NdotL == 0)
        // {
        //     rampedDiffuse = 0;

        // }
        
        // if (light.distanceAttenuation <= 0)
        // {
        //     rampedDiffuse = 0.0;
        // }

        Color += max(rampedDiffuse, 0) * light.color.rgb;
        Diffuse += rampedDiffuse;
    }

    for (int i = 0; i < pixelLightCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPosition);
        float4 tmp = unity_LightIndices[i / 4];
        uint light_i = tmp[i % 4];

        half shadowAtten = light.shadowAttenuation * AdditionalLightRealtimeShadow(light_i, WorldPosition, light.direction);
        
        half NdotL = saturate(1.f - abs(dot(WorldNormal, light.direction)));
        half distanceAtten = light.distanceAttenuation;

        half thisDiffuse = NdotL * shadowAtten * (useDistanceAttenuation ? distanceAtten : 1.f);
        // half thisDiffuse = distanceAtten * shadowAtten * NdotL;
        
        half rampedDiffuse = 0;

        if (useRamping) {
            
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
            
        } else {
            rampedDiffuse = thisDiffuse;
        }
        // if (shadowAtten * NdotL == 0)
        // {
        //     rampedDiffuse = 0;

        // }
        
        // if (light.distanceAttenuation <= 0)
        // {
        //     rampedDiffuse = 0.0;
        // }

        Color += max(rampedDiffuse, 0) * light.color.rgb;
        Diffuse += rampedDiffuse;
    }
#endif
}


// using from hw1 since the built-in seems to only be 2d?
float3 random3D( float3 p ) {
    return frac(sin(float3(dot(p, float3(127.1f, 311.7f, 191.999f)),
                                         dot(p, float3(269.5f, 183.3f, 773.2f)),
                                         dot(p, float3(103.37f, 217.83f, 523.7f)))) * 43758.5453f);
}

void perlin3D_float( float3 p, out float val ) {
    float3 pFloor = floor(p);
    float sum = 0.f;
    for (int dz = 0; dz <= 1; ++dz) {
        for (int dy = 0; dy <= 1; ++dy) {
            for (int dx = 0; dx <= 1; ++dx) {
                float3 distVec = p - (pFloor + float3(dx,dy,dz));
                float3 gradientVec = random3D(pFloor + float3(dx,dy,dz)) * 2.f - 1.f;
                float influence = dot(gradientVec, distVec);
                // sum += influence;
                float3 absDistVec = abs(distVec);
                float3 scaleVec = 1.f - 6.f * pow(absDistVec, float3(5.f,5.f,5.f)) + 15.f * pow(absDistVec, float3(4.f,4.f,4.f)) - 10.f * pow(absDistVec, float3(3.f,3.f,3.f));

                sum += scaleVec.x * scaleVec.y * scaleVec.z * influence;
            }
        }
    }
    val = sum;
    // return sum;
}




