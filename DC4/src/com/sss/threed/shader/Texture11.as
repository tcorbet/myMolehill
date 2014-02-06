package com.sss.threed.shader 
{
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2013-01-28
**
** Texture with effect from a single, directional light.
** This needs to be a Phong (per pixel) implementation, unlike Color1, becauase the
** diffuse color can only be known after linear sampling of the interpolated
** UV coordinates.
*/
public final class Texture11 extends ProgramBase
{
	public function
	Texture11()
	{
		super (ProgramBase.TEXTURE_11,
			(
			// Inputs:
			// va0		Vector3D, vertex position
			// va1		Vector3D. vertex normal
			// va2		UV coordinates
			// vc0-3	Matrix3D, final transform
			// vc4-7	Matrix3D, object transform
			// vc8		Directional light's direction
			// vc26		Lighting controls
			// vc27		Constants and switches
			"m44 op, va0, vc0 \n" +					// Project Vertex Position to Clipping Space.
			"m33 vt0.xyz, va1, vc4 \n" +			// Transform Vertex Normal.
			"mov vt0.w, vc27.x \n" +				// Constant 1.0.
			"nrm vt0.xyz, vt0 \n" +					// Normalize the transformed Normal.
			"dp3 vt1.x, vt0.xyz, vc8.xyz \n" + 		// Form Dot Product with Prenormalized Light Direction Vector.
			"neg vt1.x, vt1.x \n" +					// Switch the Sign of the Computed Scalar Result.
			"sat vt1.x, vt1.x \n" +					// Clamp the Result between 0 and 1.
			"mov vt1.yzw, vc27.x \n" +
			"mov v0, vt1 \n" +  					// Pass the factor for the light.
			"mov vt3.xyz, vc8.xyz \n" +
			"neg vt3.xyz, vt3.xyz \n" +				// Derive anti-light.			
			"dp3 vt4.x, vt0.xyz, vt3.xyz \n" +		// Use anti-light parameters.
			"neg vt4.x, vt4.x \n" +
			"sat vt4.x, vt4.x \n" +
			"mov vt4.yzw, vc27.x \n" +
			"mov v1, vt4 \n" +  					// Pass the factor for the anti-light.
			/* Not interesting for flat surfaces. Test when some curved, textured object appears.
			"mov vt3.xyz, vc8.xyz \n" +				// l
			"add vt3.xyz, vt3.xyz, vc10.xyz \n" +	// + v
			"dp3 vt4.xyz, vt3.xyz, vt3.xyz \n" +	// sums
			"add vt4.w, vt4.x, vt4.y \n" +			// of component
			"add vt4.w, vt4.w, vt4.z \n" +			// squares
			"sqt vt4.w, vt4.w \n" +					// yields the magnitude.
			"div vt5.xyz, vt3.xyz, vt4.www \n" +	// Component values divided by magnitude
			"mov vt5.w, vc27.x \n" +				// finally gives
			"nrm vt5.xyz, vt5 \n" +					// the normalized h term
			"neg vt5.xyz, vt5.xyz \n" +				// with sign switched as before
			"sat vt5.xyz, vt5.xyz \n" +				// but only if positive.
			"dp3 vt6.x, vt0.xyz, vt5.xyz \n" +		// Now normal's dot product with h
			"pow vt6.x, vt6.x, vc26.w \n" +			// is raised to some exponential value
			"mov vt6.yzw, vc27.x \n" +				// which must be padded
			"mov v2, vt6 \n" +						// in order to be passed along.
			*/
			"mov v3, va2"							// Pass UV Coordinates to the Fragment Shader.
			),
			/*----------*/
			(
			// v0		Light factor
			// v1		Anti-light factor
			// v2		Specular factor
			// v3		UV coordinates
			// fs0		Texture map
			// fc26		Lighting controls
			"tex ft0, v3, fs0 <2d, linear, nomipmap, clamp> \n" +
			"mul ft2.xyz, ft0.xyz, v0.x \n" +		// Moderate Diffuse color elements by light factor.
			"mul ft2.xyz, ft2.xyz, fc26.xxx \n" +	// Apply light intensity weighting factor.
			"mul ft3.xyz, ft0.xyz, v1.x \n" +		// Moderate Diffuse color elements by anti-light factor.
			"mul ft3.xyz, ft3.xyz, fc26.yyy \n" +	// Apply anti-light intensity weighting factor.
			"add ft4.xyz, ft2.xyz, ft3.xyz \n" +	// Combine light and anti-light effects.
			/* Not interesting for flat surfaces. Test when some curved, textured object appears.
			"mul ft5.xyz, ft0.xyz, v2.x \n" +		// Moderate Diffuse color elements by specular factor.
			"add ft4.xyz, ft4.xyz, ft5.xyz \n" +	// Add to the mix.
			*/
			"mov ft4.w, ft0.w \n" +					// Set Alpha.
			"mov oc, ft4"							// Send Moderated Color to Rasterizer.
			)
			);
	} // End of Constructor for Texture11.

} // End of Texture11 Class.

} // End of Package Declaration.
