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
public final class Cube extends GeometryBase
{
	public function
	Cube (params:Array)
	{
		super (6);
		constructSurfaces();
	} // End of Constructor for Cube.

	// CW winding.
	private function
	constructSurfaces()
	:void
	{
		startSurface ("top", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.0, 0.8, 0.0, 1.0])); // Green.
		pVx (-0.5, 0.5, -0.5); pVx (-0.5, 0.5, 0.5); pVx (0.5, 0.5, 0.5);
		pVx (0.5, 0.5, -0.5, true);

		startSurface ("front", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.0, 0.0, 0.8, 1.0])); // Blue.
		pVx (-0.5, 0.5, -0.5); pVx (0.5, 0.5, -0.5); pVx (0.5, -0.5, -0.5);
		pVx (-0.5, -0.5, -0.5, true);

		startSurface ("right", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.8, 0.0, 0.0, 1.0])); // Red.
		pVx (0.5, 0.5, -0.5); pVx (0.5, 0.5, 0.5); pVx (0.5, -0.5, 0.5);
		pVx (0.5, -0.5, -0.5, true);

		startSurface ("left", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.0, 0.8, 0.8, 1.0])); // Cyan.
		pVx (-0.5, 0.5, 0.5);  pVx (-0.5, 0.5, -0.5); pVx (-0.5, -0.5, -0.5);
		pVx (-0.5, -0.5, 0.5, true);

		startSurface ("bottom", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.8, 0.0, 0.8, 1.0])); // Magenta.
		pVx (-0.5, -0.5, -0.5); pVx (0.5, -0.5, -0.5); pVx (0.5, -0.5, 0.5);
		pVx (-0.5, -0.5, 0.5, true);

		startSurface ("rear", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.8, 0.8, 0.0, 1.0])); // Yellow.
		pVx (0.5, 0.5, 0.5); pVx (-0.5, 0.5, 0.5); pVx (-0.5, -0.5, 0.5);
		pVx (0.5, -0.5, 0.5, true);

		mergeNormals (3);
	} // End of construct Surfaces().

	private function
	startSurface (id:String, offset:uint, programID:String, material:*)
	:void
	{
		currentSurface = new Surface (id, offset, programID, material);
		geometrySurfaces[id] = currentSurface;
	} // End of startSurface().

	private function
	pVx (x:Number, y:Number, z:Number, lastV:Boolean = false)
	:void
	{
		vertices.push (x); vertices.push (y); vertices.push (z);
		indices.push (vdx++);
		++currentSurface.idx;
		if (lastV) {
			indices.push (vdx - 4);
			indices.push (vdx - 2);
			currentSurface.idx += 2;
		}
	} // End of pVx().

} // End of Cube Class.

} // End of Package Declaration.
