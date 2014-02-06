package com.sss.threed.geometry 
{
import flash.geom.Vector3D;
import flash.utils.getQualifiedClassName;

import com.sss.threed.Surface;
import com.sss.threed.geometry.GeometryBase;
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-11
*/
public final class Torus extends GeometryBase
{
	public function
	Torus (params:Array)
	{
		super (6);
		constructSurfaces (params);
	} // End of Constructor for Torus.

	// CW winding.
	private function
	constructSurfaces (params:Array)
	:void
	{
		const R0:Number = 5;
        const R1:Number = 1.8;
		var N0:uint = parseInt (params[0]);
		if (N0 < 18) N0 = 18;
		var N1:uint = parseInt (params[1]);
		if (N1 < 16) N1 = 16;
		const K:uint = (N0 * N1);

		var i:uint, j:uint;
		startSurface ("all", 0, ProgramBase.COLOR_11, Vector.<Number> ([0.7, 0.4, 0.1, 1.0]));
		for (i = 0; i < N0; ++i) {
			for (j = 0; j < N1; ++j) {
				var phi:Number = (i * 2 * Math.PI / N0);
				var psi:Number = (j * 2 * Math.PI / N1);
				pVx (
					((R0 + (R1 * Math.cos (psi))) * Math.cos (phi)),
					((R0 + (R1 * Math.cos (psi))) * Math.sin (phi)),
					(R1 * Math.sin (psi)),
					(Math.cos (psi) * Math.cos (phi)),
					(Math.cos (psi) * Math.sin (phi)),
					Math.sin (psi));
			}
		}

		var k:uint, l:uint;
		indices = new Vector.<uint> ((6 * K), true);
		for (i = 0; i < N0; ++i) {
			for (j = 0; j < N1; ++j) {
				k = ((i * N1) + j);
				l = (6 * k);
				indices[l++] = k;
				indices[l++] = ((k + N1) % K);
				indices[l++] = ((k + 1) % K);
				indices[l++] = ((k + N1 + 1) % K);
				indices[l++] = ((k + 1) % K);
				indices[l] = ((k + N1) % K);
			}
		}
		currentSurface.idx = indices.length;
	} // End of constructSurfaces().

	private function
	startSurface (id:String, offset:uint, programID:String, material:*)
	:void
	{
		currentSurface = new Surface (id, offset, programID, material);
		geometrySurfaces[id] = currentSurface;
	} // End of startSurface().

	private function
	pVx (x:Number, y:Number, z:Number, nx:Number, ny:Number, nz:Number)
	:void
	{
		vertices.push (x); vertices.push (y); vertices.push (z);
		vertices.push (-nx); vertices.push (-ny); vertices.push (-nz);
	} // End of pVx().

} // End of Torus Class.

} // End of Package Declaration.