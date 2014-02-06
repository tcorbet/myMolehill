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
public final class Axes extends GeometryBase
{
	private const HB:Number = 0.01;
	private const H:Number = 1.0;
	private const A23:Number = (Math.sqrt (3.0) * HB * 2.0 / 3.0);
	private const A13:Number = (A23 / 2.0);

	public function
	Axes (params:Array)
	{
		super (3);
		constructSurfaces (params);
	} // End of Constructor for Axes.

	// CW winding.
	private function
	constructSurfaces (params:Array)
	:void
	{
		startSurface ("XAxis", indices.length, ProgramBase.COLOR_01,
			Vector.<Number> ([0.7, 0.0, 0.0, 1.0])); // X - Red.
		pVx (0.0, 0.0, 0.0); pVx (H, HB, -A13); pVx (H, -HB, -A13);
		pVx (0.0, 0.0, 0.0); pVx (H, -HB, -A13); pVx (H, 0.0, A23);
		pVx (0.0, 0.0, 0.0); pVx (H, 0.0, A23); pVx (H, HB, -A13);
		pVx (H, HB, -A13); pVx (H, 0.0, A23); pVx (H, -HB, -A13); // E-Cap.
		if (params[0] == 2) {
			pVx (0.0, 0.0, 0.0); pVx (-H, -HB, -A13); pVx (-H, HB, -A13);
			pVx (0.0, 0.0, 0.0); pVx (-H, HB, -A13); pVx (-H, 0.0, A23);
			pVx (0.0, 0.0, 0.0); pVx (-H, 0.0, A23); pVx (-H, -HB, -A13);
			pVx (-H, -HB, -A13); pVx (-H, 0.0, A23); pVx (-H, HB, -A13); // W-Cap.
		}

		startSurface ("YAxis", indices.length, ProgramBase.COLOR_01,
			Vector.<Number> ([0.0, 0.7, 0.0, 1.0])); // Y - Green.
		pVx (0.0, 0.0, 0.0); pVx (-HB, H, -A13); pVx (HB, H, -A13);
		pVx (0.0, 0.0, 0.0); pVx (HB, H, -A13); pVx (0.0, H, A23);
		pVx (0.0, 0.0, 0.0); pVx (0.0, H, A23); pVx (-HB, H, -A13);
		pVx (-HB, H, -A13); pVx (0.0, H, A23); pVx (HB, H, -A13); // N-Cap.
		if (params[0] == 2) {
			pVx (0.0, 0.0, 0.0); pVx (HB, -H, -A13); pVx (-HB, -H, -A13);
			pVx (0.0, 0.0, 0.0); pVx (-HB, -H, -A13); pVx (0.0, -H, A23);
			pVx (0.0, 0.0, 0.0); pVx (0.0, -H, A23); pVx (HB, -H, -A13);
			pVx (HB, -H, -A13); pVx (0.0, -H, A23); pVx (-HB, -H, -A13); // S-Cap.
		}

		startSurface ("ZAxis", indices.length, ProgramBase.COLOR_01,
			Vector.<Number> ([0.0, 0.0, 0.7, 1.0])); // Z - Blue.
		pVx (0.0, 0.0, 0.0); pVx (-HB, A13, H); pVx (HB, A13, H);
		pVx (0.0, 0.0, 0.0); pVx (HB, A13, H); pVx (0.0, -A23, H);
		pVx (0.0, 0.0, 0.0); pVx (0.0, -A23, H); pVx (-HB, A13, H);
		pVx ( -HB, A13, H); pVx (0.0, -A23, H); pVx (HB, A13, H); // R-Cap.
		if (params[0] == 2) {
			pVx (0.0, 0.0, 0.0); pVx (HB, A13, -H); pVx (-HB, A13, -H);
			pVx (0.0, 0.0, 0.0); pVx (-HB, A13, -H); pVx (0.0, -A23, -H);
			pVx (0.0, 0.0, 0.0); pVx (0.0, -A23, -H); pVx (HB, A13, -H);
			pVx (HB, A13, -H); pVx (0.0, -A23, -H); pVx (-HB, A13, -H); // F-Cap.
		}
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

} // End of Axes Class.

} // End of Package Declaration.