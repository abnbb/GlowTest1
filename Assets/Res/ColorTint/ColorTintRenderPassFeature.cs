using System;
using System.Collections;
using System.Configuration;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ColorTintRenderPassFeature : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        Shader ColorTintShader = null;
        Material ColorTintMat = null;
        static String RenderingTag = "ColorTint";
        static int ColorId = Shader.PropertyToID("_ColorTint");
        private RenderTargetHandle Handle_TempRT;

        RenderTargetIdentifier currentTarget;

        ColorTint colorTint = null;
        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in an performance manner.

        public void setup(Shader shader, RenderTargetIdentifier camerTarget)
        {
            ColorTintShader = shader;
            if (ColorTintShader == null)
            {
                Debug.LogError("no ColorTint shade!");
                return;
            }
            ColorTintMat = CoreUtils.CreateEngineMaterial(ColorTintShader);
            currentTarget = camerTarget;
            
            
        }
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            if (ColorTintMat == null)
            {
                Debug.LogError("no ColorTint material!");
                return;
            }
            var stack = VolumeManager.instance.stack;
            colorTint = stack.GetComponent<ColorTint>();
            if (colorTint == null)
            {
                Debug.LogError("no ColorTint Component!");
                return;
            }
            Handle_TempRT.Init("Handle_TempRT");
            cmd.GetTemporaryRT(Handle_TempRT.id, cameraTextureDescriptor.width, cameraTextureDescriptor.height, 0);
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (!renderingData.cameraData.postProcessEnabled)
            {
                return;
            }
            CommandBuffer cmd = CommandBufferPool.Get(RenderingTag);

            ColorTintMat.SetColor("_ColorTint", colorTint.color.value);
            cmd.Blit(currentTarget, Handle_TempRT.id);
            cmd.Blit(Handle_TempRT.id,currentTarget,ColorTintMat,0);

            context.ExecuteCommandBuffer(cmd);
            context.Submit();
            CommandBufferPool.Release(cmd);
        }

        /// Cleanup any allocated resources that were created during the execution of this render pass.
        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(Handle_TempRT.id);
        }
    }

    CustomRenderPass m_ScriptablePass;

    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent passEvent;
        public Shader ColorTintShader;
    }

    public Settings setting = new Settings();
    public override void Create()
    {
        this.name = "ColorTint RenderFeature";
        m_ScriptablePass = new CustomRenderPass();
        
        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = setting.passEvent;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
        m_ScriptablePass.setup(setting.ColorTintShader,renderer.cameraColorTarget);

    }
}


