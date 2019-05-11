using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputBloom : MonoBehaviour
{
    // references to objects to modify
    public RenderEffectBloom bloomScript;
    public Renderer render;

    // intervals to change values by
    public float bloomInterval = 5.0f;
    public float luminanceInterval = 0.05f;
    public float outlineInterval = 0.05f;
    private float thickness = 0.6f;

    // UI input fields to read from for editing outline color

    void Start()
    {
        // get reference to bloom shader
        render.material.shader = Shader.Find("Custom/Outline");
    }

    void Update()
    {
        // controls for bloom factor
        if(Input.GetKey("up"))
        {
            bloomScript.BloomFactor += bloomInterval;
        }
        else if(Input.GetKey("down"))
        {
            bloomScript.BloomFactor -= bloomInterval;
        }

        // controls for luminance threshold
        if(Input.GetKey("q"))
        {
            bloomScript.LuminanceThreshold += luminanceInterval;
        }
        else if(Input.GetKey("w"))
        {
            bloomScript.LuminanceThreshold -= luminanceInterval;
        }
        
        // controls for outline thickness
        if(Input.GetKey("right"))
        {
            thickness += outlineInterval;
            render.material.SetFloat("_OutlineThickness", thickness);
        }
        else if(Input.GetKey("left"))
        {
            thickness -= outlineInterval;
            render.material.SetFloat("_OutlineThickness", thickness);
        }
    }
}
