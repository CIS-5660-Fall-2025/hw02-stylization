using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PaperOverlayFeature : ScriptableRendererFeature
{
    [Serializable]
    public class Settings
    {
       
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
        public Material material; 
    }

    class PaperOverlayPass : ScriptableRenderPass
    {
        const string k_ProfilerTag = "Paper Overlay (FullScreen)";
        readonly Settings settings;

        RenderTargetIdentifier source;
        RenderTargetIdentifier tempRT;
        int tempRTId = Shader.PropertyToID("_PaperOverlay_Temp");

        public PaperOverlayPass(Settings s) { settings = s; renderPassEvent = s.renderPassEvent; }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            source = renderingData.cameraData.renderer.cameraColorTarget;

            var desc = renderingData.cameraData.cameraTargetDescriptor;
            desc.depthBufferBits = 0; 
            cmd.GetTemporaryRT(tempRTId, desc, FilterMode.Bilinear);
            tempRT = new RenderTargetIdentifier(tempRTId);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (settings.material == null) return;

            CommandBuffer cmd = CommandBufferPool.Get(k_ProfilerTag);

            Blit(cmd, source, tempRT, settings.material, 0);

            Blit(cmd, tempRT, source);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            if (cmd == null) return;
            cmd.ReleaseTemporaryRT(tempRTId);
        }
    }

    public Settings settings = new Settings();
    PaperOverlayPass pass;

    public override void Create()
    {
        pass = new PaperOverlayPass(settings);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (renderingData.cameraData.cameraType != CameraType.Game) return; 
        if (settings.material == null) return;
        renderer.EnqueuePass(pass);
    }
}
