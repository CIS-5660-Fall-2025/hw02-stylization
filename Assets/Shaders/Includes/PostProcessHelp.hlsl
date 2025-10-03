SAMPLER(sampler_point_clamp);

void ChromaticAberration_float(float2 uv, float offset, float2 screenDim, out float3 OUT)
{
    float2 texelSize = 1.0 / screenDim;
    float2 dir = float2(1, 1);

    // Compute offsets for RGB channels
    float2 offsetR = uv + dir * offset * texelSize;
    float2 offsetG = uv + dir * offset * texelSize * 0.5;
    float2 offsetB = uv - dir * offset * texelSize * 0.5;

    // Sample texture at offsets
    float r = SAMPLE_TEXTURE2D(_MainTex, sampler_point_clamp, offsetR).r;
    float g = SAMPLE_TEXTURE2D(_MainTex, sampler_point_clamp, offsetG).g;
    float b = SAMPLE_TEXTURE2D(_MainTex, sampler_point_clamp, offsetB).b;

    OUT = float3(r, g, b);
}
