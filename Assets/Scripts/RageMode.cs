using System.Collections.Generic;
using UnityEngine;

public class RageModePostFX : MonoBehaviour
{
    [Header("Outline PostFX (Material used by your FullScreenFeature)")]
    [Tooltip("Drag the SAME material instance that your URP FullScreen Feature uses for outlines.")]
    public Material outlineMaterial;

    [Header("Camera")]
    public Camera mainCamera;
    public float normalFOV = 60f;
    public float rageFOV = 40f;
    public float zoomLerp = 6f;

    [Header("Lights")]
    public List<Light> sceneLights = new List<Light>();
    public float rageMinIntensity = 2f;

    // Outline Property Names
    readonly string propLineColor = "_LineColor";
    readonly string propDepthThicknessPx = "DepthThicknessPx";
    readonly string propNormalThicknessPx = "NormalThicknessPx";
    readonly string propWobbleAmpPx = "WobbleAmpPx";
    readonly string propWobbleFreq = "WobbleFreq";
    readonly string propWobbleSpeed = "WobbleSpeed";
    readonly string propDepthWeight = "DepthWeight";
    readonly string propNormalWeight = "NormalWeight";

    //NORMAL Mode Values
    Color lineColorNormal = new Color(0.10f, 0.10f, 0.10f);
    readonly float depthThicknessPxNormal = 1.6f;
    readonly float normalThicknessPxNormal = 0.9f;
    readonly float wobbleAmpPxNormal = 0.9f;
    readonly float wobbleFreqNormal = 100f;
    readonly float wobbleSpeedNormal = 0.9f;
    readonly float depthWeightNormal = 1.0f;
    readonly float normalWeightNormal = 0.35f;

    [Header("RAGE Mode Values")]
    public Color lineColorRage = Color.red;
    public float depthThicknessPxRage = 2.2f;
    public float normalThicknessPxRage = 1.0f;
    public float wobbleAmpPxRage = 1.4f;
    public float wobbleFreqRage = 110f;
    public float wobbleSpeedRage = 1.2f;
    public float depthWeightRage = 1.0f;
    public float normalWeightRage = 0.20f;

    bool rage;
    float targetFOV;
    struct LightState { public Color color; public float intensity; }
    readonly Dictionary<Light, LightState> originalLightState = new Dictionary<Light, LightState>();

    int idLineColor, idDepthThick, idNormalThick, idWobbleAmp, idWobbleFreq, idWobbleSpeed, idDepthWeight, idNormalWeight;

    void Awake()
    {
        if (mainCamera == null) mainCamera = Camera.main;
        targetFOV = normalFOV;

        if (sceneLights.Count == 0)
            sceneLights.AddRange(FindObjectsOfType<Light>(true));

        CacheLightState();

        idLineColor = Shader.PropertyToID(propLineColor);
        idDepthThick = Shader.PropertyToID(propDepthThicknessPx);
        idNormalThick = Shader.PropertyToID(propNormalThicknessPx);
        idWobbleAmp = Shader.PropertyToID(propWobbleAmpPx);
        idWobbleFreq = Shader.PropertyToID(propWobbleFreq);
        idWobbleSpeed = Shader.PropertyToID(propWobbleSpeed);
        idDepthWeight = Shader.PropertyToID(propDepthWeight);
        idNormalWeight = Shader.PropertyToID(propNormalWeight);

        ApplyOutlineValues(false);
        ApplyLights(false);
        SnapCameraFOV(false);
    }

    void Update()
    {
        if (Input.anyKeyDown)
        {
            rage = !rage;
            ApplyOutlineValues(rage);
            ApplyLights(rage);
            targetFOV = rage ? rageFOV : normalFOV;
        }

        if (mainCamera != null)
        {
            mainCamera.fieldOfView = Mathf.Lerp(mainCamera.fieldOfView, targetFOV, Time.deltaTime * Mathf.Max(zoomLerp, 0.01f));
        }
    }

    void ApplyOutlineValues(bool isRage)
    {
        if (outlineMaterial == null) return;

        if (outlineMaterial.HasProperty(idLineColor))
            outlineMaterial.SetColor(idLineColor, isRage ? lineColorRage : lineColorNormal);

        TrySetFloat(outlineMaterial, idDepthThick, isRage ? depthThicknessPxRage : depthThicknessPxNormal);
        TrySetFloat(outlineMaterial, idNormalThick, isRage ? normalThicknessPxRage : normalThicknessPxNormal);
        TrySetFloat(outlineMaterial, idWobbleAmp, isRage ? wobbleAmpPxRage : wobbleAmpPxNormal);
        TrySetFloat(outlineMaterial, idWobbleFreq, isRage ? wobbleFreqRage : wobbleFreqNormal);
        TrySetFloat(outlineMaterial, idWobbleSpeed, isRage ? wobbleSpeedRage : wobbleSpeedNormal);
        TrySetFloat(outlineMaterial, idDepthWeight, isRage ? depthWeightRage : depthWeightNormal);
        TrySetFloat(outlineMaterial, idNormalWeight, isRage ? normalWeightRage : normalWeightNormal);
    }

    void ApplyLights(bool isRage)
    {
        foreach (var l in sceneLights)
        {
            if (l == null) continue;

            if (isRage)
            {
                l.color = Color.red;
                l.intensity = Mathf.Max(l.intensity, rageMinIntensity);
            }
            else
            {
                if (originalLightState.TryGetValue(l, out var st))
                {
                    l.color = st.color;
                    l.intensity = st.intensity;
                }
                else
                {
                    l.color = Color.white;
                    l.intensity = 1f;
                }
            }
        }
    }

    void CacheLightState()
    {
        originalLightState.Clear();
        foreach (var l in sceneLights)
        {
            if (l == null) continue;
            originalLightState[l] = new LightState { color = l.color, intensity = l.intensity };
        }
    }

    void SnapCameraFOV(bool isRage)
    {
        if (mainCamera == null) return;
        mainCamera.fieldOfView = isRage ? rageFOV : normalFOV;
        targetFOV = mainCamera.fieldOfView;
    }

    static void TrySetFloat(Material mat, int id, float value)
    {
        if (mat != null && mat.HasProperty(id))
            mat.SetFloat(id, value);
    }
}