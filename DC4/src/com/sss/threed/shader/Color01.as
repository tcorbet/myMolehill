package com.sss.threed.shader 
{
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-12
**
** Simple flat shading which completely ignores any effects of any light sources.
*/
public final class Color01 extends ProgramBase
{
	public function
	Color01()
	{
		super (ProgramBase.COLOR_01,
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
	} // End of Constructor for Color01.

} // End of Color01 Class.

} // End of Package Declaration.