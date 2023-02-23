using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using AmazingAssets.AdvancedDissolve;
using UnityEngine.InputSystem;
using System;
using System.IO;
using static UnityEngine.ParticleSystem;

public class ChipManager : MonoBehaviour
{


    public Button button;
    
    public GameObject chipbody;

    [SerializeField]Material material;
    [SerializeField]GameObject dissovleProperty;
    [SerializeField]GameObject geometricCutout;
    AdvancedDissolvePropertiesController propertiesController;
    AdvancedDissolveGeometricCutoutController geometricCutoutController;
    public Transform target;

    public Transform start, end;

    public GameObject[] textModels = new GameObject[5];

    int index = 4;

    [SerializeField]bool isDissovle = false;
    [SerializeField] bool isChipAnim = false;
    public Material textMat,chipMat;

    
    float lerpValue = 0;
    //////////////////
    [SerializeField, Min(0f)] float duration = 1f;
    float value;

    [SerializeField] bool autoReverse = false, smoothStep = false;

    public bool Reversed { get; set; }
    public bool AutoReversed
    {
        get => autoReverse;
        set => autoReverse = value;
    }

    float SmoothValue => 3f * value * value - 2f * value * value * value;
    //////////////////


    [ColorUsage(true, true)]
    public Color[] chipColors, textColors;
    public float[] glowIntensity;

    MaterialPropertyBlock block, block_text;
    static int chipColprID = Shader.PropertyToID("_EmissionColor");
    static int textColorID = Shader.PropertyToID("_EmissionColor");
    Renderer chipRender, textRendere;
    //////////////////

    public ParticleSystem particle, particleCircle, particleBase;
    public Gradient[] gradients, baseColors;
    ParticleSystem.ColorOverLifetimeModule colorOverLifetimeModule, particalCircleModule, particalBaseModule;
    ParticleSystem.MainModule mainModule, circleMainModule,baseMainModule;

    // Start is called before the first frame update
    void Start()
    {
        block = new MaterialPropertyBlock();
        block_text = new MaterialPropertyBlock();

        chipRender = chipbody.transform.Find("Chip").GetChild(0).GetComponent<Renderer>();
        textRendere = chipbody.transform.GetChild(index).GetComponent<Renderer>();

        propertiesController = dissovleProperty.GetComponent<AdvancedDissolvePropertiesController>();
        geometricCutoutController = geometricCutout.GetComponent<AdvancedDissolveGeometricCutoutController>();

        target.position = start.position;

        UpdateModle(index);

        AdvancedDissolveProperties.Cutout.Standard.UpdateLocalProperty(
        textMat,
        AdvancedDissolveProperties.Cutout.Standard.Property.Clip,
        1f);



        mainModule = particle.main;
        mainModule.startColor = new Color (1,1,1,0);

        particleCircle.gameObject.SetActive(false);
        particleBase.gameObject.SetActive(false);

        circleMainModule = particleCircle.main;
        circleMainModule.startColor= new Color(1, 1, 1, 0);
        baseMainModule = particleBase.main;
        baseMainModule.startColor = new Color(1, 1, 1, 0);
        particleCircle.gameObject.SetActive(true);
        particleBase.gameObject.SetActive(true);


        button.onClick.AddListener(delegate
        {
            if (index < 4)
                index++;
            else
                index = 0;

            isDissovle = true;
            value = 0;
        });
    }



    void FixedUpdate()
    {
       
        //if (Input.GetKeyDown(KeyCode.N))
        //{
        //    if (index > 0)
        //        index--;
        //    else
        //        index = 4;

        //    isDissovle = true;
        //    value = 0;
        //}

        //if (Input.GetKeyDown(KeyCode.M))
        //{
        //    if (index < 4)
        //        index++;
        //    else
        //        index = 0;

        //    isDissovle = true;
        //    value = 0;
        //}

        UpdateModle(index);


        if (isDissovle)
        {
            CaculateTimeValue();

            mainModule = particle.main;
            mainModule.startColor = new Color(1, 1, 1, Math.Clamp(value,0,0.12f));

            circleMainModule = particleCircle.main;
            circleMainModule.startColor = new Color(1, 1, 1, Math.Clamp(value, 0, 0.3f));

            baseMainModule = particleBase.main;
            baseMainModule.startColor = new Color(1, 1, 1, Math.Clamp(value, 0, 0.3f));


            AdvancedDissolveProperties.Cutout.Standard.UpdateLocalProperty(
            textMat,
            AdvancedDissolveProperties.Cutout.Standard.Property.Clip,
            Math.Clamp(1f-value, 0.32f,1f));

            target.position = Vector3.Lerp(start.position, end.position, value);
        }
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

    private void UpdateModle(int index)
    {
        
        foreach (var o in textModels)
        {
            o.SetActive(false);
        }

        textModels[index].SetActive(true);

        textRendere = chipbody.transform.GetChild(index).GetComponent<Renderer>();

        AdvancedDissolveProperties.Edge.Base.UpdateLocalProperty(
        textMat,
        AdvancedDissolveProperties.Edge.Base.Property.Color,
        textColors[index]);


        propertiesController.edgeBase.color = textColors[index];
        propertiesController.edgeBase.colorIntensity = glowIntensity[index];

        block.SetColor(chipColprID, chipColors[index]);
        block_text.SetColor(textColorID, chipColors[index]);

        chipRender.SetPropertyBlock(block);
        textRendere.SetPropertyBlock(block_text);

        colorOverLifetimeModule = particle.colorOverLifetime;
        colorOverLifetimeModule.color = gradients[index];

        particalCircleModule = particleCircle.colorOverLifetime;
        particalCircleModule.color = baseColors[index];

        particalBaseModule = particleBase.colorOverLifetime;
        particalBaseModule.color = baseColors[index];

    }
}

