package com.sss.threed 
{
import flash.display3D.textures.TextureBase;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-22
*/
public final class TextureController
{
	private static const DIFFUSE:uint = 0;
	private static const NORMAL:uint = 1;
	private static const SPECULAR:uint = 2;
	private var texMaps:Array;

	public function
	TextureController()
	{
		texMaps = new Array (3);
	} // End of Constructor for TextureMap.

	public function
	dispose()
	:void
	{
		for each (var texture:TextureBase in texMaps) {
			if (texture != null) {
				texture.dispose(); // Release GPU resources.
				texture = null;
			}
		}
		texMaps = null;
	} // End of dispose().

	[Inline] public final function get diffuse():TextureBase { return (texMaps[DIFFUSE]); };
	[Inline] public final function set diffuse (value:TextureBase):void { texMaps[DIFFUSE] = value; };
	[Inline] public final function get normal():TextureBase { return (texMaps[NORMAL]); };
	[Inline] public final function set normal (value:TextureBase):void { texMaps[NORMAL] = value; };
	[Inline] public final function get specular():TextureBase { return (texMaps[SPECULAR]); };
	[Inline] public final function set specular (value:TextureBase):void { texMaps[SPECULAR] = value; };

} // End of TextureMap Class.

} // End of Package Declaration.