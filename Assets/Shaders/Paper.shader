Shader "Hidden/FullScreen/PaperOverlay"
{
    Properties
    {
        _PaperTex("Paper Texture", 2D) = "white" {}
        _Strength("Blend Strength", Range(0,1)) = 0.8
        _Tiling("Tiling (XY)", Vector) = (1,1,0,0)
        _Offset("Offset (XY)", Vector) = (0,0,0,0)
        [KeywordEnum(Multiply,Overlay,SoftLight)] _BlendMode("Blend Mode", Float) = 0
    }

    SubShader
    {
        Tags{ "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Overlay" }
        ZWrite Off
        ZTest Always
        Cull Off

        Pass
        {
            Name "PaperOverlay"
            Tags{ "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma target 2.0
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma shader_feature_local _BLENDMODE_MULTIPLY _BLENDMODE_OVERLAY _BLENDMODE_SOFTLIGHT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BlitTexture);
            SAMPLER(sampler_BlitTexture);

            TEXTURE2D(_PaperTex);
            SAMPLER(sampler_PaperTex);

            CBUFFER_START(UnityPerMaterial)
            float4 _Tiling;
            float4 _Offset;
            float  _Strength;
            CBUFFER_END

            struct Varyings { float4 positionCS: SV_POSITION; float2 uv: TEXCOORD0; };

            
            Varyings Vert(uint id : SV_VertexID)
            {
                Varyings o;
                o.positionCS = GetFullScreenTriangleVertexPosition(id);
                o.uv         = GetFullScreenTriangleTexCoord(id);
                return o;
            }

            inline float3 Overlay(float3 baseC, float3 blendC)
            {
                return lerp(2.0*baseC*blendC,
                            1.0 - 2.0*(1.0-baseC)*(1.0-blendC),
                            step(0.5, baseC));
            }
            inline float3 SoftLight(float3 baseC, float3 blendC)
            {
                return (1.0 - 2.0*blendC)*baseC*baseC + 2.0*blendC*baseC;
            }

            float4 Frag(Varyings i) : SV_Target
            {
                float4 sceneCol = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, i.uv);

                float2 uvPaper = i.uv * _Tiling.xy + _Offset.xy;
                float3 paper   = SAMPLE_TEXTURE2D(_PaperTex, sampler_PaperTex, uvPaper).rgb;

                float3 blended = sceneCol.rgb * paper;          
                #if defined(_BLENDMODE_OVERLAY)
                    blended = Overlay(sceneCol.rgb, paper);
                #elif defined(_BLENDMODE_SOFTLIGHT)
                    blended = SoftLight(sceneCol.rgb, paper);
                #endif

                float3 outRGB = lerp(sceneCol.rgb, blended, saturate(_Strength));
                return float4(outRGB, sceneCol.a);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
