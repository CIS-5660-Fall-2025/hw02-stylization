using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

// This Render Feature is responsible for blitting the camera's color buffer to a specified Render Texture.
public class BlitToTextureRenderFeature : ScriptableRendererFeature
{
    // A nested class for the settings of our render feature.
    // Making it a class allows it to be neatly organized in the Inspector.
    [System.Serializable]
    public class BlitSettings
    {
        // When in the render pipeline should this pass execute?
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRendering;

        // The Render Texture to which the camera's output will be copied.
        public RenderTexture destinationTexture = null;
    }

    // Public field for the settings. Unity will serialize this and show it in the Inspector.
    public BlitSettings settings = new BlitSettings();

    // The custom render pass that will perform the blit operation.
    private BlitPass blitPass;

    // Called once when the feature is created (e.g., when the game starts or the asset is inspected).
    public override void Create()
    {
        // Create an instance of our custom render pass, passing in the settings.
        blitPass = new BlitPass(settings);
    }

    // Called every frame for each camera. This is where you inject the render pass into the pipeline.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // We don't want to add the pass if the user hasn't specified a destination texture.
        if (settings.destinationTexture == null)
        {
            Debug.LogWarningFormat("Blit Render Feature on {0} is missing a destination texture. The pass will not be added.");
            return;
        }

        // Add our blit pass to the renderer's queue of passes.
        renderer.EnqueuePass(blitPass);
    }

    // --- The actual Render Pass implementation ---
    private class BlitPass : ScriptableRenderPass
    {
        private BlitSettings m_Settings;
        private RenderTargetIdentifier m_SourceIdentifier;

        // Constructor that takes the settings as a parameter.
        public BlitPass(BlitSettings settings)
        {
            this.m_Settings = settings;
            // Set the render pass event from the settings.
            this.renderPassEvent = settings.renderPassEvent;
        }

        // This method is called by the renderer before executing the pass.
        // It allows us to configure the render targets and clear flags.
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            // Get the camera's color buffer identifier. This is the source of our blit.
            m_SourceIdentifier = renderingData.cameraData.renderer.cameraColorTarget;
        }

        // This is the core method where the rendering logic happens.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            // Get a command buffer from the pool.
            CommandBuffer cmd = CommandBufferPool.Get("BlitPass");

            // Perform the blit.
            // This command copies the source texture to the destination texture.
            Blit(cmd, m_SourceIdentifier, m_Settings.destinationTexture);

            // Execute the command buffer and release it back to the pool.
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }
}