Shader "ReV3nus/OneLastStylize"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100
        ZWrite Off Cull Off
        Pass
        {
            Name "Calc Grads"
            

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            #pragma vertex Vert
            #pragma fragment frag

            SAMPLER(sampler_BlitTexture);
            TEXTURE2D_X(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);
            TEXTURE2D_X(_CameraNormalsTexture);
            SAMPLER(sampler_CameraNormalsTexture);
            

            float4 _TexelSize;

            float Sample01Depth(float2 uv, float2 offset)
            {
                return Linear01Depth(SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, uv + offset * _TexelSize.xy).r, _ZBufferParams);
            }

            float depthGradient(float2 uv)
            {
                float dr = Sample01Depth(uv, float2(1,0));
                float dl = Sample01Depth(uv, float2(-1,0));
                float du = Sample01Depth(uv, float2(0,1));
                float dd = Sample01Depth(uv, float2(0,-1));
                return length(float2(dr-dl,du-dd) / _TexelSize.xy);
            }
            float normalGradient(float2 uv)
            {
                float3 grad = (SAMPLE_TEXTURE2D_X(_CameraNormalsTexture, sampler_CameraNormalsTexture, uv + float2(1, 0) * _TexelSize.xy).xyz -
                              SAMPLE_TEXTURE2D_X(_CameraNormalsTexture, sampler_CameraNormalsTexture, uv + float2(-1, 0) * _TexelSize.xy).xyz) / _TexelSize.x +
                              (SAMPLE_TEXTURE2D_X(_CameraNormalsTexture, sampler_CameraNormalsTexture, uv + float2(0, 1) * _TexelSize.xy).xyz -
                              SAMPLE_TEXTURE2D_X(_CameraNormalsTexture, sampler_CameraNormalsTexture, uv + float2(0, -1) * _TexelSize.xy).xyz) / _TexelSize.y;
                return length(grad);
            }

            float GetShadow(float2 uv)
            {
                float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, uv).r;
                float3 normal = SAMPLE_TEXTURE2D_X(_CameraNormalsTexture, sampler_CameraNormalsTexture, uv).xyz;

                float4 clipPos = float4(uv * 2.0 - 1.0, depth, 1.0);
                float4 viewPos = mul(unity_CameraInvProjection, clipPos);
                viewPos /= viewPos.w;
                float3 worldPos = mul(unity_CameraToWorld, viewPos).xyz;
                
                float4 shadowCoord = TransformWorldToShadowCoord(worldPos);
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(worldPos));

                return dot(mainLight.direction, normal);
            }


            half4 frag (Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);



                // Sample the color from the input texture
                 // float4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, input.texcoord);
                 // return color;
                // float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, input.texcoord).r;
                // float linear01Depth = Linear01Depth(depth, _ZBufferParams);
                // float3 normal = SAMPLE_TEXTURE2D_X(_CameraNormalsTexture, sampler_CameraNormalsTexture, input.texcoord).xyz;
                // float contour_depth = saturate(linear01Depth * 100);

                return float4(depthGradient(input.texcoord), normalGradient(input.texcoord) * 0.001, GetShadow(input.texcoord), 1);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ColorBlitPass"
            

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            #pragma vertex Vert
            #pragma fragment frag

            SAMPLER(sampler_BlitTexture);
            TEXTURE2D_X(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);
            TEXTURE2D_X(_CameraNormalsTexture);
            SAMPLER(sampler_CameraNormalsTexture);
            TEXTURE2D(_ScreenSpaceOcclusionTexture);

            SAMPLER(sampler_ScreenSpaceOcclusionTexture);

            TEXTURE2D(_SketchTex);
            SAMPLER(sampler_SketchTex);
            TEXTURE2D(_DenseSketchTex);
            SAMPLER(sampler_DenseSketchTex);
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);
            TEXTURE2D(_StylizeColorLUT);
            SAMPLER(sampler_StylizeColorLUT);

            float4 _TexelSize;

            float2 noiseGrad(float2 uv)
            {
                int eps = 5;
                float nu = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv + float2(eps, 0) * _TexelSize.xy).r;
                float nr = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv + float2(0, eps) * _TexelSize.xy).r;
                float no = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv).r;

                float2 flow = float2(nr-no, no-nu);  //(∂N/∂y, -∂N/∂x)
                return flow;
            }

            float GetOutline(float2 uv)
            {
                float4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, uv);
                float ret = 1 - step(color.r, 0.06);
                ret += 1 - step(color.g, 0.6);
                return ret;
            }
            float3 GetWorldPos(float2 uv)
            {
                float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, uv).r;

                float4 clipPos = float4(uv * 2.0 - 1.0, depth, 1.0);
                float4 viewPos = mul(unity_CameraInvProjection, clipPos);
                viewPos /= viewPos.w;
                float3 worldPos = mul(unity_CameraToWorld, viewPos).xyz;

                return worldPos;
            }

            float GetAmbientOcclusion(float2 uv, float3 worldPos)
            {
                float occlusion = SAMPLE_TEXTURE2D(_ScreenSpaceOcclusionTexture, sampler_ScreenSpaceOcclusionTexture, uv).r;

                float2 texUV = worldPos.xz * 3.0 + floor(_Time.y * 1.7) * float2(0.7, 1.1);
                float sketch = saturate(SAMPLE_TEXTURE2D(_DenseSketchTex, sampler_DenseSketchTex, texUV).r);

                occlusion = (1 - occlusion);

                float res = occlusion * sketch * 10.0;
                return res;
            }

            float GetNLShadow(float2 uv, float3 worldPos)
            {
                float4 tex = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, uv);
                if(tex.r <= 0.001 && tex.g <= 0.001)
                {
                    return 0;
                }

                float nl = tex.b;
                nl = 1.0 - smoothstep(-0.1, 0.1, nl);
                
                float2 texUV = worldPos.xz * float2(3.4, 5.7) + floor(_Time * 2.3) * float2(1.3, 1.1);
                float sketch = saturate(SAMPLE_TEXTURE2D(_SketchTex, sampler_SketchTex, texUV).r * 2.2);

                return sketch * nl;
                return nl;
            }
            float3 GammaToLinear(float3 sRGB)
            {
                return sRGB <= 0.04045 ? sRGB / 12.92 : pow((sRGB + 0.055) / 1.055, 2.4);
            }
            float easeFunc(float x)
            {
                return x < 0.5 ? 8 * x * x * x * x : 1 - pow(-2 * x + 2, 4) / 2;
            }
            float3 GetStylizeColor(float2 uv)
            {
                float u = (2.0 - uv.x - uv.y) * 0.5;
                u = u * 0.9;
                float v = (uv.y - uv.x) * 0.5 + 0.5;

                return SAMPLE_TEXTURE2D(_StylizeColorLUT, sampler_StylizeColorLUT, float2(u, v));
            }


            half4 frag (Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float3 worldPos = GetWorldPos(input.texcoord);

                //float4 tex = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, input.texcoord);

                float2 uv = input.texcoord;

                float2 flow1 = noiseGrad((uv + floor(_Time.y * 0.7) * float2(0.1145, 0.14)) * 0.05);
                float2 flow2 = noiseGrad((uv - floor(_Time.y * 1.9) * float2(0.919, 0.81)) * 0.2);

                float res = 0;
                res += GetOutline(uv + flow1 * 0.002);
                res += GetOutline(uv + flow2 * 0.005);
                res += GetAmbientOcclusion(uv, worldPos);
                res += GetNLShadow(uv, worldPos);

                res = clamp(0, 2, res);

                float3 stylizeColor = GetStylizeColor(input.texcoord);
                float3 resColor = res * stylizeColor + (1.0 - saturate(res));

                return float4(resColor,1);
            }
            ENDHLSL
        }
    }
}
