using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine;

public static class RenderFeatureUtils
{
    public static void SetFlashingKeyword()
    {
        var pipelineAsset = GraphicsSettings.currentRenderPipeline as UniversalRenderPipelineAsset;
        if (pipelineAsset == null)
        {
            Debug.LogWarning("No URP pipeline asset found.");
            return;
        }

        var rendererData = pipelineAsset.GetRenderer(0) as ForwardRendererData;
        if (rendererData == null)
        {
            Debug.LogWarning("No UniversalRendererData found in pipeline asset.");
            return;
        }

        foreach (var feature in rendererData.rendererFeatures)
        {
            if (feature != null && feature.name == "CustomPostFeature")
            {
                var customFeature = feature as FullScreenFeature;
                if (customFeature == null)
                {
                    Debug.LogWarning("Render feature found but not of type FullScreenFeature.");
                    return;
                }

                var mat = customFeature
                    .GetType()
                    .GetField("settings", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?
                    .GetValue(customFeature) as FullScreenFeature.FullScreenPassSettings;
                if (mat == null)
                {
                    Debug.LogWarning("CustomPostFeature has no material assigned.");
                    return;
                }
                mat.material.EnableKeyword("Flashing");


                return;
            }
        }

        Debug.LogWarning("CustomPostFeature not found in renderer features.");
    }
}
