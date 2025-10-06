#ifndef  SOBELOUTLINES_INCLUDED
#define  SOBELOUTLINES_INCLUDED
SAMPLER(sampler_point_clamp);

static float2 sobelSamplePoints[9] = {
    float2(-1, 1), float2(0,1), float2(1,1),
    float2(-1, 0), float2(0,0), float2(1,1),
    float2(-1,-1), float2(0,0), float2(1,-1)
};

static float sobelXMatrix[9] = {
    1.0f, 0.0f, -1.0f,
    2.0f, 0.0f, -2.0f,
    1.0f, 0.0f, -1.0f
};

static float sobelYMatrix[9] = {
    1.0f,2.0f,1.0f,
    0.0f,0.0f,0.0f,
    -1.0f,-2.0f,-1.0f
};

void DepthSobel_float(float2 uv, float thickness, out float Out)
{
    float sobel = 0.0;

    [unroll] for (int i = 0; i < 9; i++)
    {
        float depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv + sobelSamplePoints[i] * thickness);
        sobel += depth * float2(sobelXMatrix[i], sobelYMatrix[i]);
    }

    Out = length(sobel);
}
#endif 