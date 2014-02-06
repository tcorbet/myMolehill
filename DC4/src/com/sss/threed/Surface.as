package com.sss.threed 
{
import com.sss.threed.Texturizer;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-19
*/
public final class Surface
{
	private var _id:String;
	private var _offset:uint;
	private var _programID:String;
	private var _material:*;
	private var _visible:Boolean;
	private var _datum:*;
	private var _idx:uint;

	public function
	Surface (id:String, offset:uint, programID:String = null, material:* = null)
	{
		_id = id;
		_offset = offset;
		_programID = programID;
		_material = material;
		_visible = true;
		_idx = 0;
	} // End of Constructor for Surface.

	public function
	dispose()
	:void
	{
		if (_material is Texturizer) (_material as Texturizer).dispose();
		_material = null;
	} // End of dispose().

	public function
	clone()
	:Surface
	{
		var copy:Surface = new Surface (_id, _offset, _programID, _material);
		copy.visible = _visible;
		copy.idx = _idx;
		return (copy);
	} // End of clone().

	[Inline] public final function get id():String { return (_id); };
	[Inline] public final function get offset():uint { return (_offset); };
	[Inline] public final function get programID():String { return (_programID); };
	[Inline] public final function set programID (value:String):void { _programID = value; };
	[Inline] public final function get material():* { return (_material); };
	[Inline] public final function set material (value:*):void { _material = value; };
	[Inline] public final function get visible():Boolean { return (_visible); };
	[Inline] public final function set visible (value:Boolean):void { _visible = value; };
	[Inline] public final function set datum (value:*):void { _datum = value; };
	[Inline] public final function get datum():* { return (_datum); };
	[Inline] public final function get idx():uint { return (_idx); };
	[Inline] public final function set idx (value:uint):void { _idx = value; };
	[Inline] public final function get numTriangles():uint { return (_idx / 3); };

	public function
	toString()
	:String
	{
		return (_id + " " + _programID + " " + numTriangles);
	} // End of toString().

} // End of Surface Class.

} // End of Package Declaration.