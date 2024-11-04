Shader "Custom/ChromaticAbberation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Offset ("Offset", Range(0, 1)) = 0
    }
    SubShader
    {
        Cull Off 
        Tags { "RenderPipeline"="UniversalPipeline"}

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 color = tex2D(_MainTex, i.uv);
                _Offset *= cos(_Time.y);
                color.r = tex2D(_MainTex, float2(i.uv.x - _Offset, i.uv.y - _Offset)).r;
                color.g = tex2D(_MainTex, i.uv).g;
                color.b = tex2D(_MainTex, float2(i.uv.x + _Offset, i.uv.y + _Offset)).b;

                return color;

                //float colR = tex2D(_MainTex, float2(i.uv.x -  _Offset, i.uv.y - _Offset)).r;
                //float colG = tex2D(_MainTex, i.uv).g;
                //float colB = tex2D(_MainTex, float2(i.uv.x + _Offset, i.uv.y + _Offset)).b;
                
                //return fixed4(colR, colG, colB, 1);
            }
            ENDCG
        }
    }
}
