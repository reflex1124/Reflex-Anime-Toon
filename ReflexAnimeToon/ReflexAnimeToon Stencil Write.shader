// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Reflex Toon/Stencil/Writer"
{
	Properties
	{
		_Diffuse("Diffuse", 2D) = "white" {}
		_DiffuseColor("Diffuse Color", Color) = (1,1,1,1)
		_NormalIntensity("Normal Intensity", Range( 0 , 1)) = 0.5
		[Toggle]_ObjectShadow("Object Shadow", Float) = 1
		_Shadow1Contrast("Shadow 1 Contrast", Range( 1 , 100)) = 100
		_Shadow1Texture("Shadow 1 Texture", 2D) = "white" {}
		_Shadow1Color("Shadow 1 Color", Color) = (0.8627451,0.8627451,0.8627451,1)
		_Shadow1Place("Shadow 1 Place", Range( -1 , 1)) = 0
		[Toggle]_Shadow2ContrastToggle("Shadow 2 Contrast Toggle", Float) = 0
		_Shadow2Contrast("Shadow 2 Contrast", Range( 1 , 100)) = 100
		_Shadow2Texture("Shadow 2 Texture", 2D) = "white" {}
		_Shadow2Color("Shadow 2 Color", Color) = (0.7843137,0.7843137,0.7843137,1)
		_Shadow2Place("Shadow 2 Place", Range( -1 , 1)) = 0.1
		[Toggle]_PosterizeToggle("Posterize Toggle", Float) = 0
		_DarknessMin("Darkness Min", Range( 0 , 1)) = 0
		[NoScaleOffset]_ShadowMask("Shadow Mask", 2D) = "white" {}
		_VDirLight("V Dir Light", Vector) = (0,0.6,1,0)
		[Toggle]_LightIntensityShadowPos("Light Intensity Shadow Pos", Float) = 0
		_OutlineWidth("Outline Width", Range( 0 , 1)) = 0
		_OutlineColor("Outline Color", Color) = (0.2941176,0.2941176,0.2941176,1)
		[NoScaleOffset]_OutlineMask("Outline Mask", 2D) = "white" {}
		_StencilReference("StencilReference", Float) = 3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		Stencil
		{
			Ref [_StencilReference]
			Comp Always
			Pass Replace
		}
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 uv_OutlineMask84_g75 = v.texcoord;
			float outlineVar = ( (0.0 + (_OutlineWidth - 0.0) * (0.002 - 0.0) / (1.0 - 0.0)) * tex2Dlod( _OutlineMask, float4( uv_OutlineMask84_g75, 0, 0.0) ) ).r;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, 1); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float4 temp_output_48_0_g75 = ( tex2D( _Diffuse, uv_Diffuse ) * _DiffuseColor );
			float4 DiffuseBase50_g75 = temp_output_48_0_g75;
			float3 appendResult79_g75 = (float3(_OutlineColor.r , _OutlineColor.g , _OutlineColor.b));
			float3 localFunction_ShadeSH964_g75 = Function_ShadeSH9();
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 ifLocalVar63_g75 = 0;
			if( _WorldSpaceLightPos0.w <= 0.0 )
				ifLocalVar63_g75 = ase_lightColor;
			else
				ifLocalVar63_g75 = ( float4( 0,0,0,0 ) * ase_lightColor );
			float4 temp_cast_2 = (_DarknessMin).xxxx;
			float4 clampResult73_g75 = clamp( ( float4( localFunction_ShadeSH964_g75 , 0.0 ) + ifLocalVar63_g75 ) , temp_cast_2 , float4( 1,1,1,0 ) );
			float4 Lighting80_g75 = saturate( clampResult73_g75 );
			float2 uv_Shadow2Texture = i.uv_texcoord * _Shadow2Texture_ST.xy + _Shadow2Texture_ST.zw;
			float2 uv_Shadow1Texture = i.uv_texcoord * _Shadow1Texture_ST.xy + _Shadow1Texture_ST.zw;
			float3 lerpResult4_g75 = lerp( float3( 0,0,1 ) , 0 , _NormalIntensity);
			float3 newWorldNormal5_g75 = (WorldNormalVector( i , lerpResult4_g75 ));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult5_g76 = dot( newWorldNormal5_g75 , ase_worldlightDir );
			float temp_output_6_0_g75 = (dotResult5_g76*0.5 + 0.5);
			float grayscale14_g75 = (ase_lightColor.rgb.r + ase_lightColor.rgb.g + ase_lightColor.rgb.b) / 3;
			float3 localFunction_ShadeSH98_g75 = Function_ShadeSH9();
			float grayscale11_g75 = (localFunction_ShadeSH98_g75.r + localFunction_ShadeSH98_g75.g + localFunction_ShadeSH98_g75.b) / 3;
			float blendOpSrc15_g75 = grayscale14_g75;
			float blendOpDest15_g75 = grayscale11_g75;
			float4 transform13_g75 = mul(unity_ObjectToWorld,float4( _VDirLight , 0.0 ));
			float dotResult16_g75 = dot( transform13_g75 , float4( newWorldNormal5_g75 , 0.0 ) );
			float temp_output_21_0_g75 = ( ( dotResult16_g75 * 0.5 ) + 0.5 );
			float ifLocalVar25_g75 = 0;
			if( ase_lightColor.a <= 0.0 )
				ifLocalVar25_g75 = temp_output_21_0_g75;
			else
				ifLocalVar25_g75 = lerp(lerp(temp_output_6_0_g75,saturate( ( temp_output_6_0_g75 * 1 ) ),_ObjectShadow),( ( saturate( 	max( blendOpSrc15_g75, blendOpDest15_g75 ) )) * lerp(temp_output_6_0_g75,saturate( ( temp_output_6_0_g75 * 1 ) ),_ObjectShadow) ),_LightIntensityShadowPos);
			float temp_output_38_0_g75 = ( ( ( ( _Shadow1Place + ifLocalVar25_g75 ) - 0.5 ) * _Shadow1Contrast ) + 0.5 );
			float4 temp_cast_7 = (temp_output_38_0_g75).xxxx;
			float div45_g75=256.0/float((int)255.0);
			float4 posterize45_g75 = ( floor( temp_cast_7 * div45_g75 ) / div45_g75 );
			float4 temp_cast_8 = (temp_output_38_0_g75).xxxx;
			float4 ifLocalVar52_g75 = 0;
			if( _PosterizeToggle >= 0.5 )
				ifLocalVar52_g75 = posterize45_g75;
			else
				ifLocalVar52_g75 = temp_cast_8;
			float4 lerpResult69_g75 = lerp( ( tex2D( _Shadow1Texture, uv_Shadow1Texture ) * _Shadow1Color ) , DiffuseBase50_g75 , saturate( ifLocalVar52_g75 ));
			float temp_output_47_0_g75 = ( ( ( ( _Shadow2Place + ifLocalVar25_g75 ) - 0.5 ) * lerp(_Shadow1Contrast,_Shadow2Contrast,_Shadow2ContrastToggle) ) + 0.5 );
			float4 temp_cast_10 = (temp_output_47_0_g75).xxxx;
			float div55_g75=256.0/float((int)255.0);
			float4 posterize55_g75 = ( floor( temp_cast_10 * div55_g75 ) / div55_g75 );
			float4 temp_cast_11 = (temp_output_47_0_g75).xxxx;
			float4 ifLocalVar61_g75 = 0;
			if( _PosterizeToggle >= 0.5 )
				ifLocalVar61_g75 = posterize55_g75;
			else
				ifLocalVar61_g75 = temp_cast_11;
			float4 lerpResult72_g75 = lerp( ( tex2D( _Shadow2Texture, uv_Shadow2Texture ) * _Shadow2Color ) , lerpResult69_g75 , saturate( ifLocalVar61_g75 ));
			float2 uv_ShadowMask70_g75 = i.uv_texcoord;
			float4 lerpResult76_g75 = lerp( float4( 1,1,1,1 ) , lerpResult72_g75 , tex2D( _ShadowMask, uv_ShadowMask70_g75 ));
			float4 Shadow81_g75 = lerpResult76_g75;
			o.Emission = ( float4( ( (DiffuseBase50_g75).rgb * appendResult79_g75 ) , 0.0 ) * Lighting80_g75 * Shadow81_g75 ).rgb;
			o.Normal = float3(0,0,-1);
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		Stencil
		{
			Ref [_StencilReference]
			Comp Always
			Pass Replace
		}
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _StencilReference;
		uniform float _DarknessMin;
		uniform sampler2D _Shadow2Texture;
		uniform float4 _Shadow2Texture_ST;
		uniform float4 _Shadow2Color;
		uniform sampler2D _Shadow1Texture;
		uniform float4 _Shadow1Texture_ST;
		uniform float4 _Shadow1Color;
		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform float4 _DiffuseColor;
		uniform float _PosterizeToggle;
		uniform float _Shadow1Place;
		uniform float _LightIntensityShadowPos;
		uniform float _ObjectShadow;
		uniform float _NormalIntensity;
		uniform float3 _VDirLight;
		uniform float _Shadow1Contrast;
		uniform float _Shadow2Place;
		uniform float _Shadow2ContrastToggle;
		uniform float _Shadow2Contrast;
		uniform sampler2D _ShadowMask;
		uniform float _OutlineWidth;
		uniform sampler2D _OutlineMask;
		uniform float4 _OutlineColor;


		float3 Function_ShadeSH9(  )
		{
			return ShadeSH9(half4(0,0,0,1));
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float3 localFunction_ShadeSH964_g75 = Function_ShadeSH9();
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 ifLocalVar63_g75 = 0;
			if( _WorldSpaceLightPos0.w <= 0.0 )
				ifLocalVar63_g75 = ase_lightColor;
			else
				ifLocalVar63_g75 = ( float4( 0,0,0,0 ) * ase_lightColor );
			float4 temp_cast_1 = (_DarknessMin).xxxx;
			float4 clampResult73_g75 = clamp( ( float4( localFunction_ShadeSH964_g75 , 0.0 ) + ifLocalVar63_g75 ) , temp_cast_1 , float4( 1,1,1,0 ) );
			float4 Lighting80_g75 = saturate( clampResult73_g75 );
			float2 uv_Shadow2Texture = i.uv_texcoord * _Shadow2Texture_ST.xy + _Shadow2Texture_ST.zw;
			float2 uv_Shadow1Texture = i.uv_texcoord * _Shadow1Texture_ST.xy + _Shadow1Texture_ST.zw;
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float4 temp_output_48_0_g75 = ( tex2D( _Diffuse, uv_Diffuse ) * _DiffuseColor );
			float4 DiffuseBase50_g75 = temp_output_48_0_g75;
			float3 lerpResult4_g75 = lerp( float3( 0,0,1 ) , 0 , _NormalIntensity);
			float3 newWorldNormal5_g75 = (WorldNormalVector( i , lerpResult4_g75 ));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult5_g76 = dot( newWorldNormal5_g75 , ase_worldlightDir );
			float temp_output_6_0_g75 = (dotResult5_g76*0.5 + 0.5);
			float grayscale14_g75 = (ase_lightColor.rgb.r + ase_lightColor.rgb.g + ase_lightColor.rgb.b) / 3;
			float3 localFunction_ShadeSH98_g75 = Function_ShadeSH9();
			float grayscale11_g75 = (localFunction_ShadeSH98_g75.r + localFunction_ShadeSH98_g75.g + localFunction_ShadeSH98_g75.b) / 3;
			float blendOpSrc15_g75 = grayscale14_g75;
			float blendOpDest15_g75 = grayscale11_g75;
			float4 transform13_g75 = mul(unity_ObjectToWorld,float4( _VDirLight , 0.0 ));
			float dotResult16_g75 = dot( transform13_g75 , float4( newWorldNormal5_g75 , 0.0 ) );
			float temp_output_21_0_g75 = ( ( dotResult16_g75 * 0.5 ) + 0.5 );
			float ifLocalVar25_g75 = 0;
			if( ase_lightColor.a <= 0.0 )
				ifLocalVar25_g75 = temp_output_21_0_g75;
			else
				ifLocalVar25_g75 = lerp(lerp(temp_output_6_0_g75,saturate( ( temp_output_6_0_g75 * ase_lightAtten ) ),_ObjectShadow),( ( saturate( 	max( blendOpSrc15_g75, blendOpDest15_g75 ) )) * lerp(temp_output_6_0_g75,saturate( ( temp_output_6_0_g75 * ase_lightAtten ) ),_ObjectShadow) ),_LightIntensityShadowPos);
			float temp_output_38_0_g75 = ( ( ( ( _Shadow1Place + ifLocalVar25_g75 ) - 0.5 ) * _Shadow1Contrast ) + 0.5 );
			float4 temp_cast_6 = (temp_output_38_0_g75).xxxx;
			float div45_g75=256.0/float((int)255.0);
			float4 posterize45_g75 = ( floor( temp_cast_6 * div45_g75 ) / div45_g75 );
			float4 temp_cast_7 = (temp_output_38_0_g75).xxxx;
			float4 ifLocalVar52_g75 = 0;
			if( _PosterizeToggle >= 0.5 )
				ifLocalVar52_g75 = posterize45_g75;
			else
				ifLocalVar52_g75 = temp_cast_7;
			float4 lerpResult69_g75 = lerp( ( tex2D( _Shadow1Texture, uv_Shadow1Texture ) * _Shadow1Color ) , DiffuseBase50_g75 , saturate( ifLocalVar52_g75 ));
			float temp_output_47_0_g75 = ( ( ( ( _Shadow2Place + ifLocalVar25_g75 ) - 0.5 ) * lerp(_Shadow1Contrast,_Shadow2Contrast,_Shadow2ContrastToggle) ) + 0.5 );
			float4 temp_cast_9 = (temp_output_47_0_g75).xxxx;
			float div55_g75=256.0/float((int)255.0);
			float4 posterize55_g75 = ( floor( temp_cast_9 * div55_g75 ) / div55_g75 );
			float4 temp_cast_10 = (temp_output_47_0_g75).xxxx;
			float4 ifLocalVar61_g75 = 0;
			if( _PosterizeToggle >= 0.5 )
				ifLocalVar61_g75 = posterize55_g75;
			else
				ifLocalVar61_g75 = temp_cast_10;
			float4 lerpResult72_g75 = lerp( ( tex2D( _Shadow2Texture, uv_Shadow2Texture ) * _Shadow2Color ) , lerpResult69_g75 , saturate( ifLocalVar61_g75 ));
			float2 uv_ShadowMask70_g75 = i.uv_texcoord;
			float4 lerpResult76_g75 = lerp( float4( 1,1,1,1 ) , lerpResult72_g75 , tex2D( _ShadowMask, uv_ShadowMask70_g75 ));
			float4 Shadow81_g75 = lerpResult76_g75;
			c.rgb = ( Lighting80_g75 * Shadow81_g75 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			Stencil
			{
				Ref [_StencilReference]
				Comp Always
				Pass Replace
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15900
956;92;964;936;1745.855;1157.76;1;True;False
Node;AmplifyShaderEditor.FunctionNode;134;-1764.855,-675.7598;Float;False;ReflexToonFunction;0;;75;865743dd0db312545bd2b88ae725e833;0;0;3;COLOR;0;COLOR;99;COLOR;101
Node;AmplifyShaderEditor.RangedFloatNode;135;-1355.855,-966.76;Float;False;Property;_StencilReference;StencilReference;23;0;Create;True;0;0;True;0;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OutlineNode;132;-1424.855,-544.7598;Float;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-1119.913,-857.6068;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Reflex Toon/Stenil/Writer;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;True;0;True;135;255;False;-1;255;False;-1;7;False;-1;3;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;132;0;134;99
WireConnection;132;1;134;101
WireConnection;0;13;134;0
WireConnection;0;11;132;0
ASEEND*/
//CHKSM=9025363BF2A62639975337137CCB3990C4C945A8