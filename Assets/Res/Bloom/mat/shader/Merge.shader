Shader "Hidden/Merge"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset]_Mask("mask",2D) = "white"{}
        _UVScaleOffset("_UVScaleOffset",Vector) = (1,1,0,0)
    }
    SubShader
    {   
        Tags
        {
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
            "ShaderModel"="4.5"
        }
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);
        TEXTURE2D(_BloomColor);SAMPLER(sampler_BloomColor);
        TEXTURE2D(_Mask);SAMPLER(sampler_Mask);

        float4 _UVScaleOffset;

        float3 LinearToneMapping(float3 x)
        {
            float a = 1.8;
            float b = 1.4;
            float c = 0.5;
            float d = 1.5;
            return (x * (a * x + b)) / min(float3(1000.0, 1000.0, 1000.0), (x * (a * x + c) + d));
        }
        float3 GammaToLinearSpace(float3 sRGB)
        {
            return sRGB.rgb * (sRGB.rgb * (sRGB.rgb * 0.305306011 + 0.682171111) + 0.012522878);
        }
        ENDHLSL


        // No culling or depth
        Cull Off ZWrite On ZTest Less
        Pass
        {
            Name "predraw"
            Tags{"LightMode"="BlurPrePass"}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag1

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
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv * _UVScaleOffset.xy + _UVScaleOffset.zw;
                return o;
            }

            float4 frag1 (v2f i) : SV_Target
            {
                half ifmasked = SAMPLE_TEXTURE2D(_Mask,sampler_Mask,i.uv).r;
                // sample the texture
                float4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                return col*ifmasked;
            }
            ENDHLSL
        }
        Pass
        {   
            Name "merge"
            Tags{"LightMode" = "UniversalForward"}
            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex vert
            #pragma fragment frag2
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos :TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv * _UVScaleOffset.xy + _UVScaleOffset.zw;
                o.screenPos =  ComputeScreenPos(o.vertex);
                return o;
            }

            float4 frag2 (v2f i) : SV_Target
            {
                float4 col;
                float4 finalCol;
                float2 screenUV = i.screenPos.xy/i.screenPos.w;
                col = float4(
                    SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv).rgb+ 
                    SAMPLE_TEXTURE2D(_BloomColor, sampler_BloomColor,screenUV).rgb,1.0);
                finalCol.rgb = AcesTonemap(col.rgb);
                // col.rgb = pow(finalCol.rgb,1/2.2);
                return finalCol;
                // return float4(i.uv-screenUV,0,1);
            }
            ENDHLSL
        }
    }
}
