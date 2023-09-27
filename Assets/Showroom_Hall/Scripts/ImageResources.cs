using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu]
public class ImageResources : ScriptableObject
{
    [System.Serializable]
    public class GalleryResources
    {
        public Sprite sprite;
        public string info;
    }

    public List<GalleryResources> resources;
  
}
