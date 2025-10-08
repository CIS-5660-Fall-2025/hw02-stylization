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
    float2(-1.0, 1.0), float2(0.0, 1.0), float2(1.0, 1.0),
    float2(-1.0, 0.), float2(0.0, 0.), float2(1.0, 0.),
    float2(-1.0, -1.0), float2(0.0, -1.0), float2(1.0, -1.0)
};

static float sobelHorizontalMat[9] = {
    1., 0., -1.,
    2., 0., -2.,
    1., 0., -1.
};

static float sobelVerticalMat[9] = {
    1., 2., 1.,
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

void NormalRobert_float(float2 UV, float Thickness, out float Out) {
    float2 V = Thickness * float2(1., -1.);

    float3 normal00 = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, UV+V.yy).xyz;
    float3 normal01 = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, UV+V.yx).xyz;
    float3 normal10 = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, UV+V.xy).xyz;
    float3 normal11 = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, UV+V.xx).xyz;

    float3 diff1 = normal11-normal00;
    float3 diff2 = normal10-normal01;

    Out = sqrt(dot(diff1, diff1) + dot(diff2, diff2));
}