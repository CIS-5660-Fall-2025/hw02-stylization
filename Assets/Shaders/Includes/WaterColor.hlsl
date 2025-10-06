//SamplerState sampler_MainTex;
SAMPLER(sampler_linear_repeat);
// SAMPLER(sampler_PaperTex);

// based on this shadertoy: https://www.shadertoy.com/view/ltyGRV#
    // Helper functions
    float4 getCol(float2 pos, float2 mainTexSize, UnityTexture2D MainTex)
    {
        float2 uv = pos / mainTexSize;
        float4 c1 = SAMPLE_TEXTURE2D(MainTex, sampler_linear_repeat, uv);
        float4 c2 = float4(0.4, 0.4, 0.4, 1.0); // gray on greenscreen
        float d = clamp(dot(c1.xyz, float3(-0.5, 1.0, -0.5)), 0.0, 1.0);
        return lerp(c1, c2, 1.8 * d);
    }

    float4 getCol2(float2 pos, float2 mainTexSize, UnityTexture2D MainTex)
    {
        float2 uv = pos / mainTexSize;
        float4 c1 = SAMPLE_TEXTURE2D(MainTex, sampler_linear_repeat, uv);
        float4 c2 = float4(1.5, 1.5, 1.5, 1.0); // bright white on greenscreen
        float d = clamp(dot(c1.xyz, float3(-0.5, 1.0, -0.5)), 0.0, 1.0);
        return lerp(c1, c2, 1.8 * d);
    }

    float2 getGrad(float2 pos, float delta, float2 mainTexSize, UnityTexture2D MainTex)
    {
        float2 d = float2(delta, 0);
        return float2(
            dot((getCol(pos + d.xy, mainTexSize, MainTex) - getCol(pos - d.xy, mainTexSize, MainTex)).xyz, float3(0.333, 0.333, 0.333)),
            dot((getCol(pos + d.yx, mainTexSize, MainTex) - getCol(pos - d.yx, mainTexSize, MainTex)).xyz, float3(0.333, 0.333, 0.333))
        ) / delta;
    }

    float2 getGrad2(float2 pos, float delta, float2 mainTexSize, UnityTexture2D MainTex)
    {
        float2 d = float2(delta, 0);
        return float2(
            dot((getCol2(pos + d.xy, mainTexSize, MainTex) - getCol2(pos - d.xy, mainTexSize, MainTex)).xyz, float3(0.333, 0.333, 0.333)),
            dot((getCol2(pos + d.yx, mainTexSize, MainTex) - getCol2(pos - d.yx, mainTexSize, MainTex)).xyz, float3(0.333, 0.333, 0.333))
        ) / delta;
    }

    float4 getRand(float2 pos, float NoiseTex_Size, UnityTexture2D NoiseTex) 
    {
        float2 uv = pos / NoiseTex_Size;
        return SAMPLE_TEXTURE2D(NoiseTex, sampler_linear_repeat, uv);
    }

    float htPattern(float2 pos, float NoiseTex_Size, UnityTexture2D NoiseTex)
    {
        float r = getRand(pos * 0.4 / 0.7 * 1.0, NoiseTex_Size, NoiseTex).x;
        return clamp((pow(r + 0.3, 2.0) - 0.45), 0.0, 1.0);
    }

    float getVal(float2 pos, float level, float2 mainTexSize, UnityTexture2D MainTex)
    {
        float3 col = getCol(pos, mainTexSize, MainTex).xyz;
        return length(col) + 0.0001 * length((pos - 0.5 * mainTexSize).xy);
    }
    
    float4 getBWDist(float2 pos, float2 mainTexSize, UnityTexture2D MainTex, float NoiseTex_Size, UnityTexture2D NoiseTex)
    {
        return smoothstep(0.9, 1.1, getVal(pos, 0.0, mainTexSize, MainTex) * 0.9 + htPattern(pos * 0.7, NoiseTex_Size, NoiseTex));
    }

    float2 N(float2 a) { return a.yx * float2(1, -1); }

void WatercolorEffect_float(
    float2 UV, 
    UnityTexture2D MainTex,
    UnityTexture2D NoiseTex, 
    UnityTexture2D PaperTex,
    float NoiseTex_Size,
    float SampNum,
    out float4 Out)
{
    float2 screenSize = _ScreenParams.xy;
    float2 mainTexSize = float2(1920, 1080);
    
// Initialize variables
    float2 fragCoord = UV * screenSize;
float2 pos = ((fragCoord - screenSize * 0.5) / screenSize.y * mainTexSize.y) + mainTexSize * 0.5;
    float2 pos2 = pos;
    float2 pos3 = pos;
    float2 pos4 = pos;
    float2 pos0 = pos;
    float3 col = float3(0, 0, 0);
    float3 col2 = float3(0, 0, 0);
    float cnt = 0.0;
    float cnt2 = 0.0;

    // Main loop
    for (int i = 0; i < 1 * SampNum; i++)
    {   
        // gradient for outlines (gray on green screen)
        float2 gr = getGrad(pos, 2.0, mainTexSize, MainTex) + 0.0001 * (getRand(pos, NoiseTex_Size, NoiseTex).xy - 0.5);
        float2 gr2 = getGrad(pos2, 2.0, mainTexSize, MainTex) + 0.0001 * (getRand(pos2, NoiseTex_Size, NoiseTex).xy - 0.5);
        
        // gradient for wash effect (white on green screen)
        float2 gr3 = getGrad2(pos3, 2.0, mainTexSize, MainTex) + 0.0001 * (getRand(pos3, NoiseTex_Size, NoiseTex).xy - 0.5);
        float2 gr4 = getGrad2(pos4, 2.0, mainTexSize, MainTex) + 0.0001 * (getRand(pos4, NoiseTex_Size, NoiseTex).xy - 0.5);
        
        float grl = clamp(10.0 * length(gr), 0.0, 1.0);
        float gr2l = clamp(10.0 * length(gr2), 0.0, 1.0);

        // outlines: stroke perpendicular to gradient
        pos += 0.8 * normalize(N(gr));
        pos2 -= 0.8 * normalize(N(gr2));
        float fact = 1.0 - float(i) / float(SampNum);
        col += fact * lerp(float3(1.2, 1.2, 1.2), getBWDist(pos, mainTexSize, MainTex, NoiseTex_Size, NoiseTex).xyz * 2.0, grl);
        col += fact * lerp(float3(1.2, 1.2, 1.2), getBWDist(pos2, mainTexSize, MainTex, NoiseTex_Size, NoiseTex).xyz * 2.0, gr2l);
        
        // colors + wash effect on gradients
        pos3 += 0.25 * normalize(gr3) + 0.5 * (getRand(pos0 * 0.07, NoiseTex_Size, NoiseTex).xy - 0.5);
        pos4 -= 0.5 * normalize(gr4) + 0.5 * (getRand(pos0 * 0.07, NoiseTex_Size, NoiseTex).xy - 0.5);
        
        float f1 = 3.0 * fact;
        float f2 = 4.0 * (0.7 - fact); 
        col2 += f1 * (getCol2(pos3, mainTexSize, MainTex).xyz + 0.25 + 0.4 * getRand(pos3 * 1.0, NoiseTex_Size, NoiseTex).xyz);
        col2 += f2 * (getCol2(pos4, mainTexSize, MainTex).xyz + 0.25 + 0.4 * getRand(pos4 * 1.0, NoiseTex_Size, NoiseTex).xyz);
        
        cnt2 += f1 + f2;
        cnt += fact;
    }
    
    // Normalize
    col /= cnt * 2.5;
    col2 /= cnt2 * 1.65;
    
    // Outline + color
    col = clamp(clamp(col * 0.9 + 0.1, 0.0, 1.0) * col2, 0.0, 1.0);
    
    // Paper color and grain
    float2 paperUV = UV;
    col = col * float3(0.93, 0.93, 0.85)
        * lerp(SAMPLE_TEXTURE2D(PaperTex, sampler_linear_repeat, paperUV).xyz, float3(1.2, 1.2, 1.2), 0.7)
        + 0.15 * getRand(pos0 * 2.5, NoiseTex_Size, NoiseTex).x;
        
    // Vignetting
    float r = length(UV - 0.5);
    float vign = 1.0 - r * r * r * r;
    
    Out = float4(col * vign, 1.0);
}