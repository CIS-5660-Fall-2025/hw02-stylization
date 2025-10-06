using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

internal class StylizedRendererPass : ScriptableRenderPass
{
    ProfilingSampler m_ProfilingSampler = new ProfilingSampler("Stylize");

    Material m_Material;
    RTHandle m_CameraColorTarget;
    RTHandle m_TemporaryColorTexture1;
    RTHandle m_TemporaryColorTexture2;

    Texture2D sketchTexture;
    Texture2D denseSketchTexture;
    Texture2D noiseTexture;
    Texture2D stylizeColorTexture;

    public StylizedRendererPass(Material material)
    {
        m_Material = material;
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public void SetTarget(RTHandle colorHandle)
    {
        m_CameraColorTarget = colorHandle;
    }

    public void SetTextures(Texture2D sketch, Texture2D dense, Texture2D noise, Texture2D color)
    {
        sketchTexture = sketch;
        denseSketchTexture = dense;
        noiseTexture = noise;
        stylizeColorTexture = color;
    }

    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        var desc = renderingData.cameraData.cameraTargetDescriptor;
        desc.depthBufferBits = 0;
        RenderingUtils.ReAllocateIfNeeded(ref m_TemporaryColorTexture1, desc, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "_TempColorTex1");
        RenderingUtils.ReAllocateIfNeeded(ref m_TemporaryColorTexture2, desc, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "_TempColorTex2");

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

            if (sketchTexture != null)
            {
                m_Material.SetTexture("_SketchTex", sketchTexture);
            }
            if (denseSketchTexture != null)
            {
                m_Material.SetTexture("_DenseSketchTex", denseSketchTexture);
            }
            if (noiseTexture != null)
            {
                m_Material.SetTexture("_NoiseTex", noiseTexture);
            }
            if (stylizeColorTexture != null)
            {
                m_Material.SetTexture("_StylizeColorLUT", stylizeColorTexture);
            }
            



            //Blitter.BlitTexture(cmd, m_CameraColorTarget, m_CameraColorTarget, m_Material, 0);
            Blitter.BlitCameraTexture(cmd, m_CameraColorTarget, m_TemporaryColorTexture1);
            Blitter.BlitCameraTexture(cmd, m_TemporaryColorTexture1, m_TemporaryColorTexture2, m_Material, 0);
            Blitter.BlitCameraTexture(cmd, m_TemporaryColorTexture2, m_CameraColorTarget, m_Material, 1);
        }
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();

        CommandBufferPool.Release(cmd);
    }
}

