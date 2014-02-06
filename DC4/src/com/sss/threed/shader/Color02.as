package com.sss.threed.shader 
{
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-12
**
** Simple flat shading which completely ignores any effects of any light sources.
** Identical with Color01, but using 2-sided triangles.
*/
public final class Color02 extends ProgramBase
{
	public function
	Color02()
	{
		super (ProgramBase.COLOR_02,
			(
			// Inputs:
			// va0		Vector3D, vertex position
			// vc0-3	Matrix3d, final transform
			"m44 op, va0, vc0"						// Project Vertex Position to Clipping Space.
			),
			/*----------*/
			(
			// Inputs:
			// fc0	Diffuse RGBA
			"mov oc, fc0"							// Send Constant Color to Rasterizer.
			)
			);
	} // End of Constructor for Color02.

} // End of Color02 Class.

} // End of Package Declaration.