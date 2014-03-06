package com.sss.threed.geometry 
{
import flash.geom.Vector3D;
import flash.utils.getQualifiedClassName;

import com.sss.threed.Surface;
import com.sss.threed.geometry.GeometryBase;
import com.sss.threed.shader.ProgramBase;
import com.sss.util.U;
/**
** @author J. Terry Corbet
** @version 1.0 2014-03-05
*/
public final class Ball extends GeometryBase
{
	public function
	Ball (params:Array)
	{
		super (10);
		constructSurfaces (params);
	} // End of Constructor for Ball.

	// CW winding.
	private function
	constructSurfaces (params:Array)
	:void
	{
		var vertical:Boolean = (params[0] == 1);
		const colors:Array = [
			Vector.<Number> ([0.95, 0.3, 0.4, 1.0]),
			Vector.<Number> ([0.4, 0.95, 0.3, 1.0]),
			Vector.<Number> ([0.3, 0.4, 0.95, 1.0])
			];
		var grid:Vector.<Vector3D> = new Vector.<Vector3D>();
		var numParallels:uint = parseInt (params[1]);
		if (numParallels < 8) numParallels = 8;
		var numMeridians:uint = parseInt (params[2]);
		if (numMeridians < 16) numMeridians = 16;
		var i:uint, j:uint;
		for (i = 1; i < numParallels; ++i) { // N.B. Top/Bottom Cut-off.
			var phi:Number = ((i / numParallels) * Math.PI);
			for (j = 0; j < numMeridians; ++j) {
				var theta:Number = ((j / numMeridians) * 2 * Math.PI);
				var sinPhi:Number = Math.sin (phi);
				var x:Number = (sinPhi * Math.cos (theta) / 2);
				var y:Number = (Math.cos (phi) / 2);
				var z:Number = (sinPhi * Math.sin (theta) / 2);
				// trace (U.fixedFract (x, 4), U.fixedFract (y, 4), U.fixedFract (z, 4));
				grid.push (new Vector3D (x, y, z));
			}
			// trace ("");
		}

		currentSurface = new Surface ("all", 0, ProgramBase.COLOR_12);
		geometrySurfaces["all"] = currentSurface;

		var v:Vector3D;
		var color:Vector.<Number>;
		var k:uint, l:uint, m:uint, n:uint;
		for (i = 0; i < numMeridians; ++i) {
			if (vertical) color = colors[(i % 3)];
			for (j = 0; j < (numParallels - 2); ++j) { // N.B. A second Top Cut-off.
				if (! vertical) color = colors[(j % 3)];
				k = ((j * numMeridians) + (i % numMeridians));
				l = ((j * numMeridians) + ((i + 1) % numMeridians));
				m = (((j + 1) * numMeridians) + (i % numMeridians));
				n = (((j + 1) * numMeridians) + ((i + 1) % numMeridians));
				// trace (k, l, m, n);

				v = grid[k];
				pVx (v.x, v.y, v.z, color[0], color[1], color[2], color[3]);
				v = grid[l];
				pVx (v.x, v.y, v.z, color[0], color[1], color[2], color[3]);
				v = grid[m];
				pVx (v.x, v.y, v.z, color[0], color[1], color[2], color[3]);

				v = grid[l];
				pVx (v.x, v.y, v.z, color[0], color[1], color[2], color[3]);
				v = grid[n];
				pVx (v.x, v.y, v.z, color[0], color[1], color[2], color[3]);
				v = grid[m];
				pVx (v.x, v.y, v.z, color[0], color[1], color[2], color[3]);
			}
			// trace ("");
		}

		// Top.
		for (i = (grid.length - numMeridians); i < grid.length; ++i) {
			color = ((vertical) ? colors[(i % 3)] : colors[0]);
			j = i;
			k = (i + 1);
			if (k == grid.length) k -= numMeridians;
			pVx (0.0, 0.5, 0.0, color[0], color[1], color[2], color[0]);
			v = grid[j];
			pVx (v.x, v.y, v.z, color[0], color[1], color[2], color[3]);
			v = grid[k];
			pVx (v.x, v.y, v.z, color[0], color[1], color[2], color[3]);
		}
		// Bottom.
		for (i = 0; i < numMeridians; ++i) {
			color = ((vertical) ? colors[(i % 3)] : colors[2]);
			j = (i % numMeridians);
			k = ((i + 1) % numMeridians);
			pVx (0.0, -0.5, 0.0, color[0], color[1], color[2], color[3]);
			v = grid[k];
			pVx (v.x, v.y, v.z, color[0], color[1], color[2], color[3]);
			v = grid[j];
			pVx (v.x, v.y, v.z, color[0], color[1], color[2], color[3]);
		}
		
		// trace ("All", indices.length, currentSurface.idx);
	} // End of constructSurfaces().

	private function
	pVx (x:Number, y:Number, z:Number, r:Number, g:Number, b:Number, a:Number)
	:void
	{
		vertices.push (x); vertices.push (y); vertices.push (z);
		vertices.push (-x * 2.0); vertices.push (-y * 2.0); vertices.push (-z * 2.0);
		vertices.push (r); vertices.push (g); vertices.push (b); vertices.push (a);
		indices.push (vdx++);
		++currentSurface.idx;
	} // End of pVx().

} // End of Ball Class.

} // End of Package Declaration.