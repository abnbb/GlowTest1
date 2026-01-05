Shader "Unlit/Mybloom"
{
    Properties
    {
        _MainTex("MainTex",2D) = "white"{}
        _bloomPassIndex("bloomPassIndex",int)= 0
        _Down_texelSize_x("Down_texelSize_x", Range(0,0.1)) = 0.01
        _Down_texelSize_y("Down_texelSize_y", Range(0,0.1)) = 0.01
        _Up_texelSize_x("Up_texelSize_x", Range(0,0.1)) = 0.01
        _Up_texelSize_y("Up_texelSize_y", Range(0,0.1)) = 0.01
        _radius("Up radius",Range(0,0.1)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        CGINCLUDE
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
        

        #include "UnityCG.cginc"
        #include "myBloomTools.cginc"
        
        // sampler2D _DonwTex;
        sampler2D _MainTex;
        sampler2D _InputeTex;
        float4 _DonwTex_ST;
        int _bloomPassIndex;
        float _Down_texelSize_x;
        float _Down_texelSize_y;
        sampler2D _CurrentDownSampleTexture;
        float4 _CurrentDownSampleTexture_ST;
        sampler2D _PreviousUpSampleTexture;
        float4 _PreviousUpSampleTexture_ST;
        float _Up_texelSize_x;
        float _Up_texelSize_y;
        float _radius;

        ENDCG
        

        // downsample1
        Pass
        {
            Name "downsample1"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragDown1


            fixed4 fragDown1 (v2f i) : SV_Target
            {
                fixed4 col;
                float2 texelSize = float2(_Down_texelSize_x, _Down_texelSize_y);
                
                // sample the texture
                fixed3 D =tex2D(_MainTex, i.uv + float2(-1.0, -1.0) * texelSize).xyz;
                fixed3 E =tex2D(_MainTex, i.uv + float2(1.0, -1.0) *  texelSize).xyz;
                fixed3 I =tex2D(_MainTex, i.uv + float2(-1.0,  1.0) * texelSize).xyz;
                fixed3 J =tex2D(_MainTex, i.uv + float2(1.0,  1.0) *  texelSize).xyz;
                col = fixed4(karisAverage(D, E, I, J), 1.0);
                return col;
            }
            ENDCG
        }
        //downsample2
        Pass
        {
            Name "downsample2"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragDown2


            fixed4 fragDown2 (v2f i) : SV_Target
            {
                fixed4 col;
                float2 texelSize = float2(_Down_texelSize_x, _Down_texelSize_y);
                
                // sample the texture
                fixed3 A =tex2D(_MainTex, i.uv + float2(-2.0, -2.0) * texelSize).xyz;
                fixed3 B =tex2D(_MainTex, i.uv + float2(0.0, -2.0) *  texelSize).xyz;
                fixed3 C =tex2D(_MainTex, i.uv + float2(2.0, -2.0) *  texelSize).xyz;
                fixed3 D =tex2D(_MainTex, i.uv + float2(-1.0, -1.0) * texelSize).xyz;
                fixed3 E =tex2D(_MainTex, i.uv + float2(1.0, -1.0) *  texelSize).xyz;
                fixed3 F =tex2D(_MainTex, i.uv + float2(-2.0,  0.0) * texelSize).xyz;
                fixed3 G =tex2D(_MainTex, i.uv + float2(0.0,  0.0) *  texelSize).xyz;
                fixed3 H =tex2D(_MainTex, i.uv + float2(2.0,  0.0) *  texelSize).xyz;
                fixed3 I =tex2D(_MainTex, i.uv + float2(-1.0,  1.0) * texelSize).xyz;
                fixed3 J =tex2D(_MainTex, i.uv + float2(1.0,  1.0) *  texelSize).xyz;
                fixed3 K =tex2D(_MainTex, i.uv + float2(-2.0,  2.0) * texelSize).xyz;
                fixed3 L =tex2D(_MainTex, i.uv + float2(0.0,  2.0) *  texelSize).xyz;
                fixed3 M =tex2D(_MainTex, i.uv + float2(2.0,  2.0) *  texelSize).xyz;

                fixed3 centerQuad = 0.5 * average(D, E, I, J);
                fixed3 upperLeftQuad = 0.125 * average(A, B, F, G);
                fixed3 upperRightQuad = 0.125 * average(B, G, C, H);
                fixed3 lowerLeftQuad = 0.125 * average(F, G, K, L);
                fixed3 lowerRightQuad = 0.125 * average(G, L, H, M);
                col = fixed4(centerQuad + upperLeftQuad + upperRightQuad + lowerLeftQuad + lowerRightQuad, 1.0); 
                return col;
            }
            ENDCG
        }

        //upsample1
        Pass{
            Name"upsample1"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragUp1

            fixed4 fragUp1 (v2f i) : SV_Target
            {
                fixed4 col;
                fixed4 curCol;
                float2 texelSize = 1/ float2(_Up_texelSize_x, _Up_texelSize_y);

                return tex2D(_CurrentDownSampleTexture, i.uv);
            }
            ENDCG
        }
        //upsample2
        Pass{
            Name"upsample2"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragUp2

            fixed4 fragUp2 (v2f i) : SV_Target
            {
                fixed4 col;
                fixed4 curCol;
                float2 texelSize = 1/ float2(_Up_texelSize_x, _Up_texelSize_y);

                curCol = tex2D(_CurrentDownSampleTexture, i.uv);

                fixed3 A = (1.0 / 16.0) * tex2D(_MainTex, i.uv + half2(-1.0, -1.0) *texelSize * _radius).xyz;
	            fixed3 B = (2.0 / 16.0) * tex2D(_MainTex, i.uv + half2(0.0, -1.0) * texelSize * _radius).xyz;
	            fixed3 C = (1.0 / 16.0) * tex2D(_MainTex, i.uv + half2(1.0, -1.0) * texelSize * _radius).xyz;
	            fixed3 D = (2.0 / 16.0) * tex2D(_MainTex, i.uv + half2(-1.0, 0.0) * texelSize * _radius).xyz;
	            fixed3 E = (4.0 / 16.0) * tex2D(_MainTex, i.uv + half2(0.0, 0.0) *  texelSize * _radius).xyz;
	            fixed3 F = (2.0 / 16.0) * tex2D(_MainTex, i.uv + half2(1.0, 0.0) *  texelSize * _radius).xyz;
	            fixed3 G = (1.0 / 16.0) * tex2D(_MainTex, i.uv + half2(-1.0, 1.0) * texelSize * _radius).xyz;
	            fixed3 H = (2.0 / 16.0) * tex2D(_MainTex, i.uv + half2(0.0, 1.0) *  texelSize * _radius).xyz;
	            fixed3 I = (1.0 / 16.0) * tex2D(_MainTex, i.uv + half2(1.0, 1.0) *  texelSize * _radius).xyz;
                
                col = curCol+ fixed4(A + B + C + E + F + G + H + I, 1.0);
                return col;
                }
            ENDCG
        }
    }
}
