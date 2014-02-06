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
public final class WireCube extends GeometryBase
{
	public function
	WireCube (params:Array)
	{
		super (6);
		constructSurfaces();
	} // End of Constructor for WireCube.

	// CW winding.
	private function
	constructSurfaces()
	:void
	{
		startSurface ("top", indices.length, ProgramBase.WIRE_1,
			Vector.<Number> ([0.0, 0.8, 0.0, 0.8 ])); // Green.
		pVx (-0.5, 0.5, -0.5); pVx (-0.5, 0.5, 0.5); pVx (0.5, 0.5, 0.5);
		pVx (0.5, 0.5, -0.5); pVx (-0.5, 0.5, -0.5); pVx (0.5, 0.5, 0.5);

		startSurface ("front", indices.length, ProgramBase.WIRE_1,
			Vector.<Number> ([0.0, 0.0, 0.8, 0.8])); // Blue.
		pVx (-0.5, 0.5, -0.5); pVx (0.5, 0.5, -0.5); pVx (0.5, -0.5, -0.5);
		pVx (-0.5, -0.5, -0.5); pVx (-0.5, 0.5, -0.5); pVx (0.5, -0.5, -0.5);

		startSurface ("right", indices.length, ProgramBase.WIRE_1,
			Vector.<Number> ([0.8, 0.0, 0.0, 0.8])); // Red.
		pVx (0.5, 0.5, -0.5); pVx (0.5, 0.5, 0.5); pVx (0.5, -0.5, 0.5);
		pVx (0.5, -0.5, -0.5); pVx (0.5, 0.5, -0.5); pVx (0.5, -0.5, 0.5);

		startSurface ("left", indices.length, ProgramBase.WIRE_1,
			Vector.<Number> ([0.0, 0.8, 0.8, 0.8])); // Cyan.
		pVx (-0.5, 0.5, 0.5);  pVx (-0.5, 0.5, -0.5); pVx (-0.5, -0.5, -0.5);
		pVx (-0.5, -0.5, 0.5); pVx (-0.5, 0.5, 0.5); pVx (-0.5, -0.5, -0.5);

		startSurface ("bottom", indices.length, ProgramBase.WIRE_1,
			Vector.<Number> ([0.8, 0.0, 0.8, 0.8])); // Magenta.
		pVx (-0.5, -0.5, -0.5); pVx (0.5, -0.5, -0.5); pVx (0.5, -0.5, 0.5);
		pVx (-0.5, -0.5, 0.5); pVx (-0.5, -0.5, -0.5); pVx (0.5, -0.5, 0.5);

		startSurface ("rear", indices.length, ProgramBase.WIRE_1,
			Vector.<Number> ([0.8, 0.8, 0.0, 0.8])); // Yellow.
		pVx (0.5, 0.5, 0.5); pVx (-0.5, 0.5, 0.5); pVx (-0.5, -0.5, 0.5);
		pVx (0.5, -0.5, 0.5); pVx (0.5, 0.5, 0.5); pVx (-0.5, -0.5, 0.5);

		regenerateVertices (3);
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

	private function
	regenerateVertices (span:uint)
	:void
	{
		var tv:Vector.<Number> = vertices.slice (0);
		vertices.length = 0;
		var idx:uint;
		for (idx = 0; idx < indices.length; ) {
			var jdx:uint = (indices[idx++] * span);
			var v1:Vector3D = new Vector3D (tv[jdx++], tv[jdx++], tv[jdx++]);
			jdx = (indices[idx++] * span);
			var v2:Vector3D = new Vector3D (tv[jdx++], tv[jdx++], tv[jdx++]);
			jdx = (indices[idx++] * span);
			var v3:Vector3D = new Vector3D (tv[jdx++], tv[jdx++], tv[jdx++]);

			vertices.push (v1.x); vertices.push (v1.y); vertices.push (v1.z);
			vertices.push (vertexToEdgeDistance (v1, v2, v3)); vertices.push (0.0); vertices.push (0.0);
			vertices.push (v2.x); vertices.push (v2.y); vertices.push (v2.z);
			vertices.push (0.0); vertices.push (vertexToEdgeDistance (v2, v1, v3)); vertices.push (0.0);
			vertices.push (v3.x); vertices.push (v3.y); vertices.push (v3.z);
			vertices.push (0.0); vertices.push (0.0); vertices.push (vertexToEdgeDistance (v3, v1, v2));
		}
		return;

		function vertexToEdgeDistance (v1:Vector3D, v2:Vector3D, v3:Vector3D)
		:Number
		{
			var vA:Vector3D = v2.subtract (v1);
			var vB:Vector3D = v3.subtract (v1);
			var vC:Vector3D = v3.subtract (v2);
			return (vA.crossProduct (vB).length / vC.length);
		} // End of vertexToEdgeDistance().
	} // End of regenerateVertices().

} // End of WireCube Class.

} // End of Package Declaration.
