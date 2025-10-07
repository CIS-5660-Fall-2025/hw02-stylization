#ifndef sampler_point_clamp
SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb * 2.0 - float3(1.0, 1.0, 1.0);
}

static float2 sobelSamplePoints[9] = {
    float2(-1, 1), float2(0, 1), float2(1, 1),
    float2(-1, 0), float2(0, 0), float2(1, 0),
    float2(-1, -1), float2(0, -1), float2(1, -1),
};

static float sobelXMatrix[9] = {
    1.0, 0.0, -1.0,
    2.0, 0.0, -2.0,
    1.0, 0.0, -1.0,
};

static float sobelYMatrix[9] = {
    1.0, 2.0, 1.0,
    0.0, 0.0, 0.0,
    -1.0, -2.0, -1.0,
};

float2 PxToUV(float2 px){
    return float2(px.x / max(_ScreenParams.x, 1.0), px.y / max(_ScreenParams.y, 1.0));
};

void DepthSobel_float(float2 UV, float Thickness, out float OUT) {
    float2 sobel = 0.0;

    [unroll] for (int i = 0; i < 9; i++) {
        float depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV + sobelSamplePoints[i] * Thickness);
        sobel += depth * float2(sobelXMatrix[i], sobelYMatrix[i]);
    }
    OUT = length(sobel);
};

float2 TexelSize()
{
    return float2(1.0 / max(_ScreenParams.x, 1.0),
                  1.0 / max(_ScreenParams.y, 1.0));
}

float hash21(float2 p) {
    p = frac(p * float2(123.34, 456.21));
    p += dot(p, p + 78.233);
    return frac(p.x * p.y);
}

float vnoise(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    float n00 = hash21(i + float2(0,0));
    float n10 = hash21(i + float2(1,0));
    float n01 = hash21(i + float2(0,1));
    float n11 = hash21(i + float2(1,1));

    float nx0 = lerp(n00, n10, f.x);
    float nx1 = lerp(n01, n11, f.x);
    return lerp(nx0, nx1, f.y); // 0..1
}

void NormalSobel_float(float2 UV, float Thickness, out float OUT)
{
    float2 gx = 0.0;
    float2 gy = 0.0;

    float3 n;
    [unroll] for (int i = 0; i < 9; i++)
    {
        GetNormal_float(UV + sobelSamplePoints[i] * Thickness, n);
        float2 k = float2(sobelXMatrix[i], sobelYMatrix[i]);
        gx += n.xy * k;
        gy += n.yz * k;
    }

    float mag = max(length(gx), length(gy));
    OUT = saturate(mag);
}

float DepthOutlineWobble(float2 UV, float thicknessPx,
                         float wobbleAmpPx, float wobbleFreq, float wobbleSpeed)
{
    float2 texel = TexelSize();

    float t = _Time.y * wobbleSpeed;
    float jx = vnoise(UV * wobbleFreq + float2( 1.7, 9.2) + t);
    float jy = vnoise(UV.yx * wobbleFreq + float2(-3.1, 5.4) - t);

    float2 jitter = (float2(jx, jy) - 0.5) * 2.0 * wobbleAmpPx * texel;

    float2 duv = texel * thicknessPx;

    float edge;
    DepthSobel_float(UV + jitter, duv.x, edge);
    return saturate(edge);
}

void OutlineSketchyComposite_float(
    float2 UV,
    float DepthThicknessPx,
    float NormalThicknessPx,
    float WobbleAmpPx,
    float WobbleFreq,
    float WobbleSpeed,
    float DepthThreshold,
    float NormalThreshold,
    float UseSoft,
    float DepthWeight,
    float NormalWeight,
    out float OutMask,
    out float DepthMask,
    out float NormalMask)
{
    float dEdge = DepthOutlineWobble(UV, DepthThicknessPx, WobbleAmpPx, WobbleFreq, WobbleSpeed);

    float2 texel = TexelSize();
    float nEdgeRaw;
    NormalSobel_float(UV, (texel.x * NormalThicknessPx), nEdgeRaw);

    if (UseSoft >= 0.5)
    {
        DepthMask  = smoothstep(DepthThreshold,  DepthThreshold  + 0.08, dEdge);
        NormalMask = smoothstep(NormalThreshold, NormalThreshold + 0.08, nEdgeRaw);
    }
    else
    {
        DepthMask  = step(DepthThreshold,  dEdge);
        NormalMask = step(NormalThreshold, nEdgeRaw);
    }

    float combined = max(DepthMask * DepthWeight, NormalMask * NormalWeight);

    float grain = hash21(UV * _ScreenParams.xy * 0.6 + _Time.yy * 30.0);
    combined *= lerp(0.9, 1.1, grain);

    OutMask = saturate(combined);
}


// ===================== WATERCOLOR (fullscreen) ==============================
// We declare our OWN samplers with unique names and guard them.
// This avoids both "undeclared" and "redefinition" errors on Metal/DX/Vulkan.

TEXTURE2D(_BlitTexture);     // bound by your Fullscreen blit (source frame)
TEXTURE2D(_PaperTex);        // optional; expose a Texture2D named _PaperTex in the graph

#ifndef SAMPLER_BLIT_TEX_CLAMP_DEFINED
    SAMPLER(sampler_BlitTexClamp);          // unique sampler for _BlitTexture
    #define SAMPLER_BLIT_TEX_CLAMP_DEFINED
#endif

#ifndef SAMPLER_PAPER_TEX_CLAMP_DEFINED
    SAMPLER(sampler_PaperTexClamp);         // unique sampler for _PaperTex
    #define SAMPLER_PAPER_TEX_CLAMP_DEFINED
#endif

float2 WC_Texel() {
    return float2(1.0 / max(_ScreenParams.x, 1.0),
                  1.0 / max(_ScreenParams.y, 1.0));
}

// Read from blit source using our sampler
float3 WC_ReadSrc(float2 uv) {
    return SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexClamp, uv).rgb;
}

float3 WC_Posterize(float3 c, float steps) {
    steps = max(1.0, steps);
    return floor(c * steps) / steps;
}

// luminance sobel on the frame
float WC_EdgeLuma(float2 uv, float thicknessUV) {
    float2 g = 0.0;
    [unroll] for (int i=0;i<9;i++) {
        float3 rgb = WC_ReadSrc(uv + sobelSamplePoints[i] * thicknessUV);
        float  y   = dot(rgb, float3(0.299,0.587,0.114));
        g += float2(sobelXMatrix[i], sobelYMatrix[i]) * y;
    }
    return saturate(length(g));
}

// small cheap bleed blur
float3 WC_Bleed(float2 uv, float radiusPx) {
    float2 texel = WC_Texel();
    float2 r = texel * radiusPx;

    float3 c  = WC_ReadSrc(uv) * 0.30;
    c += WC_ReadSrc(uv + float2( r.x, 0)) * 0.12;
    c += WC_ReadSrc(uv + float2(-r.x, 0)) * 0.12;
    c += WC_ReadSrc(uv + float2( 0, r.y)) * 0.12;
    c += WC_ReadSrc(uv + float2( 0,-r.y)) * 0.12;

    float2 d = r * 0.7071;
    c += WC_ReadSrc(uv +  float2( d.x,  d.y)) * 0.08;
    c += WC_ReadSrc(uv +  float2(-d.x,  d.y)) * 0.08;
    c += WC_ReadSrc(uv +  float2( d.x, -d.y)) * 0.08;
    c += WC_ReadSrc(uv +  float2(-d.x, -d.y)) * 0.08;
    return c;
}

// paper multiplier (if you expose _PaperTex)
float WC_Paper(float2 uv, float tiling, float contrast) {
    float g = SAMPLE_TEXTURE2D(_PaperTex, sampler_PaperTexClamp, uv * tiling).r;
    return saturate(1.0 + (g - 0.5) * contrast);
}

float WC_Vignette(float2 uv) {
    float2 p = uv * 2.0 - 1.0;
    p.x *= _ScreenParams.x / max(_ScreenParams.y, 1.0);
    float r = length(p);
    return smoothstep(0.6, 1.0, r);
}

// ENTRY used by Shader Graph (Fullscreen)
void WatercolorPost_float(
    float2 UV,
    float PosterizeSteps,
    float BleedRadiusPx,
    float BleedStrength,
    float EdgeDarkStrength,
    float VignetteStrength,
    float PaperTiling,
    float PaperContrast,
    out float3 OutColor)
{
    float3 baseC = WC_ReadSrc(UV);
    float3 bleed = WC_Bleed(UV, BleedRadiusPx);
    float3 soft  = lerp(baseC, bleed, saturate(BleedStrength));
    float3 poster= WC_Posterize(soft, PosterizeSteps);

    float  edge  = WC_EdgeLuma(UV, WC_Texel().x * 1.0);
    float3 inked = poster * (1.0 - EdgeDarkStrength * edge);

    float3 col   = inked * WC_Paper(UV, PaperTiling, PaperContrast);
    col *= lerp(1.0, 1.0 - VignetteStrength, WC_Vignette(UV));
    OutColor = saturate(col);
}

#endif