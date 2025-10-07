SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

void GetCrossSampleUVs_float(float2 uv, float2 TexelSize, float OffsetMultiplier, 
    out float2 UVOriginal, out float2 UVTopRight, out float2 UVBottomLeft,
    out float2 UVTopLeft, out float2 UVBottomRight)
{
    UVOriginal = uv;
    UVTopRight = uv + float2(TexelSize.x, TexelSize.y) * OffsetMultiplier;
    UVBottomLeft = uv - float2(TexelSize.x, TexelSize.y) * OffsetMultiplier;
    UVTopLeft = uv + float2(-TexelSize.x, TexelSize.y) * OffsetMultiplier;
    UVBottomRight = uv + float2(TexelSize.x, -TexelSize.y) * OffsetMultiplier;
}