SAMPLER(sampler_point_clamp);

static float sobelMatrixX[9] =
{
    1, 0, -1,
    2, 0, -2,
    1, 0, -1
};

static float sobelMatrixY[9] =
{
    1, 2, 1,
    0, 0, 0,
    -1, -2, -1
};

static float test[9] =
{
    0, 0, 0,
    0, 1, 0,
    0, 0, 0
};

void calculateDepthSobel_float(float2 uv, float thickness, out float OUT)
{
    float2 sum = float2(0., 0.);
    
    [unroll]
    for (int i = 0; i < 9; i++)
    {
        //float2 offset = float2(float(i % 3) - 1., float(i / 3) - 1.) / float2(1080, 1920);
        float2 offset = float2(float(i % 3) - 1., float(i / 3) - 1.) * thickness;
        float2 sampledTexture = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv + offset);
            
        float2 kernelValue = float2(sobelMatrixX[i], sobelMatrixY[i]);
        
        sum += sampledTexture * kernelValue;
    }
    
    OUT = length(sum);
}

void calculateNormalOutline_float(float2 uv, float thickness, Texture2D normalMap, out float OUT)
{
    // quadrants offset
    float uv1 = uv + float2(1., 1.) * thickness;
    float uv2 = uv + float2(-1., 1.) * thickness;
    float uv3 = uv + float2(- 1., -1.) * thickness;
    float uv4 = uv + float2(1., -1.) * thickness;
    
    float normal1 = SAMPLE_TEXTURE2D(normalMap, sampler_point_clamp, uv1).rgb;
    float normal2 = SAMPLE_TEXTURE2D(normalMap, sampler_point_clamp, uv2).rgb;
    float normal3 = SAMPLE_TEXTURE2D(normalMap, sampler_point_clamp, uv3).rgb;
    float normal4 = SAMPLE_TEXTURE2D(normalMap, sampler_point_clamp, uv4).rgb;
    
    float d1 = length(normal1 - normal3);
    float d2 = length(normal2 - normal4);
    
    OUT = sqrt(d1 * d1 + d2 * d2);

}

void offsetUVs_float(float2 uv, float thickness, out float2 uv1, out float2 uv2, out float2 uv3, out float2 uv4)
{
    uv1 = uv + float2(1., 1.) * thickness;
    uv2 = uv + float2(-1., 1.) * thickness;
    uv3 = uv + float2(-1., -1.) * thickness;
    uv4 = uv + float2(1., -1.) * thickness;
}

void normalOutline_float(float3 normal1, float3 normal2, float3 normal3, float3 normal4, out float OUT)
{
    float d1 = length(normal1 - normal3);
    float d2 = length(normal2 - normal4);
    
    OUT = sqrt(d1 * d1 + d2 * d2);
}
