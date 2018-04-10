using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent (typeof(Camera))]
public class SSSSSCamera : MonoBehaviour
{
	#region MASK_SPACE

	private int width;
	private int height;
	Camera cam;
	Camera depthCam;
	Shader depthShader;
	Material mat;
	RenderTexture depthRT;
	[Range (0.02f, 1000)]
	public float effectDistance = 50;

	// Use this for initialization
	void Awake ()
	{
		width = Screen.width;
		height = Screen.height;
		cam = GetComponent<Camera> ();
		cam.depthTextureMode |= DepthTextureMode.Depth;
		var camG = new GameObject ("Depth Camera", typeof(Camera));
		depthCam = camG.GetComponent<Camera> ();
		depthCam.CopyFrom (cam);
		camG.transform.SetParent (transform);
		camG.transform.localPosition = Vector3.zero;
		camG.transform.localRotation = Quaternion.identity;
		camG.transform.localScale = Vector3.one;
		camG.hideFlags = HideFlags.HideAndDontSave;
		depthCam.renderingPath = RenderingPath.Forward;
		depthCam.SetReplacementShader (Shader.Find ("Hidden/SSSSSReplace"), "RenderType");
		depthCam.farClipPlane = Mathf.Min(effectDistance,cam.farClipPlane);
		depthCam.clearFlags = CameraClearFlags.Color;
		depthCam.backgroundColor = new Color (0,0,0, 0);
		depthCam.depthTextureMode = DepthTextureMode.None;
		depthCam.enabled = false;
		depthRT = new RenderTexture (Screen.width, Screen.height, 24, RenderTextureFormat.RGFloat);
		depthCam.targetTexture = depthRT;
		blendTexID = Shader.PropertyToID ("_BlendTex");
		mat = new Material (Shader.Find ("Hidden/SSSSS"));
		blendWeightID = Shader.PropertyToID ("_BlendWeight");
		signID = Shader.PropertyToID("_Sign");
	}

	void OnPreRender ()
	{	
		//depthCam.projectionMatrix = cam.projectionMatrix;
		depthCam.Render ();
		if ((width != Screen.width) || (height != Screen.height)) {
			depthRT.Release ();
			depthRT.width = Screen.width;
			depthRT.height = Screen.height;
			width = Screen.width;
			height = Screen.height;
		}
	}

	void OnDestroy ()
	{
		Destroy (depthRT);
		if (depthCam)
			Destroy (depthCam.gameObject);
	}

	#endregion

	#region POST_PROCESS
	int signID;
	int blendTexID;
	int blendWeightID;


	void OnRenderImage (RenderTexture src, RenderTexture dest)
	{
		RenderTexture origin = RenderTexture.GetTemporary (src.descriptor);
		RenderTexture blur1 = RenderTexture.GetTemporary (src.descriptor);
		RenderTexture blur2 = RenderTexture.GetTemporary (src.descriptor);
		mat.SetTexture(signID, depthRT);

		mat.SetTexture (blendTexID, src);
		mat.SetVector (blendWeightID, new Vector4 (0.33f, 0.45f, 0.36f));
		Graphics.Blit (src, blur1, mat, 0);
		Graphics.Blit (blur1, blur2, mat, 1);
		Graphics.Blit (blur2, origin, mat, 2);

		mat.SetTexture (blendTexID, origin);
		mat.SetVector (blendWeightID, new Vector4 (0.34f, 0.19f));
		Graphics.Blit (origin, blur1, mat, 0);
		Graphics.Blit (blur1, blur2, mat, 1);
		Graphics.Blit (blur2, src, mat, 2);

		mat.SetTexture (blendTexID, src);
		mat.SetVector (blendWeightID, new Vector4 (0.46f, 0f, 0.04f));
		Graphics.Blit (src, blur1, mat, 0);
		Graphics.Blit (blur1, blur2, mat, 1);
		Graphics.Blit (blur2, dest, mat, 2);

		RenderTexture.ReleaseTemporary (blur1);
		RenderTexture.ReleaseTemporary (blur2);
		RenderTexture.ReleaseTemporary (origin);
	}

	#endregion
}
