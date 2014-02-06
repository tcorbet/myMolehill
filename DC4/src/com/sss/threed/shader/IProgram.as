package com.sss.threed.shader 
{
import flash.display3D.Program3D;

/**
** @author J. Terry Corbet
** @version 1.0 2013-12-07
*/
public interface IProgram 
{
	function get id():String;
	function get vertexProgram():String;
	function set vertexProgram (value:String):void;
	function get fragmentProgram():String;
	function set fragmentProgram (value:String):void;
	function get program3D():Program3D;
	function set program3D (value:Program3D):void;
} // End of IProgram Interface.
	
}  // End of Package Declaration.