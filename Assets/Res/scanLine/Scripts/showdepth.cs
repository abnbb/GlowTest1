using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class showdepth : MonoBehaviour
{
    // Start is called before the first frame update
    public RenderTexture rt;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Shader.GetGlobalTexture("_CameraDepthTexture"))
        {
            Graphics.Blit(Shader.GetGlobalTexture("_CameraDepthTexture"), rt);
        }
    }

    void OnPostRender()
    {
       
        
    }
}
