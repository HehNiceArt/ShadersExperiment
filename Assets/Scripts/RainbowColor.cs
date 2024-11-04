using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RainbowColor : MonoBehaviour
{
    Renderer rend;
    Material material;
    void Start()
    {
        rend = GetComponent<Renderer>();
        material = rend.material;
        material.SetColor("_Color", Color.magenta);
    }
    void Update()
    {

    }
}
