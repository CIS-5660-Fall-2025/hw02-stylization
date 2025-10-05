using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

internal class AKFRendererFeature : ScriptableRendererFeature
{
    public Shader m_Shader;

    public int m_KernelSize = 5;
    public int m_Sectors = 8;
    public Vector2 m_SamplesPerSector = new Vector2(4, 4);
    [Range(0f, 1f)]
    public float m_Anisotropicity = 0.5f;

    Material m_Material;

    AKFRenderingPass m_RenderPass = null;

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
            m_RenderPass.SetTarget(renderer.cameraColorTargetHandle, m_KernelSize, m_Sectors, m_SamplesPerSector, m_Anisotropicity);
        }
    }

    public override void Create()
    {
        if (m_Shader == null)
            return;
        m_Material = CoreUtils.CreateEngineMaterial(m_Shader);
        m_RenderPass = new AKFRenderingPass(m_Material);
    }

    protected override void Dispose(bool disposing)
    {
        CoreUtils.Destroy(m_Material);
    }
}
