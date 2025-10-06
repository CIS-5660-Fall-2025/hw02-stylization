void Pixelize_float(float3 UV, float buckets, out float3 color)
{
    UV.x *= buckets;
    UV.y *= buckets;
    UV.z *= buckets;
    UV.x = floor(UV.x);
    UV.y = floor(UV.y);
    UV.z = floor(UV.z);
    UV.x /= buckets;
    UV.y /= buckets;
    UV.z /= buckets;
    color = UV;
}