SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

//
static float2 sobelSamplePoints[9] = {
    float2(-1.0, -1.0), float2(0.0, -1.0), float2(1.0, -1.0),
    float2(-1.0, 0.), float2(0.0, 0.), float2(1.0, 0.),
    float2(-1.0, 1.0), float2(0.0, 1.0), float2(1.0, 1.0)
};

static float sobelHorizontalMat[9] = {
    1., 0., -1.,
    2., 0., -2.,
    1., 0., -1.
};

static float sobelVerticalMat[9] = {
    1., 2., -1.,
    0., 0., 0.,
    -1., -2., -1.
};

void DepthSobel_float(float2 UV, float Thickness, out float Out) {
    float sobelX, sobelY;
    sobelX = sobelY = 0.;

    [unroll] for(int i=0; i<9; i++) {
        float depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV + Thickness * sobelSamplePoints[i]);
        sobelX += sobelHorizontalMat[i]*depth;
        sobelY += sobelVerticalMat[i]*depth;
    }

    Out = sqrt(sobelX*sobelX+sobelY*sobelY);
}