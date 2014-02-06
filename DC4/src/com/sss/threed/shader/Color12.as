package com.sss.threed.shader 
{
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-26
**
** This shader is identical to Color11. It only differs with respect to the source of the
** diffuse color constant per facet.  Owing to the manner in which Ball geometries are generated,
** it is simpler to set the diffuse color as each vertex is computed rather than per surface.
*/
public final class Color12 extends ProgramBase
{
	public function
	Color12()
	{
		super (ProgramBase.COLOR_12,
			(
			// Inputs:
			// va0		Vector3D, vertex position
			// va1		Vector3D, vertex normal
			// va2		RGBA diffuse color
			// vc0-3	Matrix3D, final transform
			// vc4-7	Matrix3D, object transform
			// vc8		Directional light's direction
			// vc10		Camera position
			// vc26		Lighting controls
			// vc27		Constants and switches
			"m44 op, va0, vc0 \n" +					// Project Vertex Position to Clipping Space.
			"m33 vt0.xyz, va1, vc4 \n" +			// Transform Vertex Normal.
			"mov vt0.w, vc27.x \n" +				// Constant 1.0.
			"nrm vt0.xyz, vt0.xyz \n" +				// Normalize the transformed Normal.
			"dp3 vt1.x, vt0.xyz, vc8.xyz \n" + 		// Form Dot Product with Prenormalized Light Direction Vector.
			"neg vt1.x, vt1.x \n" +					// Switch the Sign of the Computed Scalar Result.
			"sat vt1.x, vt1.x \n" +					// Clamp the Result between 0 and 1.
			"mul vt2.xyz, va2.xyz, vt1.xxx \n" +	// Moderate Diffuse color elements by result.
			"mul vt2.xyz, vt2.xyz, vc26.xxx \n" +	// Apply light intensity weighting factor.
			// My interpretation of Real-time Rendering pp 77-78.
			"mov vt3.xyz, vc8.xyz \n" +				// l
			"add vt3.xyz, vt3.xyz, vc10.xyz \n" +	// + v
			"mul vt4.xyz, vt3.xyz, vt3.xyz \n" +	// sums
			"add vt4.w, vt4.x, vt4.y \n" +			// of component
			"add vt4.w, vt4.w, vt4.z \n" +			// squares
			"sqt vt4.w, vt4.w \n" +					// yields the magnitude.
			"div vt5.xyz, vt3.xyz, vt4.www \n" +	// Component values divided by magnitude
			"mov vt5.w, vc27.x \n" +				// finally gives
			"nrm vt5.xyz, vt5.xyz \n" +				// the normalized h term
			"neg vt5.xyz, vt5.xyz \n" +				// with sign switched as before
			"sat vt5.xyz, vt5.xyz \n" +				// but only if positive.
			"dp3 vt6.x, vt0.xyz, vt5.xyz \n" +		// Now normal's dot product with h
			"pow vt6.x, vt6.x, vc26.w \n" +			// is raised to some exponential value
			"mul vt7.xyz, va2.xyz, vt6.xxx \n" +	// that moderates the Diffuse color elements.
			"mul vt7.xyz, vt7.xyz, vc26.zzz \n" +	// Apply specular intensity weighting factor.
			"mul vt7.xyz, vt7.xyz, vc27.yyy \n" +	// If not switched off
			"add vt2.xyz, vt2.xyz, vt7.xyz \n" +	// the specular contribution is added to the mix.

			"mov vt3.xyz, vc8.xyz \n" +
			"neg vt3.xyz, vt3.xyz \n" +				// Derive anti-light.			
			"dp3 vt4.x, vt0.xyz, vt3.xyz \n" +		// Use anti-light parameters.
			"neg vt4.x, vt4.x \n" +
			"sat vt4.x, vt4.x \n" +
			"mul vt5.xyz, va2.xyz, vt4.xxx \n" +	// Calculate anti-Diffuse.
			"mul vt5.xyz, vt5.xyz, vc26.yyy \n" +	// Apply anti-light intensity weighting factor.
			"add vt6.xyz, vt2.xyz, vt5.xyz \n" +	// Combine light and anti-light effects.
			"mov vt6.w, va2.w \n" + 				// Set Alpha.
			"mov v0, vt6"							// Pass result to the Fragment Shader.
			),
			/*----------*/
			(
			// Inputs:
			// v0		Interpolated diffuse output.
			"mov oc, v0"							// Send Moderated Color to Rasterizer.
			)
			);
	} // End of Constructor for Color12.

} // End of Color12 Class.

} // End of Package Declaration.