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

	#define BLUR0 0.12516840610182164
	#define BLUR1 0.11975714566876787
	#define BLUR2 0.10488697964330942
	#define BLUR3 0.08409209097592142
	#define BLUR4 0.061716622693291805
	#define BLUR5 0.04146317758515726
	#define BLUR6 0.025499780382641484
	#define Gaus(offset, blur)\
		col = tex2D(_MainTex, uv + offset);\
		c += lerp(originColor, col, step(col.a, 0.998)) * blur;\
		col = tex2D(_MainTex, uv - offset);\
		c += lerp(originColor, col, step(col.a, 0.998)) * blur;

    inline float4 getWeightedColor(float2 uv, float2 offset){
		float4 originColor =  tex2D(_MainTex, uv);
    	float4 c = originColor * BLUR0;
		offset *= 1 - originColor.a;
		float2 offsetM2 = offset * 2;
    	float2 offsetM3 = offset * 3;
		float2 offsetM4 = offset * 4;
		float2 offsetM5 = offset * 5;
		float2 offsetM6 = offset * 6;
		float4 col;
		Gaus(offset,BLUR1)
		Gaus(offsetM2, BLUR2)
		Gaus(offsetM3, BLUR3)
		Gaus(offsetM4, BLUR4)
		Gaus(offsetM5, BLUR5)
		Gaus(offsetM6, BLUR6)
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
