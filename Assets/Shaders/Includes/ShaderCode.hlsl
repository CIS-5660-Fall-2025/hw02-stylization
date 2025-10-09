
void Bucket_float(float Input, float Threshold, float3 Color_Low, float3 Color_High, out float3 OUT)
{

    if (Input < Threshold)
    {
        OUT = Color_Low;
    }
    else
    {
        OUT = Color_High;
    }
}
