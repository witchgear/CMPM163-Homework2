using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputHills : MonoBehaviour
{
    public float mouseSensitivity = 1;
    private Transform cameraT;

    public Transform hills;
    public float hillsIncrement;

    public Renderer render;
    public float displaceIncrement;
    private float displacement = 2.6f;

    void Start()
    {
        cameraT = GetComponent<Transform>();
        render.material.shader = Shader.Find("Custom/HillFromTexture");
    }

    void Update()
    {
        // move camera based on mouse movement
        float xMove = -1 * Input.GetAxis("Mouse Y") * mouseSensitivity;
        float yMove = Input.GetAxis("Mouse X") * mouseSensitivity;
        cameraT.Rotate(xMove, yMove, 0);

        // undo any camera movement on the Z axis
        float zMove = cameraT.eulerAngles.z;
        cameraT.Rotate(0, 0, -1 * zMove);
        
        // rotate the hills with the arrow keys
        if(Input.GetKey("w"))
        {
            hills.Rotate(hillsIncrement * -1, 0, 0);
        } 
        else if(Input.GetKey("s"))
        {
            hills.Rotate(hillsIncrement, 0, 0);
        }
        else if(Input.GetKey("a"))
        {
            hills.Rotate(0, hillsIncrement * -1, 0);
        }
        else if(Input.GetKey("d"))
        {
            hills.Rotate(0, hillsIncrement, 0);
        }

        // undo any hills movement on the Z axis
        zMove = hills.eulerAngles.z;
        hills.Rotate(0, 0, -1 * zMove);

        // change hills displacement with 1/2
        if(Input.GetKey("1"))
        {
            displacement -= displaceIncrement;
            render.material.SetFloat("_DisplacementAmt", displacement);
        }
        else if(Input.GetKey("2"))
        {
            displacement += displaceIncrement;
            render.material.SetFloat("_DisplacementAmt", displacement);
        }
    }
}
