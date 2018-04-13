// Creates a simple wizard that lets you create a Light GameObject
// or if the user clicks in "Apply", it will set the color of the currently
// object selected to red

using UnityEditor;
using System.IO;
using UnityEngine;

public class MixTexture : ScriptableWizard
{
	public string path = "Arts";
	public string fileName = "mixedTexture";
	public Texture2D target;

	[MenuItem ("Tools/Mix Texture")]
	static void CreateWizard ()
	{
		ScriptableWizard.DisplayWizard<MixTexture> ("Mix Texture", "Quit", "Create");
	}

	void OnWizardOtherButton ()
	{
		
			Texture2D example = new Texture2D (target.width, target.height, TextureFormat.RGBAFloat, true);
			var RColors = target.GetPixels ();
			var colors = new Color[RColors.Length];
	
			for (int i = 0; i < colors.Length; ++i) {
				colors [i] = new Color(1,1,1,1) - RColors[i];
			}
			
			example.SetPixels (colors);
			example.Apply ();
			SaveFileToPng (example, fileName);
			Debug.Log ("Success!");
	}

	void SaveFileToPng (Texture2D picture, string fileName)
	{
		string path1 = Application.dataPath + "/" + path + "/" + fileName + ".png";
		var binary = new BinaryWriter (new FileStream (path1, FileMode.Create));
		var bytes = picture.EncodeToPNG ();
		binary.Write (bytes);
		binary.Dispose ();
	}
}

public class ResizeTexture : ScriptableWizard
{
	public int width = 1024;
	public int height = 1024;
	public Texture2D[] texs;

	[MenuItem ("Tools/Resize Texture")]
	static void CreateWizard ()
	{
		ScriptableWizard.DisplayWizard<ResizeTexture> ("Resize Texture", "Mix");
	}

	void OnWizardCreate ()
	{
		foreach (var i in texs) {
			i.Resize (width, height);
		}
	}
}

public class CleanMesh : ScriptableWizard
{
	public MeshFilter[] meshFilter;
	public bool keepUV2 = true;
	public bool keepUV3 = true;
	public bool keepUV4 = true;
	public bool keepColors = true;
	[MenuItem ("Tools/Clean Mesh")]
	static void CreateWizard ()
	{
		ScriptableWizard.DisplayWizard<ResizeTexture> ("Clean Mesh","Clean");
	}

	void OnWizardCreate(){
		foreach (var m in meshFilter) {
			if (!keepUV2) {
				m.sharedMesh.uv2 = new Vector2[0];
			}
			if (!keepUV3)
				m.sharedMesh.uv3 = new Vector2[0];
			if (!keepUV4)
				m.sharedMesh.uv4 = new Vector2[0];
			if (!keepColors)
				m.sharedMesh.colors = new Color[0];
		}
	}
}