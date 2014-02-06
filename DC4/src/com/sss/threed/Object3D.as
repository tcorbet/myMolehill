package com.sss.threed 
{
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.textures.RectangleTexture;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import com.adobe.utils.AGALMiniAssembler;

import com.sss.threed.Camera;
import com.sss.threed.Scene3D;
import com.sss.threed.Stage3DBase;
import com.sss.threed.TextureController;
import com.sss.threed.Texturizer;
import com.sss.threed.geometry.AABB;
import com.sss.threed.geometry.IBoundVolume;
import com.sss.threed.geometry.IGeometry;
import com.sss.threed.geometry.SPHBB;
import com.sss.threed.shader.IProgram;
import com.sss.threed.shader.ProgramBase;
import com.sss.math.M;
import com.sss.util.U;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-29
*/
public class Object3D
{
	private var _id:String;
	private var _transform:Matrix3D;
	private var _inverseTransform:Matrix3D;
	private var _geometryID:String;
	private var _geometry:IGeometry;
	private var _objectSurfaces:Dictionary;
	private var _renderCallBack:Function;
	private var _comps:Vector.<Vector3D>;
	private var _datum:*;
	private var _parent:Object3D;
	private var _children:Vector.<Object3D>;
	private var tab:int;
	private var boundVolumeSphere:Boolean;
	private var boundVolume:IBoundVolume;
	private var transformChanged:Boolean;
	private var _params:Array;
	private var texMaps:TextureController;
	private var _lightingControls:Vector.<Number>;

	public var visible:Boolean;
	public var pickable:Boolean;

	public function
	Object3D (id:String, geometryID:String, boundVolumeSphere:Boolean = false, ... params)
	{
		_id = id;
		_geometryID = geometryID;
		this.boundVolumeSphere = boundVolumeSphere;
		_params = params;
		_transform = new Matrix3D();
		transformChanged = true;
		texMaps = new TextureController();
		visible = true;
		pickable = true;
		tab = -1;
		_lightingControls = Vector.<Number> ([1.0, 0.3, 1.0, 16.0]);
	} // End of Constructor for Object3D.

	public function
	dispose()
	:void
	{
		for (var key:String in _objectSurfaces) {
			var surface:Surface = (_objectSurfaces[key] as Surface);
			surface.dispose();
			delete _objectSurfaces[key];
			trace ("Copy of Surface", key, "disposed.");
		}
		_params = [];
		_objectSurfaces = null;
		_geometry = null;
		_renderCallBack = null;
		texMaps.dispose();
		trace ("Object3D", _id, "disposed.");
	} // End of dispose().

	[Inline] public final function get id():String { return (_id); };
	[Inline] public final function get geometryID():String { return (_geometryID); };
	[Inline] public final function get params():Array { return (_params); };
	[Inline] public final function get isContainer():Boolean { return (_geometryID == null); };
	[Inline] public final function get geometry():IGeometry { return (_geometry); };
	[Inline] public final function set geometry (value:IGeometry):void { _geometry = value; };
	[Inline] public final function get objectSurfaces():Dictionary { return (_objectSurfaces); };
	[Inline] public final function set objectSurfaces (value:Dictionary):void { _objectSurfaces = value; };
	[Inline] public final function get renderCallBack():Function { return (_renderCallBack); };
	[Inline] public final function set renderCallBack (value:Function):void { _renderCallBack = value; };
	[Inline] public final function get translation():Vector3D { return (comps[0]); };
	[Inline] public final function get rotation():Vector3D { return (comps[1]); };
	[Inline] public final function get scale():Vector3D { return (comps[2]); };
	[Inline] public final function set comps (value:Vector.<Vector3D>):void { _comps = value; };
	[Inline] public final function set datum (value:*):void { _datum = value; };
	[Inline] public final function get datum():* { return (_datum); };
	[Inline] public final function get parent():Object3D { return (_parent); };
	[Inline] public final function set parent (value:Object3D):void { _parent = value; };
	[Inline] public final function get isContained():Boolean { return (_parent != null); };
	[Inline] public final function get children():Vector.<Object3D> { return (_children); };
	[Inline] public final function get lightingControls():Vector.<Number> { return (_lightingControls); };
	[Inline] public final function set intensity (value:Number):void { _lightingControls[0] = value; };
	[Inline] public final function set antiIntensity (value:Number):void { _lightingControls[1] = value; };
	[Inline] public final function set specIntensity (value:Number):void { _lightingControls[2] = value; };
	[Inline] public final function set specPower (value:Number):void { _lightingControls[3] = value; };

	public final function
	get transform()
	:Matrix3D
	{
		if (isContained) {
			var concatenatedTransform:Matrix3D = _transform.clone();
			concatenatedTransform.append (_parent.transform);
			return (concatenatedTransform);
		} else {
			return (_transform);
		}
	} // End of transform getter.

	public final function
	get inverseTransform()
	:Matrix3D
	{
		if (transformChanged) {
			_inverseTransform = _transform.clone();
			_inverseTransform.invert();
			transformChanged = false;
		}
		return (_inverseTransform);
	} // End of inverseTransform getter.

	public final function
	get comps()
	:Vector.<Vector3D>
	{
		if (_comps == null) _comps = _transform.decompose();
		return (_comps);
	} // End of comps getter.

	public final function
	getTabbedChild (fwd:Boolean)
	:Object3D
	{
		if (fwd) {
			if (++tab == _children.length) {
				tab = -1;
				return (null);
			}
		} else {
			if (--tab < 0) { // This will fail if the first gesture is a reverse tab.
				tab = _children.length;
				return (null);
			}
		}
		return (_children[tab]);
	} // End of getTabbedChild().

	public function
	getIntersectedDistance (point:Vector3D, ray:Vector3D)
	:Number
	{
		if (boundVolume == null) {
			if (boundVolumeSphere) {
				boundVolume = new SPHBB (_geometry);
			} else {
				boundVolume = new AABB (_geometry);
			}
			boundVolume.updateMinimaMaxima (_transform);
			// trace (boundVolume);
		}

		if (transformChanged) {
			_inverseTransform = _transform.clone();
			_inverseTransform.invert();
			transformChanged = false;
		}
		point = _inverseTransform.transformVector (point);
		// trace ("Local Pos", point);
		ray = _inverseTransform.deltaTransformVector (ray);
		// trace ("Local Dir", ray);
		// ray.normalize();  // Away3d does not normalize but Minko does.
		return (boundVolume.intersects (point, ray));
	} // End of getIntersectedDistance().

	public function
	resetTransform()
	:void
	{
		_transform.identity();
		transformChanged = true;
	} // End of resetTransform().

	public function
	uniformScale (value:Number)
	:void
	{
		_transform.appendScale (value, value, value);
		transformChanged = true;
	} // End of uniformScale().

	public function
	translate (x:Number, y:Number, z:Number)
	:void
	{
		_transform.appendTranslation (x, y, z);
		transformChanged = true;
	} // End of translate().

	public function
	rotateLocal (angle:Number, axis:Vector3D)
	:void
	{
		var position:Vector3D = _transform.position;
		_transform.position = new Vector3D (0.0, 0.0, 0.0);
		_transform.appendRotation (angle, axis);
		_transform.position = position;
		transformChanged = true;
	} // End of rotateLocal().

	public function
	addChild (child:Object3D, scene:Scene3D)
	:void
	{
		if (! isContainer) {
			throw (new Error ("Children may only be added to containers."));
		}
		child.parent = this;
		if (_children == null) _children = new Vector.<Object3D>();
		_children.push (child);
		scene.addObject (child);
	} // End of addChild().

	public function
	removeChild (child:Object3D, scene:Scene3D)
	:void
	{
		var idx:int = _children.indexOf (child);
		if (idx < 0) return;
		_children.splice (idx, 1);
		child.parent = null;
		scene.removeObject (child);
	} // End of removeChild().

	public function
	changeSurfaceMaterial (material:*, surfaceID:String = null)
	:void
	{
		var surface:Surface;
foundOut:
		if (surfaceID) {
			for each (surface in _objectSurfaces) {
				if (surface.id == surfaceID) {
					surface.material = material;
					break foundOut;
				}
			}
			throw (new Error ("Invalid Surface ID " + surfaceID + "."));
		} else {
			for each (surface in _objectSurfaces) {
				surface.material = material;
			}
		}
		trace (((surfaceID) ? surfaceID : "All"), "surface material changed.", material); 
	} // End of changeSurfaceMaterial().

	public function
	changeSurfaceProgram (programID:String, surfaceID:String = null)
	:void
	{
		var surface:Surface;
		if (surfaceID) {
			for each (surface in _objectSurfaces) {
				if (surface.id == surfaceID) {
					surface.programID = programID;
					break;
				}
			}
			throw (new Error ("Invalid Surface ID " + surfaceID + "."));
		} else {
			for each (surface in _objectSurfaces) {
				surface.programID = programID;
			}
		}
		trace (((surfaceID) ? surfaceID : "All"), "surface program changed.", programID); 
	} // End of changeSurfaceProgram().

	public function
	wire (context3D:Context3D)
	:void
	{
		for each (var surface:Surface in _objectSurfaces) {
			surface.programID = ProgramBase.WIRE_1;
		}
		_geometry.wire (context3D);
	} // End of wire().

	public function
	renderSurfaces (context3D:Context3D, stage3D:Stage3DBase, scene:Scene3D, camera:Camera)
	:void
	{
		if ((! scene.paused) && (_renderCallBack)) _renderCallBack (this);
		var currentProgramID:String = null;
		var currentSurfaceID:String = null;
		for each (var surface:Surface in _objectSurfaces) {
			if (! surface.visible) continue;
			context3D.setCulling (Context3DTriangleFace.BACK);
			switch (surface.programID) {
				case (ProgramBase.COLOR_01):
					context3D.setProgramConstantsFromVector (Context3DProgramType.FRAGMENT, 0,
						surface.material);
					break;
				case (ProgramBase.COLOR_02):
					context3D.setCulling (Context3DTriangleFace.NONE);
					context3D.setProgramConstantsFromVector (Context3DProgramType.FRAGMENT, 0,
						surface.material);
					break;
				case (ProgramBase.COLOR_11):
					context3D.setProgramConstantsFromMatrix (Context3DProgramType.VERTEX, 4,
						_transform, true);
					context3D.setProgramConstantsFromVector (Context3DProgramType.VERTEX, 8,
						scene.lightPos); // Light Direction [Position].
					context3D.setProgramConstantsFromVector (Context3DProgramType.VERTEX, 9,
						surface.material);
					context3D.setProgramConstantsFromVector (Context3DProgramType.VERTEX, 10,
						camera.position4GPU);
					break;
				case (ProgramBase.COLOR_12):
					context3D.setProgramConstantsFromMatrix (Context3DProgramType.VERTEX, 4,
						_transform, true);
					context3D.setProgramConstantsFromVector (Context3DProgramType.VERTEX, 8,
						scene.lightPos); // Light Direction [Position].
					context3D.setProgramConstantsFromVector (Context3DProgramType.VERTEX, 10,
						camera.position4GPU);
					break;
				case (ProgramBase.TEXTURE_01):
				case (ProgramBase.TEXTURE_02):
					// Nothing required.
					break;
				case (ProgramBase.TEXTURE_11):
				case (ProgramBase.TEXTURE_12):
					context3D.setProgramConstantsFromMatrix (Context3DProgramType.VERTEX, 4,
						_transform, true);
					context3D.setProgramConstantsFromVector (Context3DProgramType.VERTEX, 8,
						scene.lightPos); // Light Direction [Position].
					context3D.setProgramConstantsFromVector (Context3DProgramType.VERTEX, 10,
						camera.position4GPU);
					break;
				case (ProgramBase.TEXTURE_21):
					context3D.setProgramConstantsFromVector (Context3DProgramType.VERTEX, 4,
						scene.lightPos); // Light Direction [Position].
					context3D.setProgramConstantsFromVector (Context3DProgramType.VERTEX, 5,
						camera.position4GPU);
					context3D.setProgramConstantsFromMatrix (Context3DProgramType.FRAGMENT, 0,
						_transform, true);
					context3D.setProgramConstantsFromVector (Context3DProgramType.FRAGMENT, 4,
						scene.lightPos); // Light Direction [Position].
					break;
				case (ProgramBase.WIRE_1):
					context3D.setCulling (Context3DTriangleFace.NONE);
					context3D.setProgramConstantsFromVector (Context3DProgramType.FRAGMENT, 0,
						surface.material); // Triangle color.
					context3D.setProgramConstantsFromVector (Context3DProgramType.FRAGMENT, 1,
						Vector.<Number>([1.0, -2.0, 2.0, 2.0])); // Math constants.
					context3D.setProgramConstantsFromVector (Context3DProgramType.FRAGMENT, 2,
						Vector.<Number>([(.08), (.08), 0.0, 0.0])); // Thickness controls.
					context3D.setProgramConstantsFromVector (Context3DProgramType.FRAGMENT, 3,
						Vector.<Number>([scale.x, scale.y, scale.z, scale.w])); // Object's Scale.
					break;
			} // End of Switch on Program ID.

			if (surface.programID != currentProgramID) {
				currentProgramID = surface.programID;
				activateProgram (context3D, scene.programs, currentProgramID);
				geometry.activateVertexStreams (context3D, currentProgramID);
			}
			if (surface.id != currentSurfaceID) {
				context3D.setTextureAt (0, null);
				context3D.setTextureAt (1, null);
				context3D.setTextureAt (2, null);
				currentSurfaceID = surface.id;
				activateTexture (context3D, camera, currentProgramID, currentSurfaceID);
			}
			// trace ("Rendering", _id, surface.id, surface.programID, "Tri Count", surface.numTriangles);
			context3D.drawTriangles (geometry.indexBuffer, surface.offset, surface.numTriangles);
			stage3D.triangleCounter += surface.numTriangles;
		} // End of For Each Object Surface.
	} // End of renderSurfaces().

	private function
	activateProgram (context3D:Context3D, programDict:Object, programID:String)
	:void
	{
		var program:IProgram = programDict[programID];
		if (program.program3D == null) {
			if ((program.vertexProgram == null) || (program.fragmentProgram == null)) {
				throw (new Error (programID + " has invalid source code."));
			}
			var vertexByteCode:ByteArray = new AGALMiniAssembler (false).assemble (
				Context3DProgramType.VERTEX, program.vertexProgram);
			trace (program.vertexProgram, "\n= = = = = = = = = =");
			var fragmentByteCode:ByteArray = new AGALMiniAssembler (false).assemble (
				Context3DProgramType.FRAGMENT, program.fragmentProgram);
			trace (program.fragmentProgram);
			program.program3D = context3D.createProgram();
			program.program3D.upload (vertexByteCode, fragmentByteCode);
			trace ("Uploaded New Program", programID);
		}
		context3D.setProgram (program.program3D);
	} // End of activateProgram().

	public function
	activateTexture (context3D:Context3D, camera:Camera, programID:String, surfaceID:String)
	:void
	{
		var surface:Surface = (_objectSurfaces[surfaceID] as Surface);
		var bmd:BitmapData;
		if ((programID == ProgramBase.TEXTURE_01) || (programID == ProgramBase.TEXTURE_11)) {
			if (texMaps.diffuse == null) {
				bmd = (surface.material as BitmapData);
				texMaps.diffuse = context3D.createRectangleTexture (bmd.width, bmd.height, Context3DTextureFormat.BGRA, false);
				RectangleTexture (texMaps.diffuse).uploadFromBitmapData (bmd);
			}
			context3D.setTextureAt (0, texMaps.diffuse);
		} else if ((programID == ProgramBase.TEXTURE_02) || (programID == ProgramBase.TEXTURE_12)) {
			var texturizer:Texturizer = (surface.material as Texturizer);
			if (camera) {
				var cameraPos:Vector3D =  camera.transform.position;
				var bbPos:Vector3D = _transform.position;
				var sep:Number = Math.sqrt (
					((bbPos.x - cameraPos.x) * (bbPos.x - cameraPos.x)) +
					((bbPos.y - cameraPos.y) * (bbPos.y - cameraPos.y)) +
					((bbPos.z - cameraPos.z) * (bbPos.z - cameraPos.z))
					);
				// Denominator should be max distance divided by number of mip samples.
				var idx:uint = uint (sep / (68.0 / 9)); 
				if (idx > 9) {
					idx = 9;
				} else if (idx < 1) {
					idx = 1;
				}
				context3D.setTextureAt (0, texturizer.getMap (10 - idx));
				// trace (idx, "Using MIP", (10 - idx), sep);
			} else {
				context3D.setTextureAt (0, texturizer.getMap (9));  // Assumed starting camera position.
			}
		} else if (programID == ProgramBase.TEXTURE_21) {
			if (texMaps.diffuse == null) {
				bmd = (surface.material[0] as BitmapData);
				texMaps.diffuse = context3D.createRectangleTexture (bmd.width, bmd.height, Context3DTextureFormat.BGRA, false);
				RectangleTexture (texMaps.diffuse).uploadFromBitmapData (bmd);
				if (surface.material[1]) {
					bmd = (surface.material[1] as BitmapData);
					texMaps.normal = context3D.createRectangleTexture (bmd.width, bmd.height, Context3DTextureFormat.BGRA, false);
					RectangleTexture (texMaps.normal).uploadFromBitmapData (bmd);
				}
				if (surface.material[2]) {
					bmd = (surface.material[2] as BitmapData);
					texMaps.specular = context3D.createRectangleTexture (bmd.width, bmd.height, Context3DTextureFormat.BGRA, false);
					RectangleTexture (texMaps.specular).uploadFromBitmapData (bmd);
				}
			}
			context3D.setTextureAt (0, texMaps.diffuse);
			context3D.setTextureAt (1, texMaps.normal);
			if (texMaps.specular) context3D.setTextureAt (2, texMaps.specular);
		}
	} // End of activateTexture().

	public function
	toString()
	:String
	{
		var result:String = (_id + " " + _geometryID + " Num Surfaces = ");
		if (_geometry) {
			result += U.getDictionaryItemCount (_objectSurfaces);
		} else {
			result += 0;
		}
		result += ((isContained) ? " Contained." : " In Scene.");
		return (result);
	} // End of toString().

} // End of Object3D Class.

} // End of Package Declaration.