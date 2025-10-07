using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class key_press_listener : MonoBehaviour
{
    public KeyCode postProcessingToggle = KeyCode.Space;
    public KeyCode nextPostProcessingEffect = KeyCode.N;
    public int maxIndex = 3;
    bool post = false;
    int index = 0;
    // Start is called before the first frame update
    void Start()
    {
        Shader.SetGlobalFloat("_PostMode", -1);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(postProcessingToggle))
        {
            post = !post;
            if (!post)
            {
                Shader.SetGlobalFloat("_PostMode", -1);
            }
            else
            {
                Shader.SetGlobalFloat("_PostMode", index);
            }
        }
        else if (Input.GetKeyDown(nextPostProcessingEffect))
        {
            if (post)
            {
                index = (index + 1) % (maxIndex + 1);
                Shader.SetGlobalFloat("_PostMode", index);
                Debug.Log($"[PostFX] Switched to index={index}");
            }
        }
    }
}