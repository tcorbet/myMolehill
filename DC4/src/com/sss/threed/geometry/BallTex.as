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
public final class BallTex extends GeometryBase
{
	public function
	BallTex (params:Array)
	{
		super (8);
		constructSurfaces (params);
	} // End of Constructor for BallTex.

	[Inline] public final function get vertexVector():Vector.<Number> { return (vertices); };
	[Inline] public final function get indexVector():Vector.<uint> { return (indices); };

	// CW winding.
	// UV is upper-left toward lower-right origined.
	private function
	constructSurfaces (params:Array)
	:void
	{
		var grid:Vector.<G> = new Vector.<G>();
		var numParallels:uint = parseInt (params[0]);
		if (numParallels < 8) numParallels = 8;
		var numMeridians:uint = parseInt (params[1]);
		if (numMeridians < 16) numMeridians = 16;
		var i:uint, j:uint;
		for (i = 0; i <= numParallels; ++i) {
			var phi:Number = ((i / numParallels) * Math.PI);
			for (j = 0; j <= numMeridians; ++j) {
				var theta:Number = ((j / numMeridians) * 2 * Math.PI);
				var sinPhi:Number = Math.sin (phi);
				var x:Number = (sinPhi * Math.cos (theta) / 2);
				var y:Number = (Math.cos (phi) / 2);
				var z:Number = (sinPhi * Math.sin (theta) / 2);
				// trace (U.fixedFract (x, 4), U.fixedFract (y, 4), U.fixedFract (z, 4));
				grid.push (new G (x, y, z,
					(Number (j) / numMeridians), (Number (i) / numParallels)));
			}
			// trace ("");
		}

		currentSurface = new Surface ("all", 0, ProgramBase.TEXTURE_11);
		geometrySurfaces["all"] = currentSurface;

		var g:G;
		var k:uint, l:uint, m:uint, n:uint;
		var nmp1:uint = (numMeridians + 1);
		for (i = 0; i < numParallels; ++i) {
			for (j = 0; j < numMeridians; ++j) {
				k = ((i * nmp1) + j);
				l = (k + 1);
				m = (((i + 1) * nmp1) + j);
				n = (m + 1);
				// trace (k, l, m, n);

				g = grid[k];
				pVx (g.x, g.y, g.z, g.u, g.v);
				g = grid[l];
				pVx (g.x, g.y, g.z, g.u, g.v);
				g = grid[m];
				pVx (g.x, g.y, g.z, g.u, g.v);

				g = grid[l];
				pVx (g.x, g.y, g.z, g.u, g.v);
				g = grid[n];
				pVx (g.x, g.y, g.z, g.u, g.v);
				g = grid[m];
				pVx (g.x, g.y, g.z, g.u, g.v);
			}
			// trace ("");
		}
	} // End of constructSurfaces().

	private function
	pVx (x:Number, y:Number, z:Number, u:Number = 0.0, v:Number = 0.0)
	:void
	{
		vertices.push (x); vertices.push (y); vertices.push (z);
		vertices.push (-x * 2.0); vertices.push (-y * 2.0); vertices.push (-z * 2.0);
		vertices.push (u); vertices.push (v);
		indices.push (vdx++);
		++currentSurface.idx;
	} // End of pVx().

} // End of BallTex Class.

} // End of Package Declaration.

internal final class G
{
	private var _x:Number;
	private var _y:Number;
	private var _z:Number;
	private var _u:Number;
	private var _v:Number;

	public function
	G (x:Number, y:Number, z:Number, u:Number, v:Number)
	{
		_x = x;
		_y = y;
		_z = z;
		_u = u;
		_v = v;
	} // End of Constructor for G.

	[Inline] public final function get x():Number { return (_x); };
	[Inline] public final function get y():Number { return (_y); };
	[Inline] public final function get z():Number { return (_z); };
	[Inline] public final function get u():Number { return (_u); };
	[Inline] public final function get v():Number { return (_v); };
} // End of Internal G Class.
