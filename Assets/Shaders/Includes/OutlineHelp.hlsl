SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void NormalTextureSample_float(float2 UV, out float3 Out) {
    Out = mul(SHADERGRAPH_SAMPLE_SCENE_NORMAL(UV), (float3x3) UNITY_MATRIX_I_V);
    //Out = SHADERGRAPH_SAMPLE_SCENE_NORMAL(UV);
}