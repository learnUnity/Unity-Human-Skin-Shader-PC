SubSurface Scattering Skin!
===========================
# Features:
* Custom Lighting model for sub surface diffuse, specular & semi-transparency.
* Screen-Space SSS supported.
* Physically based textures.
* Tessellation supported.

# TODO:
* Do not support Mobile platform currently!
* Only support realistic style shading!
* Do not support deferred rendering path currently!

# Tutorial:
* The SubSurface Skin's shading is based on a physically based shader without direct or indirect specular color and a replace shader with only direct and indrect specular color. Thus, you have to use the given shader in the demo scene and attach a "SSSSSCamera" component under the camera which you want to have screen-space SSS effect.
* It is confusion that in the example material, 4 normal maps were used. The principle and philosophy of using 4 normal map is simple to understand. Our skin is made by several different layers with different physical materials, for example: epidermis, vascular， genuine leather and so on. So the specular color reflected from skin will be different from others rigid objects. You want to have a non-blured main normal map, a blured main normal map, a non-blured detail map and a blured detail map to simulate the complex light reflection under the skin. You don't have to worry about the algorithm's performance inside the shader, The shader will use forward rendering path with a well-optimized lighting algorithm based on GGX.
* There is a "Screen Space Blur map" and "Blur intensity" at the end of the material's setting. Because of the specular color will be blured by post processing component, you should have a map to determine the intensity of blur. Usually, the the blur should be stronger on skin with more grease, for example a drunked big man:). You can adjust the "blur instensity" on play mode to test the different from lower blur value or higher.
* If you have any question, please contact author by Email: gengy@msoe.edu, Thank you.