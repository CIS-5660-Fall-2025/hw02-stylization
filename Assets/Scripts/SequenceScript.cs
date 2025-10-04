using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SequenceScript : MonoBehaviour
{
    public GameObject gem, droplet, seed, main, camera, water, swords;
    public ParticleSystem lightningPS;

    public GameObject wind1, wind2;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    public void StartSequence() {
        StartCoroutine(FirstPart());
    }
    private IEnumerator FirstPart() {
        RenderFeatureUtils.SetFlashingKeyword();
        gem.GetComponent<GemScript>().StopOsc();
        yield return new WaitForSeconds(4);
        droplet.SetActive(true);
        StartCoroutine(RemoveDrop());
        yield return new WaitForSeconds(3f);

        gem.GetComponent<Fracture>().FractureObject();
        camera.GetComponent<CameraScript>().ShakeCam();
        seed.SetActive(true);
        yield return new WaitForSeconds(0.5f);
        seed.GetComponent<SeedScript>().BottomSpike();
        lightningPS.Play();
        yield return new WaitForSeconds(0.5f);
        camera.GetComponent<CameraScript>().MoveAway();
        yield return new WaitForSeconds(1.5f);

        StartCoroutine(RemoveMain());
        StartCoroutine(IncreaseWaterIntensity());
        yield return new WaitForSeconds(4f);
        seed.GetComponent<SeedScript>().IncreaseSize1();
        EnableFlash();
        camera.GetComponent<CameraScript>().ShakeCam();
        wind1.SetActive(true);
        wind2.SetActive(true);

    }

    private IEnumerator RemoveDrop() {
        float yGoal = gem.transform.position.y;
        while (droplet.transform.position.y > yGoal) {
            yield return null;
        }
        droplet.SetActive(false);
    }
    private IEnumerator RemoveMain() {
        Vector3 originalPos = main.transform.position;
        Vector3 newPos = originalPos + new Vector3(0, -7, 0);

        Vector3 originalSeedPos = seed.transform.position;
        Vector3 newSeedPos = originalSeedPos + new Vector3(0, 1, 0);

        float elapsed = 0f;
        float duration = 5f;

        while (elapsed < duration)
        {
            float t = elapsed / duration;
            t = Mathf.SmoothStep(0f, 1f, t);

            main.transform.position = Vector3.Lerp(originalPos, newPos, t);
            seed.transform.position = Vector3.Lerp(originalSeedPos, newSeedPos, t);

            elapsed += Time.deltaTime;
            yield return null;
        }
        main.SetActive(false);
    }
    private IEnumerator IncreaseWaterIntensity() {
        Material waterMat = water.GetComponent<Renderer>().material;
        float startIntensity = waterMat.GetFloat("_WaterDisplacement");
        float endIntensity = 1f;
        Vector3 originalPos = water.transform.position;
        Vector3 swordOffset =  swords.transform.position - originalPos;
        Vector3 newPos = originalPos + new Vector3(0, -1, 0);

        float elapsed = 0f;
        float duration = 4f;
        Vector3 nextPos;

        while (elapsed < duration)
        {
            float t = elapsed / duration;
            t = Mathf.SmoothStep(0f, 1f, t);

            waterMat.SetFloat("_WaterDisplacement", Mathf.Lerp(startIntensity, endIntensity, t));
            nextPos = Vector3.Lerp(originalPos, newPos, t);
            water.transform.position = nextPos;
            swords.transform.position = nextPos + swordOffset;

            elapsed += Time.deltaTime;
            yield return null;
        }
    }

    private void EnableFlash() {

    }
}
