Shader "MStudio/Skin" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_NormalScale("Normal Scale", float) = 1
		_SpecularMap("Specular Map", 2D) = "white"{}
		//_HeightScale("Height Scale", Range(-4,4)) = 1
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_OcclusionMap("Occlusion Map", 2D) = "white"{}
		_Occlusion("Occlusion Scale", Range(0,1)) = 1
    _ThickMap("Thick Map", 2D) = "black"{}
		_SpecularColor("Specular Color",Color) = (0.2,0.2,0.2,1)
		_EmissionColor("Emission Color", Color) = (0,0,0,1)
		_DetailAlbedo("Detail Albedo(RGB)", 2D) = "black"{}
		_AlbedoBlend("Albedo Blend Rate", Range(0,1)) = 0.3
		_DetailBump("Secondary Normal(RGB)", 2D) = "bump"{}
    _DetailNormalScale("Secondary Normal Scale", float) = 1
  	_ThirdBump("Third Normal(RGB)", 2D) = "bump" {}
    _ThirdNormalScale("Third Normal Scale", float) = 1
    _FourthBump("Fourth Normal(RGB)", 2D) = "bump"{}
    _FourthNormalScale("Fourth Normal Scale", float) = 1
		_RampTex("Ramp light texture", 2D) = "white"{}
		_BloodValue("Blood Value", Range(0.01, 1)) = 0.5
    _Power("Power of SSS", Range(0.1,10)) = 1
    _SSColor("SSS Color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		
	// ------------------------------------------------------------
	// Surface shader code generated out of a CGPROGRAM block:
CGINCLUDE

#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"
#include "UnityMetaPass.cginc"
#include "AutoLight.cginc"

#pragma shader_feature USE_NORMAL
#pragma shader_feature USE_SPECULAR
#pragma shader_feature USE_VERTEX
#pragma shader_feature USE_PHONG
#pragma shader_feature USE_OCCLUSION
#pragma shader_feature USE_ALBEDO
#pragma shader_feature USE_DETAILALBEDO
#pragma shader_feature USE_DETAILNORMAL

#ifdef POINT
#define UNITY_LIGHT_ATTENUATION(destName, attenNoShadow, input, worldPos) \
    unityShadowCoord3 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)).xyz; \
    float shadow = UNITY_SHADOW_ATTENUATION(input, worldPos); \
    float attenNoShadow = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;\
    float destName = attenNoShadow  * shadow;

#endif

#ifdef SPOT
#define UNITY_LIGHT_ATTENUATION(destName, attenNoShadow, input, worldPos) \
    unityShadowCoord4 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)); \
    float shadow = UNITY_SHADOW_ATTENUATION(input, worldPos); \
    float attenNoShadow =  step(0,lightCoord.z) * UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord.xyz);\
    float destName = attenNoShadow * shadow;
#endif

#ifdef DIRECTIONAL
    #define UNITY_LIGHT_ATTENUATION(destName, attenNoShadow, input, worldPos) float attenNoShadow = 1; float destName = UNITY_SHADOW_ATTENUATION(input, worldPos);
#endif

#ifdef POINT_COOKIE

#define UNITY_LIGHT_ATTENUATION(destName, attenNoShadow, input, worldPos) \
    unityShadowCoord3 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)).xyz; \
    float shadow = UNITY_SHADOW_ATTENUATION(input, worldPos); \
    float attenNoShadow = tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL * texCUBE(_LightTexture0, lightCoord).w;
    float destName = attenNoShadow * shadow;
#endif

#ifdef DIRECTIONAL_COOKIE

#define UNITY_LIGHT_ATTENUATION(destName, attenNoShadow, input, worldPos) \
    unityShadowCoord2 lightCoord = mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)).xy; \
    float shadow = UNITY_SHADOW_ATTENUATION(input, worldPos); \
    float attenNoShadow = tex2D(_LightTexture0, lightCoord).w;
    float destName = attenNoShadow * shadow;
#endif




		struct Input {
			float2 uv_MainTex;
			#if USE_DETAILALBEDO
			float2 uv_DetailAlbedo;
			#endif
		};
		
        float4 _SpecularColor;
        float4 _EmissionColor;

		float _NormalScale;
		float _Occlusion;

		float _BloodValue;
		float _Power;
		float _Thickness;
    sampler2D _ThickMap;
    float _DetailNormalScale;
    float _ThirdNormalScale;
    float _FourthNormalScale;

		sampler2D _DetailAlbedo;
		float _AlbedoBlend;
		sampler2D _DetailBump;
    sampler2D _ThirdBump;
    sampler2D _FourthBump;

		float4 _DetailAlbedo_ST;
		float4 _DetailBump_ST;
    float4 _ThirdBump_ST;
    float4 _FourthBump_ST;
    float4 _SSColor;
		sampler2D _BumpMap;
		sampler2D _SpecularMap;
		sampler2D _OcclusionMap;
		sampler2D _RampTex;
		sampler2D _MainTex;
		half _Glossiness;
		float4 _Color;

		inline void surf (Input IN, inout SurfaceOutputStandardSpecular o) {
			// Albedo comes from a texture tinted by color
			float2 uv = IN.uv_MainTex;// - parallax_mapping(IN.uv_MainTex,IN.viewDir);
			#if USE_ALBEDO
			float4 c = tex2D (_MainTex, uv) * _Color;

			#if USE_DETAILALBEDO
			float4 dA = tex2D(_DetailAlbedo, IN.uv_DetailAlbedo);
			c.rgb = lerp(c.rgb, dA.rgb, _AlbedoBlend);
			#endif
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			#else
			#if USE_DETAILALBEDO
			float4 dA = tex2D(_DetailAlbedo, IN.uv_DetailAlbedo);
			o.Albedo.rgb = lerp(1, dA.rgb, _AlbedoBlend) * _Color;
			#else
			o.Albedo = _Color.rgb;
			o.Alpha = _Color.a;
			#endif
			#endif

			#if USE_OCCLUSION
			o.Occlusion = lerp(1, tex2D(_OcclusionMap, IN.uv_MainTex).r, _Occlusion);
			#else
			o.Occlusion = 1;
			#endif

			#if USE_SPECULAR
			float4 spec = tex2D(_SpecularMap, IN.uv_MainTex);
			o.Specular = _SpecularColor  * spec.rgb;
			o.Smoothness = _Glossiness * spec.a;
			#else
			o.Specular = _SpecularColor;
			o.Smoothness = _Glossiness;
			#endif


			#if USE_NORMAL
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
			o.Normal.xy *= _NormalScale;
			#else
			o.Normal = float3(0,0,1);
			#endif
			#if UNITY_PASS_FORWARDBASE
			o.Emission = _EmissionColor;
			#endif
		}


inline float4 Skin_GGXVisibilityTerm (float4 NdotL, float4 NdotV, float roughness)
{
    float a = roughness;
    float4 lambdaV = NdotL * (NdotV * (1 - a) + a);
    float4 lambdaL = NdotV * (NdotL * (1 - a) + a);
    return 0.5f / (lambdaV + lambdaL + 1e-5f);
}

inline float4 Skin_GGXTerm (float4 NdotH, float roughness)
{
    float a2 = roughness * roughness;
    float4 d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
    return UNITY_INV_PI * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile,
                                            // therefore epsilon is smaller than what can be represented by half
}

inline float4 Pow_5 (float4 x)
{
    return x*x * x*x * x;
}

inline float3 FresnelLerp (float3 F0, float3 F90, float4 cosA)
{
    float4 t = Pow_5 (1 - cosA);   // ala Schlick interpoliation
    return lerp (F0, F90, (t.x + t.y + t.z + t.w) * 0.25);
}

#define BLOODCOLOR(NdotL)\
	float4 NdotLInDiff = NdotL * 0.5 + 0.5;\
	float3 diffuse = (tex2D(_RampTex, float2(NdotLInDiff.x, _BloodValue)) + tex2D(_RampTex, float2(NdotLInDiff.y, _BloodValue)) + tex2D(_RampTex, float2(NdotLInDiff.z, _BloodValue)) + tex2D(_RampTex, float2(NdotLInDiff.w, _BloodValue))).xyz * 0.25;

float3 BRDF (float3 diffColor, float3 specColor, float oneMinusReflectivity, float smoothness,
    float3 normal0, float3 normal1, float3 normal2, float3 normal3, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{
    float perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    float3 floatDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

    float4 nv = float4(dot(normal0, viewDir), dot(normal1, viewDir), dot(normal2, viewDir), dot(normal3, viewDir));    // This abs allow to limit artifact

    float4 nl = saturate(float4(dot(normal0, light.dir), dot(normal1, light.dir), dot(normal2, light.dir), dot(normal3, light.dir)));
    float4 nh = saturate(float4(dot(normal0, floatDir), dot(normal1, floatDir), dot(normal2, floatDir), dot(normal3, floatDir)));

    float lh = saturate(dot(light.dir, floatDir));
    BLOODCOLOR(nl);

    float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

    // GGX with roughtness to 0 would mean no specular at all, using max(roughness, 0.002) here to match HDrenderloop roughtness remapping.
    roughness = max(roughness, 0.002);
    #if defined(_SPECULARHIGHLIGHTS_OFF)
    float specularTerm = 0.0;
    #else
    float4 V = Skin_GGXVisibilityTerm (nl, nv, roughness);
    float4 D = Skin_GGXTerm (nh, roughness);

    float4 allSpecularTerm = V*D * UNITY_PI;
    float specularTerm = (allSpecularTerm.x + allSpecularTerm.y + allSpecularTerm.z + allSpecularTerm.w) * 0.25; // Torrance-Sparrow model, Fresnel is applied later

#   ifdef UNITY_COLORSPACE_GAMMA
        specularTerm = sqrt(max(1e-4h, specularTerm));
#   endif

    // specularTerm * nl can be NaN on Metal in some cases, use max() to make sure it's a sane value
    specularTerm = max(0, specularTerm * nl);
    #endif

    #if UNITY_PASS_FORWARDADD
     half3 color =   (diffColor * diffuse + specularTerm * FresnelTerm (specColor, lh)) * light.color;
    #else
    float surfaceReduction;
#   ifdef UNITY_COLORSPACE_GAMMA
        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
#   else
        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
#   endif
    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    float3 color =   diffColor * (gi.diffuse + light.color * diffuse)
                    + specularTerm * light.color * FresnelTerm (specColor, lh)
                    + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);
    #endif
    return color;
}


inline float4 Skin_LightingStandardSpecular (SurfaceOutputStandardSpecular s, float3 normal1, float3 normal2, float3 normal3, float3 viewDir, UnityGI gi)
{

    // energy conservation
    float oneMinusReflectivity;
    s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);

    // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
    float outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

    float4 c = float4(BRDF (s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, normal1, normal2, normal3, viewDir, gi.light, gi.indirect), outputAlpha);
    return c;
}




inline float3 SubTransparentColor(float3 lightDir, float3 viewDir, float3 lightColor, float3 pointDepth){
	float VdotH = pow(saturate(dot(viewDir, -lightDir) + 0.5), _Power);
	return lightColor * VdotH * pointDepth * _SSColor;
}

ENDCG
	// ---- forward rendering base pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0

#pragma multi_compile_fog
#pragma multi_compile_fwdbase

// -------- variant for: <when no other keywords are defined>
#if !defined(INSTANCING_ON)
// Surface shader code generated based on:
// vertex modifier: 'disp'
// writes to per-pixel normal: YES
// writes to emission: YES
// writes to occlusion: YES
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: YES
// reads from normal: no
// 1 texcoords actually used
//   float2 _MainTex


#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) float3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

// Original surface shader snippet:
#line 22 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif
// vertex-to-fragment interpolation data
// no lightmaps:
#ifndef LIGHTMAP_ON
struct v2f_surf {
  UNITY_POSITION(pos);
  float2 pack0 : TEXCOORD0; // _MainTex
  float4 tSpace0 : TEXCOORD1;
  float4 tSpace1 : TEXCOORD2;
  float4 tSpace2 : TEXCOORD3;

  #if UNITY_SHOULD_SAMPLE_SH
  half3 sh : TEXCOORD4; // SH
  #endif
  UNITY_SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)
  #if SHADER_TARGET >= 30
  float4 lmap : TEXCOORD7;
  #endif

  #if USE_DETAILALBEDO
  float2 pack1 : TEXCOORD8;
  #endif

  float2 pack2 : TEXCOORD9;

  float3 worldViewDir : TEXCOORD10;
  float3 lightDir : TEXCOORD11;
  float4 screenPos : TEXCOORD12;
  float2 pack3 : TEXCOORD13;
  float2 pack4 : TEXCOORD14;
};
#endif
// with lightmaps:
#ifdef LIGHTMAP_ON
struct v2f_surf {
  UNITY_POSITION(pos);
  float2 pack0 : TEXCOORD0; // _MainTex
  float4 tSpace0 : TEXCOORD1;
  float4 tSpace1 : TEXCOORD2;
  float4 tSpace2 : TEXCOORD3;

  float4 lmap : TEXCOORD4;
  UNITY_SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)


    #if USE_DETAILALBEDO
  float2 pack1 : TEXCOORD7;
  #endif


  float2 pack2 : TEXCOORD8;

  float3 worldViewDir : TEXCOORD9;
  float3 lightDir : TEXCOORD10;
  float4 screenPos : TEXCOORD11;
  float2 pack3 : TEXCOORD12;
  float2 pack4 : TEXCOORD13;
};
#endif
float4 _MainTex_ST;

// vertex shader
inline v2f_surf vert_surf (appdata_full v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);

 
  o.pos = UnityObjectToClipPos(v.vertex);
  o.screenPos = ComputeScreenPos(o.pos);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  o.worldViewDir = (UnityWorldSpaceViewDir(worldPos));
  float3 worldNormal = UnityObjectToWorldNormal(v.normal);
  float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  float3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  #if USE_DETAILALBEDO
 o.pack1 = TRANSFORM_TEX(v.texcoord,_DetailAlbedo);
  #endif

  o.pack2 = TRANSFORM_TEX(v.texcoord, _DetailBump);
  o.pack3 = TRANSFORM_TEX(v.texcoord, _ThirdBump);
  o.pack4 = TRANSFORM_TEX(v.texcoord, _FourthBump);
   o.tSpace0 = (float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x));
  o.tSpace1 = (float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y));
  o.tSpace2 = (float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z));
    
  #ifdef DYNAMICLIGHTMAP_ON
  o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  #endif
  #ifdef LIGHTMAP_ON
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif

  // SH/ambient and vertex lights
  #ifndef LIGHTMAP_ON
    #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
      o.sh = 0;
      // Approximated illumination from non-important point lights
      #ifdef VERTEXLIGHT_ON
        o.sh += Shade4PointLights (
          unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
          unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
          unity_4LightAtten0, worldPos, worldNormal);
      #endif
      o.sh = ShadeSHPerVertex (worldNormal, o.sh);
    #endif
  #endif // !LIGHTMAP_ON

  UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
    #ifndef USING_DIRECTIONAL_LIGHT
    o.lightDir = (UnityWorldSpaceLightDir(worldPos));
  #else
    o.lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  return o;
}


// fragment shader
inline float4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  
  surfIN.uv_MainTex = IN.pack0.xy;
  #if USE_DETAILALBEDO
  surfIN.uv_DetailAlbedo = IN.pack1;
  #endif

  float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
  float3 lightDir = normalize(IN.lightDir);
  float3 worldViewDir = normalize(IN.worldViewDir);
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
  #else
  SurfaceOutputStandardSpecular o;
  #endif
  float3x3 wdMatrix= float3x3(  normalize(IN.tSpace0.xyz),  normalize(IN.tSpace1.xyz),  normalize(IN.tSpace2.xyz));
  // call surface function
  surf (surfIN, o);
  float3 detailNormal = UnpackNormal(tex2D(_DetailBump, IN.pack2));
  detailNormal.xy *= _DetailNormalScale;
  detailNormal = normalize(mul(wdMatrix, detailNormal));
  float3 thirdNormal = UnpackNormal(tex2D(_ThirdBump, IN.pack3));
  thirdNormal.xy *= _ThirdNormalScale;
  thirdNormal = normalize(mul(wdMatrix, thirdNormal));
  float3 fourthNormal = UnpackNormal(tex2D(_FourthBump, IN.pack4));
  fourthNormal.xy *= _FourthNormalScale;
  fourthNormal = normalize(mul(wdMatrix, fourthNormal));


  // compute lighting & shadowing factor
  UNITY_LIGHT_ATTENUATION(atten, attenNoShadow, IN, worldPos)
  float4 c = 0;

  o.Normal = normalize(mul(wdMatrix, o.Normal));

  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.light.color = _LightColor0.rgb;
 // float3 bloodColor = BloodColor(o.Normal, lightDir) * o.Albedo * gi.light.color;
  gi.light.dir = lightDir;
  //TODO
  //Didn't finish yet
  //float3 transparentColor = SubTransparentColor(lightDir, worldViewDir,  _LightColor0.rgb, thickness);
  // Call GI (lightmaps/SH/reflections) lighting function
  UnityGIInput giInput;
  UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
  giInput.light = gi.light;
  giInput.worldPos = worldPos;
  giInput.worldViewDir = worldViewDir;
  giInput.atten = atten;
  #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    giInput.lightmapUV = IN.lmap;
  #else
    giInput.lightmapUV = 0.0;
  #endif
  #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
    giInput.ambient = IN.sh;
  #else
    giInput.ambient.rgb = 0.0;
  #endif
  giInput.probeHDR[0] = unity_SpecCube0_HDR;
  giInput.probeHDR[1] = unity_SpecCube1_HDR;
  #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
    giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
  #endif
  #ifdef UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
  #endif
  LightingStandardSpecular_GI(o, giInput, gi);
  // realtime lighting: call lighting function
  c += Skin_LightingStandardSpecular (o, detailNormal, thirdNormal, fourthNormal, worldViewDir, gi);
  float3 subTrans = SubTransparentColor(lightDir, worldViewDir, _LightColor0.rgb * attenNoShadow, tex2D(_ThickMap, IN.pack0));
  //float spec =  specColor(worldViewDir, lightDir, o.Normal);
  c.rgb += o.Emission + subTrans;//+ transparentColor

  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  UNITY_OPAQUE_ALPHA(c.a);
  return c;
}


#endif

ENDCG

}

	// ---- forward rendering additive lights pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardAdd" }
		ZWrite Off Blend One One

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0

#pragma multi_compile_fog
#pragma skip_variants INSTANCING_ON
#pragma multi_compile_fwdadd_fullshadows

// -------- variant for: <when no other keywords are defined>
#if !defined(INSTANCING_ON)
// Surface shader code generated based on:
// vertex modifier: 'disp'
// writes to per-pixel normal: YES
// writes to emission: YES
// writes to occlusion: YES
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: YES
// reads from normal: no
// 1 texcoords actually used
//   float2 _MainTex

#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) float3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

// Original surface shader snippet:
#line 22 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

		

// vertex-to-fragment interpolation data
struct v2f_surf {
  UNITY_POSITION(pos);
  float2 pack0 : TEXCOORD0; // _MainTex
  float3 tSpace0 : TEXCOORD1;
  float3 tSpace1 : TEXCOORD2;
  float3 tSpace2 : TEXCOORD3;
  float3 worldPos : TEXCOORD4;
  UNITY_SHADOW_COORDS(5)
  UNITY_FOG_COORDS(6)

   #if USE_DETAILALBEDO
  float2 pack1 : TEXCOORD7;
  #endif


  float2 pack2 : TEXCOORD8;

  float3 worldViewDir : TEXCOORD9;
  float3 lightDir : TEXCOORD10;
  float4 screenPos : TEXCOORD11;
  float2 pack3 : TEXCOORD12;
  float2 pack4 : TEXCOORD13;
};
float4 _MainTex_ST;

// vertex shader
inline v2f_surf vert_surf (appdata_full v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
 
 o.pos = UnityObjectToClipPos(v.vertex);
  o.screenPos = ComputeScreenPos(o.pos);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  #if USE_DETAILALBEDO
  o.pack1 = TRANSFORM_TEX(v.texcoord,_DetailAlbedo);
  #endif

  o.pack2 = TRANSFORM_TEX(v.texcoord, _DetailBump);
  o.pack3 = TRANSFORM_TEX(v.texcoord, _ThirdBump);
  o.pack4 = TRANSFORM_TEX(v.texcoord, _FourthBump);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  o.worldViewDir = (UnityWorldSpaceViewDir(worldPos));
  float3 worldNormal = UnityObjectToWorldNormal(v.normal);
  float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  float3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  o.tSpace0 = (float3(worldTangent.x, worldBinormal.x, worldNormal.x));
  o.tSpace1 = (float3(worldTangent.y, worldBinormal.y, worldNormal.y));
  o.tSpace2 = (float3(worldTangent.z, worldBinormal.z, worldNormal.z));
      
  o.worldPos = worldPos;
      #ifndef USING_DIRECTIONAL_LIGHT
    o.lightDir = (UnityWorldSpaceLightDir(worldPos));
  #else
    o.lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
  return o;
}

// fragment shader
inline float4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  
  surfIN.uv_MainTex = IN.pack0.xy;
    #if USE_DETAILALBEDO
  surfIN.uv_DetailAlbedo = IN.pack1;
  #endif

  float3 worldPos = (IN.worldPos);
  float3 lightDir = normalize(IN.lightDir);
  float3 worldViewDir = normalize(IN.worldViewDir);
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
  #else
  SurfaceOutputStandardSpecular o;
  #endif
  float3x3 wdMatrix= float3x3(  normalize(IN.tSpace0.xyz),  normalize(IN.tSpace1.xyz),  normalize(IN.tSpace2.xyz));
  // call surface function
  surf (surfIN, o);
  float3 detailNormal = UnpackNormal(tex2D(_DetailBump, IN.pack2));
  detailNormal.xy *= _DetailNormalScale;
  detailNormal = normalize(mul(wdMatrix, detailNormal));
  float3 thirdNormal = UnpackNormal(tex2D(_ThirdBump, IN.pack3));
  thirdNormal.xy *= _ThirdNormalScale;
  thirdNormal = normalize(mul(wdMatrix, thirdNormal));
  float3 fourthNormal = UnpackNormal(tex2D(_FourthBump, IN.pack4));
  fourthNormal.xy *= _FourthNormalScale;
  fourthNormal = normalize(mul(wdMatrix, fourthNormal));
  UNITY_LIGHT_ATTENUATION(atten, attenNoShadow, IN, worldPos)
  float4 c = 0;

  o.Normal = normalize(mul(wdMatrix, o.Normal));

  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.light.color = _LightColor0.rgb * atten;
  gi.light.dir = lightDir;
  //TODO
  //Didn't finish yet
 // float3 transparentColor = SubTransparentColor(lightDir, worldViewDir,  _LightColor0.rgb, thickness);
  float3 subTrans = SubTransparentColor(lightDir, worldViewDir, _LightColor0.rgb * attenNoShadow, tex2D(_ThickMap, IN.pack0));
  c += Skin_LightingStandardSpecular (o, detailNormal, thirdNormal, fourthNormal, worldViewDir, gi);
  c.rgb += subTrans;
  // float spec =  specColor(worldViewDir, lightDir, o.Normal);
//  c.rgb +=  transparentColor;
  c.a = 0.0;
  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  UNITY_OPAQUE_ALPHA(c.a);
  return c;
}


#endif


ENDCG

}

Pass {
		Name "ShadowCaster"
		Tags { "LightMode" = "ShadowCaster" }
		ZWrite On ZTest Less

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf

#pragma target 3.0

#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma multi_compile_shadowcaster

// -------- variant for: <when no other keywords are defined>
#if !defined(INSTANCING_ON)


#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

// Original surface shader snippet:
#line 10 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

struct v2f_surf {
  V2F_SHADOW_CASTER;
};

// vertex shader
inline v2f_surf vert_surf (appdata_base v) {
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
  return o;
}

// fragment shader
inline float4 frag_surf (v2f_surf IN) : SV_Target {
 	SHADOW_CASTER_FRAGMENT(IN)
}


#endif

ENDCG

}
	// ---- meta information extraction pass:
	Pass {
		Name "Meta"
		Tags { "LightMode" = "Meta" }
		Cull Off

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0

#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma skip_variants INSTANCING_ON
#pragma shader_feature EDITOR_VISUALIZATION


// -------- variant for: <when no other keywords are defined>
#if !defined(INSTANCING_ON)


#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) float3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

// Original surface shader snippet:
#line 22 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif


// vertex-to-fragment interpolation data
struct v2f_surf {
  UNITY_POSITION(pos);
  float2 pack0 : TEXCOORD0; // _MainTex
  float4 tSpace0 : TEXCOORD1;
  float4 tSpace1 : TEXCOORD2;
  float4 tSpace2 : TEXCOORD3;
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO
};
float4 _MainTex_ST;

// vertex shader
inline v2f_surf vert_surf (appdata_full v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);

  o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  float3 worldNormal = UnityObjectToWorldNormal(v.normal);
  float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  float3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
   
  return o;
}

// fragment shader
inline float4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  
  surfIN.uv_MainTex = IN.pack0.xy;
  float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
  #else
  SurfaceOutputStandardSpecular o;
  #endif



  // call surface function
  surf (surfIN, o);
  UnityMetaInput metaIN;
  UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
  metaIN.Albedo = o.Albedo;
  metaIN.Emission = o.Emission;
  metaIN.SpecularColor = o.Specular;
  return UnityMetaFragment(metaIN);
}


#endif


ENDCG

}

	// ---- end of surface shader generated code

#LINE 90

	}
CustomEditor "SpecularShaderEditor"
}
