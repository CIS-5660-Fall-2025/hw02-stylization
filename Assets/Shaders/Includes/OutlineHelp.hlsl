SAMPLER(sampler_point_clamp);

// Functions for the shader
void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
} 



void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalBuffer, sampler_point_clamp, uv).rgb;
}

// Private functions for internal use
float GetDepthHelper(float2 uv)
{
    return SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}

// following implementation from https://www.youtube.com/watch?v=RMt6DcaMxcE

static float2 sobelSamplePoints[9] = {
    float2(-1, 1), float2(0, 1), float2(1, 1),
    float2(-1, 0), float2(0, 0), float2(1, 1),
    float2(-1, -1), float2(0, -1), float2(1, -1),
};

// x component weights
static float sobelXMatrix[9] = {
    1, 0, -1,
    2, 0, -2,
    1, 0, -1
};

// y component weights
static float sobelYMatrix[9] = {
    1, 2, 1,
    0, 0, 0,
    -1, -2, -1
};

void GetSobelDepth_float(float2 uv, float Thickness, out float Out)
{
    float2 sobel = 0;
    [unroll] for (int i = 0; i < 9; i++) {
        float depth = GetDepthHelper(uv + sobelSamplePoints[i] * Thickness);
        sobel += depth * float2(sobelXMatrix[i], sobelYMatrix[i]);
    }
    Out = length(sobel);
}

void WhiteIfLessThan_float(float3 color, float thresh, out float4 outcolor) {
    if (color[0]+color[1] + color[2] > thresh) {
        outcolor = float4(1,1,1, 0);
    } else {
        outcolor = float4(color[0], color[1], color[2], 1);
    }

}