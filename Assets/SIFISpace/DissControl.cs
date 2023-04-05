using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using AmazingAssets.AdvancedDissolve;

public class DissControl : MonoBehaviour
{

    [SerializeField, Min(0f)] float duration = 1f;
    float value;

    [SerializeField] bool autoReverse = false, smoothStep = false;

    public bool Reversed { get; set; }

    [SerializeField] bool isDissovle = false;
    public bool AutoReversed
    {
        get => autoReverse;
        set => autoReverse = value;
    }

    [SerializeField] AdvancedDissolvePropertiesController propertiesController;
    [SerializeField] AdvancedDissolveGeometricCutoutController geometricCutoutController;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (isDissovle)
        {
            CaculateTimeValue();
            geometricCutoutController.target1Radius = value*42f;
        }
    }

    public void DissolveScene()
    {
        isDissovle = true;
    }


    private void CaculateTimeValue()
    {
        float delta = Time.deltaTime / duration;
        if (Reversed)
        {
            value -= delta;
            if (value <= 0f)
            {
                if (autoReverse)
                {
                    value = Mathf.Min(1f, -value);
                    Reversed = false;
                }
                else
                {
                    value = 0f;
                    isDissovle = false;
                }
            }
        }
        else
        {
            value += delta;
            if (value >= 1f)
            {
                if (autoReverse)
                {
                    value = Mathf.Max(0f, 2f - value);
                    Reversed = true;
                }
                else
                {
                    value = 1f;
                    isDissovle = false;
                }
            }
        }
    }
}
