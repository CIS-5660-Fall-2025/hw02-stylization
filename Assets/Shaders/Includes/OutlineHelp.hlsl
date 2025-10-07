

static const float2 SOBEL_OFFS[9] = {
    float2(-1,  1), float2(0,  1), float2(1,  1),
    float2(-1,  0), float2(0,  0), float2(1,  0),
    float2(-1, -1), float2(0, -1), float2(1, -1)
};

static const float SOBEL_X[9] = { 1, 0,-1,  2, 0,-2,  1, 0,-1 };
static const float SOBEL_Y[9] = { 1, 2, 1,  0, 0, 0, -1,-2,-1 };

inline float L01(float zRaw) { return Linear01Depth(zRaw, _ZBufferParams); }

void DepthSobel_float(float2 UV, float Thickness, out float Out)
{
    float2 texel = Thickness / _ScreenParams.xy;

    float gx = 0.0, gy = 0.0;

    [unroll] for (int i = 0; i < 9; i++)
    {
        float2 uvSample = UV + SOBEL_OFFS[i] * texel;
        float d = L01(SHADERGRAPH_SAMPLE_SCENE_DEPTH(uvSample));
        gx += d * SOBEL_X[i];
        gy += d * SOBEL_Y[i];
    }

    Out = saturate(sqrt(gx * gx + gy * gy));   
}
