﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class SSSSSCamera : MonoBehaviour
{
    #region MASK_SPACE
    Camera cam;
    Material mat;
    CommandBuffer buffer;
    // Use this for initialization
    void Awake()
    {

        cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.Depth;
        blendTexID = Shader.PropertyToID("_BlendTex");
        blendTex1ID = Shader.PropertyToID("_BlendTex1");
        mat = new Material(Shader.Find("Hidden/SSSSS"));
        blendWeightID = Shader.PropertyToID("_BlendWeight");
        blendWeight1ID = Shader.PropertyToID("_BlendWeight1");
        blendWeight2ID = Shader.PropertyToID("_BlendWeight2");

        int blur1ID = Shader.PropertyToID("_Blur1Tex");
        int blur2ID = Shader.PropertyToID("_Blur2Tex");
        Shader.SetGlobalVector(blendWeightID, new Vector4(0.33f, 0.45f, 0.36f));
        Shader.SetGlobalVector(blendWeight1ID, new Vector4(0.34f, 0.19f));
        Shader.SetGlobalVector(blendWeight2ID, new Vector4(0.46f, 0f, 0.04f));
        buffer = new CommandBuffer();
        buffer.name = "SSSSS";
        buffer.GetTemporaryRT(blendTexID, Screen.width, Screen.height, 24);
        buffer.GetTemporaryRT(blendTex1ID, Screen.width, Screen.height, 24);
        buffer.GetTemporaryRT(blur1ID, Screen.width, Screen.height, 24);
        buffer.GetTemporaryRT(blur2ID, Screen.width, Screen.height, 24);
        buffer.Blit(BuiltinRenderTextureType.CameraTarget, blendTexID);
        buffer.Blit(blendTexID, blur1ID, mat, 0);
        buffer.Blit(blur1ID, blur2ID, mat, 1);
        buffer.Blit(blur2ID, blendTex1ID, mat, 2);

        buffer.Blit(blendTex1ID, blur1ID, mat, 0);
        buffer.Blit(blur1ID, blur2ID, mat, 1);
        buffer.Blit(blur2ID, blendTexID, mat, 3);

        buffer.Blit(blendTexID, blur1ID, mat, 0);
        buffer.Blit(blur1ID, blur2ID, mat, 1);
        buffer.Blit(blur2ID, BuiltinRenderTextureType.CameraTarget, mat, 4);
        buffer.ReleaseTemporaryRT(blendTexID);
        buffer.ReleaseTemporaryRT(blendTex1ID);
        buffer.ReleaseTemporaryRT(blur1ID);
        buffer.ReleaseTemporaryRT(blur2ID);
    }

    void OnEnable()
    {
        cam.AddCommandBuffer(CameraEvent.AfterForwardOpaque, buffer);
    }

    void OnDisable()
    {
        cam.RemoveCommandBuffer(CameraEvent.AfterForwardOpaque, buffer);
    }

    #endregion

    #region POST_PROCESS

    int blendTexID;
    int blendTex1ID;
    int blendWeightID;
    int blendWeight1ID;
    int blendWeight2ID;

    #endregion
}
