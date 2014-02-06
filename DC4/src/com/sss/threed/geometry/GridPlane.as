package com.sss.threed.geometry
{
import flash.utils.getQualifiedClassName;

import com.sss.threed.Surface;
import com.sss.threed.geometry.GeometryBase;
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-27
*/
public final class GridPlane extends GeometryBase
{
	public function
	GridPlane (params:Array)
	{
		super (3);
		constructSurfaces (params);
	} // End of Constructor for GridPlane.

	// CW winding.
	private function
	constructSurfaces (params:Array)
	:void
	{
		var xWidth:Number = parseFloat (params[0]);
		if ((isNaN (xWidth)) || (xWidth < 30)) xWidth = 30;
		var zWidth:Number = parseFloat (params[1]);
		if ((isNaN (zWidth)) || (zWidth < 30)) zWidth = 30;
		var xHatch:Number = parseFloat (params[2]);
		if ((isNaN (xHatch)) || (xHatch < .2)) xHatch = .2;
		var zHatch:Number = parseFloat (params[3]);
		if ((isNaN (zHatch)) || (zHatch < .2)) zHatch = .2;

		var xHalf:Number = (xWidth / 2.0);
		var zHalf:Number = (zWidth / 2.0);
		var y:Number = 0.02;
		startSurface ("fb", indices.length, ProgramBase.COLOR_02,
			Vector.<Number> ([0.0, 0.0, 0.0, 1.0]));
		for (var x:Number = -xHalf; x <= xHalf; ) {
			pVx (x, y, -zHalf); pVx (x, y, zHalf); pVx (x, -y, zHalf);
			pVx (x, -y, zHalf); pVx (x, -y, -zHalf); pVx (x, y, -zHalf);
			x += (xWidth * xHatch);
		}
		startSurface ("lr", indices.length, ProgramBase.COLOR_02,
			Vector.<Number> ([0.0, 0.0, 0.0, 1.0]));
		for (var z:Number = -zHalf; z <= zHalf; ) {
			pVx (-xHalf, y, z); pVx (xHalf, y, z); pVx (xHalf, -y, z);
			pVx (xHalf, -y, z); pVx (-xHalf, -y, z); pVx (-xHalf, y, z);
			z += (zWidth * zHatch);
		}
	} // End of construct Surfaces().

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

} // End of GridPlane Class.

} // End of Package Declaration.
