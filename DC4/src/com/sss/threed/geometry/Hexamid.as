package com.sss.threed.geometry 
{
import flash.utils.getQualifiedClassName;

import com.sss.threed.Surface;
import com.sss.threed.geometry.GeometryBase;
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2013-14-01-11
*/
public final class Hexamid extends GeometryBase
{
	private const HB:Number = 0.2;
	private const A:Number = (Math.sqrt (3.0) * HB);
	private const H:Number = 1.0;

	public function
	Hexamid (params:Array)
	{
		super (6);
		constructSurfaces();
	} // End of Constructor for Hexamid.

	// CW winding.
	private function
	constructSurfaces()
	:void
	{
		startSurface ("1", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.9, 0.0, 0.0, 1.0]));
		pVx (-H, 0.0, 0.0); pVx (0.0, A, HB); pVx (0.0, A, -HB);
		pVx (H, 0.0, 0.0); pVx (0.0, A, -HB); pVx (0.0, A, HB);

		startSurface ("2", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.9, 0.9, 0.0, 1.0]));
		pVx (-H, 0.0, 0.0); pVx (0.0, A, -HB); pVx (0.0, 0.0, -(HB * 2.0));
		pVx (H, 0.0, 0.0); pVx (0.0, 0.0, -(HB * 2.0)); pVx (0.0, A, -HB);

		startSurface ("3", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.0, 0.9, 0.0, 1.0]));
		pVx (-H, 0.0, 0.0); pVx (0.0, 0.0, -(HB * 2.0)); pVx (0.0, -A, -HB);
		pVx (H, 0.0, 0.0); pVx (0.0, -A, -HB); pVx (0.0, 0.0, -(HB * 2.0));

		startSurface ("4", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.0, 0.9, 0.9, 1.0]));
		pVx (-H, 0.0, 0.0); pVx (0.0, -A, -HB); pVx (0.0, -A, HB);
		pVx (H, 0.0, 0.0); pVx (0.0, -A, HB); pVx (0.0, -A, -HB);

		startSurface ("5", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.0, 0.0, 0.9, 1.0]));
		pVx (-H, 0.0, 0.0); pVx (0.0, -A, HB); pVx (0.0, 0.0, (HB * 2.0));
		pVx (H, 0.0, 0.0); pVx (0.0, 0.0, (HB * 2.0)); pVx (0.0, -A, HB);

		startSurface ("6", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.9, 0.0, 0.9, 1.0]));
		pVx (-H, 0.0, 0.0); pVx (0.0, 0.0, (HB * 2.0)); pVx (0.0, A, HB);
		pVx (H, 0.0, 0.0); pVx (0.0, A, HB); pVx (0.0, 0.0, (HB * 2.0));

		mergeNormals (3);
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

} // End of Hexamid Class.

} // End of Package Declaration.