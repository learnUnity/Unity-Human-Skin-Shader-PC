Shader "Hidden/SSSSS"
{
	Properties
	{
		_MainTex ("Tex", 2D) = "white" {}
	}
	SubShader
	{
	CGINCLUDE
	#include "UnityCG.cginc"
	sampler2D _MainTex;
	float4 _MainTex_TexelSize;


    inline float4 getWeightedColor(float2 uv, float2 offset){
		float4 originColor =  tex2D(_MainTex, uv);
    	float4 c = originColor * 0.324;
		offset *= (1 - originColor.a) * 3;
    	float2 offsetM3 = offset * 3;
    	float2 offsetM2 = offset * 2;
		float4 col = tex2D(_MainTex, uv + offsetM3);
    	c += lerp(originColor, col, step(col.a, 0.998)) * 0.0205;
		col = tex2D(_MainTex, uv + offsetM2);
    	c += lerp(originColor, col, step(col.a, 0.998))  * 0.0855;
		col = tex2D(_MainTex, uv + offset);
    	c += lerp(originColor, col, step(col.a, 0.998)) * 0.232;
		col = tex2D(_MainTex, uv - offsetM3);
    	c += lerp(originColor, col, step(col.a, 0.998)) * 0.0205;
		col = tex2D(_MainTex, uv - offsetM2);
    	c += lerp(originColor, col, step(col.a, 0.998))  * 0.0855;
		col = tex2D(_MainTex, uv - offset);
    	c += lerp(originColor, col, step(col.a, 0.998)) * 0.232;
		c.a = originColor.a;
    	return c;
    }
    	struct v2f_mg
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float2 offset : TEXCOORD1;
			};
    		inline float4 frag_blur (v2f_mg i) : SV_Target
			{
				return getWeightedColor(i.uv, i.offset);
			}

	ENDCG
	//0. vert 1. hori 2. blend 3. add
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
		//Vertical 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_blur


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};



			inline v2f_mg vert (appdata v)
			{
				v2f_mg o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.offset = _MainTex_TexelSize.xy * float2(0,1);
				return o;
			}
			ENDCG
		}

		Pass
		{
		//Horizontal 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_blur


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};


			inline v2f_mg vert (appdata v)
			{
				v2f_mg o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.offset = _MainTex_TexelSize.xy * float2(1,0);
				return o;
			}
			ENDCG
		}

		Pass{
			//Blend
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _BlendTex;
			float4 _BlendWeight;
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 oneMinusWeight : TEXCOORD1;
			};

			inline v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.oneMinusWeight = float4(1,1,1,1) - _BlendWeight;
				return o;
			}

			inline float4 frag (v2f i) : SV_Target
			{
				return tex2D(_BlendTex, i.uv) * i.oneMinusWeight + tex2D(_MainTex, i.uv) * _BlendWeight;
			}
			ENDCG
		}

		Pass{
			//Blend
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _BlendTex1;
			float4 _BlendWeight1;
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 oneMinusWeight : TEXCOORD1;
			};

			inline v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.oneMinusWeight = float4(1,1,1,1) - _BlendWeight1;
				return o;
			}

			inline float4 frag (v2f i) : SV_Target
			{
				return tex2D(_BlendTex1, i.uv) * i.oneMinusWeight + tex2D(_MainTex, i.uv) * _BlendWeight1;
			}
			ENDCG
		}

		Pass{
			//Blend
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _BlendTex;
			float4 _BlendWeight2;
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 oneMinusWeight : TEXCOORD1;
			};

			inline v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.oneMinusWeight = float4(1,1,1,1) - _BlendWeight2;
				return o;
			}

			inline float4 frag (v2f i) : SV_Target
			{
				return tex2D(_BlendTex, i.uv) * i.oneMinusWeight + tex2D(_MainTex, i.uv) * _BlendWeight2;
			}
			ENDCG
		}
	}
}
