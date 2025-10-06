Shader "Custom/ToonShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
        _HighlightColor ("Highlight Color", Color) = (1, 1, 1, 1)
        _ShadowColor ("Shadow Color", Color) = (1, 1, 1, 1)
        _ShadowMap("Shadow Map", 2D) = "white"
    }
    SubShader
    {
        Name "UniversalForward"
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Name "Forward Lit"
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS  : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 objPos : TEXCOORD2;
                float4 shadowCoords : TEXCOORD3;
                float2 uv : TEXCOORD4;
            };

            
            TEXTURE2D(_ShadowMap);
            SAMPLER(sampler_ShadowMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _MainColor;
                half4 _HighlightColor;
                half4 _ShadowColor;
                float4 _ShadowMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                VertexPositionInputs positions = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs normals = GetVertexNormalInputs(IN.normalOS);

                OUT.positionCS = positions.positionCS;
                OUT.positionWS = positions.positionWS;
                OUT.normal = normals.normalWS;

                OUT.shadowCoords = GetShadowCoord(positions);

                OUT.uv = TRANSFORM_TEX(IN.uv, _ShadowMap);

                return OUT;
            }

            half4 GetShadowColor(half shadow, float2 uv)
            {
                half4 tex = SAMPLE_TEXTURE2D(_ShadowMap, sampler_ShadowMap, uv);
                half4 shadowColor = (0.4 + 0.6 * tex) * _ShadowColor;

                return shadow * _MainColor + (1-shadow) * shadowColor;
            }
            half4 GetSurfaceColor(float NdotL)
            {
                if(NdotL > 0.95)return _HighlightColor;
                return _MainColor;
            }

            half4 GetSpecularColor(float3 N, float3 H)
            {
                float3 N1  = normalize(float3(N.x, N.y * 1.0, N.z));
                float3 H1  = normalize(float3(H.x, (H.y + 0.4) * 1.0, H.z));
                if(dot(N1, H1) >= 0.995)return 1;

                float3 N2  = normalize(float3(N.x, N.y * 0.4, N.z));
                float3 H2  = normalize(float3(H.x, (H.y - 0.3) * 0.4, H.z));
                if(dot(N2, H2) >= 0.992)return 1;
                return 0;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light mainLight = GetMainLight(TransformWorldToShadowCoord(IN.positionWS));

                float3 N = normalize(IN.normal);
                float3 L = mainLight.direction;
                float3 V = normalize(_WorldSpaceCameraPos.xyz - IN.positionWS);
                float3 H = normalize(L + V);
                
                float NdotL = saturate(dot(N, L));

                if(NdotL <= 0) return GetShadowColor(0.0, IN.uv);
                
                half shadowAmount = MainLightRealtimeShadow(IN.shadowCoords);
                return shadowAmount < 0.5 ? GetShadowColor(shadowAmount, IN.uv) : GetSurfaceColor(NdotL) + GetSpecularColor(N, H);
            }
            
            ENDHLSL
        }

        Pass
        {
            Name "Forward Add"
            Tags { "LightMode" = "UniversalForwardOnly" }
            Blend One One
            ZWrite Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS

            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS  : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 objPos : TEXCOORD2;
                float4 shadowCoords : TEXCOORD3;
                float2 uv : TEXCOORD4;
            };

            
            TEXTURE2D(_ShadowMap);
            SAMPLER(sampler_ShadowMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _MainColor;
                half4 _HighlightColor;
                half4 _ShadowColor;
                float4 _ShadowMap_ST;
                float _Smoothness;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                VertexPositionInputs positions = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs normals = GetVertexNormalInputs(IN.normalOS);

                OUT.positionCS = positions.positionCS;
                OUT.positionWS = positions.positionWS;
                OUT.normal = normals.normalWS;

                OUT.shadowCoords = GetShadowCoord(positions);

                OUT.uv = TRANSFORM_TEX(IN.uv, _ShadowMap);

                return OUT;
            }


            half4 frag(Varyings IN) : SV_Target
            {
                int additionalLightsCount = GetAdditionalLightsCount();
                half3 finalColor = 0;

                for (int i = 0; i < additionalLightsCount; ++i)
                {
                    Light additionalLight = GetAdditionalLight(i, IN.positionWS, half4(1,1,1,1));
                    half NdotL = saturate(dot(IN.normal, additionalLight.direction));
                    half3 diffuse = additionalLight.color * additionalLight.shadowAttenuation * additionalLight.distanceAttenuation;
                    
                    float attenuation = additionalLight.shadowAttenuation * additionalLight.distanceAttenuation;

                    diffuse =additionalLight.color * (attenuation < 0.05 ? attenuation : attenuation > 0.5 ? 0.6 : 0.4);
                    

                    finalColor += diffuse;
                }

                return half4(finalColor, 1.0);
            }
            
            ENDHLSL
        }

        Pass
        {
            Name "Shadow Cast"
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
}
