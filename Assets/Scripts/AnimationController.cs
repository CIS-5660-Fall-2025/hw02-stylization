using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationController : MonoBehaviour
{
    public Material[] materials;
    public Material NormalOutline;
    public Material PostProcess;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            foreach (var mat in materials)
            {
                mat.SetFloat("_Animated", 1f);
            }
            NormalOutline.SetFloat("_Normal_Threshold", 10f);
        }
        else if (Input.GetKeyDown(KeyCode.LeftShift)) {
            foreach (var mat in materials)
            {
                mat.SetFloat("_Animated", 0f);
            }
            NormalOutline.SetFloat("_Normal_Threshold", 0.7f);
        }

        if (Input.GetKeyDown(KeyCode.Alpha1) || Input.GetKeyDown(KeyCode.Keypad1))
        {
            PostProcess.SetFloat("_Post_Process", 1f);
        } 
        else if (Input.GetKeyDown(KeyCode.Alpha2) || Input.GetKeyDown(KeyCode.Keypad2))
        {
            PostProcess.SetFloat("_Post_Process", 2f);
        }
        else if (Input.GetKeyDown(KeyCode.Alpha0) || Input.GetKeyDown(KeyCode.Keypad0))
        {
            PostProcess.SetFloat("_Post_Process", 0f);
        }
    }
}
