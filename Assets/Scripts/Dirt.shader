// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LoveYouSeifer/Dirt"
{
    Properties
    {
        _MainTex("Dirt Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _DirtRoughness ("Dirt Roughness", Range(0, 1)) = 0.5
        _Threshold ("Threshold", Range(0, 1)) = 0.5
        _Fade("Fade", Range(0, 1)) = 0.5
        _CircleRadius("Circle Radius", Range(0, 1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert;
            #pragma fragment frag;
            #pragma target 3.0

            #include "UnityPBSLighting.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; 
            float _Smoothness;
            float _Metallic;
            
            float _DirtVisibility;
            float _Threshold;
            float _Fade;
            float _CircleRadius;

            struct Interpolators{
                float4  position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };
            struct VertexData{
                float4  position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert(VertexData v){
                Interpolators i;

                i.position = UnityObjectToClipPos(v.position);
                i.worldPos = mul(unity_ObjectToWorld, v.position);
                i.normal = UnityObjectToWorldNormal(v.normal);

                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.normal = normalize(i.normal);
                return i;
            }

            float4 frag(Interpolators i) : SV_TARGET{
                i.normal = normalize(i.normal);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb;
                float3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                float2 uvCenter = float2(0.5, 0.5);
                float distanceFromCenter = distance(i.uv, uvCenter);
                float circle = 1 - smoothstep(_CircleRadius - _Fade, _CircleRadius + _Fade, distanceFromCenter);
                float dirtValue = tex2D(_MainTex, i.uv).r;
                dirtValue *=  (1- circle);

                if(dirtValue < _Threshold)
                {
                    discard;
                }

                albedo *= lerp(1.0, albedo * _DirtVisibility, dirtValue);

                float3 specularTint;
                float oneMinusReflectivity;
                
                albedo *= DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);

                UnityLight light;
                light.color = lightColor;
                light.dir = lightDir;
                light.ndotl = DotClamped(i.normal, lightDir);

                UnityIndirect indirectLight;
                indirectLight.diffuse = 0;
                indirectLight.specular = 0;

                return UNITY_BRDF_PBS(albedo, specularTint, oneMinusReflectivity, _Smoothness, i.normal, viewDir, light, indirectLight);
            }
            ENDCG
        }
    }
}
