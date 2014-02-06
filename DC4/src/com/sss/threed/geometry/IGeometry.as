package com.sss.threed.geometry 
{
import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.geom.Matrix3D;
import flash.utils.Dictionary;

import com.sss.threed.Camera;
import com.sss.threed.Object3D;
import com.sss.threed.Stage3DBase;
import com.sss.threed.Surface;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-08
*/
public interface IGeometry
{
	function dispose():void;
	function get indexBuffer():IndexBuffer3D;
	function get geometrySurfaces():Dictionary;
	function get numVertices():uint;
	function addSurface (surface:Surface):void;
	function getSurfaceByID (id:String):Surface;
	function getSurfacePicked (obj:Object3D, x:Number, y:Number, stage3D:Stage3DBase):Surface;
	function activateVertexStreams (context3D:Context3D, programID:String):void;
	function findMinimaMaxima (transform:Matrix3D):Array;
	function get geometryID():String;
	function wire (context3D:Context3D):void;
	function toString():String;
} // End of IGeometry Interface.
	
}  // End of Package Declaration.