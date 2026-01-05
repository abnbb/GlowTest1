Shader "OrangeFilter/PBR2"
{
	Properties
	{
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        _Cutoff ("AlphaCutoff", Range(0.0, 1.0)) = 0.5
        [HideInInspector] _Cull ("__cull", Float) = 2.0

        _UVScaleOffset ("UVScaleOffset", Vector) = (1, 1, 0, 0)
        _Color ("Color", Color) = (1, 1, 1, 1)

        [NoScaleOffset] _MainTex ("MainTex", 2D) = "white" {}
        [NoScaleOffset] _NormalMap ("NormalMap", 2D) = "bump" {}
        [NoScaleOffset] _MetallicRoughnessOcclusionMap ("MetallicRoughnessOcclusionMap", 2D) = "white" {}

        _Metallic ("Metallic", Range(0, 1)) = 1
        _Roughness ("Roughness", Range(0, 1)) = 1
        _Occlusion ("Occlusion", Range(0, 1)) = 1

        [NoScaleOffset] _IrradianceMap ("IrradianceMap", Cube) = "white" {}
        [NoScaleOffset] _PrefilterMap ("PrefilterMap", Cube) = "white" {}
        _IBLExposure("IBLExposure", Range(0, 10)) = 1.0
        [NoScaleOffset] _BRDF ("BRDF", 2D) = "white" {}


        [HideInInspector] _LightInViewEnable("__lv", Float) = 0.0

        _LightDir ("LightDir", Vector) = (0, 0, -1, 0)
		_LightColor ("LightColor", Color) = (1, 1, 1, 1)
        _LightIntensity ("LightIntensity", Range(0, 100)) = 1

        [HideInInspector] _Light2Enable ("__l2", Float) = 0.0
        _LightDir2 ("LightDir2", Vector) = (0, 0, -1, 0)
        _LightColor2 ("LightColor2", Color) = (1, 1, 1, 1)
        _LightIntensity2 ("LightIntensity2", Range(0, 100)) = 1
		
		_UseSceneLight ("Use Scene Light", Float) = 0.0

		_FrameCount ("FrameCount", Int) = 1
		_FrameX ("FrameX", Int) = 1
		_FrameY ("FrameY", Int) = 1
		_FrameRate ("FrameRate", float) = 1.0

		_OffsetSpeed ("OffsetSpeed", Vector) = (0, 0, 0, 0)

        [NoScaleOffset] _EmissiveMap ("EmissiveMap", 2D) = "white" {}
        _EmissiveColor ("EmissiveColor", Color) = (0, 0, 0, 0)

        [HideInInspector] _EmissiveBloomEnable("__12",Float) = 0.0
        _EmissiveBloomColor("EmissiveBloomColor",Color) = (1, 1, 1, 1)
        _EmissiveBloomIntensity("_EmissiveBloomIntensity",Range(0,1)) = 1.0

        [HideInInspector] _RIMEnable("__l2", Float) = 0.0
        _RimColor("RimColor", Color) = (0, 0, 0, 0)
        _RimFallOff("RimFallOff", Range(0, 1)) = 1.0

        [HideInInspector] _IridescenceEnable("__l2", Float) = 0.0
        _IridescenceIntensity("IridescenceIntensity", Range(0, 1)) = 1.0
        _IridescenceFallOff("IridescenceFallOff", Range(0, 1)) = 1.0
        _IridescenceSaturation("IridescenceSaturation", Range(0, 1)) = 1.0

        [HideInInspector] _FresnelAlphaEnable("__l2", Float) = 0.0
        _fresnelBase("fresnelBase", Range(0, 1)) = 1.0
        _fresnelScale("fresnelScale", Range(0, 1)) = 1.0
        _fresnelIndensity("fresnelIndensity", Range(0, 5)) = 5
	}

	SubShader
	{
        Pass{
            Name "predraw"
            Tags{"LightMode"="BlurPrePass"}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag1
            #pragma shader_feature _EMISSIVE_BLOOM_ON
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_EmissiveMap);SAMPLER(sampler_EmissiveMap);
            float4 _UVScaleOffset;
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
                float4 col = float4(0,0,0,1);
#ifdef _EMISSIVE_BLOOM_ON
                // sample the texture
                col = SAMPLE_TEXTURE2D(_EmissiveMap,sampler_EmissiveMap,i.uv);
#endif  
                return col;

            }
            ENDHLSL
            }

		Pass
		{
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #pragma target 3.0 
            #pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _LIGHT2_ON
            #pragma shader_feature _FRAME_ANIM_ON
            #pragma shader_feature _OFFSET_ANIM_ON
            #pragma shader_feature _VIEW_SPACE_LIGHTING_ON
            #pragma shader_feature _NORMALMAP_ON
            #pragma shader_feature _ALPHABLEND_ON
            #pragma shader_feature _ALPHABLEND_ADD_ON
            #pragma shader_feature _CULLOFF_ON
            #pragma shader_feature _SKIN_ON
            #pragma shader_feature _RIM_ON
            #pragma shader_feature _IRIDESCENCE_ON
            #pragma shader_feature _FRESNELAPLPHA_ON
            #pragma shader_feature _EMISSIVE_BLOOM_ON

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 posProj : SV_POSITION;
				float2 uv : TEXCOORD0;
#ifdef _NORMALMAP_ON
				half4 tspace0 : TEXCOORD1;
				half4 tspace1 : TEXCOORD2;
				half4 tspace2 : TEXCOORD3;
#else
                half3 pos : TEXCOORD1;
                half3 normal : TEXCOORD2;
                
#endif
#ifdef _EMISSIVE_BLOOM_ON
                half4 screenPos :TEXCOORD4;
#endif
			};

			sampler2D unity_NHxRoughness;

#ifdef _ALPHATEST_ON
            float _Cutoff;
#endif

			float4 _UVScaleOffset;
            float4 _Color;

			sampler2D _MainTex;
			sampler2D _NormalMap;
            sampler2D _MetallicRoughnessOcclusionMap;

            float _Metallic;
            float _Roughness;
            float _Occlusion;

            samplerCUBE _IrradianceMap;
            samplerCUBE _PrefilterMap;
            float _IBLExposure;
            sampler2D _BRDF;
			
			float _UseSceneLight;
			float4 _GlobalLightDir1;
			float4 _GlobalLightColor1;
			float _GlobalLightIntensity1;

			half3 _LightDir;
			fixed4 _LightColor;
            float _LightIntensity;
#ifdef _LIGHT2_ON
            half3 _LightDir2;
            fixed4 _LightColor2;
            float _LightIntensity2;
#endif

// face            
#ifdef _CULLOFF_ON
            uint _face;
#endif
            

#ifdef _FRAME_ANIM_ON
			uint _FrameCount;
			uint _FrameX;
			uint _FrameY;
			float _FrameRate;
#endif

#ifdef _OFFSET_ANIM_ON
			float4 _OffsetSpeed;
#endif

            sampler2D _EmissiveMap;
            fixed3 _EmissiveColor;
#ifdef _EMISSIVE_BLOOM_ON
            sampler2D _EmissiveBloomMap;
            float4 _EmissiveBloomColor;
            float _EmissiveBloomIntensity;
#endif

#ifdef _RIM_ON
            fixed3 _RimColor;
            float _RimFallOff;
#endif

#ifdef _IRIDESCENCE_ON
            float _IridescenceIntensity;
            float _IridescenceFallOff;
            float _IridescenceSaturation;
#endif


#ifdef _FRESNELAPLPHA_ON
            float _fresnelBase;
            float _fresnelScale;
            float _fresnelIndensity;
#endif

			v2f vert (appdata v)
			{
				v2f o;
				o.posProj = UnityObjectToClipPos(v.vertex);
				
#ifdef _FRAME_ANIM_ON
                // _FrameCount > 1
				uint frame = (uint) (_Time.y * _FrameRate);
				frame = frame % _FrameCount;
				uint x = frame % _FrameX;
				uint y = _FrameX - 1 - frame / _FrameX;
				float w = 1.0 / float(_FrameX);
				float h = 1.0 / float(_FrameY);

				float4 scale_offset;
				scale_offset.x = w;
				scale_offset.y = h;
				scale_offset.z = float(x) * w;
				scale_offset.w = float(y) * h;

				o.uv = v.uv * scale_offset.xy + scale_offset.zw;
#else
                // _FrameCount == 0
                o.uv = v.uv * _UVScaleOffset.xy + _UVScaleOffset.zw;
#endif

#ifdef _OFFSET_ANIM_ON
				o.uv += _OffsetSpeed.xy * _Time.y;
#endif

#ifdef _VIEW_SPACE_LIGHTING_ON
                float4x4 mat = UNITY_MATRIX_MV;
#else
                float4x4 mat = UNITY_MATRIX_M;
#endif
                float3 pos = mul(mat, v.vertex).xyz;
                half3 normal = normalize(mul(mat, half4(v.normal, 0.0)).xyz);

#ifdef _NORMALMAP_ON
                half3 tangent = normalize(mul(mat, v.tangent).xyz);
				half3 bitangent = normalize(cross(normal, tangent) * v.tangent.w);

				o.tspace0 = half4(tangent.x, bitangent.x, normal.x, pos.x);
                o.tspace1 = half4(tangent.y, bitangent.y, normal.y, pos.y);
                o.tspace2 = half4(tangent.z, bitangent.z, normal.z, pos.z);
#else
                o.pos = pos;
                o.normal = normal;
#endif
#ifdef _EMISSIVE_BLOOM_ON
                o.screenPos =  ComputeScreenPos(o.posProj);
#endif
				return o;
			}

            // ----------------------------------------------------------------------------
            float DistributionGGX(float3 N, float3 H, float roughness)
            {
                const float PI = 3.14159265359;
                float a = roughness * roughness;
                float a2 = a * a;
                float NdotH = max(dot(N, H), 0.0);
                float NdotH2 = NdotH * NdotH;

                float nom = a2;
                float denom = (NdotH2 * (a2 - 1.0) + 1.0);
                denom = PI * denom * denom;

                return nom / denom;
            }
            // ----------------------------------------------------------------------------
            float GeometrySchlickGGX(float NdotV, float roughness)
            {
                float r = (roughness + 1.0);
                float k = (r * r) / 8.0;

                float nom = NdotV;
                float denom = NdotV * (1.0 - k) + k;

                return nom / denom;
            }
            // ----------------------------------------------------------------------------
            float GeometrySmith(float3 N, float3 V, float3 L, float roughness)
            {
                float NdotV = max(dot(N, V), 0.0);
                float NdotL = max(dot(N, L), 0.0);
                float ggx2 = GeometrySchlickGGX(NdotV, roughness);
                float ggx1 = GeometrySchlickGGX(NdotL, roughness);

                return ggx1 * ggx2;
            }
            // ----------------------------------------------------------------------------
            float3 fresnelSchlick(float cosTheta, float3 F0)
            {
                return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
            }
            // ----------------------------------------------------------------------------
            float3 fresnelSchlickRoughness(float cosTheta, float3 F0, float roughness)
            {
                float smoothness = 1.0 - roughness;
                return F0 + (max(float3(smoothness, smoothness, smoothness), F0) - F0) * pow(1.0 - cosTheta, 5.0);
            }
            // ----------------------------------------------------------------------------
            float3 RimColorFunc(float3 N, float3 V, float3 rc, float fallOff)
            {
                float revNoV = 1.0 - max(0.0, dot(N, V));
                return rc * pow(revNoV, fallOff);
            }
            //-----------------------------------------------------------------------------
            float3 IridescenceColor(float3 N, float3 V, float fresnel, float iridescenceIntensity, float saturation)
            {
                float camedge = dot(N, V);
                float3 k = normalize(float3(1.0, 1.0, 1.0));
                float t = camedge * 3.14 * 6.0;
                float3 iridemix = float3(1.0, 0.0, 0.0);
                float3 clrmix = iridemix * cos(t) + cross(k, iridemix) * sin(t) + k * dot(k, iridemix) * (1.0 - cos(t));
                float mask = lerp(1.0, 0.0, camedge);
                float fn = pow(mask, fresnel);
                float3 cm = clrmix * iridescenceIntensity * fn;
                float ds = dot(cm, float3(0.3, 0.59, 0.11));
                float3 cms = lerp(float3(ds, ds, ds), cm, saturation);
                return cms;
            }
            //-----------------------------------------------------------------------------
            float3 LinearToneMapping(float3 x)
            {
                float a = 1.8;
                float b = 1.4;
                float c = 0.5;
                float d = 1.5;
                return (x * (a * x + b)) / min(float3(1000.0, 1000.0, 1000.0), (x * (a * x + c) + d));
            }
            //-----------------------------------------------------------------------------
            float4 pbr2(v2f i)
            {
                float2 uv = i.uv;
                float4 base = tex2D(_MainTex, uv);

                float3 albedo = base.rgb * _Color.rgb;
                float alpha = base.a * _Color.a;

#ifdef _ALPHATEST_ON
                clip(alpha - _Cutoff - 0.001);
#endif

                float3 mro = tex2D(_MetallicRoughnessOcclusionMap, uv).rgb;
                float metallic = mro.r * _Metallic;
                float roughness = mro.g * _Roughness;
                float ao = mro.b * _Occlusion;

#ifdef _NORMALMAP_ON
                float3 n = normalize(UnpackNormal(tex2D(_NormalMap, i.uv)));

                float3 normal;
                normal.x = dot(i.tspace0.xyz, n);
                normal.y = dot(i.tspace1.xyz, n);
                normal.z = dot(i.tspace2.xyz, n);
                normal = normalize(normal);

                float3 pos = float3(i.tspace0.w, i.tspace1.w, i.tspace2.w);

#else
                float3 normal = normalize(i.normal);
                float3 pos = i.pos;
#endif
				
//face         
#ifdef _CULLOFF_ON
				normal = _face ? normal : -normal;
#endif
				
				

#ifdef _VIEW_SPACE_LIGHTING_ON
                half3 viewDir = normalize(-pos);
#else
                half3 viewDir = normalize(_WorldSpaceCameraPos - pos);
#endif
                float3 lightDir = -normalize(_UseSceneLight > 0.5 ? _GlobalLightDir1 : _LightDir);
                float3 lightColor = _UseSceneLight > 0.5 ? _GlobalLightColor1 : _LightColor * 
					(_UseSceneLight > 0.5 ? _GlobalLightIntensity1 : _LightIntensity);

#ifdef _LIGHT2_ON
                float3 lightDir2 = normalize(-_LightDir2);
                float3 lightColor2 = _LightColor2 * _LightIntensity2;

                const int LightCount = 2;
                float3 lightDirs[LightCount];
                float3 lightColors[LightCount];
                lightDirs[0] = lightDir;
                lightColors[0] = lightColor;
                lightDirs[1] = lightDir2;
                lightColors[1] = lightColor2;
#else
                const int LightCount = 1;
                float3 lightDirs[LightCount];
                float3 lightColors[LightCount];
                lightDirs[0] = lightDir;
                lightColors[0] = lightColor;
#endif

                const float PI = 3.14159265359;
                float3 N = normal;
                float3 V = viewDir;

                float3 R = reflect(-V, N);

                float3 F0 = float3(0.04, 0.04, 0.04);
                F0 = lerp(F0, albedo, metallic);
                float3 Lo = float3(0.0, 0.0, 0.0);

                for (int j = 0; j < LightCount; ++j)
                {
                    float3 L = lightDirs[j];
                    float3 H = normalize(V + L);
                    float3 radiance = lightColors[j];

                    float NDF = DistributionGGX(N, H, roughness);
                    float G = GeometrySmith(N, V, L, roughness);
                    float3 F = fresnelSchlick(max(dot(H, V), 0.0), F0);

                    float3 nominator = NDF * G * F;
                    float denominator = 4 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.001; // 0.001 to prevent divide by zero.
                    float3 specular = nominator / denominator;

                    float3 kS = F;
                    float3 kD = float3(1.0, 1.0, 1.0) - kS;
                    kD *= 1.0 - metallic;

                    float NdotL = max(dot(N, L), 0.0);
                    Lo += (kD * albedo / PI + specular) * radiance * NdotL;
                }

                float3 F = fresnelSchlickRoughness(max(dot(N, V), 0.0), F0, roughness);

                float3 kS = F;
                float3 kD = 1.0 - kS;
                kD *= 1.0 - metallic;

                float3 irradiance = texCUBE(_IrradianceMap, N).rgb;
                float3 diffuse = irradiance * albedo;

                const float MAX_REFLECTION_LOD = 7.0;
                float3 prefilteredColor = texCUBElod(_PrefilterMap, float4(R, roughness * MAX_REFLECTION_LOD)).rgb;
                float2 brdf = tex2D(_BRDF, float2(max(dot(N, V), 0.0), roughness)).rg;
                float3 specular = prefilteredColor * (F * brdf.x + brdf.y);

                float3 ambient = (kD * diffuse + specular) * _IBLExposure * ao;
                float3 color = ambient + Lo;

                float3 emissive = tex2D(_EmissiveMap, uv).rgb * _EmissiveColor.rgb;
#ifdef _EMISSIVE_BLOOM_ON
                float2 ScreenUV = i.screenPos.xy/i.screenPos.w;
                float3 emissive_bloom = _EmissiveBloomIntensity*tex2D(_EmissiveBloomMap, ScreenUV).rgb*_EmissiveBloomColor.rgb;
                emissive+=emissive_bloom;
#endif
                color += emissive;
#ifdef _RIM_ON
                color.rgb += RimColorFunc(N, V, _RimColor.rgb, _RimFallOff);
#endif

#ifdef _IRIDESCENCE_ON
                float3 irid = IridescenceColor(N, V, _IridescenceFallOff, _IridescenceIntensity, _IridescenceSaturation);
                color.rgb += irid;
#endif
                // HDR tonemapping
                color.rgb = LinearToneMapping(color.rgb);
                //color = color / (color + float3(1.0, 1.0, 1.0));
                // gamma correct
                color =  color;
#ifdef _FRESNELAPLPHA_ON
                float fresnel = _fresnelBase + _fresnelScale * pow(1 - dot(N, V), _fresnelIndensity);
                alpha = alpha * fresnel;
#endif              

                return float4(color, alpha);
            }

            float4 frag (v2f i, uint f : SV_isFrontFace) : SV_Target
			{
#ifdef _CULLOFF_ON
				_face = f;	
#endif
				return pbr2(i);
			}
            ENDCG
		}
	}

    CustomEditor "PBR2ShaderGUI"
}