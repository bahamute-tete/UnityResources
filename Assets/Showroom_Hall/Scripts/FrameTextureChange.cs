using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FrameTextureChange : MonoBehaviour
{
    public ImageResources galleryAssetes;
    public int index = 0;
    static int texID = Shader.PropertyToID("_BaseMap");

    [HideInInspector]
    public Sprite sprite = null;

    [HideInInspector]
    public string info = null;

    Material material1;
    Renderer rendener;

    [SerializeField] Material selectedMat, UnSeclectedMat;
    Material[] newMats = new Material[2];
    public bool isSelectd = false;






    // Start is called before the first frame update
    void Start()
    {
        sprite = galleryAssetes.resources[index].sprite;
        info = galleryAssetes.resources[index].info;


        isSelectd = false;

        rendener = GetComponent<Renderer>();

        material1 = rendener.materials[1];
        newMats[0] = UnSeclectedMat;
        newMats[1] = material1;
        material1.SetTexture(texID, sprite.texture);
        rendener.materials = newMats;


    }

    void Update()
    {
        if (isSelectd == true)
        {
            newMats[0] = selectedMat;
        }
        else
        {
            newMats[0] = UnSeclectedMat;
        }

        rendener.materials = newMats;
    }
}
