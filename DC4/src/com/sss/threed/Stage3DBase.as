package com.sss.threed 
{
import flash.display.Sprite;
import flash.display.Stage3D;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProfile;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DRenderMode;
import flash.display3D.Context3DStencilAction;
import flash.display3D.Context3DTriangleFace;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.getTimer;

import com.adobe.utils.PerspectiveMatrix3D;

import com.sss.fonts.App4Fonts;
import com.sss.math.M;
import com.sss.threed.Camera;
import com.sss.threed.Scene3D;
import com.sss.util.U;
/**
** @author J. Terry Corbet
** @version 1.0 2014-02-27
*/
public class Stage3DBase extends Sprite
{
	// If these variables are not declared static, an extended class' Constructor
	// is unable to override their values prior to invoking super().
	protected static var stageWidth:Number = 800.0;
	protected static var stageHeight:Number = 600.0;
	protected static var backgroundRGBA:Vector.<Number> = new <Number> [
		(0xdd / 0xff), (0xee / 0xff), (0xee / 0xff), (0xff / 0xff)];
	protected static var fov:Number = 45.0;
	protected static var near:Number = 0.1;
	protected static var far:Number = 1000.0;

	protected var context3D:Context3D;
	protected var frameCounter:uint;
	protected var scene:Scene3D;

	private var _aspectRatio:Number;
	private var _projection:PerspectiveMatrix3D = new PerspectiveMatrix3D();
	protected var _camera:Camera;
	private var finalTransform:Matrix3D = new Matrix3D();

	private var statsDisplay:TextField;
	private var statsMinimized:Boolean;
	private var priorFC:uint;
	private var priorTime:Number;
	private var switches:Vector.<Number> = Vector.<Number> ([1.0, 1.0, 0.0, 0.0]);
	private var objectCounter:uint;
	private var _triangleCounter:uint;

	public function
	Stage3DBase()
	{
		super();

		new App4Fonts();
	
		if (stage) {
			appInit (null);
		} else {
			addEventListener (Event.ADDED_TO_STAGE, appInit);
		}
	} // End of Constructor for Stage3DBase.

	private function
	appInit (event:Event)
	:void
	{
		trace ("Stage3DBase.appInit", "Entered");
		removeEventListener (Event.ADDED_TO_STAGE, appInit);

		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.quality = StageQuality.BEST;

		stage.addEventListener (Event.RESIZE,
			function (event:Event)
			:void
			{
				trace ("Main Stage Resized.");
				stageWidth = stage.stageWidth;
				stageHeight = stage.stageHeight;
				aspectRatio = (stageWidth / stageHeight);
			} // End of anonymous closure.
		);

		var stage3D:Stage3D;
		try {
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener (Event.CONTEXT3D_CREATE, initMolehill);
			stage3D.requestContext3D (Context3DRenderMode.AUTO, Context3DProfile.BASELINE);
		} catch (error:Error) {
			trace ("Request Context", error.errorID, error.message);
		}

		trace ("Scene Dimensions", stageWidth, stageHeight);
		_aspectRatio = (stageWidth / stageHeight);
		scene = new Scene3D (stage, this);
	} // End of appInit()().

	private function
	initMolehill (event:Event)
	:void
	{
		context3D = Stage3D (event.target).context3D;
		trace ("Stage3DBase.initMolehill", "Context3D", context3D.driverInfo);
		// context3D.enableErrorChecking = true;
		context3D.setDepthTest (true, Context3DCompareMode.LESS); // LESS_EQUAL);
		context3D.setStencilActions (Context3DTriangleFace.FRONT, Context3DCompareMode.ALWAYS,
			Context3DStencilAction.KEEP, Context3DStencilAction.KEEP, Context3DStencilAction.KEEP);
		context3D.setBlendFactors (Context3DBlendFactor.SOURCE_ALPHA,
			Context3DBlendFactor.ZERO); // Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

		context3D.configureBackBuffer (stageWidth, stageHeight, 16, true, false);

		setupScene (new Vector3D (0.0, 0.0, -60.0), new Vector3D());
		stage.addEventListener (Event.ENTER_FRAME, render);
		stage.addEventListener (Event.EXIT_FRAME, reportGPUUsage);
	} // End of initMolehill().

	protected function
	setupScene (cameraPosition:Vector3D, cameraPOI:Vector3D)
	:void
	{
		_camera = new Camera (cameraPosition, cameraPOI, stage);
		updateProjection();

		statsDisplay = new TextField();
		addChild (statsDisplay);
		statsDisplay.x = -1000; statsDisplay.y = -1000;
		statsDisplay.width = 120; 
		statsDisplay.multiline = true;
		statsDisplay.alpha = 0.85;
		statsDisplay.background = true;
		statsDisplay.backgroundColor = 0xdddd00;
		statsDisplay.border = true;
		statsDisplay.defaultTextFormat = new TextFormat ("_typewriter", 11, 0x444444, true, true);
		statsDisplay.selectable = false;
		statsDisplay.addEventListener (MouseEvent.CLICK,
			function (event:MouseEvent)
			:void
			{
				event.stopPropagation();
				statsMinimized = (! statsMinimized);
			} // End of anonymous closure.
		);

		priorFC = frameCounter;
		priorTime  = getTimer();

		stage.addEventListener (KeyboardEvent.KEY_DOWN,
			function (event:KeyboardEvent)
			:void
			{
				switch (event.keyCode) {
					case (Keyboard.NUMPAD_ADD):
						if (event.ctrlKey) {
							changeFOV (fov + 1);
						} else if (event.shiftKey) {
							switches[1] = 1;
						}
						break;
					case (Keyboard.NUMPAD_SUBTRACT):
						if (event.ctrlKey) {
							changeFOV (fov - 1);
						} else if (event.shiftKey) {
							switches[1] = 0;
						}
						break;
				} // End of Switch on KeyCode.
			} // End of anonymous closure.
		);
	} // End of setupScene().

	private function
	render (event:Event)
	:void
	{
		if (! context3D) return;
		++frameCounter;
		_triangleCounter = objectCounter = 0;

		_camera.updatePosition();

		context3D.clear (backgroundRGBA[0], backgroundRGBA[1], backgroundRGBA[2],
			backgroundRGBA[3], 1.0, 0x00);
		context3D.setStencilReferenceValue (0);

		var objIndex:uint = 0;
		for each (var obj:Object3D in scene.objects) {
			if (! obj.visible) continue;
			if (obj.isContainer) {
				for each (var child:Object3D in obj.children) {
					if (! child.visible) continue;
					renderObject (child, scene, ++objIndex);
				}
			} else {
				renderObject (obj, scene, ++objIndex);
			}
		}

		context3D.present();

		reportStatistics();
	} // End of render().

	private function
	renderObject (obj:Object3D, scene:Scene3D, objIndex:uint)
	:void
	{
		finalTransform.identity();
		finalTransform.append (obj.transform);
		finalTransform.append (_camera.cameraView);
		finalTransform.append (_projection);

		context3D.setProgramConstantsFromMatrix (Context3DProgramType.VERTEX, 0, finalTransform, true);
		context3D.setProgramConstantsFromVector (Context3DProgramType.VERTEX, 27, switches);
		context3D.setProgramConstantsFromVector (Context3DProgramType.FRAGMENT, 27, switches);
		context3D.setProgramConstantsFromVector (Context3DProgramType.VERTEX, 26, obj.lightingControls);
		context3D.setProgramConstantsFromVector (Context3DProgramType.FRAGMENT, 26, obj.lightingControls);
		context3D.setProgramConstantsFromVector (Context3DProgramType.FRAGMENT, 25,
			Vector.<Number> ([255.0, 127.5, 0.00784313725, 0.0]));

		obj.renderSurfaces (context3D, this, scene, _camera);
		++objectCounter;

		if ((frameCounter == 1) && (objIndex == 1)) {
			M.prettyRaw ("CameraView", _camera.cameraView);
			M.prettyRaw ("Projection", _projection);
			M.prettyRaw ("Final", finalTransform);
		}
		if (frameCounter == 1) M.prettyRaw (obj.id, obj.transform);
	} // End of renderObject().

	private function
	reportStatistics()
	:void
	{
		var now:Date = new Date(); // Because getTimer() leaks.
		var ms:Number = (now.time - priorTime);
		if ((ms) > 1000) {
			if (statsMinimized) {
				statsDisplay.height = 15;
				statsDisplay.text = (
					U.fixedFract (((frameCounter - priorFC) / ms * 1000.0), 0) + " " +
					objectCounter + "; " +
					_triangleCounter
					);
			} else {
				statsDisplay.height = 75;
				statsDisplay.text = (
					"FR/S: " + U.fixedFract (((frameCounter - priorFC) / ms * 1000.0), 0) + "\n" +
					"O-TR: " + objectCounter + "-" + _triangleCounter + "\n" +
					"PRIV: " + U.fixedFract ((System.privateMemory / 1024), 0) + "\n" +
					"TOTL: " + U.fixedFract ((System.totalMemory / 1024), 0) + "\n" +
					"FREE: " + U.fixedFract ((System.freeMemory / 1024), 0)
					);
			}
			statsDisplay.x = (stageWidth - (statsDisplay.width + 1));
			statsDisplay.y = (stageHeight - (statsDisplay.height + 1));
			priorFC = frameCounter;
			priorTime = now.time;
		}
		if (ms > 5000) System.gc();
	} // End of reportStatistics();

	private function
	reportGPUUsage (event:Event)
	:void
	{
		stage.removeEventListener (Event.EXIT_FRAME, reportGPUUsage);
		trace ("GPU Usage", stage.wmodeGPU);
	} // End of reportGPUUsage().

	[Inline] public final function get sceneWidth():Number { return (stageWidth); };
	[Inline] public final function get sceneHeight():Number { return (stageHeight); };
	[Inline] public final function get projection():Matrix3D { return (_projection); };
	[Inline] public final function get camera():Camera { return (_camera); };
	[Inline] public final function get triangleCounter():uint { return (_triangleCounter); };
	[Inline] public final function set triangleCounter (value:uint):void { _triangleCounter = value; };

	public function
	getBackground (moderator:Number = 0.0)
	:uint
	{
		moderator += 1.0;
		return (
			((backgroundRGBA[0] * 0xff * moderator) << 16) |
			((backgroundRGBA[1] * 0xff * moderator) << 8) |
			(backgroundRGBA[2] * 0xff * moderator)
			);
	} // End of getBackground().

	public function
	changeFOV (value:Number)
	:void
	{
		fov = value;
		updateProjection();
	} // End of changeFOV().

	private function
	set aspectRatio (value:Number)
	:void
	{
		_aspectRatio = value;
		if (context3D) context3D.configureBackBuffer (stageWidth, stageHeight, 16, true, false);
		updateProjection();
	} // End of aspectRatio setter.

	// This is Adobe's Left Hand Perspective Lens.
	private function
	updateProjection()
	:void
	{
		var yScale:Number = (1.0 / Math.tan ((fov * Math.PI / 180.0) / 2.0));
		var xScale:Number = (yScale / _aspectRatio);

		_projection.copyRawDataFrom (Vector.<Number> ([
			xScale, 0.0, 0.0, 0.0,
			0.0, yScale, 0.0, 0.0,
			0.0, 0.0, (far / (far - near)), (-(far * near) / (far - near)),
			0.0, 0.0, 1.0, 0.0]),
			0, true);
	} // End of updateProjection().

} // End of Stage3DBase Class.

} // End of Package Declaration.