float3 RandomFloat3_float(float3 input)
{
    return frac(sin(dot(input, float3(12.9898, 78.233, 45.164))) * 43758.5453);
}

float3 ToCell(float3 )

void GetNearestVoronoiCellPosition_float(float3 Position, float VoronoiCellScale, out float3 NearestCellPosition)
{
    float3 cell = floor(Position / VoronoiCellScale);

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