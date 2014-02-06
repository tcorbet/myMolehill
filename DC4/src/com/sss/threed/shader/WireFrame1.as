package com.sss.threed.shader 
{
import com.sss.threed.shader.ProgramBase;
/**
** @author J. Terry Corbet
** @version 1.0 2013-12-11
*/
public final class WireFrame1 extends ProgramBase
{
	public function
	WireFrame1()
	{
		super (ProgramBase.WIRE_1,
			(
			// Inputs:
			// va0		Vector3D, vertex position
			// va1		Edge distances
			// vc0-3	Matrix3d, final transform
			"m44 op, va0, vc0 \n" +					// Project Vertex Position to Clipping Space.
			"mov v0, va1"							// Pass Distances to the Fragment Shader.
			),
			/*----------*/
			(
			// Inputs:
			// v0		Transformed distances	
			// fc0		Triangle RGBA
			// fc1		Various math constants
			// fc2		Triangle edge thickness values
			// fc3		Object scale
			// ft0		Correct fragment distance
			// ft1		1 or 0
			// ft2		Triangle color
			// ft3		smoothValue
			"mov ft2, fc0 \n" +
			"min ft0.x, v0.x, v0.y \n" +			// min d.x, distanceIn.x, distanceIn.y;
			"min ft0.x, ft0.x, v0.z \n" +			// min d.x, d.x, distanceIn.z;
			"mul ft0.x, ft0.x, fc3.x \n" +
			// If fragment distance greater then max allowed thickness, exit with no output.
			"slt ft1.x, ft0.x, fc2.y \n" +			// If distance > border width, result is 0
			"sub ft4.x, ft1.x, fc1.x \n" +			// So, subtracting 1 will cause ft4 to go negative.
			"kil ft4.x \n" +						// If ft4 is negative, exit without outputting any pixel.
			// Get smooth value - it's a value in range [+1] -> [~0] on 2px interval.
			"sub ft4, fc2.y, ft0.x \n" +			// temp = THICKNESS_PLUS_ONE - d.x;
			"sub ft4, fc1.z, ft4 \n" +				// temp = TWO - temp;
			"pow ft4, ft4, fc1.w \n" +				// temp = pow temp POW;
			"mul ft4, ft4, fc1.y \n" +				// temp *= MINUS_TWO;
			"exp ft3, ft4 \n" +						// exp smoothValue temp;
			// If fragment distance [d] < [thickess - 1], then 'temp' set to 1 otherwise set to smooth value.
			"slt ft1, ft0.x, fc2.x \n" +			// slt oneOrZero d.x THICKNESS_MINUS_ONE;
			"mul ft4, fc1.x, ft1 \n" +				// temp = ONE * oneOrZero;
			"sub ft1, fc1.x, ft1 \n" +				// oneOrZero = ONE - oneOrZero;
			"mul ft3, ft3, ft1 \n" +				// smoothValue *= oneOrZero;
			"add ft4, ft4, ft3 \n" +				// temp += smoothValue;
			"mul ft2.w, ft2.w, ft4 \n" +			// color.w *= temp;
			"mov oc, ft2"
			)
			);
	} // End of Constructor for WireFrame1.

} // End of WireFrame1 Class.

} // End of Package Declaration.