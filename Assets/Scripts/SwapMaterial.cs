using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class SwapMaterial : MonoBehaviour
{
    public CanvasRenderer background;
    public Texture2D backgroundGreen;
    public Texture2D backgroundRed;

    public Turntable turntable;

    public MeshRenderer body;
    public MeshRenderer cloak;
    public MeshRenderer head;
    public MeshRenderer needle;

    public Material bodyMat;
    public Material cloakFlutter;
    public Material maskMat;
    public Material needleMat;

    public Material bodySilk;
    public Material cloakSilk;
    public Material maskSilk;
    public Material needleSilk;

    private bool silkBind = false;

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            silkBind = !silkBind;
            if (silkBind)
            {
                turntable.rotationSpeed = 30;
                background.SetTexture(backgroundRed);
                body.material = bodySilk;
                cloak.material = cloakSilk;
                head.material = maskSilk;
                needle.material = needleSilk;
            } else
            {
                turntable.rotationSpeed = 15;
                background.SetTexture(backgroundGreen);
                body.material = bodyMat;
                cloak.material = cloakFlutter;
                head.material = maskMat;
                needle.material = needleMat;
            }

        }
    }
}
