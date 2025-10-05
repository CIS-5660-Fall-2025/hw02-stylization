using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;

internal class WhiteScreenRendererPass : ScriptableRenderPass
{
    ProfilingSampler m_ProfilingSampler = new ProfilingSampler("White Screen");

    Material m_Material;
    RTHandle m_CameraColorTarget;
    RTHandle m_TemporaryColorTexture;

    float m_Intensity;

    public WhiteScreenRendererPass(Material material)
    {
        m_Material = material;
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public void SetTarget(RTHandle colorHandle, float intensity)
    {
        m_CameraColorTarget = colorHandle;
        m_Intensity = intensity;
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        var desc = renderingData.cameraData.cameraTargetDescriptor;
        desc.depthBufferBits = 0;
        RenderingUtils.ReAllocateIfNeeded(ref m_TemporaryColorTexture, desc, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "_TempColorTexWhite");

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
            m_Material.SetFloat("_Intensity", m_Intensity);

            Blitter.BlitCameraTexture(cmd, m_CameraColorTarget, m_TemporaryColorTexture);
            Blitter.BlitCameraTexture(cmd, m_TemporaryColorTexture, m_CameraColorTarget, m_Material, 0);
        }
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();

        CommandBufferPool.Release(cmd);
    }
}
