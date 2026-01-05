Shader "PostProcess/ColoTint"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorTint("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline"}
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
            float4 _ColorTint;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformWorldToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv)*_ColorTint;
                return col;
            }
            ENDHLSL
        }
    }
}
