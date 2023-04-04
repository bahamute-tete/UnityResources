using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using AmazingAssets.AdvancedDissolve;
using static UnityEngine.Mathf;
using System;
using UnityEngine.Rendering.VirtualTexturing;

public class TerrainChange : MonoBehaviour
{
    public GameObject[] Tblocs = new GameObject[3];
    GameObject currentGameObj = null;

    public Button changeBtn;

    private int blockIndex = 2;

    //////////////////
    [SerializeField, Min(0f)] float duration = 1f, waitTime = 1f;
    float value,dissValue;
    float wait;

    [SerializeField] bool autoReverse = false;

    public bool Reversed { get; set; }
    public bool AutoReversed
    {
        get => autoReverse;
        set => autoReverse = value;
    }
    //////////////////
    public Transform target;
    [SerializeField] bool isDissovle = false;
    public Transform start, end;
    ////////////////////////////
    [SerializeField] GameObject dissovleProperty;
    [SerializeField] GameObject geometricCutout;
    AdvancedDissolvePropertiesController propertiesController;
    AdvancedDissolveGeometricCutoutController geometricCutoutController;
    ///////////////////////////
    public ParticleSystem[] pSystems;
    public Color[] startColors;
    ParticleSystem.ColorOverLifetimeModule[] colorOverModules;
    ParticleSystem.MainModule[] mainModules;
    public float[] colorAlphas;
    float[] zeroAlpha;
    ///////////////////////////
    private void Awake()
    {
        propertiesController = dissovleProperty.GetComponent<AdvancedDissolvePropertiesController>();
        geometricCutoutController = geometricCutout.GetComponent<AdvancedDissolveGeometricCutoutController>();

        zeroAlpha = new float[startColors.Length];
        Array.Fill<float>(zeroAlpha, 0);

        target.position = start.position;
       
    }

    private void ParticleInitial()
    {
        colorOverModules = new ParticleSystem.ColorOverLifetimeModule[pSystems.Length];
        mainModules = new ParticleSystem.MainModule[pSystems.Length];

        if (startColors.Length == pSystems.Length * 2)
        {

            SetParticleStartColor(zeroAlpha);
        }
    }

    private void SetParticleStartColor(float[] alphas)
    {
        for (int i = 0; i < colorOverModules.Length; i++)
        {
            colorOverModules[i] = pSystems[i].colorOverLifetime;
            mainModules[i] = pSystems[i].main;

            var startColor = pSystems[i].main.startColor;
            startColor.mode = ParticleSystemGradientMode.TwoColors;
            startColor.colorMin = startColors[i];
            startColor.colorMax = startColors[i + 4];

            var minColor = startColor.colorMin;
            var maxColor = startColor.colorMax;
            minColor.a = alphas[i];
            maxColor.a = alphas[i+4];
            startColor.colorMin = minColor;
            startColor.colorMax = maxColor;

            mainModules[i].startColor = startColor;
        }
    }

    void Start()
    {

        changeBtn.onClick.AddListener(delegate
        {
            if (blockIndex < Tblocs.Length - 1)
                blockIndex++;
            else
                blockIndex = 0;

            isDissovle = true;
            value = 0;
            dissValue = 0;
            wait = 0;
            propertiesController.cutoutStandard.clip = 0;
            target.position = start.position;
            SetParticleStartColor(colorAlphas);
            CreateBlockState(blockIndex);

        });
        ParticleInitial();
        CreateBlockState(blockIndex);
    }


    void FixedUpdate()
    {
        if (isDissovle)
        {
            value = CaculateTimeValue(value);
           
            target.position = Vector3.Lerp(start.position, end.position, value);
        }

        
        if (Vector3.SqrMagnitude(target.position - end.position) < 0.0001f)
        {
            float delta = Time.deltaTime / waitTime;
            wait += delta;
           
            if (wait >= 1)
            {
                dissValue = CaculateTimeValue(dissValue);
                propertiesController.cutoutStandard.clip = dissValue;
                SetParticleStartColor(zeroAlpha);
                wait = 1f;
            }

        }
    }

    void CreateBlockState(int index)
    {
        if (transform.childCount != 0)
        {

            DestroyImmediate(transform.GetChild(0).gameObject);
            currentGameObj = null;
        }

       
            currentGameObj = Instantiate(Tblocs[index], transform);
    }

    private float  CaculateTimeValue(float value)
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
                    
                }
            }
        }

        return value;
    }
}
