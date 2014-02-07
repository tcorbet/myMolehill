package com.sss.threed
{
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.ui.Keyboard;

import com.sss.math.M;
/**
** @author J. Terry Corbet
** @version 1.0 2014-02-07
*/
public final class Camera
{
	private const PLANAR:uint = 1;
	private const PIVOTAL:uint = 2;
	private const ORBITAL:uint = 3;
	private const DAMPING:Number = 1.15;
	private const NORTH_POLE:Number = (Math.PI - .000001);
	private const SOUTH_POLE:Number = .000001;
	private const RAW:Vector.<Number> = new Vector.<Number> (16, true);
	private const PIx2:Number = (Math.PI * 2.0);
	private const TO_RAD:Number = (Math.PI / 180.0);
	private const TO_DEG:Number = (180/0 / Math.PI);

	private var _transform:Matrix3D;
	private var _cameraView:Matrix3D;
	private var _initialPosition:Vector3D;
	private var _initialPOI:Vector3D;
	private var _poi:Vector3D;
	private var _position4GPU:Vector.<Number>;

	private var touched:Boolean;
	private var zoomAcceleration:Number;
	private var zoomVelocity:Number;
	private var horizontalAcceleration:Number;
	private var horizontalVelocity:Number;
	private var verticalAcceleration:Number;
	private var verticalVelocity:Number;
	private var pitchAcceleration:Number;
	private var pitchVelocity:Number;
	private var yawAcceleration:Number;
	private var yawVelocity:Number;

	private var mode:uint;
	private var _easing:Boolean;
	private var linearAcceleration:Number;
	private var maxLinearVelosity:Number;
	private var rotationalAcceleration:Number;
	private var maxRotationalVelosity:Number;
	private var epsilon:Number;

	public function
	Camera (position:Vector3D, poi:Vector3D, stage:Stage)
	{
		trace ("Camera Constructor", "Entered");
		_initialPosition = position;
		_initialPOI = poi;
		_easing = true;

		zoomAcceleration = horizontalAcceleration = verticalAcceleration = 0.0;
		yawAcceleration = pitchAcceleration = 0.0;
		zoomVelocity = horizontalVelocity = verticalVelocity = 0.0;
		yawVelocity = pitchVelocity = 0.0;
		linearAcceleration = 0.1;
		maxLinearVelosity = (linearAcceleration * 3.0);
		epsilon = (linearAcceleration * 0.01);
		rotationalAcceleration = 0.05;
		maxRotationalVelosity = (rotationalAcceleration * 3.0);

		stage.addEventListener (KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener (KeyboardEvent.KEY_UP, keyUpHandler);

		reset();
	} // End of Constructor for Camera.

	public function
	reset()
	:void
	{
		if (_transform) {
			_transform.identity();
		} else {
			_transform = new Matrix3D();
		}
		_transform.appendTranslation (_initialPosition.x, _initialPosition.y, _initialPosition.z);
		_poi = _initialPOI;
		lookAt (_poi);
		mode = PLANAR;
	} // End of reset().

	/* This method must be invoked at the start of every render cycle to get the camera repositioned
	^^ and reoriented taking into account any navigation commands that have taken place.
	** In the original Dunstan implementation, it was also a convenient place to incrementally move
	** the directional light for the scene. That code has no place in the present implemenation.
	*/
	public function
	updatePosition()
	:void
	{
		horizontalVelocity = calculateUpdatedVelocity (horizontalVelocity, horizontalAcceleration, maxLinearVelosity);
		if (horizontalVelocity != 0.0) doPlanar (horizontalVelocity, Vector3D.X_AXIS);

		verticalVelocity = calculateUpdatedVelocity (verticalVelocity, verticalAcceleration, maxLinearVelosity);
		if (verticalVelocity != 0.0) doPlanar (verticalVelocity, Vector3D.Y_AXIS);

		zoomVelocity = calculateUpdatedVelocity (zoomVelocity, zoomAcceleration, maxLinearVelosity);
		if (zoomVelocity != 0.0) doPlanar (zoomVelocity, Vector3D.Z_AXIS);
		
		yawVelocity = calculateUpdatedVelocity (yawVelocity, yawAcceleration, maxRotationalVelosity);
		if (yawVelocity != 0.0) doPivotal (yawVelocity, Vector3D.Y_AXIS);

		pitchVelocity = calculateUpdatedVelocity (pitchVelocity, pitchAcceleration, maxRotationalVelosity);
		if (pitchVelocity != 0.0) doPivotal (pitchVelocity, Vector3D.X_AXIS);
	} // End of updatePosition().

	private function
	calculateUpdatedVelocity (velocity:Number, acceleration:Number, maxVelocity:Number)
	:Number
	{
		// trace ("DD.calcVel", "In", velocity, acceleration);
		var newVelocity:Number;
		if (acceleration != 0.0) {
			newVelocity = (velocity + acceleration);
			if (newVelocity > maxVelocity) {
				newVelocity = maxVelocity;
			} else if (newVelocity < -maxVelocity) {
				newVelocity = -maxVelocity;
			}
		} else {
			if (_easing) {
				newVelocity = (velocity / DAMPING);
				if (Math.abs (newVelocity) < epsilon) newVelocity = 0.0;
			} else {
				newVelocity = 0.0;
			}
		}
		// trace ("DD.calcVel", "Out", velocity, newVelocity);
		return (newVelocity);
	} // End of calculateUpdatedVelocity().

	private function
	doPlanar (units:Number, axis:Vector3D)
	:void
	{
		// trace ("Camera.moveAlongAxis", units, axis);
		// M.decomposeEuler ("Before Move", _transform);
		var delta:Vector3D = axis.clone();
		delta.scaleBy (units);
		var comps:Vector.<Vector3D> = _transform.decompose();
		comps[0] = position.add (delta);
		_transform.recompose (comps);
		_poi = _poi.add (delta);
		lookAt (_poi);
	} // End of doPlanar().

	private function
	doPivotal (angle:Number, axis:Vector3D)
	:void
	{
		if (isNaN (angle)) return;
		var position:Vector3D = _transform.position;
		_transform.position = new Vector3D (0.0, 0.0, 0.0);
		_transform.appendRotation (angle, axis);
		_transform.position = position;
		touched = true;
	} // End of doPivotal().

	private function
	doOrbital (altitudeDelta:Number, azimuthDelta:Number, zenithDelta:Number)
	:void
	{
		var position:Vector3D = _transform.position;
		var target:Vector3D = _poi;

		position.x -= target.x;
		position.y -= target.y;
		position.z -= target.z;

		var altitude:Number = Math.sqrt (
			(position.x * position.x) +
			(position.y * position.y) +
			(position.z * position.z));
		// trace ("Position In", position, altitude);
		var theta:Number = Math.atan2 (position.z, position.x);
		var phi:Number = Math.acos (position.y / altitude);

		altitude += (altitude * altitudeDelta);

		theta += azimuthDelta;
		if (theta < -Math.PI) {
			theta += PIx2;
		} else if (theta > Math.PI) {
			theta -= PIx2;
		}

		phi += zenithDelta;
		if (phi > NORTH_POLE) {
			phi = NORTH_POLE;
		} else if (phi < SOUTH_POLE) {
			phi = SOUTH_POLE;
		}

		var sinPhi:Number = Math.sin (phi);
		position.x = (altitude * Math.cos (theta) * sinPhi);
		position.y = (altitude * Math.cos (phi));
		position.z = (altitude * Math.sin (theta) * sinPhi);

		position.x += target.x;
		position.y += target.y;
		position.z += target.z;
		// trace ("Position Out", position, altitude);
		_transform.position = position;
		lookAt (target);
	} // End of doOrbital().

	private function
	keyDownHandler (event:KeyboardEvent)
	:void
	{
		// trace ("CameraDown", "Code", event.keyCode);
		switch (event.keyCode) {
			case (Keyboard.SHIFT):
			case (Keyboard.CONTROL):
				break;
			case (Keyboard.UP):
				if (event.shiftKey) {
					pitchAcceleration = -rotationalAcceleration;
					// trace ("PUP");
					mode = PIVOTAL;
				} else if (event.ctrlKey) {
					doOrbital (0, 0, -.05);
					// trace ("OUP");
					mode = ORBITAL;
				} else {
					verticalAcceleration = linearAcceleration;
					// trace ("UP");
					mode = PLANAR;
				}
				break;
			case (Keyboard.DOWN):
				if (event.shiftKey) {
					pitchAcceleration = rotationalAcceleration;
					// trace ("PDN");
					mode = PIVOTAL;
				} else if (event.ctrlKey) {
					doOrbital (0, 0, .05);
					// trace ("ODN");
					mode = ORBITAL;
				} else {
					verticalAcceleration = -linearAcceleration;
					// trace ("DN");
					mode = PLANAR;
				}
				break;
			case (Keyboard.LEFT):
				if (event.shiftKey) {
					yawAcceleration = -rotationalAcceleration;
					// trace ("HLT");
					mode = PIVOTAL;
				} else if (event.ctrlKey) {
					doOrbital (0, -.1, 0);
					// trace ("OLT");
					mode = ORBITAL;
				} else {
					horizontalAcceleration = -linearAcceleration;
					// trace ("LT");
					mode = PLANAR;
				}
				break;
			case (Keyboard.RIGHT):
				if (event.shiftKey) {
					yawAcceleration = rotationalAcceleration;
					// trace ("HRT");
					mode = PIVOTAL;
				} else if (event.ctrlKey) {
					doOrbital (0, .1, 0);
					// trace ("ORT");
					mode = ORBITAL;
				} else {
					horizontalAcceleration = linearAcceleration;
					// trace ("RT");
					mode = PLANAR;
				}
				break;
			case (Keyboard.HOME):
				zoomAcceleration = linearAcceleration;
				// trace ("IN");
				break;
			case (Keyboard.END):
				zoomAcceleration = -linearAcceleration;
				// trace ("OUT");
				break;
			case (Keyboard.NUMPAD_ADD):
				if ((! event.shiftKey) && (! event.ctrlKey)) _easing = true;
				break;
			case (Keyboard.NUMPAD_SUBTRACT):
				if ((! event.shiftKey) && (! event.ctrlKey)) _easing = false;
				break;
			case (Keyboard.ESCAPE):
				reset();
				break;
			default:
				// trace ("Unexpected Key Code", event.keyCode);
				return;
		} // End of Switch on KeyCode.
	} // End of keyDownHandler().

	private function
	keyUpHandler (event:KeyboardEvent)
	:void
	{
		// trace ("CameraUp", "Code", event.keyCode);
		switch (event.keyCode) {
			case (Keyboard.SHIFT):
			case (Keyboard.CONTROL):
				break;
			case (Keyboard.UP):
			case (Keyboard.DOWN):
				verticalAcceleration = 0.0;
				pitchAcceleration = 0.0;
				break;
			case (Keyboard.LEFT):
			case (Keyboard.RIGHT):
				horizontalAcceleration = 0.0;
				yawAcceleration = 0.0;
				break;
			case (Keyboard.HOME):
			case (Keyboard.END):
				zoomAcceleration = 0.0;
				break;
		} // End of Switch on KeyCode.
	} // End of keyUpHandler().

	// Adapted from Away3d.
	public function
	lookAt (target:Vector3D)
	:void
	{
		var xAxis:Vector3D, yAxis:Vector3D, zAxis:Vector3D;
		var rawData:Vector.<Number>;
		
		zAxis = target.subtract (position);
		zAxis.normalize();
		xAxis = Vector3D.Y_AXIS.crossProduct (zAxis);
		xAxis.normalize();
		yAxis = zAxis.crossProduct (xAxis);
	
		RAW[0] = xAxis.x;
		RAW[1] = xAxis.y;
		RAW[2] = xAxis.z;
		RAW[3] = 0.0;
		
		RAW[4] = yAxis.x;
		RAW[5] = yAxis.y;
		RAW[6] = yAxis.z;
		RAW[7] = 0.0;
		
		RAW[8] = zAxis.x;
		RAW[9] = zAxis.y;
		RAW[10] = zAxis.z;
		RAW[11] = 0.0;
		
		RAW[12] = position.x;
		RAW[13] = position.y;
		RAW[14] = position.z;
		RAW[15] = 1.0;
		
		_transform.copyRawDataFrom (RAW);
		touched = true;
	} // End of lookAt().

	[Inline] public final function get transform():Matrix3D { return (_transform); };
	[Inline] public final function get position():Vector3D { return (_transform.position); };
	[Inline] public final function get position4GPU():Vector.<Number> { return (_position4GPU); };
	[Inline] public final function get poi():Vector3D { return (_poi); };
	[Inline] public final function get easing():Boolean { return (_easing); };
	[Inline] public final function set easing (value:Boolean):void { _easing = value; };

	public final function
	set poi (value:Vector3D)
	:void
	{
		if (mode == PLANAR) {
			var delta:Vector3D = value.subtract (_poi);
			_transform.position = _transform.position.add (delta);
		}
		_poi = value;
		lookAt (_poi);
	} // End of poi setter.

	/* 2013-12-03
	** This implementation logic is supposed to follow the guideline that says the transform matrix
	** here should be the inverse of the transpose of the camera's transform. But, if I perform the
	** transpose, it breaks. I suspect that the reason has something to do with row-major versus
	** column-major content being in my transform matrix, coming out of lookAt(), which is called
	** by reset(). I set the RawData row-major, whereas all the texts on this topic are assuming
	** column-major. Ergo a transpose is not required because my matirx is already configured the way
	** a column-major matrix would be after a transpose.
	** 
	*/
	public function
	get cameraView()
	:Matrix3D
	{
		if (touched) {
			touched = false;
			_cameraView = _transform.clone();
			// See comments above. _cameraView.transpose();
			// M.prettyRaw ("CV", _cameraView);

			var wasInverted:Boolean = _cameraView.invert();
			if (! wasInverted) trace ("Oops");
			// M.prettyRaw ("CVI", _cameraView);
			var pos:Vector3D = position;
			_position4GPU = Vector.<Number> ([pos.x, pos.y, pos.z, 1.0]);
		}
		return (_cameraView);
	} // End of cameraView getter.

} // End of Camera Class.

} // End of Package Declaration.