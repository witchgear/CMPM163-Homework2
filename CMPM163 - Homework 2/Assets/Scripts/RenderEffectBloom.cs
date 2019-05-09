using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderEffectBloom : MonoBehaviour
{

    public Shader BloomShader;
    [Range(0.0f, 100.0f)]
    public float BloomFactor;
    [Range(0.0f, 1.0f)]
    public float LuminanceThreshold;
    private Material screenMat;

    Material ScreenMat
    {
        get
        {
            if (screenMat == null)
            {
                screenMat = new Material(BloomShader);
                screenMat.hideFlags = HideFlags.HideAndDontSave;
            }
            return screenMat;
        }
    }


    void Start()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }

        if (!BloomShader && !BloomShader.isSupported)
        {
            enabled = false;
        }
       
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (BloomShader != null)
        {

            // Create two temp rendertextures to hold bright pass and blur pass result
            RenderTexture rt1 = RenderTexture.GetTemporary(sourceTexture.width, sourceTexture.height);
            RenderTexture rt2 = RenderTexture.GetTemporary(sourceTexture.width, sourceTexture.height);

            // Set LuminanceThreshold to _Threshold in shader
            ScreenMat.SetFloat("_Threshold", LuminanceThreshold);

            // Blit using bloom shader pass 0 for bright pass ( Graphics.Blit(SOURCE, DESTINATION, MATERIAL, PASS INDEX);)
            Graphics.Blit(sourceTexture, rt1, ScreenMat, 0);

            // Set BloomFactor to _Steps in the shader
            ScreenMat.SetFloat("_Steps", BloomFactor);

            // Blit using bloom shader pass 1 for blur pass ( Graphics.Blit(SOURCE, DESTINATION, MATERIAL, PASS INDEX);)
            Graphics.Blit(rt1, rt2, ScreenMat, 1);

            // Set sourceTexture to _BaseTex in the shader
            ScreenMat.SetTexture("_BaseTex", sourceTexture);

            // Blit using bloom shader pass 2 for combine pass ( Graphics.Blit(SOURCE, DESTINATION, MATERIAL, PASS INDEX);)
            Graphics.Blit(rt2, destTexture, ScreenMat, 2);

            // Release both temp rendertextures
            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);

        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }

    // Update is called once per frame
    void Update()
    {

    }

    void OnDisable()
    {
        if (screenMat)
        {
            DestroyImmediate(screenMat);
        }
    }
}
