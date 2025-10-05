Shader "ReV3nus/KuwaharaFilter"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100
        ZWrite Off Cull Off
        Pass
        {
            Name "Anisotropic Kuwahara Pass"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            float _KernelSize;
            int _Sectors;
            int2 _SamplesPerSector;
            float _Anisotropicity;
            float4 _TexelSize;
            
            SAMPLER(sampler_BlitTexture);
            TEXTURE2D_X(_CameraNormalsTexture);
            SAMPLER(sampler_CameraNormalsTexture);

            float luminance(float3 c)
            {
                return dot(c, float3(0.2126, 0.7152, 0.0722));
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                float3 normal = SAMPLE_TEXTURE2D_X(_CameraNormalsTexture, sampler_CameraNormalsTexture, input.texcoord);
                if(length(normal) <= 0.01)
                {
                    normal = float3(0, 0, -1);    
                }

                float3 ref = abs(normal.z) < 0.999 ? float3(0,0,1) : float3(0,1,0);
                float3 tangent   = normalize(cross(ref, normal));
                float3 bitangent = normalize(cross(normal, tangent));
                float2 screen_tangent   = mul(UNITY_MATRIX_VP, float4(tangent, 0.0));
                float2 screen_bitangent = mul(UNITY_MATRIX_VP, float4(bitangent, 0.0));
                screen_tangent = screen_tangent * _Anisotropicity + float2(1, 0) * (1 - _Anisotropicity);
                screen_bitangent = screen_bitangent * _Anisotropicity + float2(0, 1) * (1 - _Anisotropicity);
                //return float4(normal.xyz, 1);

                float3 sector_means[16]; // Max 16 sectors
                float sector_variances[16];

                float sector_angle_step = TWO_PI / (float)_Sectors;

                for (int i = 0; i < _Sectors; i++)
                {
                    float3 sum = (float3)0;
                    float3 sum_sq = (float3)0;
                    int count = 0;

                    float current_angle_start = (float)i * sector_angle_step;

                    float current_angle = current_angle_start;
                    float angle_step = sector_angle_step / (_SamplesPerSector.x * _SamplesPerSector.y);

                    for (int j = 0; j < _SamplesPerSector.x; j++)
                    {
                        for(int k = 0; k < _SamplesPerSector.y; k++)
                        {
                            float r = (float)(k + 1) / (float)(_SamplesPerSector.y); 
                            //float angle = current_angle_start + r() * sector_angle_step;
                            float angle = current_angle;
                            current_angle += angle_step;
                        
                            float2 local_offset = float2(cos(angle), sin(angle)) * r * _KernelSize;
                        
                            float2 deformed_offset = screen_tangent * local_offset.x + screen_bitangent * local_offset.y;

                            float2 sample_uv = input.texcoord + deformed_offset * _TexelSize.xy;
                        
                            float3 c = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, sample_uv).rgb;
                            sum += c;
                            sum_sq += c * c;
                            count++;
                        }
                    }

                    float3 mean = sum / count;
                    float3 variance_vec = abs((sum_sq / count) - (mean * mean));
                    float variance = luminance(variance_vec);

                    sector_means[i] = mean;
                    sector_variances[i] = variance;
                }


                int min_sector_index = 0;
                float min_variance = 1.0;
                
                for (int i = 0; i < _Sectors; i++)
                {
                    if (sector_variances[i] < min_variance)
                    {
                        min_variance = sector_variances[i];
                        min_sector_index = i;
                    }
                }
                
                return float4(sector_means[min_sector_index], 1.0);
            }
            ENDHLSL
        }
    }
}
