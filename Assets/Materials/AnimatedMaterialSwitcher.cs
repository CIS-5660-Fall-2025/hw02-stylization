using System.Collections.Generic;
using UnityEngine;

public class AnimatedMaterialSwitcher : MonoBehaviour
{
    [Header("Materials")]
    public Material defaultMaterial;   
    public Material glowMaterial;   

    [Header("Control Keys")]
    public KeyCode keyNormal = KeyCode.Alpha1;  
    public KeyCode keyGlow = KeyCode.Alpha2;  
    public KeyCode keyToggle = KeyCode.Alpha3;  

    [Header("Advanced")]
    public bool includeInactiveChildren = true;
    public bool reapplyEveryFrame = true;       
    public bool duplicateGlowPerRenderer = false; 

    private readonly List<Renderer> _renderers = new List<Renderer>();
    private readonly Dictionary<Renderer, Material[]> _orig = new Dictionary<Renderer, Material[]>();
    private readonly Dictionary<Renderer, Material[]> _glow = new Dictionary<Renderer, Material[]>();
    private bool _isGlow = false;

    void Awake()
    {

        GetComponentsInChildren(includeInactiveChildren, _renderers);


        foreach (var r in _renderers)
        {
            if (!r) continue;

  
            var origMats = r.materials; 
            _orig[r] = origMats;

            var count = origMats.Length;
            var glowArray = new Material[count];

            for (int i = 0; i < count; i++)
            {
                glowArray[i] = duplicateGlowPerRenderer ? new Material(glowMaterial) : glowMaterial;
                if (glowArray[i].HasProperty("_EmissionColor"))
                    glowArray[i].EnableKeyword("_EMISSION");
            }
            _glow[r] = glowArray;
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(keyNormal)) SetGlow(false);
        if (Input.GetKeyDown(keyGlow)) SetGlow(true);
        if (Input.GetKeyDown(keyToggle)) SetGlow(!_isGlow);

        if (reapplyEveryFrame)
        {
            if (_isGlow) Apply(_glow);
            else Apply(_orig);
        }
    }

    void SetGlow(bool on)
    {
        _isGlow = on;
        Apply(on ? _glow : _orig);
    }

    void Apply(Dictionary<Renderer, Material[]> map)
    {
        foreach (var r in _renderers)
        {
            if (!r) continue;
            if (!map.TryGetValue(r, out var mats)) continue;
            r.materials = mats;
        }
    }
}
