using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIResize : MonoBehaviour
{
    [SerializeField]int preWindowWidth, preWindowHeight;
    [SerializeField] GameObject imageCavans, videoCavans, Btn;
    Vector3 preScaleimage, preScaleVideo, preScaleBtn;
    float ratio;

    private void Awake()
    {
        preWindowWidth = Screen.width;
        preWindowHeight = Screen.height;

        preScaleimage = imageCavans.transform.localScale;
        preScaleVideo = videoCavans.transform.localScale;
        preScaleBtn = Btn.transform.localScale;


        RectTransform imageCavansRect = imageCavans.GetComponent<RectTransform>();
        ratio = imageCavansRect.sizeDelta.x / preWindowWidth;

    }
    // Start is called before the first frame update
    void Start()
    {
   
        Application.onBeforeRender += OnWindowsResize;
    }


    void OnWindowsResize()
    {
        if (Screen.width != preWindowWidth || Screen.height != preWindowHeight)
        {
            AdjustUI();

            preWindowWidth = Screen.width;
            preWindowHeight = Screen.height;

  
        }
    }

    void AdjustUI()
    {
        RectTransform imageCavansRect = imageCavans.GetComponent<RectTransform>();
        ratio = imageCavansRect.sizeDelta.x / preWindowWidth;
        
        float scale = Screen.width * ratio/ imageCavansRect.sizeDelta.x;

        imageCavans.transform.localScale *= scale;
        videoCavans.transform.localScale *= scale;
        Btn.transform.localScale *= scale;
    }

}
