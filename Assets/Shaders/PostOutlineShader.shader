Shader "PostOutlineShader"
{
    Properties
     {
         _MainTex("InputTex", 2D) = "white" {}
     	_Debug("Debug", Float) = 0.
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
     }

     SubShader
     {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType"="Opaque"
        }

        ZWrite Off
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Name "POST OUTLINE"
            HLSLPROGRAM
            #pragma enable_d3d11_debug_symbols

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl" // needed to sample scene depth
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl" // needed to sample scene normals
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl" // needed to sample scene color/luminance
            #include "Packages/jp.keijiro.noiseshader/Shader/ClassicNoise2D.hlsl" // needed to sample scene color/luminance
            #include "Packages/jp.keijiro.noiseshader/Shader/ClassicNoise3D.hlsl" // needed to sample scene color/luminance
            #include "Packages/jp.keijiro.noiseshader/Shader/SimplexNoise2D.hlsl"

            #pragma vertex Vert // vertex shader is provided by the Blit.hlsl include
            #pragma fragment frag

            float _Debug;
            float4 _OutlineColor;
            sampler2D   _MainTex;
            float4 frag(Varyings IN) : SV_Target
            {
                float2 uv = IN.texcoord.xy;
                float2 texel_size = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);
                float4 sample1;
                float sample1_offset = SimplexNoise(uv*5);
                float m[9] = {
				    1./16, 1./8., 1./16., 
				    1./8, 1./4., 1./8., 
				    1./16, 1./8., 1./16.
				};
                for(int y = -1; y <= 1;y++){
                    for(int x = -1;x<=1;x++){
                        sample1 += tex2D(_MainTex, sample1_offset*0.001 + uv+float2(x*texel_size.x*0.7, y*texel_size.y*0.7)) * m[y*3+x+4];
                    }
                }
                sample1 = sin((sample1*1.5 * PI) / 2) * (sample1_offset*0.6+0.4);
                
                float2 randomOffset = ClassicNoise(uv*8.+114514.)*0.004;
                float4 sample2 = tex2D(_MainTex, uv+randomOffset) ;
                float OUT = saturate(max(sample1, sample2).x*3);
                if (_Debug>1.0)
                {
	                return float4(OUT.xx, 0., 1.);
                }else
                {
					return float4(1.0 * _OutlineColor.xyz, OUT);
                }
                
                //return countbits(~(p.x & p.y) + 1) % 2 * float4(uv, 1, 1) * color;
            }
            ENDHLSL
        }
    }
}
