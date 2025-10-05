using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;

internal class WhiteScreenRendererFeature : ScriptableRendererFeature
{
    public Shader m_Shader;

    [Range(0f, 1f)]
    public float m_Intensity;

    Material m_Material;

    WhiteScreenRendererPass m_RenderPass = null;

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
            m_RenderPass.SetTarget(renderer.cameraColorTargetHandle, m_Intensity);
        }
    }

    public override void Create()
    {
        if (m_Shader == null)
            return;
        m_Material = CoreUtils.CreateEngineMaterial(m_Shader);
        m_RenderPass = new WhiteScreenRendererPass(m_Material);
    }

    protected override void Dispose(bool disposing)
    {
        CoreUtils.Destroy(m_Material);
    }
}
