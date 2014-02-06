package com.sss.threed.shader 
{
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2013-01-29
**
** This is is a derivative of Texture11, but as the normals are supplied per pixel
** from a second texture, most of the work needs must be moved to the fragment shader.
*/
public final class Texture21 extends ProgramBase
{
	public function
	Texture21()
	{
		super (ProgramBase.TEXTURE_21,
			(
			// Inputs:
			// va0		Vector3D, vertex position
			// va1		UV coordinates
			// vc0-3	Matrix3D, final transform
			// vc4		Directional light's direction
			// vc5		Camera position
			// vc27		Constants and switches
			"m44 op, va0, vc0 \n" +					// Project Vertex Position to Clipping Space.
			"mov v0, va1 \n" +						// Pass UV Coordinates to the Fragment Shader.

			"mov vt0.xyz, vc4.xyz \n" +				// l
			"add vt0.xyz, vt0.xyz, vc5.xyz \n" +	// + v
			"mul vt1.xyz, vt0.xyz, vt0.xyz \n" +	// sums
			"add vt1.w, vt1.x, vt1.y \n" +			// of component
			"add vt1.w, vt1.w, vt1.z \n" +			// squares
			"sqt vt1.w, vt1.w \n" +					// yields the magnitude.
			"div vt2.xyz, vt0.xyz, vt1.www \n" +	// Component values divided by magnitude
			"mov vt2.w, vc27.x \n" +				// finally gives
			"nrm vt2.xyz, vt2.xyz \n" +				// the normalized h term
			"neg vt2.xyz, vt2.xyz \n" +				// with sign switched as before
			"sat vt2.xyz, vt2.xyz \n" +				// but only if positive.
			"mov v1, vt2"							// Pass h to the Fragment Shader.
			),
			/*----------*/
			(
			// v0		UV coordinates
			// v1		Half vector
			// fc0-3	Matrix3D, object transform
			// fc4		Directional light's direction
			// fs0		Diffuse texture map
			// fs1		Normal map
			// fc25		Normal map controls
			// fc26		Lighting conrols.
			// fc27		Constants and switches
			"tex ft0, v0, fs0 <2d, nearest, nomipmap, clamp> \n" +
			"tex ft1, v0, fs1 <2d, nearest, nomipmap, clamp> \n" +
			"mul ft1.xyz, ft1.xyz, fc25.xxx \n" +	// Times 0xFF.
			"sub ft1.xyz, ft1.xyz, fc25.yyy \n" +	// Minus 127.5.
			"mul ft1.xyz, ft1.xyz, fc25.zzz \n" +	// Times 1 / 127.5.
			"m33 ft2.xyz, ft1, fc0 \n" +			// Transform Vertex Normal.
			"mov ft2.w, fc27.x \n" +				// Constant 1.0.
			"nrm ft2.xyz, ft2.xyz \n" +				// Normalize the transformed Normal.
			"dp3 ft3.x, ft2.xyz, fc4.xyz \n" + 		// Form Dot Product with Prenormalized Light Direction Vector.
			// "neg ft3.x, ft3.x \n" +				// DO NOT switch the sign of the resi;t for Diffuse.
			"sat ft3.x, ft3.x \n" +					// Clamp the Result between 0 and 1.
			"mul ft4.xyz, ft0.xyz, ft3.xxx \n" +	// Moderate Diffuse color elements by result.
			"mul ft4.xyz, ft4.xyz, fc26.xxx \n" +	// Apply light intensity weighting factor.
			"mov ft3.xyz, fc4.xyz \n" +
			"neg ft3.xyz, ft3.xyz \n" +				// Derive anti-light.
			"dp3 ft3.x, ft2.xyz, ft3.xyz \n" +		// Use anti-light parameters.
			// "neg ft3.x, ft3.x \n" +				// DO NOT switch the sign of the result for anti-Diffuse.
			"sat ft3.x, ft3.x \n" +
			"mul ft3.xyz, ft0.xyz, ft3.xxx \n" +	// Calculate anti-Diffuse.
			"mul ft3.xyz, ft3.xyz, fc26.yyy \n" +	// Apply anti-light intensity weighting factor.
			"add ft4.xyz, ft4.xyz, ft3.xyz \n" +	// Combine light and anti-light effects.

			"dp3 ft5.x, ft2.xyz, v1.xyz \n" +		// Dot product of normal and h.
			"neg ft5.x, ft5.x \n" +					// BUT DO switch the sign of the result for Specular.
			"sat ft5.x, ft5.x \n" +					// Clamp the Result between 0 and 1.
			"pow ft5.x, ft5.x, fc26.w \n" +			// is raised to some exponential value
			"mul ft5.xyz, ft0.xyz, ft5.xxx \n" + 	// that moderates the Diffuse color elements.
			"mul ft5.xyz, ft5.xyz, fc26.zzz \n" +	// Apply specular intensity weighting factor.
			"mul ft5.xyz, ft5.xyz, fc27.yyy \n" +	// If not switched off
			"add ft4.xyz, ft4.xyz, ft5.xyz \n" +	// the specular contribution is added to the mix.
			
			"mov ft4.w, ft0.w \n" +					// Set Alpha.
			"mov oc, ft4"							// Send Moderated Color to Rasterizer.
			)
			);
	} // End of Constructor for Texture21.

} // End of Texture21 Class.

} // End of Package Declaration.
