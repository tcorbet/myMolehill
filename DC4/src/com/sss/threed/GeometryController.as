package com.sss.threed 
{
import flash.utils.Dictionary;

import com.sss.threed.Object3D;
import com.sss.threed.geometry.Axes;
import com.sss.threed.geometry.Ball;
import com.sss.threed.geometry.BallTex;
import com.sss.threed.geometry.BillBoard;
import com.sss.threed.geometry.Cube;
import com.sss.threed.geometry.CubeTex;
import com.sss.threed.geometry.GeometryBase;
import com.sss.threed.geometry.GridPlane;
import com.sss.threed.geometry.Hexamid;
import com.sss.threed.geometry.Pointer;
import com.sss.threed.geometry.RCube;
import com.sss.threed.geometry.Torus;
import com.sss.threed.geometry.TriTester;
import com.sss.threed.geometry.WireCube;
/**
** @author J. Terry Corbet
** @version 1.0 2014-03-05
*/
public class GeometryController
{
	public static const AXES:String = "AxesGeom";
	public static const BALL:String = "BallGeom";
	public static const BALLTEX:String = "BallTexGeom";
	public static const BBOARD:String = "BBoardGeom";
	public static const CUBE:String = "CubeGeom";
	public static const CUBETEX:String = "CubeTexGeom";
	public static const GRID:String = "GridGeom";
	public static const HEXAMID:String = "HexamidGeom";
	public static const POINTER:String = "PointerGeom";
	public static const RCUBE:String = "RCubeGeom";
	public static const TORUS:String = "TorusGeom";
	public static const TRITESTER:String = "TTGeom";
	public static const WIRECUBE:String = "WireCubeGeom";

	private static var _instance:GeometryController;
	private static var geometryUses:Dictionary; new Dictionary (false);

	public function
	GeometryController (singleton:Singleton = null)
	{
		if (singleton != null) {
			geometryUses = new Dictionary (false);
		} else {
			throw (new Error ("GeometryController is a singleton Class."));
		}	
	} // End of Constructor for GeometryController.

	public static function
	get instance()
	:GeometryController
	{
		return ((_instance != null) ?
			_instance :
			(_instance = new GeometryController (new Singleton()))
			);
	} // End of instance getter.

	public function
	checkOut (obj:Object3D)
	:GeometryBase
	{
		var geometry:GeometryBase;
		var id:String = formTrackingID (obj);
		var user:UseCounter = geometryUses[id];
		if (user) {
			++user.count;
			geometry = user.geometry;
		} else {
			var gid:String = obj.geometryID;
			if (gid == AXES) {
				geometry = new Axes (obj.params);
			} else if (gid == BALL) {
				geometry = new Ball (obj.params);
			} else if (gid == BALLTEX) {
				geometry = new BallTex (obj.params);
			} else if (gid == BBOARD) {
				geometry = new BillBoard (obj.params);
			} else if (gid == CUBE) {
				geometry = new Cube (obj.params);
			} else if (gid == CUBETEX) {
				geometry = new CubeTex (obj.params);
			} else if (gid == GRID) {
				geometry = new GridPlane (obj.params);
			} else if (gid == HEXAMID) {
				geometry = new Hexamid (obj.params);
			} else if (gid == POINTER) {
				geometry = new Pointer (obj.params);
			} else if (gid == RCUBE) {
				geometry = new RCube (obj.params);
			} else if (gid == TORUS) {
				geometry = new Torus (obj.params);
			} else if (gid == TRITESTER) {
				geometry = new TriTester (obj.params);
			} else if (gid == WIRECUBE) {
				geometry = new WireCube (obj.params);
			}
			user = new UseCounter (geometry);
			geometryUses[id] = user;
		}
		return (geometry);
	} // End of checkOut().

	public function
	checkIn (obj:Object3D)
	:void
	{
		var id:String = formTrackingID (obj);
		var user:UseCounter = geometryUses[id];
		if (--user.count == 0) {
			user.geometry.dispose();
			user.geometry = null;
			delete geometryUses[id];
		}
	} // End of checkIn().

	private function
	formTrackingID (obj:Object3D)
	:String
	{
		var id:String = obj.geometryID;
		for each (var param:* in obj.params) id += ("-" + param.toString());
		return (id);
	} // End of formTrackingID().

} // End of GeometryController Class.

} // End of Package Declaration.

internal final class Singleton { }

import com.sss.threed.geometry.GeometryBase;

internal final class UseCounter
{
	public var geometry:GeometryBase;
	public var count:uint;

	public function
	UseCounter (geometry:GeometryBase)
	{
		this.geometry = geometry;
		count = 1;
	} // End of Constructor for UseCounter.

} // End of Internal UseCounter Class.