SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

void GetCrossSampleUVs_float(float4 UV, float2 TexelSize,
    float OffsetMultiplier, out float2 UVOriginal,
    out float2 UVTopRight, out float2 UVBottomLeft,
    out float2 UVTopLeft, out float2 UVBottomRight)
{
    UVOriginal = UV;
    UVTopRight = UV.xy + TexelSize * OffsetMultiplier;
    UVBottomLeft = UV.xy - TexelSize * OffsetMultiplier;
    UVTopLeft = UV.xy + float2(-TexelSize.x, TexelSize.y) * OffsetMultiplier;
    UVBottomRight = UV.xy + float2(TexelSize.x, -TexelSize.y) * OffsetMultiplier;
}

static float2 sobelSamplePoints[9] = {
    float2(-1, 1), float2(0, 1), float2(1, 1),
    float2(-1, 0), float2(0, 0), float2(1, 0),
    float2(-1, -1), float2(0, -1), float2(1, -1)
};

static float sobelXMatrix[9] = {
    1, 0, -1,
    2, 0, -2,
    1, 0, -1
};

static float sobelYMatrix[9] = {
    1, 2, 1,
    0, 0, 0,
    -1, -2, -1
};

void DepthSobel_float(float2 UV, float Thickness, out float Out)
{
    float2 sobel = 0;

    [unroll] for(int i = 0; i < 9; i++)
    {
        float depth;
        GetDepth_float(UV + sobelSamplePoints[i] * Thickness, depth);
        sobel += depth * float2(sobelXMatrix[i], sobelYMatrix[i]);
    }

    Out = length(sobel);
}

void ColorSobel_float(float2 UV, float Thickness, out float Out)
{
    float2 sobelR = 0;
    float2 sobelG = 0;
    float2 sobelB = 0;

    [unroll] for(int i = 0; i<9; i++){
        float3 rgb = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV + sobelSamplePoints[i] * Thickness);
        float2 kernel = float2(sobelXMatrix[i], sobelYMatrix[i]);
        sobelR += rgb.r * kernel;
        sobelG += rgb.g * kernel;
        sobelB += rgb.b * kernel;
    }

    Out = max(length(sobelR), max(length(sobelG), length(sobelB)));
}

void NormalSobel_float(float2 UV, float Thickness, out float Out)
{
    float2 sobelX = 0;
    float2 sobelY = 0;
    float2 sobelZ = 0;

    [unroll] for(int i = 0; i<9; i++){
        float3 xyz = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, UV + sobelSamplePoints[i] * Thickness).rgb;
        float2 kernel = float2(sobelXMatrix[i], sobelYMatrix[i]);
        sobelX += xyz.r * kernel;
        sobelY += xyz.g * kernel;
        sobelZ += xyz.b * kernel;
    }

    Out = max(length(sobelX), max(length(sobelY), length(sobelZ)));
}