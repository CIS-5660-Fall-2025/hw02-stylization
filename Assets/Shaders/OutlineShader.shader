Shader "Edge Detection"
{
    Properties
    {
        _OutlineThickness ("Outline Thickness", Float) = 1
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _ScaleEdgeNormal ("ScaleEdge Normal", Float) = 1
        _ScaleEdgeDepth ("ScaleEdge Depth", Float) =  1
        _ScaleEdgeLuminance ("ScaleEdge Luminance", Float) = 1
        _OffsetEdgeNormal ("OffsetEdge Normal", Float) = 0
        _OffsetEdgeDepth ("OffsetEdge Depth", Float) =  0
        _OffsetEdgeLuminance ("OffsetEdge Luminance", Float) = 0
        _RenderDebug ("RenderDebug", Float) = 0
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
            Name "EDGE DETECTION OUTLINE"
            
            HLSLPROGRAM
            #pragma enable_d3d11_debug_symbols

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl" // needed to sample scene depth
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl" // needed to sample scene normals
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl" // needed to sample scene color/luminance
            #include "Packages/jp.keijiro.noiseshader/Shader/ClassicNoise2D.hlsl" // needed to sample scene color/luminance
            #include "Packages/jp.keijiro.noiseshader/Shader/ClassicNoise3D.hlsl" // needed to sample scene color/luminance

            float _OutlineThickness;
            float4 _OutlineColor;
            float _ScaleEdgeNormal;
            float _ScaleEdgeDepth;
            float _ScaleEdgeLuminance;
            float _OffsetEdgeNormal;
            float _OffsetEdgeDepth;
            float _OffsetEdgeLuminance;
            float _RenderDebug;

            #pragma vertex Vert // vertex shader is provided by the Blit.hlsl include
            #pragma fragment frag

          
            // struct Attributes
            // {
            //     uint vertexID : SV_VertexID;
            //     float4 pos:POSITION0;
            //     float4 normal:NORMAL0;
            //     float2 uv:TEXCOORD0;
            //     UNITY_VERTEX_INPUT_INSTANCE_ID
            // };

            // struct Varyings
            // {
            //     float4 positionCS : SV_POSITION;
            //     float4 normal:NORMAL0;
            //     float2 texcoord   : TEXCOORD0;
            //     UNITY_VERTEX_OUTPUT_STEREO
            // };

            // Varyings Vert(Attributes input)
            // {
            //     Varyings output;
            //     // UNITY_SETUP_INSTANCE_ID(input);
            //     // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
            //     float4 pos = input.pos;
            //     float2 uv  = input.uv;
            //     // #if SHADER_API_GLES
            //     //     float4 pos = input.positionOS;
            //     //     float2 uv  = input.uv;
            //     // #else
            //     //     float4 pos = GetFullScreenTriangleVertexPosition(input.vertexID);
            //     //     float2 uv  = GetFullScreenTriangleTexCoord(input.vertexID);
            //     // #endif
            //     pos += ClassicNoise(0.1*input.normal.xyz)*0.1;
            //     output.positionCS = mul(UNITY_MATRIX_MVP, pos);
            //     output.normal = input.normal;
            //     output.texcoord   = uv;
            //     return output;
            // }

            // Edge detection kernel that works by taking the sum of the squares of the differences between diagonally adjacent pixels (Roberts Cross).
            float RobertsCross(float3 samples[4])
            {
                const float3 difference_1 = samples[1] - samples[2];
                const float3 difference_2 = samples[0] - samples[3];
                return sqrt(dot(difference_1, difference_1) + dot(difference_2, difference_2));
            }

            // The same kernel logic as above, but for a single-value instead of a vector3.
            float RobertsCross(float samples[4])
            {
                const float difference_1 = samples[1] - samples[2];
                const float difference_2 = samples[0] - samples[3];
                return sqrt(difference_1 * difference_1 + difference_2 * difference_2);
            }
            
            // Helper function to sample scene normals remapped from [-1, 1] range to [0, 1].
            float3 SampleSceneNormalsRemapped(float2 uv)
            {
                return SampleSceneNormals(uv) * 0.5 + 0.5;
            }

            // Helper function to sample scene luminance.
            float SampleSceneLuminance(float2 uv)
            {
                float3 color = SampleSceneColor(uv);
                return color.r * 0.3 + color.g * 0.59 + color.b * 0.11;
            }
            
            float3 GetViewDirection(float2 uv){
                #if UNITY_REVERSED_Z
                    real depth = SampleSceneDepth(uv);
                #else
                    // Adjust z to match NDC for OpenGL
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(uv));
                #endif
                return ComputeWorldSpacePosition(uv, depth, UNITY_MATRIX_I_P);

            }

            float3 GetWorldPosition(float2 uv){
                #if UNITY_REVERSED_Z
                    real depth = SampleSceneDepth(uv);
                #else
                    // Adjust z to match NDC for OpenGL
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(uv));
                #endif
                return ComputeWorldSpacePosition(uv, depth, UNITY_MATRIX_I_VP);

            }

            float GetMainOutline(float2 uv){
                /* Some Hardcode parameters */
                float LineOffset = 0.5; // Distance between the drawn outline and the actual edge
                float2 texel_size = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);

                float3 normalAtSamplePoint = SampleSceneNormalsRemapped(uv)*2.-1.;
                float3 normalViewSpace = (mul(UNITY_MATRIX_V, float4(normalAtSamplePoint, 0.)).xyz);
                if(length(normalViewSpace)<0.1){
                    normalViewSpace = float3(0.,0.,1.);
                }else{
                    normalViewSpace = normalize(normalViewSpace);
                }
                // if(length(normalViewSpace-normalViewSpace)==0.){
                //     normalViewSpace = float3(0.,0.,1.);
                // }
                //return float4(normalViewSpace*0.5+0.5, 1.);
                float depthAtSamplePoint = 1./SampleSceneDepth(uv);
                // Generate 4 diagonally placed samples.
                const float half_width_f = floor(_OutlineThickness * 0.5);
                const float half_width_c = ceil(_OutlineThickness * 0.5);
                float2 uvs[4];
                uvs[0] = uv + texel_size * float2(half_width_f, half_width_c) * float2(-1, 1);  // top left
                uvs[1] = uv + texel_size * float2(half_width_c, half_width_c) * float2(1, 1);   // top right
                uvs[2] = uv + texel_size * float2(half_width_f, half_width_f) * float2(-1, -1); // bottom left
                uvs[3] = uv + texel_size * float2(half_width_c, half_width_f) * float2(1, -1);  // bottom right
                
                float3 normal_samples[4];
                float depth_samples[4], luminance_samples[4];
                
                for (int i = 0; i < 4; i++) {
                    depth_samples[i] = 1./SampleSceneDepth(uvs[i]);  // convert to actual scene depth (linear to world)
                    normal_samples[i] = SampleSceneNormalsRemapped(uvs[i]);
                    //luminance_samples[i] = SampleSceneLuminance(uvs[i]);
                }
                
                // Apply edge detection kernel on the samples to compute edges.
                float edge_depth = RobertsCross(depth_samples) * _ScaleEdgeDepth + _OffsetEdgeDepth;
                float edge_normal = RobertsCross(normal_samples) * _ScaleEdgeNormal + _OffsetEdgeNormal;
                //float edge_luminance = RobertsCross(luminance_samples) * _ScaleEdgeLuminance + _OffsetEdgeLuminance;
                float3 viewSpaceDir = normalize(GetViewDirection(uv));
                float NdotV = abs(dot(normalViewSpace, -viewSpaceDir));
                float depth_threshold = 25.;
                // Threshold the edges (discontinuity must be above certain threshold to be counted as an edge). The sensitivities are hardcoded here.
                
                edge_depth = (0.9*NdotV+0.1) * edge_depth > depth_threshold ? 1 : 0;

                float DirectionOffset = 0.1;
                // if(abs(dot(GetViewForwardDir(), (normalAtSamplePoint - 0.5)*2))<DirectionOffset){
                //     edge_depth = 0;
                // }
                
                float normal_threshold = 1 / 4.0f;
                edge_normal = edge_normal > normal_threshold ? 1 : 0;
                
                //float luminance_threshold = 1 / 0.5f;
                //edge_luminance = edge_luminance > luminance_threshold ? 1 : 0;
                
                // Combine the edges from depth/normals/luminance using the max operator.
                return max(edge_normal, edge_depth);//max(edge_depth, min(edge_normal, edge_luminance));
            }




            float4 frag(Varyings IN) : SV_TARGET
            {
                float2 uv = IN.texcoord;
                uv += ClassicNoise(uv*2.)*0.001;
                //return GetMainOutline(uv);
                float2 texel_size = float2(1.0 / _ScreenParams.x / 2., 1.0 / _ScreenParams.y / 2.);
                
                float total = 0.;
                for(int y = 0; y <= 1;y++){
                    for(int x = 0;x<=1;x++){
                        total = GetMainOutline(uv+float2(x*texel_size.x, y*texel_size.y));
                    }
                }

                // Color the edge with a custom color.
                return total;
            }
            ENDHLSL
        }
    }
}