
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using TMPro;
using UnityEngine.UI;



public class CustomCharactor : MonoBehaviour
{
    Button b;
    public GameObject avatarBody;

    [System.Serializable]
    public struct avatarData
    {
        public GameObject hair;
        public Texture2D eye;
        public Texture2D skin;
        public Texture2D dress;
    };
    public List<avatarData> avatars = new List<avatarData>();

    int defaultIndex = 0;
    int currentIndex;

    Transform hairSlot;
    GameObject player;
    GameObject currentHair;

    Material eyeMat, dressMat, skinMat;
    static int eyeTexID = Shader.PropertyToID("_BaseMap");
    static int dressTexID = Shader.PropertyToID("_BaseMap");
    static int skinTexID = Shader.PropertyToID("_BaseMap");

    Animator bodyAnimator, hairAnimator;

    public TextMeshProUGUI text;
    

    void Start()
    {
        if (!avatarBody)
        {
            return;
        }

        player = Instantiate(avatarBody, Vector3.zero, Quaternion.identity, transform);
        bodyAnimator = player.GetComponent<Animator>();

        GetSharedMaterial();

        hairSlot = GameObject.FindGameObjectWithTag("HairTGD").transform;
        currentIndex = defaultIndex;
        CreateCustomAvatar(currentIndex);
        PlayIdleClips();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.G))
        {
            PlayGreetClips();
        }
    }

    void InitialHairTransform(GameObject hair)
    {
        hair.transform.localPosition = Vector3.zero;
        Transform rootBone = hair.transform.Find("root");
        rootBone.transform.localPosition = Vector3.zero;
        rootBone.transform.localRotation = Quaternion.identity;
        hair.SetActive(true);
    }

    private void CreateCustomAvatar(int index)
    {
        if (currentHair == null)
        {
            currentHair = Instantiate(avatars[index].hair,
                                      hairSlot.transform.position,
                                      hairSlot.rotation,
                                      hairSlot);


        }

        InitialHairTransform(currentHair);

        if (eyeMat && dressMat && skinMat)
        {
            eyeMat.SetTexture(eyeTexID, avatars[index].eye);
            dressMat.SetTexture(dressTexID, avatars[index].dress);
            skinMat.SetTexture(skinTexID, avatars[index].skin);
        }

        hairAnimator = currentHair.GetComponent<Animator>();
    }

    public void AvatarChange(int index)
    {
        Destroy(currentHair);
        currentHair = null;
        CreateCustomAvatar(index);

        var bodyStateInfo = bodyAnimator.GetCurrentAnimatorStateInfo(0);
        int stateName = bodyStateInfo.shortNameHash;
        hairAnimator = currentHair.GetComponent<Animator>();
        hairAnimator.Play(stateName);
    }

    void GetSharedMaterial()
    {
        var body = player.transform.Find("head");
        var dress = player.transform.Find("shangbanshen");

        eyeMat = body.GetComponent<Renderer>().sharedMaterials[1];
        skinMat = body.GetComponent<Renderer>().sharedMaterials[0];
        dressMat = dress.GetComponent<Renderer>().sharedMaterials[1];
    }

    void PlayRunClips()
    {
        
        bodyAnimator.SetFloat("Speed", 1.0f);
        hairAnimator.SetFloat("Speed", 1.0f);
        text.text = "Run(loop)";
    }

    void PlayWalkClips()
    {   
        bodyAnimator.SetFloat("Speed", 0.3f);
        hairAnimator.SetFloat("Speed", 0.3f);
        text.text = "Walk(loop)";
    }

    void PlayJumpClips()
    {
        bodyAnimator.SetTrigger("Jump");
        hairAnimator.SetTrigger("Jump");
        PlayIdleClips();
        text.text = "Jump(Once)";
    }

    void PlayGreetClips()
    {
        bodyAnimator.SetTrigger("Greet");
        hairAnimator.SetTrigger("Greet");
        PlayIdleClips();
        text.text = "Greet(Once)";
    }

    void PlayIdleClips()
    {
        bodyAnimator.SetFloat("Speed", 0);
        hairAnimator.SetFloat("Speed", 0);
        text.text = "Idle(loop)";
    }

    void AnimationChange(int index)
    {
        switch (index)
        {
            case 0:
                PlayIdleClips();
                break;

            case 1:
                PlayWalkClips();
                break;


            case 2:
                PlayRunClips();
                break;


            case 3:
                PlayGreetClips();
                break;

            case 4:
                PlayJumpClips();
                break;

            default:
                PlayIdleClips();
                break;
        }
    }

    public void LeftArrow()
    {
        currentIndex = (currentIndex > 0) ? currentIndex - 1 : 4;
        AnimationChange(currentIndex);

    }

    public void RightArrow()
    {
        currentIndex = (currentIndex < 4) ? currentIndex +1 : 0;
        AnimationChange(currentIndex);
    }



   

}
