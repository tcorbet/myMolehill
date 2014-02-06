package com.sss.threed 
{
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.Dictionary;
import flash.utils.Timer;

import com.sss.threed.Camera;
import com.sss.threed.GeometryController;
import com.sss.threed.Object3D;
import com.sss.threed.Stage3DBase;
import com.sss.threed.Surface;
import com.sss.threed.geometry.GeometryBase;
import com.sss.threed.shader.IProgram;
/**
** @author J. Terry Corbet
** @version 1.0 2014-02-05
*/
public class Scene3D 
{
	private var stage:Stage;
	private var stage3D:Stage3DBase;
	private var gc:GeometryController;
	private var _paused:Boolean;
	private var _objects:Vector.<Object3D>;
	private var _programs:Dictionary;
	private var _lightPos:Vector.<Number>;
	private var _tab:int;
	private var tabLabel:TextField
	private var tabLabelTimer:Timer;
	private var graphics:Graphics;

	public function
	Scene3D (stage:Stage, stage3D:Stage3DBase)
	{
		this.stage = stage;
		this.stage3D = stage3D;
		gc = GeometryController.instance;
		_objects = new Vector.<Object3D>();
		_programs = new Dictionary (false);
		lightPos = Vector.<Number>([250.0, 250.0, -1000.0, 0.0]);

		var root:Sprite = (stage3D as Sprite);
		graphics = root.graphics;

		tabLabel = new TextField();
		tabLabel.visible = false;
		root.addChild (tabLabel);
		tabLabel.width = 100;
		tabLabel.height = 20;
		tabLabel.alpha = 0.85;
		tabLabel.autoSize = TextFieldAutoSize.LEFT;
		tabLabel.background = true;
		tabLabel.backgroundColor = stage3D.getBackground();
		tabLabel.border = true;
		tabLabel.restrict = ("");
		tabLabel.defaultTextFormat = new TextFormat ("_typewriter", 16, 0xdd0000, true, true);
		tabLabel.selectable = false;
		_tab = -1;
		tabLabelTimer = new Timer (10000, 1);
		tabLabelTimer.addEventListener (TimerEvent.TIMER,
			function (event:TimerEvent)
			:void
			{
				tabLabel.visible = false;
				graphics.clear();
			} // End of anonymous clsoure.
		);
		tabLabel.addEventListener (MouseEvent.CLICK,
			function (event:MouseEvent)
			:void
			{
				event.stopPropagation();
				var selectedObject:Object3D = (tabLabel.metaData as Object3D);
				if (selectedObject) {
					if (selectedObject.visible) {
						selectedObject.visible = false;
						_tab = (getObjectTab (selectedObject.id) - 1);
					} else {
						selectedObject.visible = true;
					}
				}
			} // End of anonymous closure.
		);

		stage.addEventListener (KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener (MouseEvent.CLICK, mouseClickHandler);
		stage.addEventListener (MouseEvent.MIDDLE_CLICK, mouseClickHandler);
		stage.addEventListener (MouseEvent.RIGHT_CLICK, mouseClickHandler);
	} // End of Constructor for Scene3D.

	[Inline] public final function get paused():Boolean { return (_paused); };
	[Inline] public final function get objects():Vector.<Object3D> { return (_objects); };
	[Inline] public final function get tab():int { return (_tab); };
	[Inline] public final function set tab (value:int):void { _tab = value; };
	[Inline] public final function get programs():Dictionary { return (_programs); };
	[Inline] public final function get lightPos():Vector.<Number> { return (_lightPos); };

	public final function
	set lightPos (value:Vector.<Number>)
	:void
	{
		var pos:Vector3D = new Vector3D (value[0], value[1], value[2], value[3]);
		pos.normalize();
		_lightPos = Vector.<Number> ([pos.x, pos.y, pos.z, pos.w]);
	} // End of lightPos setter.

	[Inline] public final function
	get selectedObject()
	:Object3D
	{
		return ((_tab >= 0) ? _objects[_tab] : null);
	} // End of selectedObject getter.

	public function
	addProgram (program:IProgram)
	:void
	{
		_programs[program.id] = program;
	} // End of addProgram.

	public function
	addObject (obj:Object3D)
	:void
	{
		if (! obj.isContainer) {
			var geometry:GeometryBase = gc.checkOut (obj);
			for each (var surface:Surface in geometry.geometrySurfaces) {
				if (_programs[surface.programID] == null) {
					throw (new Error (geometry.geometryID + " has unknown Program '" +
						surface.programID + "'."));
				}
			}
			obj.geometry = geometry;
			obj.objectSurfaces = cloneSurfaces (geometry.geometrySurfaces);
		}
		if (! obj.isContained) _objects.push (obj);
	} // End of addObject().

	public function
	removeObject (obj:Object3D)
	:void
	{
		if (obj.isContainer) {
			for each (var child:Object3D in obj.children) {
				child.parent = null;
				remove (child);
			}
			obj.children.length = 0;
		} else {
			remove (obj);
		}
		return;

		function remove (obj:Object3D)
		:void
		{
			var idx:int = _objects.indexOf (obj);
			if (idx >= 0) {
				gc.checkIn (obj);
				_objects.splice (idx, 1);
			}
		} // End of remove().
	} // End of removeObject().

	public function
	getObject (id:String)
	:Object3D
	{
		var result:Object3D;
		for each (var obj:Object3D in _objects) {
			if (obj.id == id) {
				result = obj;
				break;
			}
		}
		return (result);
	} // End of getObject().

	public function
	get objectCount()
	:uint
	{
		return (_objects.length);
	} // End of objectCount getter.

	public function
	getObjectTab (id:String)
	:int
	{
		var tab:int = -1;
		var idx:uint = 0;
		for each (var obj:Object3D in _objects) {
			if (obj.id == id) {
				tab = idx;
				break;
			}
			++idx;
		}
		return (tab);
	} // End of getObjectTab().

	private function
	cloneSurfaces (incoming:Dictionary)
	:Dictionary
	{
		var outgoing:Dictionary = new Dictionary (false);
		for (var key:Object in incoming) {
			outgoing[key] = Surface (incoming[key]).clone();
		}
		return (outgoing);
	} // End of cloneSurfaces().

	private function
	keyDownHandler (event:KeyboardEvent)
	:void
	{
		switch (event.keyCode) {
			/* This logic is not as confounded as it appears.
			** First, it has the added complexity of allowing both forward and backward navigateion.
			** Second, it uses a virtual object at position -1 to allow a clearing of the screen
			** of all object highlighting.
			** Third, it seemlessly handles forward and backward tabbing of objects in containter.
			*/
			case (Keyboard.TAB):
				tabLabelTimer.stop();
				var fwd:Boolean = (! event.shiftKey);
				if (fwd) {
					if (++_tab >= _objects.length) _tab = -1;
				} else {
					if (--_tab <= -1) _tab = (_objects.length - 1);
				}
				if (_tab < 0) break;
				var tabObject:Object3D = _objects[_tab];
				if (tabObject.isContainer) {
					tabObject = tabObject.getTabbedChild (fwd);
					if (tabObject) {
						showSelected (tabObject);
						break;
					} else {
						if (fwd) {
							if (--_tab <= -1) _tab = (_objects.length - 1);
						} else {
							if (++_tab >= _objects.length) _tab = -1;
						}
					}
				}
				if (_tab >= 0) {
					tabObject = _objects[_tab];
					showSelected (tabObject);
				}
				break;
		} // End of Switch on KeyCode.
	} // End of keyDownHandler().

	private function
	mouseClickHandler (event:MouseEvent)
	:void
	{
		switch (event.type) {
			case (MouseEvent.CLICK): // Pick.
				var picked:Object3D = pick (event.stageX, event.stageY);
				if (picked) {
					trace ("Picked", picked.id);
					_tab = getObjectTab (picked.id);
					if (event.ctrlKey) {
						var surface:Surface = picked.geometry.getSurfacePicked (
							picked, event.stageX, event.stageY, stage3D);
						trace ("Surface Picked", picked.id, ((surface) ? surface.id : "None"));
						showSelected (picked, ((surface) ? surface.id : "None"));
					} else {
						showSelected (picked);
					}
				}
				break;
			case (MouseEvent.MIDDLE_CLICK): // Move Light.
				var z:Number = ((event.shiftKey) ? 1000.0 : -1000.0);
				if (event.stageX < (stage.stageWidth / 2.0)) {
					if (event.stageY < (stage.stageHeight / 2.0)) {
						lightPos = Vector.<Number>([-250.0, 250.0, z, 0.0]);
					} else {
						lightPos = Vector.<Number>([-250.0, -250.0, z, 0.0]);
					}
				} else {
					if (event.stageY < (stage.stageHeight / 2.0)) {
						lightPos = Vector.<Number>([250.0, 250.0, z, 0.0]);
					} else {
						lightPos = Vector.<Number>([250.0, -250.0, z, 0.0]);
					}
				}
				break;
			case (MouseEvent.RIGHT_CLICK): // Toggle Pause.
				_paused = ((_paused) ? false : true);;
				break;
		} // End of Switch on Event Type.
	} // End of mouseClickHandler().

	private function
	pick (x:Number, y:Number)
	:Object3D
	{
		var sx:Number = (((x * 2.0) / stage3D.sceneWidth) - 1.0);
		var sy:Number = (((y * 2.0) / stage3D.sceneHeight) - 1.0);
		var lensInverse:Matrix3D = stage3D.projection.clone();
		lensInverse.invert();
		var temp:Vector3D = lensInverse.transformVector (new Vector3D (0.0, 0.0, 0.0, 1.0));
		temp.z = 0.0;
		var rayPos:Vector3D = stage3D.camera.transform.transformVector (temp);
		// trace ("Ray Pos", rayPos);
		temp = lensInverse.transformVector (new Vector3D (sx, -sy, 1.0, 1.0));
		temp.z = 1.0;
		var rayDir:Vector3D = stage3D.camera.transform.transformVector (temp);
		rayDir = rayDir.subtract (rayPos);
		// trace ("Ray Dir", rayDir);

		var hits:Array = [];
		var intersectedDistance:Number;
		for each (var obj:Object3D in _objects) {
			if (obj.isContainer) {
				for each (var child:Object3D in obj.children) {
					if (! child.pickable) continue;
					var crayPos:Vector3D = obj.inverseTransform.transformVector (rayPos);
					var crayDir:Vector3D = obj.inverseTransform.deltaTransformVector (rayDir);
					intersectedDistance = child.getIntersectedDistance (crayPos, crayDir);
					// trace ("Contained", child.id, crayPos, crayDir, intersectedDistance);
					if (intersectedDistance >= 0) {
						trace ("Intersected", child.id, intersectedDistance);
						hits.push ({ object : child, distance : intersectedDistance });
					}
				}
			} else {
				if (! obj.pickable) continue;
				intersectedDistance = obj.getIntersectedDistance (rayPos, rayDir);
				// trace (obj.id, rayPos, rayDir, intersectedDistance);
				if (intersectedDistance >= 0) {
					trace ("Intersected", obj.id, intersectedDistance);
					hits.push ({ object : obj, distance : intersectedDistance });
				}
			}
		}
		if (hits.length < 1) {
			return (null);
		} else if (hits.length > 1) {
			trace ("");
			for each (var hit:Object in hits) {
				trace (hit["object"].id, hit["distance"]);
			}
			trace ("");
			hits.sortOn ("distance", Array.NUMERIC);
		}
		return (hits[0].object);
	} // End of pick();

	private function
	showSelected (obj:Object3D, surfaceID:String = null)
	:void
	{
		var cameraInverse:Matrix3D = stage3D.camera.transform.clone();
		cameraInverse.invert();
		var screenPos:Vector3D = stage3D.projection.transformVector (
			cameraInverse.transformVector (obj.transform.position));
		screenPos.x /= screenPos.w;
		screenPos.y /= -screenPos.w; // Note inverted Y Axis.
		screenPos.z = obj.transform.position.z;
		screenPos.x = ((screenPos.x + 1.0) * stage3D.sceneWidth / 2.0);
		screenPos.y = ((screenPos.y + 1.0) * stage3D.sceneHeight / 2.0);
		// trace (obj.id, "Centered At", screenPos);
		tabLabel.x = screenPos.x;
		tabLabel.y = screenPos.y;
		tabLabel.text = obj.id;
		if (surfaceID) tabLabel.text += (":" + surfaceID);
		tabLabel.visible = true;
		tabLabelTimer.start();

		graphics.clear();
		graphics.lineStyle ( 1, 0x0000ff, 1);
		graphics.beginFill (0xff0000);
		graphics.drawCircle (screenPos.x, screenPos.y, 5);

		tabLabel.metaData = obj;
	} // End of showSelected().

} // End of Scene3D Class.

} // End of Package Declaration.