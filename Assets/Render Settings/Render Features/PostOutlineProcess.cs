using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using static FullScreenOutline;

public class PostOutlineProcessFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class PostOutlineProcessFeatureSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
        public Material material;
    }

    [SerializeField] private PostOutlineProcessFeatureSettings settings;

    class PostOutlineProcessPass : ScriptableRenderPass
    {
        const string ProfilerTag = "PostOutlineProcessPass";
        PostOutlineProcessFeatureSettings settings;

        public PostOutlineProcessPass()
        {
            profilingSampler = new ProfilingSampler(nameof(PostOutlineProcessPass));
        }

        public void Setup(ref PostOutlineProcessFeatureSettings inSettings)
        {
            settings = inSettings;
        }

        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get();
           
            using (new ProfilingScope(cmd, profilingSampler))
            {
                CoreUtils.SetRenderTarget(cmd, renderingData.cameraData.renderer.cameraColorTargetHandle);

                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                UnityEngine.Debug.Log("Blit");

                Blitter.BlitTexture(cmd, Vector2.one, settings.material, 0);
            }
            // Execute the command buffer and release it.
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            if (cmd == null) throw new ArgumentNullException("cmd");
        }
    }

    PostOutlineProcessPass m_FullScreenPass;
    /// <inheritdoc/>
    public override void Create()
    {
        m_FullScreenPass = new PostOutlineProcessPass();
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // Don't render for some views.
        if (renderingData.cameraData.cameraType is CameraType.Preview or CameraType.Reflection) return;

        if (settings.material == null)
        {
            UnityEngine.Debug.LogWarning("Not all required materials could be created. Post Outline will not render.");
            return;
        }
        m_FullScreenPass.ConfigureInput(ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Normal | ScriptableRenderPassInput.Color);
        m_FullScreenPass.Setup(ref settings);
        renderer.EnqueuePass(m_FullScreenPass);
    }
}


