package com.sss.threed.geometry
{
import flash.geom.Vector3D;
import flash.utils.getQualifiedClassName;

import com.sss.threed.Surface;
import com.sss.threed.geometry.GeometryBase;
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-25
*/
public final class CubeTex extends GeometryBase
{
	public function
	CubeTex (params:Array)
	{
		super (8);
		constructSurfaces();
	} // End of Constructor for CubeTex.

	[Inline] public final function get vertexVector():Vector.<Number> { return (vertices); };
	[Inline] public final function get indexVector():Vector.<uint> { return (indices); };

	// CW winding.
	// UV is upper-left toward lower-right origined.
	private function
	constructSurfaces()
	:void
	{
		pVs (-0.5, 0.5, -0.5, 0.25, 0.3333, ["top", ProgramBase.TEXTURE_11]);
		pVs (-0.5, 0.5, 0.5, 0.25, 0.0); pVs (0.5, 0.5, 0.5, 0.5, 0.0);
		pVs (0.5, 0.5, -0.5, 0.5, 0.3333); pVs (-0.5, 0.5, -0.5, 0.25, 0.3333); pVs (0.5, 0.5, 0.5, 0.5, 0.0);

		pVs (-0.5, 0.5, -0.5, 0.25, 0.3333, ["front", ProgramBase.TEXTURE_11]);
		pVs (0.5, 0.5, -0.5, 0.5, 0.3333); pVs (0.5, -0.5, -0.5, 0.5, 0.6667);
		pVs (-0.5, -0.5, -0.5, 0.25, 0.6667); pVs (-0.5, 0.5, -0.5, 0.25, 0.3333); pVs (0.5, -0.5, -0.5, 0.5, 0.6667);

		pVs (0.5, 0.5, -0.5, 0.5, 0.3333, ["right", ProgramBase.TEXTURE_11]);
		pVs (0.5, 0.5, 0.5, 0.75, 0.3333); pVs (0.5, -0.5, 0.5, 0.75, 0.6667);
		pVs (0.5, -0.5, -0.5, 0.5, 0.6667); pVs (0.5, 0.5, -0.5, 0.5, 0.3333); pVs (0.5, -0.5, 0.5, 0.75, 0.6667); 

		pVs (-0.5, 0.5, 0.5, 0.0, 0.3333, ["left", ProgramBase.TEXTURE_11]);
		pVs (-0.5, 0.5, -0.5, 0.25, 0.3333); pVs (-0.5, -0.5, -0.5, 0.25, 0.6667);
		pVs ( -0.5, -0.5, 0.5, 0.0, 0.6667); pVs (-0.5, 0.5, 0.5, 0.0, 0.3333); pVs (-0.5, -0.5, -0.5, 0.25, 0.6667); 

		pVs (-0.5, -0.5, -0.5, 0.25, 0.6667, ["bottom", ProgramBase.TEXTURE_11]);
		pVs (0.5, -0.5, -0.5, 0.5, 0.6667); pVs (0.5, -0.5, 0.5, 0.5, 1.0);
		pVs ( -0.5, -0.5, 0.5, 0.25, 1.0); pVs (-0.5, -0.5, -0.5, 0.25, 0.6667); pVs (0.5, -0.5, 0.5, 0.5, 1.0); 

		pVs (0.5, 0.5, 0.5, 0.75, 0.3333, ["rear", ProgramBase.TEXTURE_11]);
		pVs (-0.5, 0.5, 0.5, 1.0, 0.3333); pVs (-0.5, -0.5, 0.5, 1.0, 0.6667);
		pVs (0.5, -0.5, 0.5, 0.75, 0.6667); pVs (0.5, 0.5, 0.5, 0.75, 0.3333); pVs ( -0.5, -0.5, 0.5, 1.0, 0.6667);

		mergeNormals (5);
	} // End of constructSurfaces().

	private function
	startSurface (id:String, offset:uint, programID:String)
	:void
	{
		currentSurface = new Surface (id, offset, programID);
		geometrySurfaces[id] = currentSurface;
	} // End of startSurface().

	protected function
	pVs (x:Number, y:Number, z:Number, u:Number = 0.0, v:Number = 0.0, value:* = null)
	:void
	{
		if (value is Array) startSurface (value.shift(), indices.length, value.shift());
		pVx (x, y, z, u, v);
	} // End of pVs().

	private function
	pVx (x:Number, y:Number, z:Number, u:Number = 0.0, v:Number = 0.0)
	:void
	{
		vertices.push (x); vertices.push (y); vertices.push (z);
		vertices.push (u); vertices.push (v);
		indices.push (vdx++);
		++currentSurface.idx;
	} // End of pVx().

} // End of CubeTex Class.

} // End of Package Declaration.
