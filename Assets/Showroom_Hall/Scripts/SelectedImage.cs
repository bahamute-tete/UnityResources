using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Globalization;
using UnityEngine.Video;

public class SelectedImage : MonoBehaviour
{
    [SerializeField] Camera cam;
    [SerializeField] GameObject displayImageRoot;
    [SerializeField] Image image;
    [SerializeField] bool showImage = false,showVideo =false;
    [SerializeField] CanvasGroup canvasGroup,videoCanvasGroup;
    [SerializeField] Button btnQuit,videoBtnQuit;
    LerpAnim btnAnim,videoBtnAnim;

    [SerializeField] GameObject textBox,videoTextBox;
    [SerializeField] TextMeshProUGUI textInfo;

    LerpAnim textBoxAnim, videoTextBoxAnim;

    [SerializeField]LerpAnim texAnim,videoAnim;
    RectTransform btnRect, textBoxRect,videoBtnRect, videoTextBoxRect;

    FrameTextureChange textureChange;

    [SerializeField] GameObject videoImageRoot;
    

    [SerializeField] GameObject selectedObj;
    [SerializeField] GameObject player;

    [SerializeField] AudioSource audioSource;


    // Start is called before the first frame update
    void Start()
    {
        Initialize();

        btnQuit.onClick.AddListener(delegate
        {
            resetUIImage();
        });


        videoBtnQuit.onClick.AddListener(delegate
        {
            resetUIVideo();
        });
    }

    private void Initialize()
    {
       

        canvasGroup.alpha = 0.0f;
        videoCanvasGroup.alpha = 0.0f;

        textBoxAnim = textBox.GetComponent<LerpAnim>();
        textBoxRect = textBox.GetComponent<RectTransform>();
        textBoxRect.anchoredPosition = new Vector2(0, -77);

        btnAnim = btnQuit.transform.GetComponent<LerpAnim>();
        btnRect = btnQuit.transform.GetComponent<RectTransform>();


       
        videoBtnAnim = videoBtnQuit.transform.GetComponent<LerpAnim>();
        videoBtnRect = videoBtnAnim.transform.GetComponent<RectTransform>();

        videoTextBoxAnim = videoTextBox.GetComponent<LerpAnim>();
        videoTextBoxRect = videoTextBox.GetComponent<RectTransform>();
        videoTextBoxRect.anchoredPosition = new Vector2(0, -77);

        videoImageRoot.SetActive(false);
        displayImageRoot.SetActive(false);

        audioSource.volume = 0.55f;
        
    }


    //private void OnDrawGizmos()
    //{
    //    Gizmos.color = Color.red;
    //    if (selectedObj)
    //        Gizmos.DrawLine(selectedObj.transform.position, player.transform.position);

    //    Gizmos.color = Color.yellow;
    //    Gizmos.DrawLine(selectedObj.transform.position, Camera.main.transform.position);
    //    float dis = Vector3.Distance(selectedObj.transform.position, Camera.main.transform.position);
    //    Debug.Log("dis :"+ dis);
    //}

    // Update is called once per frame
    void Update()
    {
   
        Ray ray = cam.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, maxDistance:7f))
        {
            if (hit.collider.tag.Equals("frame") )
            {
                selectedObj = hit.transform.gameObject;

                if (isRange(4f))
                {
                    selectedObj.GetComponent<FrameTextureChange>().isSelectd = true;

                    if (Input.GetMouseButtonDown(0))
                    {
                        textureChange = hit.transform.GetComponent<FrameTextureChange>();
                        image.sprite = textureChange.sprite;
                        textInfo.text = textureChange.info.ToString();

                        displayImageRoot.SetActive(true);
                        videoImageRoot.SetActive(false);

                        showImage = true;
                        showVideo = false;
                    }
                }
               
            }


            if (hit.collider.tag.Equals("frameVideo"))
            {
                selectedObj = hit.transform.gameObject;

                if (isRange(4f))
                {
                    selectedObj.GetComponent<FrameTextureChange>().isSelectd = true;

                    if (Input.GetMouseButtonDown(0))
                    {
                        videoImageRoot.SetActive(true);
                        displayImageRoot.SetActive(false);

                        showImage = false;
                        showVideo = true;
                    }
                }
               
            }
        }
        else
        {
            if (selectedObj)
                selectedObj.GetComponent<FrameTextureChange>().isSelectd = false;
        }


        if (showImage)
        {
            StartCoroutine(alphaChange(0.02f, canvasGroup));

            if (canvasGroup.alpha > 0.999f)
            {
                btnAnim.Active();
                textBoxAnim.Active();

                showImage = false;
                StopAllCoroutines();
            }
        }

        if (showVideo)
        {
            audioSource.volume = 0f;
            StartCoroutine(alphaChange(0.02f,videoCanvasGroup));

            if (videoCanvasGroup.alpha > 0.999f)
            {
                videoBtnAnim.Active();
                videoTextBoxAnim.Active();

                showVideo = false;
                StopAllCoroutines();
            }
        }

        if (selectedObj)
        {
            if (isRange(4f).Equals(false))
            {
                resetUIImage();
                resetUIVideo();
                selectedObj = null;
            }
        }

    }

    IEnumerator alphaChange(float alpha,CanvasGroup canvasGroup)
    {
        yield return new WaitForSeconds(0.1f);
        canvasGroup.alpha += alpha;

    }

    bool isRange(float threshold )
    {
        float distane = Vector3.Distance(player.transform.position, selectedObj.transform.position);
        //Debug.Log("distance= " + distane);
        return distane<=threshold?true:false;

    }

    void resetUIImage()
    {
        textBoxRect.anchoredPosition = new Vector2(0, -77);
        texAnim.reverse = false;

        showImage = false;

        canvasGroup.alpha = 0.0f;

        btnRect.anchoredPosition = new Vector2(-32, -32);
        btnAnim.reverse = false;

        displayImageRoot.SetActive(false);
        image.sprite = null;
        audioSource.volume = 0.55f;
    }

    void resetUIVideo()
    {
        videoTextBoxRect.anchoredPosition = new Vector2(0, -77);
        videoAnim.reverse = false;

        videoCanvasGroup.alpha = 0.0f;

        videoBtnRect.anchoredPosition = new Vector2(-32, -32);
        videoBtnAnim.reverse = false;

        videoImageRoot.SetActive(false);
        showVideo = false;
        audioSource.volume = 0.55f;
    }


}
