using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeedScript : MonoBehaviour
{
    public Transform bottomSpike, leftSpike, rightSpike, centerHollow;

    public Transform center, outer;
    public Fracture centerFracture;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    public void FractureCenter() {
        centerFracture.FractureObject();
        centerHollow.gameObject.SetActive(true);
    }

    public void IncreaseSize1() {
        StartCoroutine(IncreaseSizeCor(2, 3.6f));
    }
    public void IncreaseSize2() {
        StartCoroutine(IncreaseSizeCor(5, 7));
    }

    private IEnumerator IncreaseSizeCor(float centerEndScale, float outerEndScale) {
        float originalCenterScale = center.localScale.x;
        float newCenterScale = centerEndScale;
        
        float originalOuterScale = outer.localScale.x;
        float newOuterScale = outerEndScale;

        float elapsed = 0f;
        float duration = 0.28f;

        float nextScaleCenter, nextScaleOuter;
        while (elapsed < duration)
        {
            float t = elapsed / duration;
            t = Mathf.Pow(t, 4f);

            nextScaleCenter = Mathf.Lerp(originalCenterScale, newCenterScale, t);
            nextScaleOuter = Mathf.Lerp(originalOuterScale, newOuterScale, t);
            center.localScale = new Vector3(nextScaleCenter, nextScaleCenter, nextScaleCenter);
            outer.localScale = new Vector3(nextScaleOuter, nextScaleOuter, nextScaleOuter);

            elapsed += Time.deltaTime;
            yield return null;
        }
    }

    public void HorizontalSpike() {
        StartCoroutine(HorizontalSpikeCor());
    }

    private IEnumerator HorizontalSpikeCor() {
        float originalScale = 0.01f;
        float newScale = leftSpike.localScale.x;

        float elapsed = 0f;
        float duration = 0.27f;

        Vector3 nextScale;
        while (elapsed < duration)
        {
            float t = elapsed / duration;
            t = Mathf.Pow(t, 4f);

            nextScale = new Vector3 (newScale, newScale, Mathf.Lerp(originalScale, newScale, t));
            leftSpike.localScale = nextScale;
            rightSpike.localScale = nextScale;

            elapsed += Time.deltaTime;
            yield return null;
        }
    }

    public void BottomSpike() {
        StartCoroutine(BottomSpikeCor());
    }

    private IEnumerator BottomSpikeCor() {
        float originalScale = 0.01f;
        float newScale = bottomSpike.localScale.x;

        float elapsed = 0f;
        float duration = 0.3f;

        while (elapsed < duration)
        {
            float t = elapsed / duration;
            t = Mathf.Pow(t, 4f);

            bottomSpike.localScale = new Vector3 (newScale, newScale, Mathf.Lerp(originalScale, newScale, t));

            elapsed += Time.deltaTime;
            yield return null;
        }
    }
}
