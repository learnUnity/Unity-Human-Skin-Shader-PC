#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"
#include "UnityMetaPass.cginc"
#include "AutoLight.cginc"

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
		float _MinDist;
		float _MaxDist;
		float _Tessellation;
		float _Phong;
		float _NormalScale;
		float _Occlusion;
		float _VertexScale;
		float _VertexOffset;
		float _BloodValue;

    float _DetailNormalScale;
    float _ThirdNormalScale;
    float _FourthNormalScale;
		float4 _SSColor;
    float _Power;
    float _Distortion;
		float _Thickness;
    sampler2D _ThickMap;
		float _MinDistance;
		sampler2D _DetailAlbedo;
		float _AlbedoBlend;
		sampler2D _DetailBump;
    sampler2D _ThirdBump;
    sampler2D _FourthBump;
		float4 _DetailAlbedo_ST;
		float4 _DetailBump_ST;
    float4 _ThirdBump_ST;
    float4 _FourthBump_ST;

		sampler2D _BumpMap;
		sampler2D _SpecularMap;
		sampler2D _HeightMap;
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


struct InternalTessInterp_appdata_full {
  float4 vertex : INTERNALTESSPOS;
  float4 tangent : TANGENT;
  float3 normal : NORMAL;
  float4 texcoord : TEXCOORD0;
  float4 texcoord1 : TEXCOORD1;
  float4 texcoord2 : TEXCOORD2;
};

struct appdata_fwdbase{
    float4 vertex : POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    float4 texcoord1 : TEXCOORD1;
    float4 texcoord2 : TEXCOORD2;
};

struct appdata_fwdadd{
    float4 vertex : POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    float4 texcoord1 : TEXCOORD1;
};

inline InternalTessInterp_appdata_full tessvert_surf (appdata_full v) {
  InternalTessInterp_appdata_full o;
  o.vertex = v.vertex;
  o.tangent = v.tangent;
  o.normal = v.normal;
  o.texcoord = v.texcoord;
  o.texcoord1 = v.texcoord1;
  o.texcoord2 = v.texcoord2;
  return o;
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
  float4 x2 = x * x;
  return x2 * x2 * x;
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

    float4 nl = float4(dot(normal0, light.dir), dot(normal1, light.dir), dot(normal2, light.dir), dot(normal3, light.dir));
    float4 nh = saturate(float4(dot(normal0, floatDir), dot(normal1, floatDir), dot(normal2, floatDir), dot(normal3, floatDir)));

    float lh = saturate(dot(light.dir, floatDir));
    BLOODCOLOR(nl);
    nl = saturate(nl);
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

float3 BRDFNoDiff (float3 specColor, float oneMinusReflectivity, float smoothness,
    float3 normal0, float3 normal1, float3 normal2, float3 normal3, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{
    float perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    float3 floatDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

    float4 nv = float4(dot(normal0, viewDir), dot(normal1, viewDir), dot(normal2, viewDir), dot(normal3, viewDir));    // This abs allow to limit artifact

    float4 nl = saturate(float4(dot(normal0, light.dir), dot(normal1, light.dir), dot(normal2, light.dir), dot(normal3, light.dir)));
    float4 nh = saturate(float4(dot(normal0, floatDir), dot(normal1, floatDir), dot(normal2, floatDir), dot(normal3, floatDir)));

    float lh = saturate(dot(light.dir, floatDir));

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
     float3 color =   specularTerm * FresnelTerm (specColor, lh) * light.color;
    #else
    float surfaceReduction;
#   ifdef UNITY_COLORSPACE_GAMMA
        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
#   else
        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
#   endif
    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    float3 color =   specularTerm * light.color * FresnelTerm (specColor, lh)
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

inline float4 Skin_Diffuse (SurfaceOutputStandardSpecular s, float3 normal1, float3 normal2, float3 normal3, UnityGI gi)
{

    // energy conservation
    float oneMinusReflectivity;
    s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);

    // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
    float outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);
    float4 nl = saturate(float4(dot(s.Normal, gi.light.dir), dot(normal1, gi.light.dir), dot(normal2,  gi.light.dir), dot(normal3,  gi.light.dir)));
    BLOODCOLOR(nl)
    #if UNITY_PASS_FORWARDBASE
    float3 color = s.Albedo * (gi.light.color * diffuse + gi.indirect.diffuse);
    #else
    float3 color = s.Albedo * gi.light.color * diffuse;
    #endif
    return float4(color,1);
}

inline float4 Skin_Specular (SurfaceOutputStandardSpecular s, float3 normal1, float3 normal2, float3 normal3, float3 viewDir, UnityGI gi)
{
    // energy conservation
    float oneMinusReflectivity;
    s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);

    // shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
    float outputAlpha;
    s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);
    float4 c = float4(BRDFNoDiff (s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, normal1, normal2, normal3, viewDir, gi.light, gi.indirect), outputAlpha);

    return c;
}


inline float3 SubTransparentColor(float3 lightDir, float3 normal0, float3 normal1, float3 normal2, float3 normal3, float3 viewDir, float3 lightColor, float3 pointDepth){
	float VdotH = pow(saturate(dot(viewDir, -normalize(lightDir + normalize(normal0 + normal1 + normal2 + normal3)  * _Distortion) + 0.5)), _Power);
	return lightColor * VdotH * _SSColor.rgb * pointDepth;
}

inline void vert(inout appdata_full v){

	v.vertex.xyz += v.normal *( (tex2Dlod(_HeightMap, v.texcoord).r + _VertexOffset) * _VertexScale);

}

inline float3 UnityCalcTriEdgeTessFactors (float3 triVertexFactors)
{
    float3 tess;
    tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
    tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
    tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
    return tess;
}


inline float UnityCalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess)
{
    float3 wpos = mul(unity_ObjectToWorld,vertex).xyz;
    float dist = distance (wpos, _WorldSpaceCameraPos);
    float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
    return f;
}

inline float3 tessDist (float4 v0, float4 v1, float4 v2)
{
    float3 f;
    f.x = UnityCalcDistanceTessFactor (v0,_MinDist,_MaxDist,_Tessellation);
    f.y = UnityCalcDistanceTessFactor (v1,_MinDist,_MaxDist,_Tessellation);
    f.z = UnityCalcDistanceTessFactor (v2,_MinDist,_MaxDist,_Tessellation);
   	return UnityCalcTriEdgeTessFactors (f);
}


//TODO
//Calculate thickness

inline UnityTessellationFactors hsconst_surf (InputPatch<InternalTessInterp_appdata_full,3> v) {
  UnityTessellationFactors o;
  float3 tf = (tessDist(v[0].vertex, v[1].vertex, v[2].vertex));
  float3 objCP = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1)).xyz;
  float3 dir = step(0, float3(dot(normalize(objCP - v[0].vertex), v[0].normal), dot(normalize(objCP - v[1].vertex), v[1].normal), dot(normalize(objCP - v[2].vertex), v[2].normal)));
  tf = lerp(0, tf, saturate(dir.x + dir.y + dir.z));
  o.edge[0] = tf.x;
  o.edge[1] = tf.y;
  o.edge[2] = tf.z;
  o.inside = (tf.x + tf.y + tf.z) * 0.33333333;
  return o;

}


[UNITY_domain("tri")]
[UNITY_partitioning("fractional_odd")]
[UNITY_outputtopology("triangle_cw")]
[UNITY_patchconstantfunc("hsconst_surf")]
[UNITY_outputcontrolpoints(3)]
inline InternalTessInterp_appdata_full hs_surf (InputPatch<InternalTessInterp_appdata_full,3> v, uint id : SV_OutputControlPointID) {
  return v[id];
}