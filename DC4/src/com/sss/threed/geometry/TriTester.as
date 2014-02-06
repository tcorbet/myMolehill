package com.sss.threed.geometry 
{
import flash.utils.getQualifiedClassName;

import com.sss.threed.Surface;
import com.sss.threed.geometry.GeometryBase;
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-16
*/
public final class TriTester extends GeometryBase
{
	private const HB:Number = 0.25;
	private const H:Number = 0.5;

	public function
	TriTester (params:Array)
	{
		super (7);
		constructSurfaces();
	} // End of Constructor for TriTester.

	// CW winding.
	private function
	constructSurfaces()
	:void
	{
		startSurface ("top", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([8.0, 8.0, 1.0, 1.0]));
		pVx (0.0, H, 0.0); pVx (-HB, 0.0, HB); pVx (HB, 0.0, HB);
		pVx (0.0, H, 0.0); pVx (HB, 0.0, HB); pVx (HB, 0.0, -HB);
		pVx (0.0, H, 0.0); pVx (HB, 0.0, -HB); pVx (-HB, 0.0, -HB);
		pVx (0.0, H, 0.0); pVx (-HB, 0.0, -HB); pVx (-HB, 0.0, HB);

		startSurface ("bottom", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([7.0, 7.0, 2.0, 1.0]));
		pVx (0.0, -H, 0.0); pVx (HB, 0.0, HB); pVx (-HB, 0.0, HB);
		pVx (0.0, -H, 0.0); pVx (HB, 0.0, -HB); pVx (HB, 0.0, HB);
		pVx (0.0, -H, 0.0); pVx (-HB, 0.0, -HB); pVx (HB, 0.0, -HB);
		pVx (0.0, -H, 0.0); pVx (-HB, 0.0, HB); pVx (-HB, 0.0, -HB);

		mergeNormals (4, 4, false);
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
		vertices.push (0xbbccddee);
		indices.push (vdx++);
		++currentSurface.idx;
	} // End of pVx().

} // End of TriTester Class.

} // End of Package Declaration.