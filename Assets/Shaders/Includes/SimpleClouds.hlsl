#ifndef SIMPLECLOUDS_INCLUDED
#define SIMPLECLOUDS_INCLUDED

static float hash(float2 p)
{
    p = frac(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return frac(p.x * p.y);
}

static float noise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    float a = hash(i + float2(0.0, 0.0));
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
}

static float fbm(float2 p)
{
    float v = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    [unroll]
    for (int i = 0; i < 4; ++i)
    {
        v += amp * noise(p * freq);
        freq *= 2.0;
        amp *= 0.5;
    }
    return v;
}

void SimpleClouds_float(float2 UV, float Time, float Scale, float Density, float Speed, float4 Color, float mode, out float4 OUT)
{
    if (mode != 0.0f) {
        float t = Time * Speed;

        float2 p = UV * Scale + float2(0, t);

        float c = lerp(fbm(p), fbm(p * 2.0 + 37.17), 0.5);

        c = saturate((c - 0.4) * Density);

        float alpha = c * Color.a;
        float3 rgb = Color.rgb;

        OUT = float4(rgb, alpha);
    }
    else {
        float t = Time * Speed;

        float grain = noise(UV * 300.0 + float2(0.0, t));
        grain = smoothstep(0.8, 0.85, grain) * 0.25;
        grain = saturate(grain);

        float alpha = grain * Color.a;
        float3 rgb = Color.rgb;

        OUT = float4(rgb, alpha);
    }
}

#endif
