package com.sss.threed.shader 
{
import flash.display3D.Program3D;

import com.sss.threed.shader.IProgram;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-20
*/
public class ProgramBase
	implements IProgram
{
	public static const COLOR_01:String = "Flat-shading-1";
	public static const COLOR_02:String = "Flat-shading-2";
	public static const COLOR_11:String = "Phong-shading-faceted";
	public static const COLOR_12:String = "Phong-shading-skinned";
	public static const TEXTURE_01:String = "Flat-texture-01";
	public static const TEXTURE_02:String = "Flat-texture-02";
	public static const TEXTURE_11:String = "Phong-texture-11";
	public static const TEXTURE_12:String = "Phong-texture-12";
	public static const TEXTURE_21:String = "Normalmap-texture-21";
	public static const WIRE_1:String = "Wire-1";

	private var _id:String;
	private var _vertexProgram:String;
	private var _fragmentProgram:String;
	private var _program3D:Program3D;

	public function
	ProgramBase (id:String, vertexProgram:String = null, fragmentProgram:String = null)
	{
		_id = id;
		_vertexProgram = vertexProgram;
		_fragmentProgram = fragmentProgram;
	} // End of Constructor for ProgramBase.

	[Inline] public final function get id():String { return (_id); };
	[Inline] public final function get vertexProgram():String { return (_vertexProgram); };
	[Inline] public final function set vertexProgram (value:String):void { _vertexProgram = value; };
	[Inline] public final function get fragmentProgram():String { return (_fragmentProgram); };
	[Inline] public final function set fragmentProgram (value:String):void { _fragmentProgram = value; };
	[Inline] public final function get program3D():Program3D { return (_program3D); };
	[Inline] public final function set program3D (value:Program3D):void { _program3D = value; };

	public function
	toString()
	:String
	{
		return (_id + "\n" + _vertexProgram + "\n----------\n" + _fragmentProgram);
	} // End of toString().

} // End of ProgramBase Class.

} // End of Package Declaration.