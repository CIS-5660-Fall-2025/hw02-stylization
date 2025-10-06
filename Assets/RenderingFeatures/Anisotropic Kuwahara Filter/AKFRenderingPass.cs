using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

internal class AKFRenderingPass : ScriptableRenderPass
{
    ProfilingSampler m_ProfilingSampler = new ProfilingSampler("ColorBlit");
    Material m_Material;
    RTHandle m_CameraColorTarget;
    RTHandle m_TemporaryColorTexture;

    int m_KernelSize;
    int m_Sectors;
    Vector2 m_SamplesPerSector;
    float m_Anisotropicity;

    public AKFRenderingPass(Material material)
    {
        m_Material = material;
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public void SetTarget(RTHandle colorHandle, int kernelSize, int sectors, Vector2 samplesPerSector, float anisotropicity)
    {
        m_CameraColorTarget = colorHandle;
        m_KernelSize = kernelSize;
        m_Sectors = sectors;
        m_SamplesPerSector = samplesPerSector;
        m_Anisotropicity = anisotropicity;
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        var desc = renderingData.cameraData.cameraTargetDescriptor;
        desc.depthBufferBits = 0;
        RenderingUtils.ReAllocateIfNeeded(ref m_TemporaryColorTexture, desc, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "_TempColorTex2");

        ConfigureTarget(m_CameraColorTarget);
        ConfigureInput(ScriptableRenderPassInput.Color | ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Normal);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        var cameraData = renderingData.cameraData;
        if (cameraData.camera.cameraType != CameraType.Game)
            return;

        if (m_Material == null)
            return;

        CommandBuffer cmd = CommandBufferPool.Get();
        using (new ProfilingScope(cmd, m_ProfilingSampler))
        {
            var cameraTargetDescriptor = renderingData.cameraData.cameraTargetDescriptor;
            Vector4 texelSize = new Vector4(
                1.0f / cameraTargetDescriptor.width,
                1.0f / cameraTargetDescriptor.height,
                cameraTargetDescriptor.width,
                cameraTargetDescriptor.height
            );
            m_Material.SetVector("_TexelSize", texelSize);

            m_Material.SetFloat("_KernelSize", m_KernelSize);
            m_Material.SetFloat("_Sectors", m_Sectors);
            m_Material.SetVector("_SamplesPerSector", m_SamplesPerSector);
            m_Material.SetFloat("_Anisotropicity", m_Anisotropicity);

            //Blitter.BlitCameraTexture(cmd, m_CameraColorTarget, m_CameraColorTarget, m_Material, 0);
            Blitter.BlitCameraTexture(cmd, m_CameraColorTarget, m_TemporaryColorTexture);
            Blitter.BlitCameraTexture(cmd, m_TemporaryColorTexture, m_CameraColorTarget, m_Material, 0);
        }
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();

        CommandBufferPool.Release(cmd);
    }
}

