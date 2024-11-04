Shader "Custom/Tutorial_Shader"
{
    //Anything passing here will show in Unity
    Properties{
        //Declaring variables
        //[type] [name] : [semantic]

        _Color ("Cool Color", Color) = (1,1,1,1)
        //Texture Map
        _MainTexture ("Main Texture", 2D) = "white"{}
        
        _DissolveTexture ("Dissolve Texture", 2D) = "white"{}
        _DissolveCutoff ("Dissolve Cutoff", Range(0, 1)) = 1
        _ExtrudeAmount ("Exture Amount", float) = 0
    }

    //If you're deploying to multiple platforms it can be useful to add multiple subshaders;
    //For example, you might want two subshaders, one of higher quality for PC/Desktop
    //and one of lower quality but faster for mobile.
    SubShader{
        Tags {"RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"}
        //Where object gets rendered
        Pass{
            //Inside CGPROGRAM will be the actual code
            CGPROGRAM
            // Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members normal)
            #pragma exclude_renderers d3d11


            //telling Unity we have a vertex function and fragment function
            #pragma vertex vertexFunction
            #pragma fragment fragmentFunction 

            //helper functions
            #include "UnityCG.cginc"
            
            //data structure
            struct appdata{
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            //vertex to fragment
            //will contain data that will be passed through the fragment function
            struct v2f{
                //SV = system value
                //represents the final transformed vertex position used for rendering 
                float4 position : SV_POSITION;
                //textcoord = texture coordinates
                float2 uv : TEXCOORD0;
            };

            //**********************
            //Get properties into CG
            //**********************
            float4 _Color;
            sampler2D _MainTexture;
            sampler2D _DissolveTexture;
            float _DissolveCutoff;
            float _ExtrudeAmount;

            //Unity will look into the structure, here it's appdata
            //and will attempt to pass in values
            v2f vertexFunction(appdata IN){
                v2f OUT;

                //Before transforming the vertices ouf of local model space, it will offset them a certain amount outwards
                //by adding their normal direction multiplied by the _ExtrudeAmount
                //A normal is just a vector that represents the direction that the vertex is facing.
                IN.vertex.xyz += IN.normal.xyz * _ExtrudeAmount * sin(_Time.y);

                //Gets the current positions of the vertices
                //Takes a vertex that is represented in local object space,
                //transforms it to the rendering camera clip space
                OUT.position = UnityObjectToClipPos(IN.vertex);
                OUT.uv = IN.uv;

                return OUT;
            }

            //Tells Unity that we're outputting a fixed4 color to be rendered
            fixed4 fragmentFunction(v2f IN) : SV_TARGET{
                //tex2D takes in texture we want to sample, and the UV coordinates
                //return tex2D(_MainTexture, IN.uv);

                float4 textureColor = tex2D(_MainTexture, IN.uv);
                float4 dissolveColor = tex2D(_DissolveTexture, IN.uv);
                
                //Checks if the value given is less than 0. 
                //If true, will discard the pixel and draw nothing. 
                //If false, will keep the pixel and continue. 
                clip(dissolveColor.rgb - _DissolveCutoff);
                return textureColor * _Color;
            }
            ENDCG
        }
    }
}
