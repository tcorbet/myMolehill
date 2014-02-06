package com.sss.threed.shader 
{
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-12
**
** Currently the same as Texture01.
** The only reason for the duplication is that Object3D needs to
** be able to distinquish between the two techniques in activateTexture.
** Use this for a BillBoard with constant lighting.
*/
public final class Texture02 extends ProgramBase
{
	public function
	Texture02()
	{
		super (ProgramBase.TEXTURE_02,
			(
			// Inputs:
			// va0		Vector3D, vertex position
			// va2		UV coordinates
			// vc0-3	Matrix3d, final transform
			"m44 op, va0, vc0 \n" +					// Project Vertex Position to Clipping Space.
			"mov v0, va2"							// Pass UV Coordinates to the Fragment Shader.
			),
			/*----------*/
			(
			// Inputs:
			// v0		UV coordinates
			// fs0		Texture map
			"tex oc, v0, fs0 <2d, linear, nomipmap, clamp>"
			)
			);
	} // End of Constructor for Texture02.

} // End of Texture02 Class.

} // End of Package Declaration.