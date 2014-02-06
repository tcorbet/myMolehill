package com.sss.threed.geometry 
{
import flash.geom.Matrix3D;
import flash.geom.Vector3D;

import com.sss.threed.geometry.IBoundVolume;
import com.sss.threed.geometry.IGeometry;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-06
** Away3d tests for intersection in model space. A Microsoft DirectX article says that doing so is
** more efficient because it avoids having to transform the aabb volume in the manner that I am now
** doing it whenever the object's transformChanged setting is true.
*/
public class AABB
	implements IBoundVolume
{
	private var geometry:IGeometry;
	private var _min:Vector3D;
	private var _max:Vector3D;

	public function
	AABB (geometry:IGeometry) 
	{
		this.geometry = geometry;
		_min = new Vector3D();
		_max = new Vector3D();
	} // End of Constructor for AABB.

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
		return (
			(point.x >= _min.x) && (point.x <= _max.x) &&
			(point.y >= _min.y) && (point.y <= _max.y) &&
			(point.z >= _min.z) && (point.z <= _max.z));
	} // End of contains();

	// OBB in Away3d.
	public function
	intersects (org:Vector3D, ray:Vector3D)
	:Number
	{
		if (contains (org)) return (0);
		var centerX:Number = ((_max.x + _min.x) / 2.0);
		var centerY:Number = ((_max.y + _min.y) / 2.0);
		var centerZ:Number = ((_max.z + _min.z) / 2.0);
		// trace ("Centers", centerX, centerY, centerZ);
		var halfX:Number = ((_max.x - _min.x) / 2.0);
		var halfY:Number = ((_max.y - _min.y) / 2.0);
		var halfZ:Number = ((_max.z - _min.z) / 2.0);
		// trace ("Halves", halfX, halfY, halfZ);
		var px:Number = (org.x - centerX), py:Number = (org.y - centerY), pz:Number = (org.z - centerZ);
		// trace ("P", px, py, pz);
		var vx:Number = ray.x, vy:Number = ray.y, vz:Number = ray.z;
		// trace ("V", vx, vy, vz);
		var dx:Number, dy:Number, dz:Number;
		var hit:Boolean;
		var t:Number;

		if ((! hit) && (vz > 0)) {
			t = ((-halfZ - pz) / vz);
			if (t > 0) {
				dx = (px + (t * vx));
				if ((dx > -halfX) && (dx < halfX)) {
					dy = (py + (t * vy));
					if ((dy > -halfY) && (dy < halfY)) hit = true;
				}
			}
		}
		if ((! hit) && (vz < 0)) {
			t = ((halfZ - pz) / vz);
			if (t > 0) {
				dx = (px + (t * vx));
				if ((dx > -halfX) && (dx < halfX)) {
					dy = (py + (t * vy));
					if ((dy > -halfY) && (dy < halfY)) hit = true;
				}
			}
		}
		if ((! hit) && (vx > 0)) {
			t = ((-halfX - px) / vx);
			if (t > 0) {
				dy = (py + (t * vy));
				if ((dy > -halfY) && (dy < halfY)) {
					dz = (pz + (t * vz));
					if ((dz > -halfZ) && (dz < halfZ)) hit = true;
				}
			}
		}
		if ((! hit) && (vx < 0)) {
			t = ((halfX - px) / vx);
			if (t > 0) {
				dy = (py + (t * vy));
				if ((dy > -halfY) && (dy < halfY)) {
					dz = (pz + (t * vz));
					if ((dz > -halfZ) && (dz < halfZ)) hit = true;
				}
			}
		}
		if ((! hit) && (vy > 0)) {
			t = ((-halfY - py) / vy);
			if (t > 0) {
				dx = (px + (t * vx));
				if ((dx > -halfX) && (dx < halfX)) {
					dz = (pz + (t * vz));
					if ((dz > -halfZ) && (dz < halfZ)) hit = true;
				}
			}
		}
		if ((! hit) && (vy < 0)) {
			t = ((halfY - py) / vy);
			if (t > 0) {
				dx = (px + (t * vx));
				if ((dx > -halfX) && (dx < halfX)) {
					dz = (pz + (t * vz));
					if ((dz > -halfZ) && (dz < halfZ)) hit = true;
				}
			}
		}
		return ((hit) ? t : -1.0);
	} // End of intersects().
	/*
	// Woo in Dunn & Parberry.
	public function
	intersects (org:Vector3D, delta:Vector3D)
	:Number
	{
		if (contains (org)) return (0);
		var x:Number, y:Number, z:Number;
		var xt:Number, yt:Number, zt:Number;
		if (org.x < _min.x) {
			xt = (_min.x - org.x);
			if (xt > delta.x) return (-1);
			xt /= delta.x;
		} else if (org.x > _max.x) {
			xt = (_max.x - org.x);
			if (xt < delta.x) return (-1);
			xt /= delta.x;
		} else xt = -1;
		if (org.y < _min.y) {
			yt = (_min.y - org.y);
			if (yt > delta.y) return (-1);
			yt /= delta.y;
		} else if (org.y > _max.y) {
			yt = (_max.y - org.y);
			if (yt < delta.y) return (-1);
			yt /= delta.y;
		} else yt = -1;
		if (org.z < _min.z) {
			zt = (_min.z - org.z);
			if (zt > delta.z) return (-1);
			zt /= delta.z;
		} else if (org.z > _max.z) {
			zt = (_max.z - org.z);
			if (zt < delta.z) return (-1);
			zt /= delta.z;
		} else zt = -1;

		var t:Number = xt;
		if (yt > t) {
			t = yt;
			x = (org.x + (delta.x * t));
			if ((x < _min.x) || (x > _max.x)) return (-1);
			z = (org.z + (delta.z * t));
			if ((z < _min.z) || (z > _max.z)) return (-1);
		} else if (zt > t) {
			t = zt;
			x = (org.x + (delta.x * t));
			if ((x < _min.x) || (x > _max.x)) return (-1);
			y = (org.y + (delta.y * t));
			if ((y < _min.y) || (y > _max.y)) return (-1);
		} else {
			y = (org.y + (delta.y * t));
			if ((y < _min.y) || (y > _max.y)) return (-1);
			z = (org.z + (delta.z * t));
			if ((z < _min.z) || (z > _max.z)) return (-1);
		}
		return (t);
	} // End of intersects().
	*/
	public function
	toString()
	:String
	{
		return (geometry.geometryID + "\n  Min: " + _min + "\n  Max: " + _max);
	} // End of toString().

} // End of AABB Class.

} // Ende of Package Declaration.