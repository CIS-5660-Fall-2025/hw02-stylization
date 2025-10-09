SAMPLER(sampler_point_clamp);

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

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}

void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

void DepthSobel_float(float2 uv, float Thickness, out float Out) {
    float2 sobel = float2(0, 0);
    for (int i = 0; i < 9; i++) {
        float depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv + sobelSamplePoints[i] * Thickness);
        sobel += depth * float2(sobelXMatrix[i], sobelYMatrix[i]);

    }
    Out = length(sobel);
}

void NormalSobel_float(float2 uv, float Thickness, out float Out) {
    float3 normal_sample[9];
    for (int i = 0; i < 9; i++) {
        normal_sample[i] = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv + sobelSamplePoints[i] * Thickness).rgb;
    }
    float3 sx = float3(0, 0, 0);
    float3 sy = float3(0, 0, 0);
    for (int i = 0; i < 9; i++) {
        sx += normal_sample[i] * sobelXMatrix[i];
        sy += normal_sample[i] * sobelYMatrix[i];
    }
    float3 sobel = sqrt(sx * sx + sy * sy);
    Out = length(sobel);
}
