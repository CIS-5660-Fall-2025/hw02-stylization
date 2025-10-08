SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}

static float2 sobelPoints[9] =
{
    float2(-1, -1), float2(0, -1), float2(1, -1),
    float2(-1, 0), float2(0, 0), float2(1, 0),
    float2(-1, 1), float2(0, 1), float2(1, 1),
};
static float sobel[18] =
{
    1, 0, -1,
    2, 0, -2,
    1, 0, -1,
    
    1, 2, 1,
    0, 0, 0,
    -1, -2, -1,
};


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

void Sobel_float(float2 uv, float thickness, out float result)
{
    float2 resultVec = float2(0, 0);
    
    [unroll]
    for (int i = 0; i < 9; i++)
    {
        resultVec += SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv + sobelPoints[i] * thickness * float2(1080. / 1920., 1)) * float2(sobel[i], sobel[i + 9]);
    }

    result = length(resultVec);

}


void CrossSampleUv_float(float2 uv, float2 texelSize, float offsetMul, out float2 uvTr, out float2 uvTl, out float2 uvBr, out float2 uvBl)
{
    uvTr = uv + texelSize * float2(offsetMul, -offsetMul);
    uvTl = uv + texelSize * float2(-offsetMul, -offsetMul);
    uvBr = uv + texelSize * float2(offsetMul, offsetMul);
    uvBl = uv + texelSize * float2(-offsetMul, offsetMul);
}