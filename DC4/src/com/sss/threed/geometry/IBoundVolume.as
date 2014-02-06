package com.sss.threed.geometry 
{
import flash.geom.Matrix3D;
import flash.geom.Vector3D;

import com.sss.threed.Camera;
import com.sss.threed.Surface;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-06
*/
public interface IBoundVolume
{
	function contains (point:Vector3D):Boolean;
	function intersects (org:Vector3D, ray:Vector3D):Number;
	function updateMinimaMaxima (transform:Matrix3D):void;
	function toString():String;
} // End of IBoundVolume Interface.
	
}  // End of Package Declaration.