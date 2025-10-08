// https://ameye.dev/notes/edge-detection-outlines/

using System;
using System.Diagnostics;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class FullScreenOutline : ScriptableRendererFeature
{
    private class FullScreenOutlinePass : ScriptableRenderPass
    {
        private Material material;
        private RenderTexture renderTexture;

        //private static readonly int OutlineThicknessProperty = Shader.PropertyToID("_OutlineThickness");
        //private static readonly int OutlineColorProperty = Shader.PropertyToID("_OutlineColor");
        //private static readonly int ThresholdNormal = Shader.PropertyToID("_ThresholdNormal");
        //private static readonly int ThresholdDepth = Shader.PropertyToID("_ThresholdDepth");
        //private static readonly int ThresholdLuminance = Shader.PropertyToID("_ThresholdLuminance");

        public FullScreenOutlinePass()
        {
            profilingSampler = new ProfilingSampler(nameof(FullScreenOutlinePass));
        }

        public void Setup(ref FullScreenOutlineSettings settings, ref Material edgeDetectionMaterial, ref RenderTexture rt)
        {
            material = edgeDetectionMaterial;
            renderPassEvent = settings.renderPassEvent;
            renderTexture = rt;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var outlineCmd = CommandBufferPool.Get();

            using (new ProfilingScope(outlineCmd, profilingSampler))
            {
                if (renderTexture != null)
                {
                    CoreUtils.SetRenderTarget(outlineCmd, renderTexture.colorBuffer);
                }
                else
                {
                    CoreUtils.SetRenderTarget(outlineCmd, renderingData.cameraData.renderer.cameraColorTargetHandle);
                }
                outlineCmd.ClearRenderTarget(true, true, Color.black);
                context.ExecuteCommandBuffer(outlineCmd);
                outlineCmd.Clear();

                Blitter.BlitTexture(outlineCmd, Vector2.one, material, 0);
            }

            context.ExecuteCommandBuffer(outlineCmd);
            CommandBufferPool.Release(outlineCmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            if (cmd == null)
            {
                throw new ArgumentNullException(nameof(cmd));
            }
        }
    }

    [Serializable]
    public class FullScreenOutlineSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
        [Range(0, 15)] public int outlineThickness = 1;
        public Color outlineColor = Color.black;
    }

    [SerializeField] private FullScreenOutlineSettings settings;
    public Material edgeDetectionMaterial;
    public RenderTexture RTexture;
    private FullScreenOutlinePass edgeDetectionPass;

    /// <summary>
    /// Called
    /// - When the Scriptable Renderer Feature loads the first time.
    /// - When you enable or disable the Scriptable Renderer Feature.
    /// - When you change a property in the Inspector window of the Renderer Feature.
    /// </summary>
    public override void Create()
    {
        edgeDetectionPass ??= new FullScreenOutlinePass();
    }

    /// <summary>
    /// Called
    /// - Every frame, once for each camera.
    /// </summary>
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // Don't render for some views.
        if (renderingData.cameraData.cameraType is CameraType.Preview or CameraType.Reflection) return;

        if (edgeDetectionMaterial == null)
        {
            //edgeDetectionMaterial = CoreUtils.CreateEngineMaterial(Shader.Find("Edge Detection"));
            if (edgeDetectionMaterial == null)
            {
                UnityEngine.Debug.LogWarning("Not all required materials could be created. Edge Detection will not render.");
                return;
            }
        }

        edgeDetectionPass.ConfigureInput(ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Normal | ScriptableRenderPassInput.Color);
        edgeDetectionPass.Setup(ref settings, ref edgeDetectionMaterial, ref RTexture);

        renderer.EnqueuePass(edgeDetectionPass);
    }

    /// <summary>
    /// Clean up resources allocated to the Scriptable Renderer Feature such as materials.
    /// </summary>
    override protected void Dispose(bool disposing)
    {
        edgeDetectionPass = null;
        CoreUtils.Destroy(edgeDetectionMaterial);
    }
}