using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Collections.Generic;
using System.Security.Permissions;
using System;


public class GlowBlurRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class BlurSettings
    {
        public float down_scale = 0.004f;
        public float Up_scale = 15.5f;
        public float radius = 0.03f;
        [Range(0,12)]public int iteration= 6;
    }
    public BlurSettings settings;
    class BloomBlurRenderPass : ScriptableRenderPass
    {
        private BlurSettings blursettings;
        private Material blurMat;
        static int _BloomColorID = Shader.PropertyToID("_EmissiveBloomMap");
        static int _CurrentDownSampleTextureID = Shader.PropertyToID("_CurrentDownSampleTexture");

        static int _radiusID = Shader.PropertyToID("_radius");
        static int _Down_texelSize_x = Shader.PropertyToID("_Down_texelSize_x");
        static int _Down_texelSize_y = Shader.PropertyToID("_Down_texelSize_y");
        static int _Up_texelSize_x = Shader.PropertyToID("_Up_texelSize_x");
        static int _Up_texelSize_y = Shader.PropertyToID("_Up_texelSize_y");

        private RenderTargetHandle Handle_InputRT;
        private RenderTargetHandle Handle_blurRT;
        private RenderTargetHandle[] DownSample_RTs;
        private RenderTargetHandle[] UpSample_RTs;

        private RenderTargetHandle Handle_DepthRT;
        ShaderTagId shaderTag = new ShaderTagId("BlurPrePass");

        public BloomBlurRenderPass(BlurSettings bs)
        {
            blursettings = bs;
        }


        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in an performance manner.

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            blurMat = new Material(Shader.Find("Hidden/GlowBlur"));

            blursettings.iteration = Math.Min(12, Math.Max(0, blursettings.iteration));
            Handle_DepthRT.Init("Handle_DepthRT");
            cmd.GetTemporaryRT(Handle_DepthRT.id, cameraTextureDescriptor.width, cameraTextureDescriptor.height, 24, FilterMode.Point, RenderTextureFormat.Depth);
            Handle_InputRT.Init("Handle_InputRT");
            cmd.GetTemporaryRT(Handle_InputRT.id, cameraTextureDescriptor.width, cameraTextureDescriptor.height, 0);
            Handle_blurRT.Init("Handle_blurRT");
            cmd.GetTemporaryRT(Handle_blurRT.id, cameraTextureDescriptor.width, cameraTextureDescriptor.height, 0);


            DownSample_RTs = new RenderTargetHandle[blursettings.iteration];
            UpSample_RTs = new RenderTargetHandle[blursettings.iteration];

            for (int i = 0; i < blursettings.iteration; i++)
            {
                DownSample_RTs[i].Init($"Downsample{i}");
                cmd.GetTemporaryRT(DownSample_RTs[i].id, cameraTextureDescriptor.width, cameraTextureDescriptor.height, 0);
                UpSample_RTs[i].Init($"Upsample{i}");
                cmd.GetTemporaryRT(UpSample_RTs[i].id, cameraTextureDescriptor.width, cameraTextureDescriptor.height, 0);
            }

            ConfigureTarget(Handle_InputRT.id, Handle_DepthRT.id);
            ConfigureClear(ClearFlag.All, Color.black);

            cmd.SetGlobalTexture(_BloomColorID, Handle_blurRT.id);
        }

        // Here you can implement the rendering logic.  
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("Bloom Blur");
            var drawingSettings = CreateDrawingSettings(shaderTag, ref renderingData, SortingCriteria.CommonOpaque);
            var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);

            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);

            blurMat.SetFloat(_Down_texelSize_x, blursettings.down_scale);
            blurMat.SetFloat(_Down_texelSize_y, blursettings.down_scale);

            cmd.Blit(Handle_InputRT.id, DownSample_RTs[0].id);
            cmd.Blit(DownSample_RTs[0].id, DownSample_RTs[1].id, blurMat, 0);
            for (int i = 1; i < blursettings.iteration - 1; i++)
            {
                cmd.Blit(DownSample_RTs[i].id, DownSample_RTs[i + 1].id, blurMat, 1);
            }


            blurMat.SetFloat(_Up_texelSize_x, blursettings.Up_scale);
            blurMat.SetFloat(_Up_texelSize_y, blursettings.Up_scale);
            blurMat.SetFloat(_radiusID, blursettings.radius);

            cmd.SetGlobalTexture(_CurrentDownSampleTextureID, DownSample_RTs[5].Identifier());
            cmd.Blit(null, UpSample_RTs[5].id, blurMat, 2);
            for (int i = blursettings.iteration - 2; i >= 0; i--)
            {
                cmd.SetGlobalTexture(_CurrentDownSampleTextureID, DownSample_RTs[i].Identifier());
                cmd.Blit(UpSample_RTs[i + 1].id, UpSample_RTs[i].id, blurMat, 3);
            }

            cmd.Blit(UpSample_RTs[0].id, Handle_blurRT.id);

            context.ExecuteCommandBuffer(cmd);
            context.Submit();
            CommandBufferPool.Release(cmd);
        }

        /// Cleanup any allocated resources that were created during the execution of this render pass.
        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(Handle_InputRT.id);
            cmd.ReleaseTemporaryRT(Handle_blurRT.id);
            for (int i = 0; i < 6; i++)
            {
                cmd.ReleaseTemporaryRT(DownSample_RTs[i].id);
                cmd.ReleaseTemporaryRT(UpSample_RTs[i].id);
            }
        }
    }

    BloomBlurRenderPass m_ScriptablePass;


    public override void Create()
    {
        m_ScriptablePass = new BloomBlurRenderPass(settings);
        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.BeforeRenderingOpaques;
        
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


