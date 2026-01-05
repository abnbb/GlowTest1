using System;
using UnityEngine;

namespace UnityEditor
{
    class HelmetPBR2GlowShaderGUI : ShaderGUI
    {
        public enum BlendMode
        {
            Opaque,
            Cutout,
            Transparent,
            Add,
        }

        private static class Styles
        {
            public static string renderMode = "RenderMode";
            public static readonly string[] blendNames = Enum.GetNames(typeof(BlendMode));
        }

        MaterialEditor m_MaterialEditor;
        bool m_FirstTimeApply = true;
        MaterialProperty _Mode = null;
        MaterialProperty _Cutoff = null;
        MaterialProperty _Cull = null;

        MaterialProperty _UVScaleOffset = null;
        MaterialProperty _Color = null;

        MaterialProperty _MainTex = null;
        MaterialProperty _NormalMap = null;
        MaterialProperty _MetallicRoughnessOcclusionMap = null;

        MaterialProperty _Metallic = null;
        MaterialProperty _Roughness = null;
        MaterialProperty _Occlusion = null;

        MaterialProperty _IrradianceMap = null;
        MaterialProperty _PrefilterMap = null;
        MaterialProperty _IBLExposure = null;
        MaterialProperty _BRDF = null;

        MaterialProperty _LightInViewEnable = null;
        MaterialProperty _ShadowMapOn = null;

        MaterialProperty _LightDir = null;
        MaterialProperty _LightColor = null;
        MaterialProperty _LightIntensity = null;
        MaterialProperty _Light2Enable = null;
        MaterialProperty _LightDir2 = null;
        MaterialProperty _LightColor2 = null;
        MaterialProperty _LightIntensity2 = null;

        MaterialProperty _UseSceneLight = null;

        MaterialProperty _FrameCount = null;
        MaterialProperty _FrameX = null;
        MaterialProperty _FrameY = null;
        MaterialProperty _FrameRate = null;
        MaterialProperty _OffsetSpeed = null;

        MaterialProperty _EmissiveMap = null;
        MaterialProperty _EmissiveColor = null;
        MaterialProperty _EmissiveBloomEnable = null;
        MaterialProperty _EmissiveBloomColor = null;
        MaterialProperty _EmissiveBloomIntensity = null;


        MaterialProperty _RIMEnable = null;
        MaterialProperty _RimColor = null;
        MaterialProperty _RimFallOff = null;

        MaterialProperty _IridescenceEnable = null;
        MaterialProperty _IridescenceIntensity = null;
        MaterialProperty _IridescenceFallOff = null;
        MaterialProperty _IridescenceSaturation = null;

        MaterialProperty _FresnelAlphaEnable = null;
        MaterialProperty _fresnelBase = null;
        MaterialProperty _fresnelScale = null;
        MaterialProperty _fresnelIndensity = null;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            FindProperties(props);

            m_MaterialEditor = materialEditor;
            Material material = materialEditor.target as Material;

            if (m_FirstTimeApply)
            {
                MaterialChanged(material);
                m_FirstTimeApply = false;
            }

            ShaderPropertiesGUI(material);
        }

        public void FindProperties(MaterialProperty[] props)
        {
            _Mode = FindProperty("_Mode", props);
            _Cutoff = FindProperty("_Cutoff", props);
            _Cull = FindProperty("_Cull", props);

            _UVScaleOffset = FindProperty("_UVScaleOffset", props);
            _Color = FindProperty("_Color", props);

            _MainTex = FindProperty("_MainTex", props);
            _NormalMap = FindProperty("_NormalMap", props);
            _MetallicRoughnessOcclusionMap = FindProperty("_MetallicRoughnessOcclusionMap", props);

            _Metallic = FindProperty("_Metallic", props);
            _Roughness = FindProperty("_Roughness", props);
            _Occlusion = FindProperty("_Occlusion", props);

            _IrradianceMap = FindProperty("_IrradianceMap", props);
            _PrefilterMap = FindProperty("_PrefilterMap", props);
            _IBLExposure = FindProperty("_IBLExposure", props);
            _BRDF = FindProperty("_BRDF", props);

            // 不强制有该属性, URP 将时使用 Unity 中自建灯光
            _LightInViewEnable = FindProperty("_LightInViewEnable", props, false);
            _ShadowMapOn = FindProperty("_ShadowMapOn", props, false);

            _LightDir = FindProperty("_LightDir", props, false);
            _LightColor = FindProperty("_LightColor", props, false);
            _LightIntensity = FindProperty("_LightIntensity", props, false);
            _Light2Enable = FindProperty("_Light2Enable", props, false);
            _LightDir2 = FindProperty("_LightDir2", props, false);
            _LightColor2 = FindProperty("_LightColor2", props, false);
            _LightIntensity2 = FindProperty("_LightIntensity2", props, false);
            _UseSceneLight = FindProperty("_UseSceneLight", props, false);

            _FrameCount = FindProperty("_FrameCount", props);
            _FrameX = FindProperty("_FrameX", props);
            _FrameY = FindProperty("_FrameY", props);
            _FrameRate = FindProperty("_FrameRate", props);
            _OffsetSpeed = FindProperty("_OffsetSpeed", props);

            _EmissiveMap = FindProperty("_EmissiveMap", props);
            _EmissiveColor = FindProperty("_EmissiveColor", props);
            _EmissiveBloomEnable = FindProperty("_EmissiveBloomEnable", props);
            _EmissiveBloomColor = FindProperty("_EmissiveBloomColor", props);
            _EmissiveBloomIntensity = FindProperty("_EmissiveBloomIntensity", props);

            _RIMEnable = FindProperty("_RIMEnable", props);
            _RimColor = FindProperty("_RimColor", props);
            _RimFallOff = FindProperty("_RimFallOff", props);

            _IridescenceEnable = FindProperty("_IridescenceEnable", props);
            _IridescenceIntensity = FindProperty("_IridescenceIntensity", props);
            _IridescenceFallOff = FindProperty("_IridescenceFallOff", props);
            _IridescenceSaturation = FindProperty("_IridescenceSaturation", props);

            _FresnelAlphaEnable = FindProperty("_FresnelAlphaEnable", props);
            _fresnelBase = FindProperty("_fresnelBase", props);
            _fresnelScale = FindProperty("_fresnelScale", props);
            _fresnelIndensity = FindProperty("_fresnelIndensity", props);
        }

        public void ShaderPropertiesGUI(Material material)
        {
            EditorGUI.BeginChangeCheck();

            BlendModePopup();

            if (((BlendMode)material.GetFloat("_Mode") == BlendMode.Cutout))
            {
                m_MaterialEditor.RangeProperty(_Cutoff, "AlphaCutoff");
            }

            bool cullOff = ((int)_Cull.floatValue) == (int)UnityEngine.Rendering.CullMode.Off;
            cullOff = EditorGUILayout.Toggle("CullOff", cullOff);
            if (cullOff)
            {
                _Cull.floatValue = (int)UnityEngine.Rendering.CullMode.Off;
                material.EnableKeyword("_CULLOFF_ON");
            }
            else
            {
                _Cull.floatValue = (int)UnityEngine.Rendering.CullMode.Back;
                material.DisableKeyword("_CULLOFF_ON");
            }

            m_MaterialEditor.VectorProperty(_UVScaleOffset, "UVScaleOffset");
            m_MaterialEditor.ColorProperty(_Color, "Color");

            m_MaterialEditor.TextureProperty(_MainTex, "MainTex");
            m_MaterialEditor.TextureProperty(_NormalMap, "NormalMap");
            m_MaterialEditor.TextureProperty(_MetallicRoughnessOcclusionMap, "MetallicRoughnessOcclusionMap");

            m_MaterialEditor.RangeProperty(_Metallic, "Metallic");
            m_MaterialEditor.RangeProperty(_Roughness, "Roughness");
            m_MaterialEditor.RangeProperty(_Occlusion, "Occlusion");

            m_MaterialEditor.TextureProperty(_IrradianceMap, "IrradianceMap");
            m_MaterialEditor.TextureProperty(_PrefilterMap, "PrefilterMap");
            m_MaterialEditor.RangeProperty(_IBLExposure, "IBLExposure");
            m_MaterialEditor.TextureProperty(_BRDF, "BRDF");

            if (_LightInViewEnable != null)
            {
                bool lightInView = ((int)_LightInViewEnable.floatValue) == 1;
                lightInView = EditorGUILayout.Toggle("LightInView", lightInView);
                _LightInViewEnable.floatValue = lightInView ? 1.0f : 0.0f;
                SetKeyword(material, "_VIEW_SPACE_LIGHTING_ON", lightInView);
            }

            if (_ShadowMapOn != null)
            {
                bool shadow = ((int)_ShadowMapOn.floatValue) == 1;
                shadow = EditorGUILayout.Toggle("ShadowMapOn?", shadow);
                _ShadowMapOn.floatValue = shadow ? 1.0f : 0.0f;
                SetKeyword(material, "_SHADOWMAP_ON", shadow);
            }

            if (_UseSceneLight != null)
            {
                bool bUseSceneLight = EditorGUILayout.Toggle("UseSceneLight", ((int)_UseSceneLight.floatValue) == 1);
                _UseSceneLight.floatValue = bUseSceneLight ? 1.0f : 0.0f;
                if (!bUseSceneLight)
                {
                    m_MaterialEditor.VectorProperty(_LightDir, "LightDir");
                    m_MaterialEditor.ColorProperty(_LightColor, "LightColor");
                    m_MaterialEditor.RangeProperty(_LightIntensity, "LightIntensity");
                }
            }

            if (_Light2Enable != null)
            {
                bool light2 = ((int)_Light2Enable.floatValue) == 1;
                light2 = EditorGUILayout.Toggle("Light2", light2);
                _Light2Enable.floatValue = light2 ? 1.0f : 0.0f;
                SetKeyword(material, "_LIGHT2_ON", light2);
                if (light2)
                {
                    m_MaterialEditor.VectorProperty(_LightDir2, "LightDir2");
                    m_MaterialEditor.ColorProperty(_LightColor2, "LightColor2");
                    m_MaterialEditor.RangeProperty(_LightIntensity2, "LightIntensity2");
                }
            }

            m_MaterialEditor.TextureProperty(_EmissiveMap, "EmissiveMap");
            m_MaterialEditor.ColorProperty(_EmissiveColor, "EmissiveColor");


            bool EmissiveBloom = ((int)_EmissiveBloomEnable.floatValue) == 1;
            EmissiveBloom = EditorGUILayout.Toggle("Emissive Bloom", EmissiveBloom);
            _EmissiveBloomEnable.floatValue = EmissiveBloom ? 1.0f : 0.0f;
            SetKeyword(material, "_EMISSIVE_BLOOM_ON", EmissiveBloom);
            if (EmissiveBloom) {
                m_MaterialEditor.ColorProperty(_EmissiveBloomColor, "_EmissiveBloomColor");
                m_MaterialEditor.RangeProperty(_EmissiveBloomIntensity, "_EmissiveBloomIntensity");
            }

            bool rim = ((int)_RIMEnable.floatValue) == 1;
            rim = EditorGUILayout.Toggle("RIMEnable", rim);
            _RIMEnable.floatValue = rim ? 1.0f : 0.0f;
            SetKeyword(material, "_RIM_ON", rim);
            if (rim)
            {
                m_MaterialEditor.ColorProperty(_RimColor, "RimColor");
                m_MaterialEditor.RangeProperty(_RimFallOff, "RimFallOff");
            }

            bool iridescence = ((int)_IridescenceEnable.floatValue) == 1;
            iridescence = EditorGUILayout.Toggle("IridesceneEnable", iridescence);
            _IridescenceEnable.floatValue = iridescence ? 1.0f : 0.0f;
            SetKeyword(material, "_IRIDESCENCE_ON", iridescence);
            if (iridescence)
            {
                m_MaterialEditor.RangeProperty(_IridescenceIntensity, "IridescenceIntensity");
                m_MaterialEditor.RangeProperty(_IridescenceFallOff, "IridescenceFallOff");
                m_MaterialEditor.RangeProperty(_IridescenceSaturation, "IridescenceSaturation");
            }

            bool fresnelalpha = ((int)_FresnelAlphaEnable.floatValue) == 1;
            fresnelalpha = EditorGUILayout.Toggle("FresnelAlphaEnable", fresnelalpha);
            _FresnelAlphaEnable.floatValue = fresnelalpha ? 1.0f : 0.0f;
            SetKeyword(material, "_FRESNELAPLPHA_ON", fresnelalpha);
            if (fresnelalpha)
            {
                m_MaterialEditor.RangeProperty(_fresnelBase, "fresnelBase");
                m_MaterialEditor.RangeProperty(_fresnelScale, "fresnelScale");
                m_MaterialEditor.RangeProperty(_fresnelIndensity, "fresnelIndensity");
            }

            int frameCount = (int)_FrameCount.floatValue;
            frameCount = EditorGUILayout.IntField("FrameCount", frameCount);
            frameCount = Mathf.Max(frameCount, 1);
            _FrameCount.floatValue = frameCount;
            SetKeyword(material, "_FRAME_ANIM_ON", frameCount > 1);
            if (frameCount > 1)
            {
                _FrameX.floatValue = EditorGUILayout.IntField("FrameX", (int)_FrameX.floatValue);
                _FrameY.floatValue = EditorGUILayout.IntField("FrameY", (int)_FrameY.floatValue);
                _FrameRate.floatValue = Mathf.Max(EditorGUILayout.FloatField("FrameRate", _FrameRate.floatValue), 0.0f);
            }

            m_MaterialEditor.VectorProperty(_OffsetSpeed, "OffsetSpeed");
            SetKeyword(material, "_OFFSET_ANIM_ON", _OffsetSpeed.vectorValue != Vector4.zero);

            if (EditorGUI.EndChangeCheck())
            {
                foreach (var obj in _Mode.targets)
                    MaterialChanged((Material)obj);
            }
        }

        void BlendModePopup()
        {
            EditorGUI.showMixedValue = _Mode.hasMixedValue;
            var mode = (BlendMode)_Mode.floatValue;

            EditorGUI.BeginChangeCheck();
            mode = (BlendMode)EditorGUILayout.Popup(Styles.renderMode, (int)mode, Styles.blendNames);
            if (EditorGUI.EndChangeCheck())
            {
                m_MaterialEditor.RegisterPropertyChangeUndo("RenderMode");
                _Mode.floatValue = (float)mode;
            }

            EditorGUI.showMixedValue = false;
        }

        static void MaterialChanged(Material material)
        {
            SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));
            SetKeyword(material, "_NORMALMAP_ON", material.GetTexture("_NormalMap"));
        }

        public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
        {
            switch (blendMode)
            {
                case BlendMode.Opaque:
                    material.SetOverrideTag("RenderType", "");
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    material.SetInt("_ZWrite", 1);
                    material.DisableKeyword("_ALPHATEST_ON");
                    material.DisableKeyword("_ALPHABLEND_ON");
                    material.DisableKeyword("_ALPHABLEND_ADD_ON");
                    material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    material.renderQueue = -1;
                    break;
                case BlendMode.Cutout:
                    material.SetOverrideTag("RenderType", "TransparentCutout");
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    material.SetInt("_ZWrite", 1);
                    material.EnableKeyword("_ALPHATEST_ON");
                    material.DisableKeyword("_ALPHABLEND_ON");
                    material.DisableKeyword("_ALPHABLEND_ADD_ON");
                    material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    break;
                case BlendMode.Transparent:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    material.SetInt("_ZWrite", 0);
                    material.DisableKeyword("_ALPHATEST_ON");
                    material.EnableKeyword("_ALPHABLEND_ON");
                    material.DisableKeyword("_ALPHABLEND_ADD_ON");
                    material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
                case BlendMode.Add:
                    material.SetOverrideTag("RenderType", "Transparent");
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_ZWrite", 0);
                    material.DisableKeyword("_ALPHATEST_ON");
                    material.EnableKeyword("_ALPHABLEND_ON");
                    material.EnableKeyword("_ALPHABLEND_ADD_ON");
                    material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
            }
        }

        static void SetKeyword(Material m, string keyword, bool state)
        {
            if (state)
                m.EnableKeyword(keyword);
            else
                m.DisableKeyword(keyword);
        }
    }
}