package com.sss.threed.geometry 
{
import flash.geom.Matrix3D;
import flash.geom.Vector3D;

import com.sss.threed.geometry.IBoundVolume;
import com.sss.threed.geometry.IGeometry;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-06
*/
public class SPHBB
	implements IBoundVolume
{
	private var geometry:IGeometry;
	private var _min:Vector3D;
	private var _max:Vector3D;

	public function
	SPHBB (geometry:IGeometry) 
	{
		this.geometry = geometry;
		_min = new Vector3D();
		_max = new Vector3D();
	} // End of Constructor for SPHBB.

	public function
	updateMinimaMaxima (transform:Matrix3D)
	:void
	{
		var minMax:Array = geometry.findMinimaMaxima (transform);
		_min = (minMax[0] as Vector3D);
		_max = (minMax[1] as Vector3D);
	} // End of updateMinimaMaxima().

	public function
	contains (point:Vector3D)
	:Boolean
	{
		var t:Number = ((point.x * point.x) + (point.y * point.y) + (point.z * point.z));
		return (Math.sqrt (t) <= 1);
	} // End of contains();

	// Dunn & Parberry.
	public function
	intersects (org:Vector3D, ray:Vector3D)
	:Number
	{
		if (contains (org)) return (0);
		var r:Number = 0.5;
		var e:Vector3D = new Vector3D (-org.x, -org.y, -org.z);
		ray.normalize();
		var a:Number = e.dotProduct (ray);
		var t:Number = ((r * r) - e.dotProduct (e) + (a * a));
		return ((t < 0) ? -1 : (a - Math.sqrt (t)));
	} // End of intersects().

	public function
	toString()
	:String
	{
		return (geometry.geometryID + "\n  Min: " + _min + "\n  Max: " + _max);
	} // End of toString().

} // End of SPHBB Class.

} // Ende of Package Declaration.