#ifndef INK_SHADOW_INCLUDED
#define INK_SHADOW_INCLUDED
float4 TriPlanarSample(UnityTexture2D tex, float3 normalWS, float3 positionWS, float3 pivotWS, float scale)
{
    float3 an = abs(normalWS) + 1e-5;
    float invSum = 1.0 / (an.x + an.y + an.z);
    float3 w = an * invSum;
    float3 p = (positionWS - pivotWS) * scale;

    float4 cx = SAMPLE_TEXTURE2D_LOD(tex, tex.samplerstate, p.yz, 0.0) * w.x;
    float4 cy = SAMPLE_TEXTURE2D_LOD(tex, tex.samplerstate, p.xz, 0.0) * w.y;
    float4 cz = SAMPLE_TEXTURE2D_LOD(tex, tex.samplerstate, p.xy, 0.0) * w.z;
    return cx + cy + cz;
}


void InkShadowColorAndFactor_float(
    float3 positionWS,
    float3 normalWS,
    float3 pivotWS,
    UnityTexture2D noiseTex,
    float noiseScaleA, float noiseScaleB, float noiseStrength,
    float useTriPlanar,
    float shadowFactorIn,
    float shadowInMin, float shadowInMax,
    float shadowOutMin, float shadowOutMax,
    float3 inColor, float3 outColor,
    out float3 shadowColor,
    out float   shadowFactor
)
{
    float nA, nB;
    if (useTriPlanar > 0.5)
    {
        nA = TriPlanarSample(noiseTex, normalWS, positionWS, pivotWS, noiseScaleA).r;
        nB = TriPlanarSample(noiseTex, normalWS, positionWS, pivotWS, noiseScaleB).r;
    }
    else
    {
        nA = SAMPLE_TEXTURE2D_LOD(noiseTex, noiseTex.samplerstate, positionWS.xz * noiseScaleA, 0.0).r;
        nB = SAMPLE_TEXTURE2D_LOD(noiseTex, noiseTex.samplerstate, positionWS.xz * noiseScaleB, 0.0).r;
    }

    float n = ((nA + nB) * 0.5) * 2.0 - 1.0;


    float jitter = n * noiseStrength * 0.15;
    shadowFactor = saturate(shadowFactorIn + jitter);

    float sIn = smoothstep(shadowInMin, shadowInMax, shadowFactor);
    float sOut = smoothstep(shadowOutMin, shadowOutMax, shadowFactor);

    float3 c = lerp(inColor, outColor, sIn);
    c = lerp(c, 1.0.xxx, sOut);
    shadowColor = c;
}

#endif
