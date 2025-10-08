using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TVScreen : MonoBehaviour
{
    [SerializeField] Color[] screenColors;
    [SerializeField] float channelChangeTime = 0.4f;
    int currentChannel = -1;

    IEnumerator ChangeChannel(Action<MaterialPropertyBlock> changeChannelAction)
    {
        var renderer = GetComponent<MeshRenderer>();
        var propBlock = new MaterialPropertyBlock();

        float currTime = 0f;
        float switchScreenTime = channelChangeTime * 0.5f;

        while (currTime < switchScreenTime)
        {
            currTime += Time.deltaTime;

            renderer.GetPropertyBlock(propBlock);
            propBlock.SetFloat("_ChannelChangeFac", currTime / switchScreenTime);
            renderer.SetPropertyBlock(propBlock);

            yield return null;
        }

        // Change channel
        renderer.GetPropertyBlock(propBlock);
        SwitchToDifferentChannel();
        changeChannelAction(propBlock);//propBlock.SetColor("_InnerColor", screenColors[currentChannel]);
        renderer.SetPropertyBlock(propBlock);

        //
        while (currTime < channelChangeTime)
        {
            currTime += Time.deltaTime;

            float fac = (currTime - switchScreenTime) / (channelChangeTime - switchScreenTime);
            renderer.GetPropertyBlock(propBlock);
            propBlock.SetFloat("_ChannelChangeFac", 1f - fac);
            renderer.SetPropertyBlock(propBlock);

            yield return null;
        }

        // Ensure ChannelChangeFac = 0
        renderer.GetPropertyBlock(propBlock);
        propBlock.SetFloat("_ChannelChangeFac", 0f);
        renderer.SetPropertyBlock(propBlock);

    }

    public void BeginChangeChannel()
    {
        StartCoroutine(ChangeChannel(propBlock => propBlock.SetColor("_InnerColor", screenColors[currentChannel])));
    }

    public void TakeClover()
    {
        foreach (var tv in SceneMaterialSwitcher.Ins.Televisions)
        {
            var screen = tv.GetComponentInChildren<TVScreen>();
            screen.SetCloverActive(screen == this ? true : false);
        }
    }

    public void SetCloverActive(bool active)
    {
        StartCoroutine(ChangeChannel(propBlock => propBlock.SetInteger("_HasClover", active ? 1 : 0)));
    }

    void SwitchToDifferentChannel()
    {
        if (currentChannel == -1)
        {
            currentChannel = UnityEngine.Random.Range(0, screenColors.Length);
        }
        else
        {
            int nc = UnityEngine.Random.Range(0, screenColors.Length - 1);
            currentChannel = nc >= currentChannel ? nc + 1 : nc;
        }
    }

    void Start()
    {
        var renderer = GetComponent<MeshRenderer>();
        var propBlock = new MaterialPropertyBlock();
        renderer.GetPropertyBlock(propBlock);
        SwitchToDifferentChannel();
        //propBlock.SetFloat("_TVBrightness", transform.parent.parent.transform.localScale.x < 3.4f ? 0.2f : 1f);
        propBlock.SetFloat("_HueShift", UnityEngine.Random.Range(-0.08f, 0.08f));

        //propBlock.SetColor("_InnerColor", Color.HSVToRGB(Random.Range(-0.2f, 0.2f) + 5f/6f, .68f, 1f));
        renderer.SetPropertyBlock(propBlock);
    }
}
