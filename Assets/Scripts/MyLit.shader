// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Custom/MyLit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GridTex ("Grid Texture", 2D) = "gray"{}
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert;
            #pragma fragment frag;
            
            #include "UnityCG.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; 
            // _ST = Scale and Tiling
            sampler2D _GridTex;
            float4 _GridTex_ST;

            struct Interpolators{
                float4  position : POSITION;
                float2 uv : TEXCOORD0;
                float2 uvDetail : TEXCOORD1;
            };
            struct VertexData{
                float4  position : POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert(VertexData v){
                Interpolators i;

                // Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
                i.position = UnityObjectToClipPos(v.position);
                //From UnityCG.cginc
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.uvDetail = TRANSFORM_TEX(v.uv, _GridTex);
                return i;
            }

            float4 frag(Interpolators i) : SV_TARGET{
                float4 color = tex2D(_MainTex, i.uv) * _Color;
                color *= tex2D(_GridTex, i.uvDetail) * unity_ColorSpaceDouble;
                return color;
            }


            ENDCG
        }
    }
}
