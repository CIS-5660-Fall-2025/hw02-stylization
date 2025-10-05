using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TVScreen : MonoBehaviour
{
    [SerializeField] Color[] screenColors;
    [SerializeField] float channelChangeTime = 0.4f;
    int currentChannel = -1;

    IEnumerator ChangeChannel()
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
        propBlock.SetColor("_InnerColor", screenColors[currentChannel]);
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
        StartCoroutine(ChangeChannel());
    }

    public void SwitchToDifferentChannel()
    {
        if (currentChannel == -1)
        {
            currentChannel = Random.Range(0, screenColors.Length);
        }
        else
        {
            int nc = Random.Range(0, screenColors.Length - 1);
            currentChannel = nc >= currentChannel ? nc + 1 : nc;
        }
    }

    void Start()
    {
        var renderer = GetComponent<MeshRenderer>();
        var propBlock = new MaterialPropertyBlock();
        renderer.GetPropertyBlock(propBlock);
        SwitchToDifferentChannel();
        //propBlock.SetColor("_InnerColor", screenColors[currentChannel]);
        //propBlock.SetColor("_InnerColor", Color.HSVToRGB(Random.Range(-0.2f, 0.2f) + 5f/6f, .68f, 1f));
        renderer.SetPropertyBlock(propBlock);
    }
}
