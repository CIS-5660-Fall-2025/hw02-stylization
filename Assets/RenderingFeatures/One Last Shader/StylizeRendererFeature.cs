using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

internal class StylizeRendererFeature : ScriptableRendererFeature
{
    public Shader m_Shader;

    public Texture2D sketchTexture;
    public Texture2D denseSketchTexture;
    public Texture2D noiseTexture;
    public Texture2D stylizeColorTexture;

    Material m_Material;

    StylizedRendererPass m_RenderPass = null;

    public override void AddRenderPasses(ScriptableRenderer renderer,
                                    ref RenderingData renderingData)
    {
        if (renderingData.cameraData.cameraType == CameraType.Game)
            renderer.EnqueuePass(m_RenderPass);
    }

    public override void SetupRenderPasses(ScriptableRenderer renderer,
                                        in RenderingData renderingData)
    {
        if (renderingData.cameraData.cameraType == CameraType.Game)
        {
            // Calling ConfigureInput with the ScriptableRenderPassInput.Color argument
            // ensures that the opaque texture is available to the Render Pass.
            m_RenderPass.ConfigureInput(ScriptableRenderPassInput.Color);
            m_RenderPass.SetTarget(renderer.cameraColorTargetHandle);
            m_RenderPass.SetTextures(sketchTexture, denseSketchTexture, noiseTexture, stylizeColorTexture);
        }
    }

    public override void Create()
    {
        if (m_Shader == null)
            return;
        m_Material = CoreUtils.CreateEngineMaterial(m_Shader);
        m_RenderPass = new StylizedRendererPass(m_Material);
    }

    protected override void Dispose(bool disposing)
    {
        CoreUtils.Destroy(m_Material);
    }
}
