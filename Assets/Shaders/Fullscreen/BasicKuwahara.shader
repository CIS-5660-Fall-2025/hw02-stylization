Shader "Hidden/BasicKuwahara"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Kuwahara Radius", Float) = 1.0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _Radius;

            struct Window{
                int x1;
                int y1;
                int x2;
                int y2;
            };

            fixed4 frag (v2f p) : SV_Target
            {
                float n = float((_Radius + 1) * (_Radius + 1));
                float3 m[4];
                float3 s[4];

                for(int a = 0; a < 4; ++a){
                    m[a] = float3(0, 0, 0);
                    s[a] = float3(0, 0, 0);
                }

                Window W[4] = {
                    {-_Radius, -_Radius, 0, 0},
                    {0, -_Radius, _Radius, 0},
                    {0, 0, _Radius, _Radius},
                    {-_Radius, 0, 0, _Radius}
                };

                for(int k = 0; k < 4; ++k){
                    for(int j = W[k].y1; j <= W[k].y2; ++j){
                        for(int i = W[k].x1; i <= W[k].x2; ++i){
                            float3 c = tex2D(_MainTex, p.uv + float2(i, j) * _MainTex_TexelSize.xy);
                            m[k] += c;
                            s[k] += c * c;
                        }
                    }
                }

                float min_sigma2 = 1e+2;

                fixed4 col = tex2D(_MainTex, p.uv);

                for(int b = 0; b < 4; ++b){
                    m[b] /= n;
                    s[b] = abs(s[b] / n - m[b] * m[b]);

                    float sigma2 = s[b].r + s[b].g + s[b].b;
                    if(sigma2 < min_sigma2){
                        min_sigma2 = sigma2;
                        col = float4(m[b], 1.0);
                    }
                }
                return col;
            }
            ENDCG
        }
    }
}
