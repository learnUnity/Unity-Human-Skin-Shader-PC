Shader "Hidden/SSSSSReplaceMask"
{
	CGINCLUDE
		#include "UnityCG.cginc"
		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};
		struct v2f
		{
			float4 vertex : SV_POSITION;
		};

		struct v2f_shadow {
  V2F_SHADOW_CASTER;
};

// vertex shader
inline v2f_shadow vert_shadow (appdata_base v) {
  v2f_shadow o;
  UNITY_INITIALIZE_OUTPUT(v2f_shadow,o);
  TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
  return o;
}

// fragment shader
inline float4 frag_shadow (v2f_shadow IN) : SV_Target {
 	SHADOW_CASTER_FRAGMENT(IN)
}


	ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return 0;
			}
			ENDCG
		}

		Pass {
Name "ShadowCaster"
Tags { "LightMode" = "ShadowCaster" }
ZWrite On ZTest Less
CGPROGRAM
// compile directives
#pragma vertex vert_shadow
#pragma fragment frag_shadow
#pragma target 3.0
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma multi_compile_shadowcaster
ENDCG
}
	}

	SubShader
	{
		Tags { "RenderType"="SubSurfaceTess" }
		Pass {

CGPROGRAM
// compile directives

#pragma vertex tessvert_surf_shadowCaster
#pragma fragment frag_surf
#pragma hull hs_surf_shadow
#pragma domain ds_surf
#pragma target 4.6
#include "Lighting.cginc"

float	_MinDist;
float	_MaxDist;
float	_Tessellation;
float	_Phong;
sampler2D	_HeightMap;
float	_VertexScale;
float	_VertexOffset;

struct InternalTessInterp_appdata_base {
  float4 vertex : INTERNALTESSPOS;
  float3 normal : NORMAL;
  float4 texcoord : TEXCOORD0;
};

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

// vertex shader
inline v2f vert_surf (appdata_base v) {
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	return o;
}



inline UnityTessellationFactors hsconst_surf_shadow (InputPatch<InternalTessInterp_appdata_base,3> v) {
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
[UNITY_patchconstantfunc("hsconst_surf_shadow")]
[UNITY_outputcontrolpoints(3)]
inline InternalTessInterp_appdata_base hs_surf_shadow (InputPatch<InternalTessInterp_appdata_base,3> v, uint id : SV_OutputControlPointID) {
  return v[id];
}

inline InternalTessInterp_appdata_base tessvert_surf_shadowCaster (appdata_base v) {
  InternalTessInterp_appdata_base o;
  o.vertex = v.vertex;
  o.normal = v.normal;
  o.texcoord = v.texcoord;
  return o;
}

inline void disp_shadow(inout appdata_base v){
	v.vertex.xyz += v.normal *( (tex2Dlod(_HeightMap, v.texcoord).r + _VertexOffset) * _VertexScale);
}

[UNITY_domain("tri")]
inline v2f ds_surf (UnityTessellationFactors tessFactors, const OutputPatch<InternalTessInterp_appdata_base,3> vi, float3 bary : SV_DomainLocation) {
  appdata_base v;
  v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
  float3 pp[3];
  pp[0] = v.vertex.xyz - vi[0].normal * (dot(v.vertex.xyz, vi[0].normal) - dot(vi[0].vertex.xyz, vi[0].normal));
  pp[1] = v.vertex.xyz - vi[1].normal * (dot(v.vertex.xyz, vi[1].normal) - dot(vi[1].vertex.xyz, vi[1].normal));
  pp[2] = v.vertex.xyz - vi[2].normal * (dot(v.vertex.xyz, vi[2].normal) - dot(vi[2].vertex.xyz, vi[2].normal));
  v.vertex.xyz = _Phong * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-_Phong) * v.vertex.xyz;
  v.normal = vi[0].normal*bary.x + vi[1].normal*bary.y + vi[2].normal*bary.z;
  v.texcoord = vi[0].texcoord*bary.x + vi[1].texcoord*bary.y + vi[2].texcoord*bary.z;
  disp_shadow(v);
  v2f o = vert_surf (v);
  return o;
}

// fragment shader
inline fixed4 frag_surf (v2f IN) : SV_Target {
 	return 1;
}

ENDCG

}
	}

	SubShader
	{
		Tags { "RenderType"="TransparentCutout" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return 0;
			}
			ENDCG
		}
	}

	SubShader
	{
		Tags { "RenderType"="Overlay" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return 0;
			}
			ENDCG
		}
	}

	SubShader
	{
		Tags { "RenderType"="TreeOpaque" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return 0;
			}
			ENDCG
		}

		Pass {
Name "ShadowCaster"
Tags { "LightMode" = "ShadowCaster" }
ZWrite On ZTest Less
CGPROGRAM
// compile directives
#pragma vertex vert_shadow
#pragma fragment frag_shadow
#pragma target 3.0
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma multi_compile_shadowcaster
ENDCG
}
	}

	SubShader
	{
		Tags { "RenderType"="TreeTransparentCutout" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return 0;
			}
			ENDCG
		}
	}

	SubShader
	{
		Tags { "RenderType"="TreeBillboard" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return 0;
			}
			ENDCG
		}

		Pass {
Name "ShadowCaster"
Tags { "LightMode" = "ShadowCaster" }
ZWrite On ZTest Less
CGPROGRAM
// compile directives
#pragma vertex vert_shadow
#pragma fragment frag_shadow
#pragma target 3.0
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma multi_compile_shadowcaster
ENDCG
}
	}

	SubShader
	{
		Tags { "RenderType"="Grass" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return 0;
			}
			ENDCG
		}

		Pass {
Name "ShadowCaster"
Tags { "LightMode" = "ShadowCaster" }
ZWrite On ZTest Less
CGPROGRAM
// compile directives
#pragma vertex vert_shadow
#pragma fragment frag_shadow
#pragma target 3.0
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma multi_compile_shadowcaster
ENDCG
}
	}

	SubShader
	{
		Tags { "RenderType"="GrassBillboard" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return 0;
			}
			ENDCG
		}

		Pass {
Name "ShadowCaster"
Tags { "LightMode" = "ShadowCaster" }
ZWrite On ZTest Less
CGPROGRAM
// compile directives
#pragma vertex vert_shadow
#pragma fragment frag_shadow
#pragma target 3.0
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma multi_compile_shadowcaster
ENDCG
}
	}
}
