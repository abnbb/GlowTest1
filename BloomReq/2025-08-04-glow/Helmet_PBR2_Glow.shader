Shader "OrangeFilter/Helmet_PBR2_Glow"
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
        Tags
        {
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
            "ShaderModel"="4.5"
        }

        Pass{
            Name "predraw"
            Tags{"LightMode"="BlurPrePass"}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define _EmissiveBlurPass
            #include "PBR2GlowCommon.hlsl"
          
            ENDHLSL
        }

		Pass
		{

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            HLSLPROGRAM
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

			#include "PBR2GlowCommon.hlsl"
            ENDHLSL
		}
	}

    CustomEditor "HelmetPBR2GlowShaderGUI"
}