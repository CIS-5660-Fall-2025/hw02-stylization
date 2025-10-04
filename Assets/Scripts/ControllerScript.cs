using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ControllerScript : MonoBehaviour
{
    private bool sequenceStarted;
    private float inputTimer, countdownTimer;
    private bool altMode;
    private bool m;

    [SerializeField] Transform water;
    [SerializeField] GameObject gem, gemTop;
    [SerializeField] GameObject rocks;
    Material gemMat, gemMat2;
    Material skyMat;

    // Start is called before the first frame update
    void Start()
    {
        inputTimer = 1;
        countdownTimer = 7;

        gemMat = gem.GetComponent<Renderer>().materials[0];
        gemMat2 = gemTop.GetComponent<Renderer>().materials[0];
        skyMat = new Material(RenderSettings.skybox);
        RenderSettings.skybox = skyMat;
    }

    // Update is called once per frame
    void Update()
    {
        if (sequenceStarted) return;
        inputTimer -= Time.deltaTime;

        if (altMode) {
            countdownTimer -= Time.deltaTime;
            if (countdownTimer < 0) {
                sequenceStarted = true;
                GetComponent<SequenceScript>().StartSequence();
                return;
            }
        }

        if (Input.GetKeyDown(KeyCode.Space) && inputTimer < 0) {
            inputTimer = 6.2f;
            altMode = !altMode;
            if (altMode) {
                if (!m) {
                    GetComponent<AudioSource>().Play();
                    m = true;
                }

                StartCoroutine(WaterRise(true));
                StartCoroutine(SkyChange(true));
                StartCoroutine(GemChange(true));

            } else {
                countdownTimer = 12;
                StartCoroutine(WaterRise(false));
                StartCoroutine(SkyChange(false));
                StartCoroutine(GemChange(false));
            }
        }
    }

    private IEnumerator WaterRise(bool rise) {
        Vector3 originalPos = water.position;
        Vector3 newPos = rise ? (new Vector3(0f,0.590000021f,0.649999976f)) : (new Vector3(0f,-1.53999996f,0.649999976f));

        float elapsed = 0f;
        float time = 5;

        while (elapsed < time)
        {
            float t = elapsed / time;

            t = Mathf.SmoothStep(0f, 1f, t);
            water.position = Vector3.Lerp(originalPos, newPos, t);

            elapsed += Time.deltaTime;
            yield return null;
        }

        water.position = newPos;
        rocks.SetActive(false);
    }
    private IEnumerator SkyChange(bool darken) {
        float currDarkVal = skyMat.GetFloat("_Darkness");
        float newDarkVal = darken ? 0.44f : 0f;
        float currCyanVal = skyMat.GetFloat("_Cyan");
        float newCyanVal = darken ? 0.1f : 0f;

        float elapsed = 0f;
        float time = 3.7f;

        while (elapsed < time)
        {
            float t = elapsed / time;
            skyMat.SetFloat("_Darkness", Mathf.Lerp(currDarkVal, newDarkVal, t));
            skyMat.SetFloat("_Cyan", Mathf.Lerp(currCyanVal, newCyanVal, Mathf.Max(0, 2f * t - 1f)));

            elapsed += 0.05f;
            yield return new WaitForSeconds(0.05f);
        }
        skyMat.SetFloat("_Darkness", newDarkVal);
        skyMat.SetFloat("_Cyan", newCyanVal);
    }
    private IEnumerator GemChange(bool darken) {
        float currVal = gemMat.GetFloat("_Black");
        float newVal = darken ? -0.1f : 0.05f;

        float elapsed = 0f;
        float time = 6f;

        while (elapsed < time)
        {
            float t = elapsed / time;
            gemMat.SetFloat("_Black", Mathf.Lerp(currVal, newVal, t));
            gemMat2.SetFloat("_Black", Mathf.Lerp(currVal, newVal, t));

            elapsed += 0.1f;
            yield return new WaitForSeconds(0.1f);
        }
        gemMat.SetFloat("_Black", newVal);
    }
}
