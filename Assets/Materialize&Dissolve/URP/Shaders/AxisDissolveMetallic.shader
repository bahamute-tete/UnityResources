// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AxisDissolveMetallic"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(Main)][NoScaleOffset][SingleLineTexture][Space]_MainTex("Albedo", 2D) = "white" {}
		[HideInInspector]_Cutoff("Alpha Clip Threshold", Range( 0 , 1)) = 1
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset][SingleLineTexture]_MetallicTexture("Metallic Texture", 2D) = "white" {}
		_MetallicValue("Metallic Value", Range( 0 , 1)) = 0
		_Glossiness("Smoothness Value", Range( 0 , 1)) = 0
		[KeywordEnum(AlbedoAlpha,MetallicAlpha)] _GlossSource("Source", Float) = 1
		[NoScaleOffset][Normal][SingleLineTexture]_BumpMap("Normal Texture", 2D) = "bump" {}
		[NoScaleOffset][SingleLineTexture]_OcclusionMap1("Occlusion Map", 2D) = "white" {}
		[Toggle]_UseEmission("UseEmission", Float) = 0
		[NoScaleOffset][SingleLineTexture]_EmissionMap("Emission Texture", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[Header(Main Dissolve Settings)][Space]_DissolveAmount("Dissolve Amount", Range( 0 , 1)) = 1
		_MinValueWhenAmount0("Min Value (When Amount = 0)", Float) = 0
		_MaxValueWhenAmount1("Max Value (When Amount = 1)", Float) = 3
		[KeywordEnum(X,Y,Z)] _Axis("Axis", Float) = 1
		[KeywordEnum(Albedo,Emission)] _EdgesAffect("EdgesAffect", Float) = 1
		[Toggle(_INVERTDIRECTIONMINMAX_ON)] _InvertDirectionMinMax("Invert Direction (Min & Max)", Float) = 0
		[Toggle(_USETRIPLANARUVS_ON)] _UseTriplanarUvs("Use Triplanar Uvs", Float) = 0
		[Header(Dissolve Guide)][NoScaleOffset][Space]_GuideTexture("Guide Texture", 2D) = "white" {}
		_GuideTilling("Guide Tilling", Float) = 1
		_GuideTillingSpeed("Guide Tilling Speed", Range( -0.4 , 0.4)) = 0.005
		_GuideStrength("Guide Strength", Range( 0 , 10)) = 0
		[Toggle(_GUIDEAFFECTSEDGESBLENDING_ON)] _GuideAffectsEdgesBlending("Guide Affects Edges Blending", Float) = 0
		[Header(Vertex Displacement)][Space]_VertexDisplacementMainEdge("Vertex Displacement Main Edge ", Range( 0 , 2)) = 0
		_VertexDisplacementSecondEdge("Vertex Displacement Second Edge", Range( 0 , 2)) = 0
		[NoScaleOffset]_DisplacementGuide(" Displacement Guide", 2D) = "white" {}
		_DisplacementGuideTillingSpeed("Displacement Guide Tilling Speed", Range( 0 , 0.2)) = 0.005
		_DisplacementGuideTilling("Displacement Guide Tilling", Float) = 1
		[Header(Main Edge)][Space]_MainEdgeWidth("Main Edge Width", Range( 0 , 0.5)) = 0.01308131
		[NoScaleOffset]_MainEdgePattern("Main Edge Pattern", 2D) = "black" {}
		_MainEdgePatternTilling("Main Edge Pattern Tilling", Float) = 1
		[HDR]_MainEdgeColor1("Main Edge Color 1", Color) = (0,0.171536,1,1)
		[HDR]_MainEdgeColor2("Main Edge Color 2", Color) = (1,0,0.5446758,1)
		[Header(Second Edge)][Space]_SecondEdgeWidth("Second Edge Width", Range( 0 , 0.5)) = 0.02225761
		[NoScaleOffset]_SecondEdgePattern("Second Edge Pattern", 2D) = "black" {}
		_SecondEdgePatternTilling("Second Edge Pattern Tilling", Float) = 1
		[HDR]_SecondEdgeColor1("Second Edge Color 1", Color) = (0,0.171536,1,1)
		[HDR]_SecondEdgeColor2("Second Edge Color 2", Color) = (1,0,0.5446758,1)
		[ASEEnd][Toggle(_2SIDESSECONDEDGE_ON)] _2SidesSecondEdge("2 Sides Second Edge", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		Cull Back
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 3.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMAL_DROPOFF_TS 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100501

			
			#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
			    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_NORMAL
			#pragma multi_compile_local __ _2SIDESSECONDEDGE_ON
			#pragma multi_compile_local __ _GUIDEAFFECTSEDGESBLENDING_ON
			#pragma multi_compile_local _AXIS_X _AXIS_Y _AXIS_Z
			#pragma multi_compile_local __ _USETRIPLANARUVS_ON
			#pragma shader_feature_local _INVERTDIRECTIONMINMAX_ON
			#pragma shader_feature_local _EDGESAFFECT_ALBEDO _EDGESAFFECT_EMISSION
			#pragma multi_compile _GLOSSSOURCE_ALBEDOALPHA _GLOSSSOURCE_METALLICALPHA


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _MainEdgeColor2;
			float4 _MainEdgeColor1;
			float4 _SecondEdgeColor2;
			float4 _SecondEdgeColor1;
			float4 _Color;
			float _Cutoff;
			float _UseEmission;
			float _MainEdgePatternTilling;
			float _SecondEdgePatternTilling;
			float _MainEdgeWidth;
			float _MaxValueWhenAmount1;
			float _MinValueWhenAmount0;
			float _GuideStrength;
			float _GuideTillingSpeed;
			float _GuideTilling;
			float _SecondEdgeWidth;
			float _DissolveAmount;
			float _VertexDisplacementMainEdge;
			float _DisplacementGuideTillingSpeed;
			float _DisplacementGuideTilling;
			float _VertexDisplacementSecondEdge;
			float _MetallicValue;
			float _Glossiness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DisplacementGuide;
			sampler2D _GuideTexture;
			sampler2D _MainTex;
			sampler2D _SecondEdgePattern;
			sampler2D _MainEdgePattern;
			sampler2D _BumpMap;
			sampler2D _EmissionMap;
			sampler2D _MetallicTexture;
			sampler2D _OcclusionMap1;


			inline float4 TriplanarSampling16_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
				yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
				zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			inline float4 TriplanarSampling62_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			inline float4 TriplanarSampling61_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 temp_cast_0 = (_DisplacementGuideTilling).xx;
				float2 temp_cast_1 = (( _TimeParameters.x * _DisplacementGuideTillingSpeed )).xx;
				float2 texCoord76_g20 = v.texcoord.xy * temp_cast_0 + temp_cast_1;
				float4 tex2DNode78_g20 = tex2Dlod( _DisplacementGuide, float4( texCoord76_g20, 0, 0.0) );
				float DissolveAmount13_g20 = _DissolveAmount;
				#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g20 = ( _SecondEdgeWidth / 2.0 );
				#else
				float staticSwitch34_g20 = 0.0;
				#endif
				#if defined(_AXIS_X)
				float staticSwitch23_g20 = v.vertex.xyz.x;
				#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = v.vertex.xyz.y;
				#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = v.vertex.xyz.z;
				#else
				float staticSwitch23_g20 = v.vertex.xyz.y;
				#endif
				float2 temp_cast_2 = (_GuideTilling).xx;
				float temp_output_3_0_g20 = ( _TimeParameters.x * _GuideTillingSpeed );
				float2 temp_cast_3 = (temp_output_3_0_g20).xx;
				float2 texCoord6_g20 = v.texcoord.xy * temp_cast_2 + temp_cast_3;
				float2 temp_cast_4 = (_GuideTilling).xx;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( v.vertex.xyz + temp_output_3_0_g20 ), v.ase_normal, 1.0, temp_cast_4, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
				#else
				float staticSwitch17_g20 = tex2Dlod( _GuideTexture, float4( texCoord6_g20, 0, 0.0) ).r;
				#endif
				float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
				#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g20 = temp_output_33_0_g20;
				#else
				float staticSwitch37_g20 = staticSwitch23_g20;
				#endif
				float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
				float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
				#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
				#else
				float2 staticSwitch19_g20 = appendResult12_g20;
				#endif
				float2 break24_g20 = staticSwitch19_g20;
				float DissolvelerpA29_g20 = break24_g20.x;
				float temp_output_1_0_g22 = DissolvelerpA29_g20;
				float DissolvelerpB31_g20 = break24_g20.y;
				float temp_output_43_0_g20 = ( ( staticSwitch37_g20 - temp_output_1_0_g22 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g22 ) );
				float DissolveWithEdges32_g20 = ( DissolveAmount13_g20 + _MainEdgeWidth );
				float EdgesAlpha75_g20 = ( step( ( DissolveAmount13_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) - step( ( DissolveWithEdges32_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) );
				float lerpResult91_g20 = lerp( ( _VertexDisplacementSecondEdge * tex2DNode78_g20.r ) , ( tex2DNode78_g20.r * _VertexDisplacementMainEdge ) , EdgesAlpha75_g20);
				float temp_output_1_0_g21 = DissolvelerpA29_g20;
				float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
				float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
				float smoothstepResult73_g20 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g20 - step( ( DissolveAmount13_g20 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g20 ) ));
				float EdgeTexBlendAlpha83_g20 = smoothstepResult73_g20;
				float lerpResult92_g20 = lerp( 0.0 , lerpResult91_g20 , EdgeTexBlendAlpha83_g20);
				float3 VertexOffset252 = ( lerpResult92_g20 * v.ase_normal );
				
				o.ase_texcoord7.xy = v.texcoord.xy;
				o.ase_texcoord8 = v.vertex;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset252;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag ( VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_MainTex255 = IN.ase_texcoord7.xy;
				float4 tex2DNode255 = tex2D( _MainTex, uv_MainTex255 );
				float4 AlbedoColor259 = ( tex2DNode255 * _Color );
				float4 temp_output_101_0_g20 = AlbedoColor259;
				float DissolveAmount13_g20 = _DissolveAmount;
				float2 temp_cast_0 = (_GuideTilling).xx;
				float temp_output_3_0_g20 = ( _TimeParameters.x * _GuideTillingSpeed );
				float2 temp_cast_1 = (temp_output_3_0_g20).xx;
				float2 texCoord6_g20 = IN.ase_texcoord7.xy * temp_cast_0 + temp_cast_1;
				float2 temp_cast_2 = (_GuideTilling).xx;
				float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( IN.ase_texcoord8.xyz + temp_output_3_0_g20 ), IN.ase_normal, 1.0, temp_cast_2, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
				#else
				float staticSwitch17_g20 = tex2D( _GuideTexture, texCoord6_g20 ).r;
				#endif
				#if defined(_AXIS_X)
				float staticSwitch23_g20 = IN.ase_texcoord8.xyz.x;
				#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = IN.ase_texcoord8.xyz.y;
				#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = IN.ase_texcoord8.xyz.z;
				#else
				float staticSwitch23_g20 = IN.ase_texcoord8.xyz.y;
				#endif
				float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
				float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
				float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
				#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
				#else
				float2 staticSwitch19_g20 = appendResult12_g20;
				#endif
				float2 break24_g20 = staticSwitch19_g20;
				float DissolvelerpA29_g20 = break24_g20.x;
				float temp_output_1_0_g21 = DissolvelerpA29_g20;
				float DissolvelerpB31_g20 = break24_g20.y;
				float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
				float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
				float smoothstepResult73_g20 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g20 - step( ( DissolveAmount13_g20 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g20 ) ));
				float EdgeTexBlendAlpha83_g20 = smoothstepResult73_g20;
				float4 lerpResult103_g20 = lerp( temp_output_101_0_g20 , float4( 0,0,0,1 ) , EdgeTexBlendAlpha83_g20);
				float2 temp_cast_3 = (_SecondEdgePatternTilling).xx;
				float2 texCoord53_g20 = IN.ase_texcoord7.xy * temp_cast_3 + float2( 0,0 );
				float2 temp_cast_4 = (_SecondEdgePatternTilling).xx;
				float4 triplanar62_g20 = TriplanarSampling62_g20( _SecondEdgePattern, IN.ase_texcoord8.xyz, IN.ase_normal, 1.0, temp_cast_4, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch71_g20 = triplanar62_g20.x;
				#else
				float staticSwitch71_g20 = tex2D( _SecondEdgePattern, texCoord53_g20 ).r;
				#endif
				float4 lerpResult79_g20 = lerp( _SecondEdgeColor1 , _SecondEdgeColor2 , staticSwitch71_g20);
				float2 temp_cast_5 = (_MainEdgePatternTilling).xx;
				float2 texCoord50_g20 = IN.ase_texcoord7.xy * temp_cast_5 + float2( 0,0 );
				float2 temp_cast_6 = (_MainEdgePatternTilling).xx;
				float4 triplanar61_g20 = TriplanarSampling61_g20( _MainEdgePattern, IN.ase_texcoord8.xyz, IN.ase_normal, 1.0, temp_cast_6, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch67_g20 = triplanar61_g20.x;
				#else
				float staticSwitch67_g20 = tex2D( _MainEdgePattern, texCoord50_g20 ).r;
				#endif
				float4 lerpResult82_g20 = lerp( _MainEdgeColor1 , _MainEdgeColor2 , staticSwitch67_g20);
				#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g20 = ( _SecondEdgeWidth / 2.0 );
				#else
				float staticSwitch34_g20 = 0.0;
				#endif
				#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g20 = temp_output_33_0_g20;
				#else
				float staticSwitch37_g20 = staticSwitch23_g20;
				#endif
				float temp_output_1_0_g22 = DissolvelerpA29_g20;
				float temp_output_43_0_g20 = ( ( staticSwitch37_g20 - temp_output_1_0_g22 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g22 ) );
				float DissolveWithEdges32_g20 = ( DissolveAmount13_g20 + _MainEdgeWidth );
				float EdgesAlpha75_g20 = ( step( ( DissolveAmount13_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) - step( ( DissolveWithEdges32_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) );
				float4 lerpResult85_g20 = lerp( lerpResult79_g20 , lerpResult82_g20 , EdgesAlpha75_g20);
				float4 lerpResult89_g20 = lerp( float4( 0,0,0,0 ) , lerpResult85_g20 , EdgeTexBlendAlpha83_g20);
				float4 EmissionColor109_g20 = lerpResult89_g20;
				float4 lerpResult106_g20 = lerp( temp_output_101_0_g20 , EmissionColor109_g20 , EdgeTexBlendAlpha83_g20);
				#if defined(_EDGESAFFECT_ALBEDO)
				float4 staticSwitch99_g20 = lerpResult106_g20;
				#elif defined(_EDGESAFFECT_EMISSION)
				float4 staticSwitch99_g20 = lerpResult103_g20;
				#else
				float4 staticSwitch99_g20 = lerpResult103_g20;
				#endif
				float4 Albedo213 = staticSwitch99_g20;
				
				float2 uv_BumpMap274 = IN.ase_texcoord7.xy;
				float3 TangentNormal264 = UnpackNormalScale( tex2D( _BumpMap, uv_BumpMap274 ), 1.0f );
				
				float2 uv_EmissionMap270 = IN.ase_texcoord7.xy;
				float4 EmissionColor272 = ( _UseEmission == 1.0 ? ( tex2D( _EmissionMap, uv_EmissionMap270 ) * _EmissionColor ) : float4( 0,0,0,0 ) );
				float4 DissolveEmission238 = EmissionColor109_g20;
				
				float2 uv_MetallicTexture267 = IN.ase_texcoord7.xy;
				float4 tex2DNode267 = tex2D( _MetallicTexture, uv_MetallicTexture267 );
				float MetallicValue261 = ( tex2DNode267.r * _MetallicValue );
				
				#if defined(_GLOSSSOURCE_ALBEDOALPHA)
				float staticSwitch282 = tex2DNode255.a;
				#elif defined(_GLOSSSOURCE_METALLICALPHA)
				float staticSwitch282 = tex2DNode267.a;
				#else
				float staticSwitch282 = tex2DNode267.a;
				#endif
				float SmoothnessValue283 = ( _Glossiness * staticSwitch282 );
				
				float2 uv_OcclusionMap1275 = IN.ase_texcoord7.xy;
				float OcclusionMap277 = tex2D( _OcclusionMap1, uv_OcclusionMap1275 ).r;
				
				float FinalAlpha96_g20 = temp_output_54_0_g20;
				float DissolveAlpha214 = FinalAlpha96_g20;
				
				float3 Albedo = Albedo213.rgb;
				float3 Normal = TangentNormal264;
				float3 Emission = ( EmissionColor272 + DissolveEmission238 ).rgb;
				float3 Specular = 0.5;
				float Metallic = MetallicValue261;
				float Smoothness = SmoothnessValue283;
				float Occlusion = OcclusionMap277;
				float Alpha = DissolveAlpha214;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
					inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
					inputData.normalWS = Normal;
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif
				
				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				half4 color = UniversalFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);

				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += Albedo * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += Albedo * transmission;
						}
					#endif
				}
				#endif

				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += Albedo * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += Albedo * translucency * strength;
						}
					#endif
				}
				#endif

				#ifdef _REFRACTION_ASE
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal,0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMAL_DROPOFF_TS 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag
#if ASE_SRP_VERSION >= 110000
			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
#endif
			#define SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _2SIDESSECONDEDGE_ON
			#pragma multi_compile_local __ _GUIDEAFFECTSEDGESBLENDING_ON
			#pragma multi_compile_local _AXIS_X _AXIS_Y _AXIS_Z
			#pragma multi_compile_local __ _USETRIPLANARUVS_ON
			#pragma shader_feature_local _INVERTDIRECTIONMINMAX_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _MainEdgeColor2;
			float4 _MainEdgeColor1;
			float4 _SecondEdgeColor2;
			float4 _SecondEdgeColor1;
			float4 _Color;
			float _Cutoff;
			float _UseEmission;
			float _MainEdgePatternTilling;
			float _SecondEdgePatternTilling;
			float _MainEdgeWidth;
			float _MaxValueWhenAmount1;
			float _MinValueWhenAmount0;
			float _GuideStrength;
			float _GuideTillingSpeed;
			float _GuideTilling;
			float _SecondEdgeWidth;
			float _DissolveAmount;
			float _VertexDisplacementMainEdge;
			float _DisplacementGuideTillingSpeed;
			float _DisplacementGuideTilling;
			float _VertexDisplacementSecondEdge;
			float _MetallicValue;
			float _Glossiness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DisplacementGuide;
			sampler2D _GuideTexture;


			inline float4 TriplanarSampling16_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
				yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
				zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

			float3 _LightDirection;
#if ASE_SRP_VERSION >= 110000 
			float3 _LightPosition;
#endif
			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float2 temp_cast_0 = (_DisplacementGuideTilling).xx;
				float2 temp_cast_1 = (( _TimeParameters.x * _DisplacementGuideTillingSpeed )).xx;
				float2 texCoord76_g20 = v.ase_texcoord.xy * temp_cast_0 + temp_cast_1;
				float4 tex2DNode78_g20 = tex2Dlod( _DisplacementGuide, float4( texCoord76_g20, 0, 0.0) );
				float DissolveAmount13_g20 = _DissolveAmount;
				#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g20 = ( _SecondEdgeWidth / 2.0 );
				#else
				float staticSwitch34_g20 = 0.0;
				#endif
				#if defined(_AXIS_X)
				float staticSwitch23_g20 = v.vertex.xyz.x;
				#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = v.vertex.xyz.y;
				#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = v.vertex.xyz.z;
				#else
				float staticSwitch23_g20 = v.vertex.xyz.y;
				#endif
				float2 temp_cast_2 = (_GuideTilling).xx;
				float temp_output_3_0_g20 = ( _TimeParameters.x * _GuideTillingSpeed );
				float2 temp_cast_3 = (temp_output_3_0_g20).xx;
				float2 texCoord6_g20 = v.ase_texcoord.xy * temp_cast_2 + temp_cast_3;
				float2 temp_cast_4 = (_GuideTilling).xx;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( v.vertex.xyz + temp_output_3_0_g20 ), v.ase_normal, 1.0, temp_cast_4, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
				#else
				float staticSwitch17_g20 = tex2Dlod( _GuideTexture, float4( texCoord6_g20, 0, 0.0) ).r;
				#endif
				float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
				#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g20 = temp_output_33_0_g20;
				#else
				float staticSwitch37_g20 = staticSwitch23_g20;
				#endif
				float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
				float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
				#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
				#else
				float2 staticSwitch19_g20 = appendResult12_g20;
				#endif
				float2 break24_g20 = staticSwitch19_g20;
				float DissolvelerpA29_g20 = break24_g20.x;
				float temp_output_1_0_g22 = DissolvelerpA29_g20;
				float DissolvelerpB31_g20 = break24_g20.y;
				float temp_output_43_0_g20 = ( ( staticSwitch37_g20 - temp_output_1_0_g22 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g22 ) );
				float DissolveWithEdges32_g20 = ( DissolveAmount13_g20 + _MainEdgeWidth );
				float EdgesAlpha75_g20 = ( step( ( DissolveAmount13_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) - step( ( DissolveWithEdges32_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) );
				float lerpResult91_g20 = lerp( ( _VertexDisplacementSecondEdge * tex2DNode78_g20.r ) , ( tex2DNode78_g20.r * _VertexDisplacementMainEdge ) , EdgesAlpha75_g20);
				float temp_output_1_0_g21 = DissolvelerpA29_g20;
				float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
				float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
				float smoothstepResult73_g20 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g20 - step( ( DissolveAmount13_g20 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g20 ) ));
				float EdgeTexBlendAlpha83_g20 = smoothstepResult73_g20;
				float lerpResult92_g20 = lerp( 0.0 , lerpResult91_g20 , EdgeTexBlendAlpha83_g20);
				float3 VertexOffset252 = ( lerpResult92_g20 * v.ase_normal );
				
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.vertex;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset252;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

		#if ASE_SRP_VERSION >= 110000 
			#if _CASTING_PUNCTUAL_LIGHT_SHADOW
				float3 lightDirectionWS = normalize(_LightPosition - positionWS);
			#else
				float3 lightDirectionWS = _LightDirection;
			#endif
				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
			#if UNITY_REVERSED_Z
				clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
			#else
				clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
			#endif
		#else
				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
			#if UNITY_REVERSED_Z
				clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
			#else
				clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
			#endif
		#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float DissolveAmount13_g20 = _DissolveAmount;
				float2 temp_cast_0 = (_GuideTilling).xx;
				float temp_output_3_0_g20 = ( _TimeParameters.x * _GuideTillingSpeed );
				float2 temp_cast_1 = (temp_output_3_0_g20).xx;
				float2 texCoord6_g20 = IN.ase_texcoord2.xy * temp_cast_0 + temp_cast_1;
				float2 temp_cast_2 = (_GuideTilling).xx;
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( IN.ase_texcoord4.xyz + temp_output_3_0_g20 ), IN.ase_normal, 1.0, temp_cast_2, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
				#else
				float staticSwitch17_g20 = tex2D( _GuideTexture, texCoord6_g20 ).r;
				#endif
				#if defined(_AXIS_X)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.x;
				#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.y;
				#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.z;
				#else
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.y;
				#endif
				float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
				float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
				float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
				#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
				#else
				float2 staticSwitch19_g20 = appendResult12_g20;
				#endif
				float2 break24_g20 = staticSwitch19_g20;
				float DissolvelerpA29_g20 = break24_g20.x;
				float temp_output_1_0_g21 = DissolvelerpA29_g20;
				float DissolvelerpB31_g20 = break24_g20.y;
				float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
				float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
				float FinalAlpha96_g20 = temp_output_54_0_g20;
				float DissolveAlpha214 = FinalAlpha96_g20;
				
				float Alpha = DissolveAlpha214;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMAL_DROPOFF_TS 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _2SIDESSECONDEDGE_ON
			#pragma multi_compile_local __ _GUIDEAFFECTSEDGESBLENDING_ON
			#pragma multi_compile_local _AXIS_X _AXIS_Y _AXIS_Z
			#pragma multi_compile_local __ _USETRIPLANARUVS_ON
			#pragma shader_feature_local _INVERTDIRECTIONMINMAX_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _MainEdgeColor2;
			float4 _MainEdgeColor1;
			float4 _SecondEdgeColor2;
			float4 _SecondEdgeColor1;
			float4 _Color;
			float _Cutoff;
			float _UseEmission;
			float _MainEdgePatternTilling;
			float _SecondEdgePatternTilling;
			float _MainEdgeWidth;
			float _MaxValueWhenAmount1;
			float _MinValueWhenAmount0;
			float _GuideStrength;
			float _GuideTillingSpeed;
			float _GuideTilling;
			float _SecondEdgeWidth;
			float _DissolveAmount;
			float _VertexDisplacementMainEdge;
			float _DisplacementGuideTillingSpeed;
			float _DisplacementGuideTilling;
			float _VertexDisplacementSecondEdge;
			float _MetallicValue;
			float _Glossiness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DisplacementGuide;
			sampler2D _GuideTexture;


			inline float4 TriplanarSampling16_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
				yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
				zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 temp_cast_0 = (_DisplacementGuideTilling).xx;
				float2 temp_cast_1 = (( _TimeParameters.x * _DisplacementGuideTillingSpeed )).xx;
				float2 texCoord76_g20 = v.ase_texcoord.xy * temp_cast_0 + temp_cast_1;
				float4 tex2DNode78_g20 = tex2Dlod( _DisplacementGuide, float4( texCoord76_g20, 0, 0.0) );
				float DissolveAmount13_g20 = _DissolveAmount;
				#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g20 = ( _SecondEdgeWidth / 2.0 );
				#else
				float staticSwitch34_g20 = 0.0;
				#endif
				#if defined(_AXIS_X)
				float staticSwitch23_g20 = v.vertex.xyz.x;
				#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = v.vertex.xyz.y;
				#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = v.vertex.xyz.z;
				#else
				float staticSwitch23_g20 = v.vertex.xyz.y;
				#endif
				float2 temp_cast_2 = (_GuideTilling).xx;
				float temp_output_3_0_g20 = ( _TimeParameters.x * _GuideTillingSpeed );
				float2 temp_cast_3 = (temp_output_3_0_g20).xx;
				float2 texCoord6_g20 = v.ase_texcoord.xy * temp_cast_2 + temp_cast_3;
				float2 temp_cast_4 = (_GuideTilling).xx;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( v.vertex.xyz + temp_output_3_0_g20 ), v.ase_normal, 1.0, temp_cast_4, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
				#else
				float staticSwitch17_g20 = tex2Dlod( _GuideTexture, float4( texCoord6_g20, 0, 0.0) ).r;
				#endif
				float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
				#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g20 = temp_output_33_0_g20;
				#else
				float staticSwitch37_g20 = staticSwitch23_g20;
				#endif
				float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
				float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
				#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
				#else
				float2 staticSwitch19_g20 = appendResult12_g20;
				#endif
				float2 break24_g20 = staticSwitch19_g20;
				float DissolvelerpA29_g20 = break24_g20.x;
				float temp_output_1_0_g22 = DissolvelerpA29_g20;
				float DissolvelerpB31_g20 = break24_g20.y;
				float temp_output_43_0_g20 = ( ( staticSwitch37_g20 - temp_output_1_0_g22 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g22 ) );
				float DissolveWithEdges32_g20 = ( DissolveAmount13_g20 + _MainEdgeWidth );
				float EdgesAlpha75_g20 = ( step( ( DissolveAmount13_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) - step( ( DissolveWithEdges32_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) );
				float lerpResult91_g20 = lerp( ( _VertexDisplacementSecondEdge * tex2DNode78_g20.r ) , ( tex2DNode78_g20.r * _VertexDisplacementMainEdge ) , EdgesAlpha75_g20);
				float temp_output_1_0_g21 = DissolvelerpA29_g20;
				float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
				float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
				float smoothstepResult73_g20 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g20 - step( ( DissolveAmount13_g20 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g20 ) ));
				float EdgeTexBlendAlpha83_g20 = smoothstepResult73_g20;
				float lerpResult92_g20 = lerp( 0.0 , lerpResult91_g20 , EdgeTexBlendAlpha83_g20);
				float3 VertexOffset252 = ( lerpResult92_g20 * v.ase_normal );
				
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.vertex;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset252;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif
			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float DissolveAmount13_g20 = _DissolveAmount;
				float2 temp_cast_0 = (_GuideTilling).xx;
				float temp_output_3_0_g20 = ( _TimeParameters.x * _GuideTillingSpeed );
				float2 temp_cast_1 = (temp_output_3_0_g20).xx;
				float2 texCoord6_g20 = IN.ase_texcoord2.xy * temp_cast_0 + temp_cast_1;
				float2 temp_cast_2 = (_GuideTilling).xx;
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( IN.ase_texcoord4.xyz + temp_output_3_0_g20 ), IN.ase_normal, 1.0, temp_cast_2, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
				#else
				float staticSwitch17_g20 = tex2D( _GuideTexture, texCoord6_g20 ).r;
				#endif
				#if defined(_AXIS_X)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.x;
				#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.y;
				#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.z;
				#else
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.y;
				#endif
				float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
				float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
				float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
				#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
				#else
				float2 staticSwitch19_g20 = appendResult12_g20;
				#endif
				float2 break24_g20 = staticSwitch19_g20;
				float DissolvelerpA29_g20 = break24_g20.x;
				float temp_output_1_0_g21 = DissolvelerpA29_g20;
				float DissolvelerpB31_g20 = break24_g20.y;
				float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
				float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
				float FinalAlpha96_g20 = temp_output_54_0_g20;
				float DissolveAlpha214 = FinalAlpha96_g20;
				
				float Alpha = DissolveAlpha214;
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				#ifdef ASE_DEPTH_WRITE_ON
				outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}
		
		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMAL_DROPOFF_TS 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_NORMAL
			#pragma multi_compile_local __ _2SIDESSECONDEDGE_ON
			#pragma multi_compile_local __ _GUIDEAFFECTSEDGESBLENDING_ON
			#pragma multi_compile_local _AXIS_X _AXIS_Y _AXIS_Z
			#pragma multi_compile_local __ _USETRIPLANARUVS_ON
			#pragma shader_feature_local _INVERTDIRECTIONMINMAX_ON
			#pragma shader_feature_local _EDGESAFFECT_ALBEDO _EDGESAFFECT_EMISSION


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _MainEdgeColor2;
			float4 _MainEdgeColor1;
			float4 _SecondEdgeColor2;
			float4 _SecondEdgeColor1;
			float4 _Color;
			float _Cutoff;
			float _UseEmission;
			float _MainEdgePatternTilling;
			float _SecondEdgePatternTilling;
			float _MainEdgeWidth;
			float _MaxValueWhenAmount1;
			float _MinValueWhenAmount0;
			float _GuideStrength;
			float _GuideTillingSpeed;
			float _GuideTilling;
			float _SecondEdgeWidth;
			float _DissolveAmount;
			float _VertexDisplacementMainEdge;
			float _DisplacementGuideTillingSpeed;
			float _DisplacementGuideTilling;
			float _VertexDisplacementSecondEdge;
			float _MetallicValue;
			float _Glossiness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DisplacementGuide;
			sampler2D _GuideTexture;
			sampler2D _MainTex;
			sampler2D _SecondEdgePattern;
			sampler2D _MainEdgePattern;
			sampler2D _EmissionMap;


			inline float4 TriplanarSampling16_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
				yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
				zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			inline float4 TriplanarSampling62_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			inline float4 TriplanarSampling61_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 temp_cast_0 = (_DisplacementGuideTilling).xx;
				float2 temp_cast_1 = (( _TimeParameters.x * _DisplacementGuideTillingSpeed )).xx;
				float2 texCoord76_g20 = v.ase_texcoord.xy * temp_cast_0 + temp_cast_1;
				float4 tex2DNode78_g20 = tex2Dlod( _DisplacementGuide, float4( texCoord76_g20, 0, 0.0) );
				float DissolveAmount13_g20 = _DissolveAmount;
				#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g20 = ( _SecondEdgeWidth / 2.0 );
				#else
				float staticSwitch34_g20 = 0.0;
				#endif
				#if defined(_AXIS_X)
				float staticSwitch23_g20 = v.vertex.xyz.x;
				#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = v.vertex.xyz.y;
				#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = v.vertex.xyz.z;
				#else
				float staticSwitch23_g20 = v.vertex.xyz.y;
				#endif
				float2 temp_cast_2 = (_GuideTilling).xx;
				float temp_output_3_0_g20 = ( _TimeParameters.x * _GuideTillingSpeed );
				float2 temp_cast_3 = (temp_output_3_0_g20).xx;
				float2 texCoord6_g20 = v.ase_texcoord.xy * temp_cast_2 + temp_cast_3;
				float2 temp_cast_4 = (_GuideTilling).xx;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( v.vertex.xyz + temp_output_3_0_g20 ), v.ase_normal, 1.0, temp_cast_4, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
				#else
				float staticSwitch17_g20 = tex2Dlod( _GuideTexture, float4( texCoord6_g20, 0, 0.0) ).r;
				#endif
				float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
				#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g20 = temp_output_33_0_g20;
				#else
				float staticSwitch37_g20 = staticSwitch23_g20;
				#endif
				float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
				float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
				#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
				#else
				float2 staticSwitch19_g20 = appendResult12_g20;
				#endif
				float2 break24_g20 = staticSwitch19_g20;
				float DissolvelerpA29_g20 = break24_g20.x;
				float temp_output_1_0_g22 = DissolvelerpA29_g20;
				float DissolvelerpB31_g20 = break24_g20.y;
				float temp_output_43_0_g20 = ( ( staticSwitch37_g20 - temp_output_1_0_g22 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g22 ) );
				float DissolveWithEdges32_g20 = ( DissolveAmount13_g20 + _MainEdgeWidth );
				float EdgesAlpha75_g20 = ( step( ( DissolveAmount13_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) - step( ( DissolveWithEdges32_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) );
				float lerpResult91_g20 = lerp( ( _VertexDisplacementSecondEdge * tex2DNode78_g20.r ) , ( tex2DNode78_g20.r * _VertexDisplacementMainEdge ) , EdgesAlpha75_g20);
				float temp_output_1_0_g21 = DissolvelerpA29_g20;
				float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
				float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
				float smoothstepResult73_g20 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g20 - step( ( DissolveAmount13_g20 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g20 ) ));
				float EdgeTexBlendAlpha83_g20 = smoothstepResult73_g20;
				float lerpResult92_g20 = lerp( 0.0 , lerpResult91_g20 , EdgeTexBlendAlpha83_g20);
				float3 VertexOffset252 = ( lerpResult92_g20 * v.ase_normal );
				
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.vertex;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset252;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex255 = IN.ase_texcoord2.xy;
				float4 tex2DNode255 = tex2D( _MainTex, uv_MainTex255 );
				float4 AlbedoColor259 = ( tex2DNode255 * _Color );
				float4 temp_output_101_0_g20 = AlbedoColor259;
				float DissolveAmount13_g20 = _DissolveAmount;
				float2 temp_cast_0 = (_GuideTilling).xx;
				float temp_output_3_0_g20 = ( _TimeParameters.x * _GuideTillingSpeed );
				float2 temp_cast_1 = (temp_output_3_0_g20).xx;
				float2 texCoord6_g20 = IN.ase_texcoord2.xy * temp_cast_0 + temp_cast_1;
				float2 temp_cast_2 = (_GuideTilling).xx;
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( IN.ase_texcoord4.xyz + temp_output_3_0_g20 ), IN.ase_normal, 1.0, temp_cast_2, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
				#else
				float staticSwitch17_g20 = tex2D( _GuideTexture, texCoord6_g20 ).r;
				#endif
				#if defined(_AXIS_X)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.x;
				#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.y;
				#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.z;
				#else
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.y;
				#endif
				float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
				float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
				float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
				#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
				#else
				float2 staticSwitch19_g20 = appendResult12_g20;
				#endif
				float2 break24_g20 = staticSwitch19_g20;
				float DissolvelerpA29_g20 = break24_g20.x;
				float temp_output_1_0_g21 = DissolvelerpA29_g20;
				float DissolvelerpB31_g20 = break24_g20.y;
				float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
				float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
				float smoothstepResult73_g20 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g20 - step( ( DissolveAmount13_g20 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g20 ) ));
				float EdgeTexBlendAlpha83_g20 = smoothstepResult73_g20;
				float4 lerpResult103_g20 = lerp( temp_output_101_0_g20 , float4( 0,0,0,1 ) , EdgeTexBlendAlpha83_g20);
				float2 temp_cast_3 = (_SecondEdgePatternTilling).xx;
				float2 texCoord53_g20 = IN.ase_texcoord2.xy * temp_cast_3 + float2( 0,0 );
				float2 temp_cast_4 = (_SecondEdgePatternTilling).xx;
				float4 triplanar62_g20 = TriplanarSampling62_g20( _SecondEdgePattern, IN.ase_texcoord4.xyz, IN.ase_normal, 1.0, temp_cast_4, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch71_g20 = triplanar62_g20.x;
				#else
				float staticSwitch71_g20 = tex2D( _SecondEdgePattern, texCoord53_g20 ).r;
				#endif
				float4 lerpResult79_g20 = lerp( _SecondEdgeColor1 , _SecondEdgeColor2 , staticSwitch71_g20);
				float2 temp_cast_5 = (_MainEdgePatternTilling).xx;
				float2 texCoord50_g20 = IN.ase_texcoord2.xy * temp_cast_5 + float2( 0,0 );
				float2 temp_cast_6 = (_MainEdgePatternTilling).xx;
				float4 triplanar61_g20 = TriplanarSampling61_g20( _MainEdgePattern, IN.ase_texcoord4.xyz, IN.ase_normal, 1.0, temp_cast_6, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch67_g20 = triplanar61_g20.x;
				#else
				float staticSwitch67_g20 = tex2D( _MainEdgePattern, texCoord50_g20 ).r;
				#endif
				float4 lerpResult82_g20 = lerp( _MainEdgeColor1 , _MainEdgeColor2 , staticSwitch67_g20);
				#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g20 = ( _SecondEdgeWidth / 2.0 );
				#else
				float staticSwitch34_g20 = 0.0;
				#endif
				#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g20 = temp_output_33_0_g20;
				#else
				float staticSwitch37_g20 = staticSwitch23_g20;
				#endif
				float temp_output_1_0_g22 = DissolvelerpA29_g20;
				float temp_output_43_0_g20 = ( ( staticSwitch37_g20 - temp_output_1_0_g22 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g22 ) );
				float DissolveWithEdges32_g20 = ( DissolveAmount13_g20 + _MainEdgeWidth );
				float EdgesAlpha75_g20 = ( step( ( DissolveAmount13_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) - step( ( DissolveWithEdges32_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) );
				float4 lerpResult85_g20 = lerp( lerpResult79_g20 , lerpResult82_g20 , EdgesAlpha75_g20);
				float4 lerpResult89_g20 = lerp( float4( 0,0,0,0 ) , lerpResult85_g20 , EdgeTexBlendAlpha83_g20);
				float4 EmissionColor109_g20 = lerpResult89_g20;
				float4 lerpResult106_g20 = lerp( temp_output_101_0_g20 , EmissionColor109_g20 , EdgeTexBlendAlpha83_g20);
				#if defined(_EDGESAFFECT_ALBEDO)
				float4 staticSwitch99_g20 = lerpResult106_g20;
				#elif defined(_EDGESAFFECT_EMISSION)
				float4 staticSwitch99_g20 = lerpResult103_g20;
				#else
				float4 staticSwitch99_g20 = lerpResult103_g20;
				#endif
				float4 Albedo213 = staticSwitch99_g20;
				
				float2 uv_EmissionMap270 = IN.ase_texcoord2.xy;
				float4 EmissionColor272 = ( _UseEmission == 1.0 ? ( tex2D( _EmissionMap, uv_EmissionMap270 ) * _EmissionColor ) : float4( 0,0,0,0 ) );
				float4 DissolveEmission238 = EmissionColor109_g20;
				
				float FinalAlpha96_g20 = temp_output_54_0_g20;
				float DissolveAlpha214 = FinalAlpha96_g20;
				
				
				float3 Albedo = Albedo213.rgb;
				float3 Emission = ( EmissionColor272 + DissolveEmission238 ).rgb;
				float Alpha = DissolveAlpha214;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMAL_DROPOFF_TS 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION
			#define ASE_NEEDS_FRAG_NORMAL
			#pragma multi_compile_local __ _2SIDESSECONDEDGE_ON
			#pragma multi_compile_local __ _GUIDEAFFECTSEDGESBLENDING_ON
			#pragma multi_compile_local _AXIS_X _AXIS_Y _AXIS_Z
			#pragma multi_compile_local __ _USETRIPLANARUVS_ON
			#pragma shader_feature_local _INVERTDIRECTIONMINMAX_ON
			#pragma shader_feature_local _EDGESAFFECT_ALBEDO _EDGESAFFECT_EMISSION


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _MainEdgeColor2;
			float4 _MainEdgeColor1;
			float4 _SecondEdgeColor2;
			float4 _SecondEdgeColor1;
			float4 _Color;
			float _Cutoff;
			float _UseEmission;
			float _MainEdgePatternTilling;
			float _SecondEdgePatternTilling;
			float _MainEdgeWidth;
			float _MaxValueWhenAmount1;
			float _MinValueWhenAmount0;
			float _GuideStrength;
			float _GuideTillingSpeed;
			float _GuideTilling;
			float _SecondEdgeWidth;
			float _DissolveAmount;
			float _VertexDisplacementMainEdge;
			float _DisplacementGuideTillingSpeed;
			float _DisplacementGuideTilling;
			float _VertexDisplacementSecondEdge;
			float _MetallicValue;
			float _Glossiness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DisplacementGuide;
			sampler2D _GuideTexture;
			sampler2D _MainTex;
			sampler2D _SecondEdgePattern;
			sampler2D _MainEdgePattern;


			inline float4 TriplanarSampling16_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
				yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
				zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			inline float4 TriplanarSampling62_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			
			inline float4 TriplanarSampling61_g20( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float2 temp_cast_0 = (_DisplacementGuideTilling).xx;
				float2 temp_cast_1 = (( _TimeParameters.x * _DisplacementGuideTillingSpeed )).xx;
				float2 texCoord76_g20 = v.ase_texcoord.xy * temp_cast_0 + temp_cast_1;
				float4 tex2DNode78_g20 = tex2Dlod( _DisplacementGuide, float4( texCoord76_g20, 0, 0.0) );
				float DissolveAmount13_g20 = _DissolveAmount;
				#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g20 = ( _SecondEdgeWidth / 2.0 );
				#else
				float staticSwitch34_g20 = 0.0;
				#endif
				#if defined(_AXIS_X)
				float staticSwitch23_g20 = v.vertex.xyz.x;
				#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = v.vertex.xyz.y;
				#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = v.vertex.xyz.z;
				#else
				float staticSwitch23_g20 = v.vertex.xyz.y;
				#endif
				float2 temp_cast_2 = (_GuideTilling).xx;
				float temp_output_3_0_g20 = ( _TimeParameters.x * _GuideTillingSpeed );
				float2 temp_cast_3 = (temp_output_3_0_g20).xx;
				float2 texCoord6_g20 = v.ase_texcoord.xy * temp_cast_2 + temp_cast_3;
				float2 temp_cast_4 = (_GuideTilling).xx;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( v.vertex.xyz + temp_output_3_0_g20 ), v.ase_normal, 1.0, temp_cast_4, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
				#else
				float staticSwitch17_g20 = tex2Dlod( _GuideTexture, float4( texCoord6_g20, 0, 0.0) ).r;
				#endif
				float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
				#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g20 = temp_output_33_0_g20;
				#else
				float staticSwitch37_g20 = staticSwitch23_g20;
				#endif
				float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
				float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
				#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
				#else
				float2 staticSwitch19_g20 = appendResult12_g20;
				#endif
				float2 break24_g20 = staticSwitch19_g20;
				float DissolvelerpA29_g20 = break24_g20.x;
				float temp_output_1_0_g22 = DissolvelerpA29_g20;
				float DissolvelerpB31_g20 = break24_g20.y;
				float temp_output_43_0_g20 = ( ( staticSwitch37_g20 - temp_output_1_0_g22 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g22 ) );
				float DissolveWithEdges32_g20 = ( DissolveAmount13_g20 + _MainEdgeWidth );
				float EdgesAlpha75_g20 = ( step( ( DissolveAmount13_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) - step( ( DissolveWithEdges32_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) );
				float lerpResult91_g20 = lerp( ( _VertexDisplacementSecondEdge * tex2DNode78_g20.r ) , ( tex2DNode78_g20.r * _VertexDisplacementMainEdge ) , EdgesAlpha75_g20);
				float temp_output_1_0_g21 = DissolvelerpA29_g20;
				float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
				float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
				float smoothstepResult73_g20 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g20 - step( ( DissolveAmount13_g20 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g20 ) ));
				float EdgeTexBlendAlpha83_g20 = smoothstepResult73_g20;
				float lerpResult92_g20 = lerp( 0.0 , lerpResult91_g20 , EdgeTexBlendAlpha83_g20);
				float3 VertexOffset252 = ( lerpResult92_g20 * v.ase_normal );
				
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.vertex;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset252;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex255 = IN.ase_texcoord2.xy;
				float4 tex2DNode255 = tex2D( _MainTex, uv_MainTex255 );
				float4 AlbedoColor259 = ( tex2DNode255 * _Color );
				float4 temp_output_101_0_g20 = AlbedoColor259;
				float DissolveAmount13_g20 = _DissolveAmount;
				float2 temp_cast_0 = (_GuideTilling).xx;
				float temp_output_3_0_g20 = ( _TimeParameters.x * _GuideTillingSpeed );
				float2 temp_cast_1 = (temp_output_3_0_g20).xx;
				float2 texCoord6_g20 = IN.ase_texcoord2.xy * temp_cast_0 + temp_cast_1;
				float2 temp_cast_2 = (_GuideTilling).xx;
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float4 triplanar16_g20 = TriplanarSampling16_g20( _GuideTexture, ( IN.ase_texcoord4.xyz + temp_output_3_0_g20 ), IN.ase_normal, 1.0, temp_cast_2, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch17_g20 = triplanar16_g20.x;
				#else
				float staticSwitch17_g20 = tex2D( _GuideTexture, texCoord6_g20 ).r;
				#endif
				#if defined(_AXIS_X)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.x;
				#elif defined(_AXIS_Y)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.y;
				#elif defined(_AXIS_Z)
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.z;
				#else
				float staticSwitch23_g20 = IN.ase_texcoord4.xyz.y;
				#endif
				float temp_output_33_0_g20 = ( ( staticSwitch17_g20 * _GuideStrength ) + staticSwitch23_g20 );
				float2 appendResult12_g20 = (float2(_MinValueWhenAmount0 , _MaxValueWhenAmount1));
				float2 appendResult14_g20 = (float2(_MaxValueWhenAmount1 , _MinValueWhenAmount0));
				#ifdef _INVERTDIRECTIONMINMAX_ON
				float2 staticSwitch19_g20 = appendResult14_g20;
				#else
				float2 staticSwitch19_g20 = appendResult12_g20;
				#endif
				float2 break24_g20 = staticSwitch19_g20;
				float DissolvelerpA29_g20 = break24_g20.x;
				float temp_output_1_0_g21 = DissolvelerpA29_g20;
				float DissolvelerpB31_g20 = break24_g20.y;
				float temp_output_47_0_g20 = ( ( temp_output_33_0_g20 - temp_output_1_0_g21 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g21 ) );
				float temp_output_54_0_g20 = step( DissolveAmount13_g20 , temp_output_47_0_g20 );
				float smoothstepResult73_g20 = smoothstep( 0.0 , 0.06 , ( temp_output_54_0_g20 - step( ( DissolveAmount13_g20 + ( _MainEdgeWidth + _SecondEdgeWidth ) ) , temp_output_47_0_g20 ) ));
				float EdgeTexBlendAlpha83_g20 = smoothstepResult73_g20;
				float4 lerpResult103_g20 = lerp( temp_output_101_0_g20 , float4( 0,0,0,1 ) , EdgeTexBlendAlpha83_g20);
				float2 temp_cast_3 = (_SecondEdgePatternTilling).xx;
				float2 texCoord53_g20 = IN.ase_texcoord2.xy * temp_cast_3 + float2( 0,0 );
				float2 temp_cast_4 = (_SecondEdgePatternTilling).xx;
				float4 triplanar62_g20 = TriplanarSampling62_g20( _SecondEdgePattern, IN.ase_texcoord4.xyz, IN.ase_normal, 1.0, temp_cast_4, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch71_g20 = triplanar62_g20.x;
				#else
				float staticSwitch71_g20 = tex2D( _SecondEdgePattern, texCoord53_g20 ).r;
				#endif
				float4 lerpResult79_g20 = lerp( _SecondEdgeColor1 , _SecondEdgeColor2 , staticSwitch71_g20);
				float2 temp_cast_5 = (_MainEdgePatternTilling).xx;
				float2 texCoord50_g20 = IN.ase_texcoord2.xy * temp_cast_5 + float2( 0,0 );
				float2 temp_cast_6 = (_MainEdgePatternTilling).xx;
				float4 triplanar61_g20 = TriplanarSampling61_g20( _MainEdgePattern, IN.ase_texcoord4.xyz, IN.ase_normal, 1.0, temp_cast_6, 1.0, 0 );
				#ifdef _USETRIPLANARUVS_ON
				float staticSwitch67_g20 = triplanar61_g20.x;
				#else
				float staticSwitch67_g20 = tex2D( _MainEdgePattern, texCoord50_g20 ).r;
				#endif
				float4 lerpResult82_g20 = lerp( _MainEdgeColor1 , _MainEdgeColor2 , staticSwitch67_g20);
				#ifdef _2SIDESSECONDEDGE_ON
				float staticSwitch34_g20 = ( _SecondEdgeWidth / 2.0 );
				#else
				float staticSwitch34_g20 = 0.0;
				#endif
				#ifdef _GUIDEAFFECTSEDGESBLENDING_ON
				float staticSwitch37_g20 = temp_output_33_0_g20;
				#else
				float staticSwitch37_g20 = staticSwitch23_g20;
				#endif
				float temp_output_1_0_g22 = DissolvelerpA29_g20;
				float temp_output_43_0_g20 = ( ( staticSwitch37_g20 - temp_output_1_0_g22 ) / ( DissolvelerpB31_g20 - temp_output_1_0_g22 ) );
				float DissolveWithEdges32_g20 = ( DissolveAmount13_g20 + _MainEdgeWidth );
				float EdgesAlpha75_g20 = ( step( ( DissolveAmount13_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) - step( ( DissolveWithEdges32_g20 + staticSwitch34_g20 ) , temp_output_43_0_g20 ) );
				float4 lerpResult85_g20 = lerp( lerpResult79_g20 , lerpResult82_g20 , EdgesAlpha75_g20);
				float4 lerpResult89_g20 = lerp( float4( 0,0,0,0 ) , lerpResult85_g20 , EdgeTexBlendAlpha83_g20);
				float4 EmissionColor109_g20 = lerpResult89_g20;
				float4 lerpResult106_g20 = lerp( temp_output_101_0_g20 , EmissionColor109_g20 , EdgeTexBlendAlpha83_g20);
				#if defined(_EDGESAFFECT_ALBEDO)
				float4 staticSwitch99_g20 = lerpResult106_g20;
				#elif defined(_EDGESAFFECT_EMISSION)
				float4 staticSwitch99_g20 = lerpResult103_g20;
				#else
				float4 staticSwitch99_g20 = lerpResult103_g20;
				#endif
				float4 Albedo213 = staticSwitch99_g20;
				
				float FinalAlpha96_g20 = temp_output_54_0_g20;
				float DissolveAlpha214 = FinalAlpha96_g20;
				
				
				float3 Albedo = Albedo213.rgb;
				float Alpha = DissolveAlpha214;
				float AlphaClipThreshold = 0.5;

				half4 color = half4( Albedo, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormals" }

			ZWrite On
			Blend One Zero
            ZTest LEqual
            ZWrite On

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMAL_DROPOFF_TS 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100501

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float3 worldNormal : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _MainEdgeColor2;
			float4 _MainEdgeColor1;
			float4 _SecondEdgeColor2;
			float4 _SecondEdgeColor1;
			float4 _Color;
			float _Cutoff;
			float _UseEmission;
			float _MainEdgePatternTilling;
			float _SecondEdgePatternTilling;
			float _MainEdgeWidth;
			float _MaxValueWhenAmount1;
			float _MinValueWhenAmount0;
			float _GuideStrength;
			float _GuideTillingSpeed;
			float _GuideTilling;
			float _SecondEdgeWidth;
			float _DissolveAmount;
			float _VertexDisplacementMainEdge;
			float _DisplacementGuideTillingSpeed;
			float _DisplacementGuideTilling;
			float _VertexDisplacementSecondEdge;
			float _MetallicValue;
			float _Glossiness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal( v.ase_normal );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.worldNormal = normalWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif
			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				
				#ifdef ASE_DEPTH_WRITE_ON
				outputDepth = DepthValue;
				#endif
				
				return float4(PackNormalOctRectEncode(TransformWorldToViewDir(IN.worldNormal, true)), 0.0, 0.0);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMAL_DROPOFF_TS 1
			#define _EMISSION
			#define _ALPHATEST_ON 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100501

			
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ _GBUFFER_NORMALS_OCT
			
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_GBUFFER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
			    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _MainEdgeColor2;
			float4 _MainEdgeColor1;
			float4 _SecondEdgeColor2;
			float4 _SecondEdgeColor1;
			float4 _Color;
			float _Cutoff;
			float _UseEmission;
			float _MainEdgePatternTilling;
			float _SecondEdgePatternTilling;
			float _MainEdgeWidth;
			float _MaxValueWhenAmount1;
			float _MinValueWhenAmount0;
			float _GuideStrength;
			float _GuideTillingSpeed;
			float _GuideTilling;
			float _SecondEdgeWidth;
			float _DissolveAmount;
			float _VertexDisplacementMainEdge;
			float _DisplacementGuideTillingSpeed;
			float _DisplacementGuideTilling;
			float _VertexDisplacementSecondEdge;
			float _MetallicValue;
			float _Glossiness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif
			FragmentOutput frag ( VertexOutput IN 
								#ifdef ASE_DEPTH_WRITE_ON
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				
				float3 Albedo = float3(0.5, 0.5, 0.5);
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = 0.5;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
					inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
					inputData.normalWS = Normal;
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				BRDFData brdfData;
				InitializeBRDFData( Albedo, Metallic, Specular, Smoothness, Alpha, brdfData);
				half4 color;
				color.rgb = GlobalIllumination( brdfData, inputData.bakedGI, Occlusion, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;
				
					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += Albedo * mainTransmission;
				
					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );
				
							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += Albedo * transmission;
						}
					#endif
				}
				#endif
				
				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;
				
					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
				
					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += Albedo * mainTranslucency * strength;
				
					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );
				
							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += Albedo * translucency * strength;
						}
					#endif
				}
				#endif
				
				#ifdef _REFRACTION_ASE
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal, 0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif
				
				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif
				
				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif
				
				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif
				
				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb);
			}

			ENDHLSL
		}
		
	}
	
	
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
200;73;1694;655;1442.761;-619.1429;1.858982;True;False
Node;AmplifyShaderEditor.CommentaryNode;254;-489.8708,591.688;Inherit;False;1242.73;2053.751;;27;283;282;281;280;279;278;277;275;274;273;272;271;270;269;268;267;265;264;263;262;261;260;259;257;256;255;0;Standard Metallic Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;209;-166.077,-51.38562;Inherit;False;955;416;;10;252;238;214;213;212;3;4;5;2;211;Dissolve Function;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;281;-396.6687,880.0156;Inherit;False;Property;_Cutoff;Alpha Clip Threshold;1;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;260;-98.46782,872.0556;Inherit;False;AlphaClipThreshold;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;3.869215,960.5977;Inherit;False;Property;_Glossiness;Smoothness Value;5;0;Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;238;536.923,-1.38562;Inherit;False;DissolveEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;239;1402.134,633.9283;Inherit;False;213;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;247;1429.134,805.9283;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;251;1159.134,863.9283;Inherit;False;238;DissolveEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;269;394.9132,1393.145;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;1195.18,992.701;Inherit;False;283;SmoothnessValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;1299.487,1234.828;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;1242.93,1145.753;Inherit;False;214;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;262;174.8942,2056.829;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;-59.01677,2109.825;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;264;-11.53679,2411.561;Inherit;False;TangentNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;253;1311.053,1302.798;Inherit;False;252;VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;298.4482,1011.929;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;267;-372.1238,1521.669;Inherit;True;Property;_MetallicTexture;Metallic Texture;3;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;261;195.6702,1532.221;Inherit;False;MetallicValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;271;249.9131,1319.34;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;223;1222.93,1049.753;Inherit;False;277;OcclusionMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;279;123.8132,1653.343;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;1370.134,712.9283;Inherit;False;264;TangentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;256;-409.2598,1264.173;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;True;0;False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;257;-124.8608,1245.654;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;51.11617,1242.577;Inherit;False;AlbedoColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;211;-67.33564,43.44286;Inherit;False;259;AlbedoColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;212;144.2479,85.27469;Inherit;False;AxisDissolve;12;;20;c7e8d1367c6e85c468a8796d0ba1e1a6;0;1;101;COLOR;1,1,1,1;False;4;COLOR;100;COLOR;102;FLOAT3;98;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;561.923,248.6144;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;242;1159.134,770.9283;Inherit;False;272;EmissionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;213;544.923,78.61438;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;274;-344.9468,2385.52;Inherit;True;Property;_BumpMap;Normal Texture;7;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;277;-63.73576,677.8239;Inherit;False;OcclusionMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;564.923,165.6144;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;273;-325.1897,2166.84;Inherit;False;Property;_EmissionColor;Emission Color;11;1;[HDR];Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;278;17.35725,1979.915;Inherit;False;Property;_UseEmission;UseEmission;9;1;[Toggle];Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;282;-15.29082,1080.267;Inherit;False;Property;_GlossSource;Source;6;0;Create;False;0;0;0;True;0;False;1;1;1;True;;KeywordEnum;2;AlbedoAlpha;MetallicAlpha;Create;False;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;240;1219.93,933.7535;Inherit;False;261;MetallicValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;433.5612,1061.093;Inherit;False;SmoothnessValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;280;-173.4569,1768.125;Inherit;False;Property;_MetallicValue;Metallic Value;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;270;-370.6808,1975.406;Inherit;True;Property;_EmissionMap;Emission Texture;10;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;362.5653,2085.802;Inherit;False;EmissionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;275;-363.4748,641.688;Inherit;True;Property;_OcclusionMap1;Occlusion Map;8;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;255;-439.8708,1072.75;Inherit;True;Property;_MainTex;Albedo;0;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;False;1;Main;0;0;True;1;Space;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;285;1577.988,848.1439;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalGBuffer;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-277.5366,1218.867;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1577.988,788.1439;Float;False;True;-1;2;;0;2;AxisDissolveMetallic;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;18;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;38;Workflow;1;637890066005861892;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;637890066030807718;Transmission;0;0;  Transmission Shadow;0.5,False,-1;0;Translucency;0;0;  Translucency Strength;1,False,-1;0;  Normal Distortion;0.5,False,-1;0;  Scattering;2,False,-1;0;  Direct;0.9,False,-1;0;  Ambient;0.1,False,-1;0;  Shadow;0.5,False,-1;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;637890065982202104;DOTS Instancing;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Write Depth;0;637890066170785359;  Early Z;0;637890066105496049;Vertex Position,InvertActionOnDeselection;1;0;0;8;False;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;284;1577.988,848.1439;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormals;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;260;0;281;0
WireConnection;238;0;212;100
WireConnection;247;0;242;0
WireConnection;247;1;251;0
WireConnection;269;0;271;3
WireConnection;262;0;278;0
WireConnection;262;2;263;0
WireConnection;263;0;270;0
WireConnection;263;1;273;0
WireConnection;264;0;274;0
WireConnection;268;0;265;0
WireConnection;268;1;282;0
WireConnection;261;0;279;0
WireConnection;271;0;259;0
WireConnection;279;0;267;1
WireConnection;279;1;280;0
WireConnection;257;0;255;0
WireConnection;257;1;256;0
WireConnection;259;0;257;0
WireConnection;212;101;211;0
WireConnection;214;0;212;0
WireConnection;213;0;212;102
WireConnection;277;0;275;1
WireConnection;252;0;212;98
WireConnection;282;1;255;4
WireConnection;282;0;267;4
WireConnection;283;0;268;0
WireConnection;272;0;262;0
WireConnection;1;0;239;0
WireConnection;1;1;246;0
WireConnection;1;2;247;0
WireConnection;1;3;240;0
WireConnection;1;4;243;0
WireConnection;1;5;223;0
WireConnection;1;6;225;0
WireConnection;1;7;248;0
WireConnection;1;8;253;0
ASEEND*/
//CHKSM=21042DA81D98B4B989AD63C510C8915CC9F21E6B