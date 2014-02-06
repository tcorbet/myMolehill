package com.sss.threed.geometry 
{
import flash.utils.getQualifiedClassName;

import com.sss.threed.Surface;
import com.sss.threed.geometry.GeometryBase;
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-11
*/
public final class Pointer extends GeometryBase
{
	private const HB:Number = 0.01;
	private const H:Number = 1.0;

	public function
	Pointer (params:Array)
	{
		super (3);
		constructSurfaces();
	} // End of Constructor for Pointer.

	// CW winding.
	private function
	constructSurfaces()
	:void
	{
		startSurface ("all", 0, ProgramBase.COLOR_01,
			Vector.<Number> ([0.0, 0.0, 0.0, 1.0]));
		pVx (0.0, H, 0.0); pVx (-HB, 0.0, HB); pVx (HB, 0.0, HB);
		pVx (0.0, H, 0.0); pVx (HB, 0.0, HB); pVx (HB, 0.0, -HB);
		pVx (0.0, H, 0.0); pVx (HB, 0.0, -HB); pVx (-HB, 0.0, -HB);
		pVx (0.0, H, 0.0); pVx (-HB, 0.0, -HB); pVx (-HB, 0.0, HB);
		pVx (-HB, 0.0, HB); pVx (-HB, 0.0, -HB); pVx (HB, 0.0, -HB);
		pVx (HB, 0.0, -HB); pVx (HB, 0.0, HB); pVx (-HB, 0.0, HB);
	} // End of constructSurfaces().

	private function
	startSurface (id:String, offset:uint, programID:String, material:*)
	:void
	{
		currentSurface = new Surface (id, offset, programID, material);
		geometrySurfaces[id] = currentSurface;
	} // End of startSurface().

	private function
	pVx (x:Number, y:Number, z:Number)
	:void
	{
		vertices.push (x); vertices.push (y); vertices.push (z);
		indices.push (vdx++);
		++currentSurface.idx;
	} // End of pVx().

} // End of Pointer Class.

} // End of Package Declaration.