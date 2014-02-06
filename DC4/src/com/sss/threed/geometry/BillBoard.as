package com.sss.threed.geometry 
{
import flash.utils.getQualifiedClassName;

import com.sss.threed.Surface;
import com.sss.threed.geometry.GeometryBase;
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-15
*/
public final class BillBoard extends GeometryBase
{
	private const H2:Number = 2.0;
	private const W2:Number = 5.0;
	private const W4:Number = 0.5;

	public function
	BillBoard (params:Array)
	{
		super (8);
		constructSurfaces (params);
	} // End of Constructor for BillBoard.

	// CW winding.
	private function
	constructSurfaces (params:Array)
	:void
	{
		// Front.
		startSurface ("face", indices.length, ProgramBase.TEXTURE_12, null);
		pVx (-W2, H2, -W4, 0.0, 0.0); pVx (W2, H2, -W4, 1.0, 0.0); pVx (W2, -H2, -W4, 1.0, 1.0);
		pVx (W2, -H2, -W4, 1.0, 1.0); pVx (-W2, -H2, -W4, 0.0, 1.0); pVx (-W2, H2, -W4, 0.0, 0.0);

		// Rear.
		var color:Vector.<Number> = Vector.<Number> ([0.7, 0.7, 0.0, 1.0]);
		if (params.length > 0) color = params[0];

		startSurface ("sides", indices.length, ProgramBase.COLOR_11, color);
		pVx (W2, H2, W4);  pVx (-W2, H2, W4); pVx (-W2, -H2, W4);
		pVx (-W2, -H2, W4);  pVx (W2, -H2, W4); pVx (W2, H2, W4);
		// Top.
		pVx (0.0, (H2 + W4), 0.0); pVx (-W2, H2, W4); pVx (W2, H2, W4);
		pVx (0.0, (H2 + W4), 0.0); pVx (W2, H2, W4); pVx (W2, H2, -W4);
		pVx (0.0, (H2 + W4), 0.0); pVx (W2, H2, -W4); pVx (-W2, H2, -W4);
		pVx (0.0, (H2 + W4), 0.0); pVx (-W2, H2, -W4); pVx (-W2, H2, W4);
		// Left.
		pVx (-(W2 + W4), 0.0, 0.0); pVx (-W2, H2, W4); pVx (-W2, H2, -W4);
		pVx (-(W2 + W4), 0.0, 0.0); pVx (-W2, H2, -W4); pVx (-W2, -H2, -W4);
		pVx (-(W2 + W4), 0.0, 0.0); pVx (-W2, -H2, -W4); pVx (-W2, -H2, W4);
		pVx (-(W2 + W4), 0.0, 0.0); pVx (-W2, -H2, W4); pVx (-W2, H2, W4);
		// Right Side.
		pVx ((W2 + W4), 0.0, 0.0); pVx (W2, H2, -W4); pVx (W2, H2, W4);
		pVx ((W2 + W4), 0.0, 0.0); pVx (W2, H2, W4); pVx (W2, -H2, W4);
		pVx ((W2 + W4), 0.0, 0.0); pVx (W2, -H2, W4); pVx (W2, -H2, -W4);
		pVx ((W2 + W4), 0.0, 0.0); pVx (W2, -H2, -W4); pVx (W2, H2, -W4);
		// Bottom.
		pVx (0.0, -(H2 + W4), 0.0); pVx (-W2, -H2, -W4); pVx (W2, -H2, -W4);
		pVx (0.0, -(H2 + W4), 0.0); pVx (W2, -H2, -W4); pVx (W2, -H2, W4);
		pVx (0.0, -(H2 + W4), 0.0); pVx (W2, -H2, W4); pVx (-W2, -H2, W4);
		pVx (0.0, -(H2 + W4), 0.0); pVx (-W2, -H2, W4); pVx (-W2, -H2, -W4);

		mergeNormals (5);
	} // End of constructSurfaces().

	private function
	startSurface (id:String, offset:uint, programID:String, material:*)
	:void
	{
		currentSurface = new Surface (id, offset, programID, material);
		geometrySurfaces[id] = currentSurface;
	} // End of startSurface().

	private function
	pVx (x:Number, y:Number, z:Number, u:Number = 0.0, v:Number = 0.0)
	:void
	{
		vertices.push (x); vertices.push (y); vertices.push (z);
		vertices.push (u); vertices.push (v);
		indices.push (vdx++);
		++currentSurface.idx;
	} // End of pVx().

} // End of BillBoard Class.

} // End of Package Declaration.