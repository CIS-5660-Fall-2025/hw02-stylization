using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Render_Settings.Render_Features
{
    public class SobelEdgeFeature : ScriptableRendererFeature
    {
        public Material sobelMaterial;
        private SobelPass sobelPass;

        // The nested pass class
        public class SobelPass : ScriptableRenderPass
        {
            private Material sobelMaterial;
            // Changed from RenderTargetIdentifier to RTHandle
            private RTHandle cameraColorTarget; 

            public SobelPass(Material material)
            {
                this.sobelMaterial = material;
                // Run after all transparent objects have been drawn
                renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
            }

            // THIS IS THE FIX: This method is called by the renderer before executing the pass.
            // It provides a handle to the camera's textures.
            public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
            {
                // Get the camera's color target.
                cameraColorTarget = renderingData.cameraData.renderer.cameraColorTargetHandle;
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                // It's good practice to exit immediately if the material is missing
                if (sobelMaterial == null)
                {
                    return;
                }

                CommandBuffer cmd = CommandBufferPool.Get("Sobel Outline Pass");

                // Use the RTHandle we got in OnCameraSetup
                Blit(cmd, cameraColorTarget, cameraColorTarget, sobelMaterial);

                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }
        }
        
        // This method creates the pass
        public override void Create()
        {
            sobelPass = new SobelPass(sobelMaterial);
        }

        // This method adds the pass to the renderer's queue
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (sobelMaterial == null) return;

            // We no longer call Setup here. We just add the pass.
            renderer.EnqueuePass(sobelPass);
        }
    }
}