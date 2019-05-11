
Shader "Custom/HillFromTexture"
{
    Properties
    {   
        _Color ("Color", Color) = (1, 1, 1, 1) //The color of our object
        _Shininess ("Shininess", Float) = 32 //Shininess
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1) //Specular highlights color
        _WaterTex ("WaterTexture", 2D) = "white" {}
        _GrassTex ("GrassTexture", 2D) = "white" {}
        _SnowTex ("SnowTexture", 2D) = "white" {}
        _HeightMapTex ("HeightMapTexture", 2D) = "white" {}
        _Cube ("Cubemap", CUBE) = "" {} // skybox used for reflections on water
        
        _DisplacementAmt ("Displacement", Float) = 1.0 
    }
    
    SubShader
    {
        Pass {
            Tags { "LightMode" = "ForwardAdd" } //Important! In Unity, point lights are calculated in the the ForwardAdd pass
            // Blend One One //Turn on additive blending if you have more than one point light
          
            Cull off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
           
            uniform float4 _LightColor0; //From UnityCG
            uniform float4 _Color; 
            uniform float4 _SpecColor;
            uniform float _Shininess;     
            uniform sampler2D _WaterTex;     
            uniform sampler2D _SnowTex;     
            uniform sampler2D _GrassTex; 
            uniform sampler2D _HeightMapTex;
            uniform samplerCUBE _Cube;
            uniform float _DisplacementAmt;
            
          
            struct appdata
            {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                    float4 vertex : SV_POSITION;
                    float3 normal : NORMAL;       
                    float2 uv : TEXCOORD0;
                    float3 vertexInWorldCoords : TEXCOORD1;
                    float  heightVal : TEXCOORD2;
            };

 
           v2f vert(appdata v)
           { 
                v2f o;
                
                //special texture sampler function to specify LOD (needed in order to access textures in vertex shader)
                //see http://developer.download.nvidia.com/cg/tex2Dlod.html
                float3 hmVal = tex2Dlod(_HeightMapTex, float4(v.uv, 0, 0)).rgb;
                
                float vDisplace = hmVal.r * _DisplacementAmt; 
                float4 newPosition = float4((v.vertex.xyz + v.normal.xyz * vDisplace).xyz, 1.0);
      
                
                o.vertexInWorldCoords = mul(unity_ObjectToWorld, newPosition); //Vertex position in WORLD coords
                o.normal = UnityObjectToWorldNormal(v.normal); //Normal vector in WORLD coords 
                o.vertex = UnityObjectToClipPos(newPosition); 
                o.uv = v.uv;
                o.heightVal = newPosition.y;
                
              

                return o;
           }

           fixed4 frag(v2f i) : SV_Target
           {
                
                float3 P = i.vertexInWorldCoords.xyz;
                float3 N = normalize(i.normal);
                float3 V = normalize(_WorldSpaceCameraPos - P);
                float3 L = normalize(_WorldSpaceLightPos0.xyz - P);
                float3 H = normalize(L + V);
                
                float3 Kd = _Color.rgb; //Color of object
                //float3 Ka = UNITY_LIGHTMODEL_AMBIENT.rgb; //Ambient light
                float3 Ka = float3(0,0,0); //UNITY_LIGHTMODEL_AMBIENT.rgb; //Ambient light
                float3 Ks = _SpecColor.rgb; //Color of specular highlighting
                float3 Kl = _LightColor0.rgb; //Color of light
                
                
                //AMBIENT LIGHT 
                float3 ambient = Ka;
                
               
                //DIFFUSE LIGHT
                float diffuseVal = max(dot(N, L), 0);
                float3 diffuse = Kd * Kl * diffuseVal;
                
                
                //SPECULAR LIGHT
                float specularVal = pow(max(dot(N,H), 0), _Shininess);
                
                if (diffuseVal <= 0) {
                    specularVal = 0;
                }
                
                float3 specular = Ks * Kl * specularVal;
                
                //FINAL LIGHT COLOR OF FRAGMENT
                float3 lightColor = float3(ambient + diffuse + specular);
                
                
                
               
                float3 water = tex2D(_WaterTex, i.uv).rgb;
                float3 grass = tex2D(_GrassTex, i.uv).rgb;
                float3 snow = tex2D(_SnowTex, i.uv).rgb;
                
                float3 textureColor;
                
                // run reflection algorithm on water, lowest height on map
                if(i.heightVal < 0.3)
                {
                    float3 P = i.vertexInWorldCoords.xyz;
             
                    //get normalized incident ray (from camera to vertex)
                    float3 vIncident = normalize(P - _WorldSpaceCameraPos);
                 
                    //reflect that ray around the normal using built-in HLSL command
                    float3 vReflect = reflect( vIncident, i.normal );
                 
                 
                    //use the reflect ray to sample the skybox
                    float4 reflectColor = texCUBE( _Cube, vReflect );
                 
                    //refract the incident ray through the surface using built-in HLSL command
                    float3 vRefract = refract( vIncident, i.normal, 0.5 );
                 
                    //float4 refractColor = texCUBE( _Cube, vRefract );
                 
                 
                    float3 vRefractRed = refract( vIncident, i.normal, 0.1 );
                    float3 vRefractGreen = refract( vIncident, i.normal, 0.4 );
                    float3 vRefractBlue = refract( vIncident, i.normal, 0.7 );
                 
                    float4 refractColorRed = texCUBE( _Cube, float3( vRefractRed ) );
                    float4 refractColorGreen = texCUBE( _Cube, float3( vRefractGreen ) );
                    float4 refractColorBlue = texCUBE( _Cube, float3( vRefractBlue ) );
                    float4 refractColor = float4(refractColorRed.r, refractColorGreen.g, refractColorBlue.b, 1.0);
                 
                    textureColor = lerp(reflectColor, refractColor, 0.5) * water;
                }
                // gradient between water and grass for middle section
                else if(i.heightVal < 0.5) 
                {
                    textureColor = lerp(water, grass, i.heightVal*2);    
                }
                // gradient between grass and snow for top of hill
                else if(i.heightVal >= 0.5) 
                {
                    textureColor = lerp(grass, snow, i.heightVal*2 - 1);   
                }
                
                return float4(lerp(textureColor, lightColor, 0.2), 1.0);       
            }
            
            ENDCG
 
            
        }
            
    }
}
