using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using UnityEngine.Rendering.Universal;
using static UnityEngine.GraphicsBuffer;
using UnityEditor;
using UnityEngine.Timeline;
using UnityEngine.UIElements;

[CustomEditor(typeof(RenderingFeatureController))]
public class RenderingFeatureControllerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        EditorGUILayout.Space();
        RenderingFeatureController myScript = (RenderingFeatureController)target;

        if (GUILayout.Button("Toggle Rendering Features"))
        {
            myScript.ToggleEnableState();
        }
        if (GUILayout.Button("Switch Rendering Effects"))
        {
            myScript.SwithcRenderingFeature();
        }
    }
}


[ExecuteAlways]
public class RenderingFeatureController : MonoBehaviour
{
    public float transSpeed = 1f;

    float state = 0f;
    float dir = -1f;
    bool enableFeatures = false;

    List<ScriptableRendererFeature> features;
    enum FEAT{ SSAO, Stylize, AKF, White};

    public void SwithcRenderingFeature()
    {
        dir = -dir;
    }
    public void ToggleEnableState()
    {
        enableFeatures = !enableFeatures;
        if (!enableFeatures) DisableAll();
        else SetFeaturesToState();
        //Debug.Log("TOGGLE to " + enableFeatures);
    }

    public void OnEnable()
    {
        state= 0f;
        dir = -1f;

        var pipelineAsset = UniversalRenderPipeline.asset;
        var rendererDataList = (ScriptableRendererData[])typeof(UniversalRenderPipelineAsset)
           .GetField("m_RendererDataList", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
           .GetValue(pipelineAsset);
        features = rendererDataList[0].rendererFeatures;

        DisableAll();
    }

    void SetFeatureState(FEAT id, bool f)
    {
        features[(int)id].SetActive(f);
    }
    void SetIntensity(float intensity)
    {
        if (features[(int)FEAT.White] is WhiteScreenRendererFeature white)
        {
            white.m_Intensity = intensity;
        }
    }
    void DisableAll()
    {
        enableFeatures = false;
        SetFeatureState(FEAT.SSAO, false);
        SetFeatureState(FEAT.Stylize, false);
        SetFeatureState(FEAT.AKF, false);
        SetFeatureState(FEAT.White, false);
    }
    void SetFeaturesToState()
    {
        //Debug.Log("State : " + state);
        enableFeatures = true;
        bool flag = state > 0.5f;
        SetFeatureState(FEAT.SSAO, flag);
        SetFeatureState(FEAT.Stylize, flag);
        SetFeatureState(FEAT.AKF, !flag);
        SetFeatureState(FEAT.White, (state > 0f && state < 1f));

        float x = (state < 0.5f) ? 4f * state * state * state : 1f - Mathf.Pow(-2f * state + 2f, 3f) / 2;
        x = x < 0.5f ? 2f * x : 2f - 2f * x;
        SetIntensity(x);
    }

    public void Update()
    {
        if(Input.GetKeyUp(KeyCode.J))
        {
            ToggleEnableState();
        }
        if (Input.GetKeyUp(KeyCode.K))
        {
            SwithcRenderingFeature();
        }

        if (!enableFeatures) return;
        state += Time.deltaTime * transSpeed * dir;
        state = Mathf.Clamp01(state);
        SetFeaturesToState();
    }



}
