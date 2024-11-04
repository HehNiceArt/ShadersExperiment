// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Custom/Lighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        [Gamma]_Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
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

            //#include "UnityStandardBRDF.cginc"
            //#include "UnityStandardUtils.cginc"
            //Physically Based Shading
            #include "UnityPBSLighting.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; 
            float _Smoothness;
            float _Metallic;

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
                //i.normal = mul(transpose((float3x3)unity_ObjectToWorld),v.normal);
                i.worldPos = mul(unity_ObjectToWorld, v.position);
                i.normal = UnityObjectToWorldNormal(v.normal);

                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.normal = normalize(i.normal);
                return i;
            }

            float4 frag(Interpolators i) : SV_TARGET{
                i.normal = normalize(i.normal);
                //return float4(i.normal * 0.5 + 0.5, 1);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb;
                float3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                float3 specularTint;
                float oneMinusReflectivity;
                
                //albedo *= 1 - max(_SpecularTint.r, max(_SpecularTint.g, _SpecularTint.b));

                //From UnityStandardUtils.cginc
                //float oneMinusReflectivity;
                //albedo = EnergyConservationBetweenDiffuseAndSpecular(albedo, _SpecularTint.rgb, oneMinusReflectivity);

                albedo *= DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);

                //************************************
                //Blinn-Phong with Specular and Metallic

                //float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);
                
                //Blinn-Phong   
                //float3 halfVector = normalize(lightDir + viewDir);

                //float3 specular = specularTint * lightColor * pow(DotClamped(halfVector, i.normal), _Smoothness * 100);

                //float3 reflectionDir = reflect(-lightDir, i.normal);

                //return float4(reflectionDir * 0.5 + 0.5,1);
                //return pow(DotClamped(halfVector, i.normal), _Smoothness * 100);
                //return float4(diffuse, 1);

                //return float4(diffuse + specular, 1); 

                //************************************

                UnityLight light;
                light.color = lightColor;
                light.dir = lightDir;
                //dot product between surface normal and light direction
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
