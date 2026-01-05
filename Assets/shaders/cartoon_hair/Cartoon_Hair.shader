Shader "OrangeFilter/Cartoon/Cartoon_Hair"
{
    Properties
    {
		_UVScaleOffset("UVScaleOffset", Vector) = (1, 1, 0, 0)
		_FrameCount("FrameCount", Int) = 1
		_FrameX("FrameX", Int) = 1
		_FrameY("FrameY", Int) = 1
		_FrameRate("FrameRate", float) = 1.0

		_OffsetSpeed("OffsetSpeed", Vector) = (0, 0, 0, 0)
		[NoScaleOffset] _MainTex("MainTex", 2D) = "white" {}
		[NoScaleOffset] _SpecularTex ("SpecularMap", 2D) = "white" {}
		[NoScaleOffset] _ShadowTex ("ShadowMap", 2D) = "white" {}
		[NoScaleOffset] _IrradianceMap ("IrradianceMap", Cube) = "white" {}
		_AmbientTint ("Ambient Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_BaseColor ("Base Color", Color) = (0.9852941, 0.8838668, 0.8838668, 1.0)
		
		_Cutoff ("Cutoff", Range(0, 1)) = 0.25
		_LightDir1 ("LightDir1", Vector) = (0, 0, 1, 0)
		_LightColor1 ("LightColor1", Color) = (1.0, 1.0, 1.0, 1.0)
		_LightDir2 ("LightDir2", Vector) = (0, 0, -1, 0)
		_LightColor2 ("LightColor2", Color) = (1.0, 1.0, 1.0, 1.0)
		
		_ShadeColor ("Shade Color", Color) = (0.4411765, 0, 0.06389464, 1.0)
		
		_AmbientIntensity ("Ambient Intensity", Range(0, 1)) = 1
		_Smoothness1 ("Smoothness1", Range(0, 1)) = 1
		_Smoothness2 ("Smoothness2", Range(0, 1)) = 1
		_Fresnel ("Fresnel", Range(0, 1)) = 0.2
		
		_Shift1 ("Shift1", Range(0, 1)) = 0.25
		_Shift2 ("Shift2", Range(0, 1)) = 0.5
		_SpecularColor1 ("SpecularColor1", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecularColor2 ("SpecularColor2", Color) = (1.0, 1.0, 1.0, 1.0)
		_DisturbIntensity ("Disturb Intensity", Range(0, 2)) = 0.25
    }
	
	CGINCLUDE
	#pragma shader_feature _FRAME_ANIM_ON
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
		float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
		float3 worldNormal : TEXCOORD1;
		float3 worldTangent : TEXCOORD2;
		float3 worldPos : TEXCOORD3;
    };

    sampler2D _MainTex;
	sampler2D _SpecularTex;
	sampler2D _ShadowTex;
	samplerCUBE _IrradianceMap;
	
    float4 _MainTex_ST;
	float4 _AmbientTint;
	float4 _BaseColor;
	
	float4 _LightDir1;
	float4 _LightColor1;
	float4 _LightDir2;
	float4 _LightColor2;
	
	float _Cutoff;
	float4 _UVScaleOffset;
	
	float4 _ShadeColor;
	
	float _Smoothness1;
	float _Smoothness2;
	float _AmbientIntensity;
	
	float _Fresnel;
	float _Shift1;
	float _Shift2;
	float4 _SpecularColor1;
	float4 _SpecularColor2;
	float _DisturbIntensity;
	

    v2f vert (appdata v)
    {
        v2f o;
		float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
		float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
		
        o.vertex = mul(unity_MatrixVP, worldPos);
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
        //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		o.worldNormal = UnityObjectToWorldNormal(v.normal);
		o.worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent));
		o.worldPos = worldPos;
		
        return o;
    }
	
    fixed4 frag (v2f i, fixed Facing, float4 albedo)
    {
		float faceDir = Facing > 0 ? 1.0 : -1.0;
		float4 basePow2 = albedo * albedo;
		
		float4 specular = tex2D(_SpecularTex, float2(i.uv.x, i.uv.y));
		
		float specW = specular.w * 2.0 + -1.0;  //remark to -1 ~ 1
		
		float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
		float3 normal = i.worldNormal * faceDir;
		float3 irradiance = texCUBE(_IrradianceMap, normal).rgb;
		
		float3 envColor = Facing > 0 ? irradiance * _AmbientTint.xyz : irradiance;
		
		float3 lightDir1 = normalize(_LightDir1.xyz);
		float3 halfDir = normalize(viewDir + lightDir1);
		float NL = dot(normal, lightDir1);
		float bNL = max(dot(-normal, lightDir1), 0.0);
		NL = min(max(abs(NL), bNL), 1.0); 
		
		float3 shadeCol = 1.0 - _ShadeColor.xyz;
		shadeCol = NL * shadeCol + _ShadeColor.xyz;
		
		float NL2 = max(dot(normal, normalize(_LightDir2.xyz)), 0.0);
		envColor = envColor * _AmbientIntensity;
		envColor = _LightColor1.xyz * shadeCol + envColor;
		
		float3 light2 = _LightColor2.xyz * specular.x * NL2 * basePow2 * 0.5;
		float3 specularCol = light2 / (light2 + 1.0);
		float3 color = envColor * basePow2 + specularCol;
		
		float roughness1 = 1.0 - _Smoothness1;
		float roughness2 = 1.0 - _Smoothness2;
		float r1 = roughness1 * roughness1;
		float r2 = roughness2 * roughness2;
		
		float rr1 = max(r1 * r1, 9.99999975e-05);
		rr1 = max(2.0 / rr1 - 2.0, 9.99999975e-05);
		float rr2 = max(r2 * r2, 9.99999975e-05);
		rr2 = max(2.0 / rr2 - 2.0, 9.99999975e-05);
		
		float fresnelScale = _Smoothness1 * 0.6 + _Fresnel;
		fresnelScale = min(fresnelScale, 1.0);
		float fresnelScaleOut = 1 - fresnelScale;
		
		float VN = clamp(dot(viewDir, normal), 0.0, 1.0);
		float fresnel = 1 - VN;
		fresnel = fresnel * fresnel;
		fresnel = fresnel * fresnel * (1 - VN);
		fresnel = fresnel * fresnelScaleOut + fresnelScale;
		
		float tangentOffset1 = specW * _DisturbIntensity + _Shift1;
		float3 tangent1 = normalize(normal * tangentOffset1 + i.worldTangent);
		float tangentIntensity1 = dot(tangent1, halfDir);
		tangentIntensity1 = max(1 - (tangentIntensity1 * tangentIntensity1), 0.0);
		tangentIntensity1 = pow(tangentIntensity1, rr1 / 2);
		
		//float tangentOffset2 = specW * _DisturbIntensity + _Shift2;
		//float3 tangent2 = normalize(tangentOffset2 * normal + i.worldTangent);
        float3 tangent2 = normalize(i.worldTangent - _Shift2 * normal);
		float tangentIntensity2 = dot(tangent2, halfDir);
		tangentIntensity2 = max(1 - (tangentIntensity2 * tangentIntensity2), 0.0);
		tangentIntensity2 = pow(tangentIntensity2, rr2 / 2) * specular.x;
		
		float3 hightLight = tangentIntensity1 * _SpecularColor1.xyz;
		hightLight += tangentIntensity2 * _SpecularColor2.xyz;
		hightLight = hightLight * specular * specular * _LightColor1.xyz * fresnel;
		color += hightLight;

		//float shadow = tex2D(_ShadowTex, float2(i.uv.x, i.uv.y * 4));
		//color.xyz *= shadow;	
        return float4(color, albedo.w);
    }
	
	fixed4 frag_opaque (v2f i, fixed Facing : VFACE) : SV_Target
    {
		float4 albedo = tex2D(_MainTex, i.uv) * _BaseColor;
		float cutoff = albedo.w - _Cutoff;
		clip(cutoff);
		
		return frag(i, Facing, albedo);
	}
	
	fixed4 frag_transparent (v2f i, fixed Facing : VFACE) : SV_Target
    {
		float4 albedo = tex2D(_MainTex, i.uv) * _BaseColor;
		float cutoff = _Cutoff - albedo.w;
		clip(cutoff);
		
		return frag(i, Facing, albedo);
	}
	
    ENDCG
	
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 100

        Pass
        {
            Tags{ "LightMode" = "LightweightForward" }
			cull off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_opaque

            ENDCG
        }
		
		Pass
        {
            Tags{ "LightMode" = "SRPDefaultUnlit" }
			cull off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_transparent
            ENDCG
        }
    }
}

//float4 base = tex2D(_MainTex, i.uv);
//float4 albedo = 0.0;
//albedo.rgb = pow(base.rgb, 2.2) * pow(_BaseColor.rgb, 2.2);
