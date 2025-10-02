float3 RGBtoHSV(float3 c)
{
    float r = c.r;
    float g = c.g;
    float b = c.b;

    float maxc = max(r, max(g, b));
    float minc = min(r, min(g, b));
    float delta = maxc - minc;

    float h = 0.0;
    float s = 0.0;
    float v = maxc;

    if (delta > 1e-5) 
    {
        s = delta / maxc;

        if (maxc == r)
            h = (g - b) / delta;
        else if (maxc == g)
            h = 2.0 + (b - r) / delta;
        else 
            h = 4.0 + (r - g) / delta;

        h = frac(h / 6.0); 
        if (h < 0.0)
            h += 1.0;
    }

    return float3(h, s, v);
}

float3 HSVtoRGB(float3 hsv)
{
    float h = hsv.x; // 0-1
    float s = saturate(hsv.y);
    float v = saturate(hsv.z);

    if (s <= 0.0)
    {
        return float3(v, v, v);
    }

    h = frac(h) * 6.0; // [0,6)
    int i = (int) floor(h);
    float f = h - i;

    float p = v * (1.0 - s);
    float q = v * (1.0 - s * f);
    float t = v * (1.0 - s * (1.0 - f));

    i = clamp(i, 0, 5);

    if (i == 0)
        return float3(v, t, p);
    else if (i == 1)
        return float3(q, v, p);
    else if (i == 2)
        return float3(p, v, t);
    else if (i == 3)
        return float3(p, q, v);
    else if (i == 4)
        return float3(t, p, v);
    else
        return float3(v, p, q);
}


float hash1(int n)
{
    n = (n << 13) ^ n;
    return 1.0 - ((n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 2147483648.0;
}

float valueNoise1D(float x)
{
    int i = (int) floor(x); 
    float f = frac(x); 
    f = f * f * (3.0 - 2.0 * f);

    
    float n0 = hash1(i);
    float n1 = hash1(i + 1);

    return lerp(n0, n1, f);
}

void ChooseVariedColorsSmooth_float(float3 Highlight, float3 Shadow, float Diffuse, float3 Midtone, float Threshold, float Threshold2, float Smoothness, out float3 OUT)
{

    float t0 = smoothstep(Threshold - Smoothness, Threshold + Smoothness, Diffuse);
    float3 shadowToMidtone = lerp(Shadow, Midtone, t0);

    float t1 = smoothstep(Threshold2 - Smoothness, Threshold2 + Smoothness, Diffuse);

    float3 base = lerp(shadowToMidtone, Highlight, t1);
    
    float3 baseHSV = RGBtoHSV(base); // 0-1
    
    // offset hue a bit based on noise
    float range = 0.1;
    float hueOffset = valueNoise1D(Diffuse * 100.) * range - range * 0.5;
    
    baseHSV.r += hueOffset;
    
    OUT = HSVtoRGB(baseHSV);
}