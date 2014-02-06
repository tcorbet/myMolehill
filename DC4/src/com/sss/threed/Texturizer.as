package com.sss.threed
{
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.display3D.Context3D;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.RectangleTexture;
import flash.geom.Matrix;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.FontPosture;
import flash.text.engine.RenderingMode;
import flash.text.engine.TextBaseline;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.utils.Dictionary;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-20
*/
public final class Texturizer
{
	private var mipMaps:Dictionary;
	private var textB:TextBlock;
	private var fontD:FontDescription;
	private var xAdjust:Number, yAdjust:Number;
	private var fontColor:uint;
	private var fillColor:uint;

	public function
	Texturizer (context3D:Context3D, text:String, width:Number, height:Number,
		xAdjust:Number = 1.0, yAdjust:Number = 1.0,
		fontColor:uint = 0x702020, fillColor:uint = 0xfff0f0f0)
	{
		this.xAdjust = xAdjust;
		this.yAdjust = yAdjust;
		this.fontColor = fontColor;
		this.fillColor = fillColor;

		mipMaps = new Dictionary();

		const numToBuild:uint = 9;
		const magnifier:Number = 1.25; // Rate of growth/decay; somewhat trial and error.
		var cume:Number = Math.pow (magnifier, (numToBuild - Math.ceil (numToBuild / 2.0)));
		var thisW:Number = (2.0 * width * cume);
		var thisH:Number = (2.0 * height * cume);
		const baseTextSize:Number = 40.0;  // Selected font size at mid zoom.
		var thisTextSize:Number = (baseTextSize * cume);
		var idx:uint = numToBuild;
		do {
			var tex:RectangleTexture = context3D.createRectangleTexture (
				thisW, thisH, Context3DTextureFormat.BGRA, false);
			mipMaps[idx] = tex;
			tex.uploadFromBitmapData (paintText (thisW, thisH, thisTextSize, (text + "; " + idx)));
			thisW /= magnifier;
			thisH /= magnifier;
			thisTextSize /= magnifier;
		} while (--idx > 0);
	} // End of Constructor for Texturizer.

	public function
	dispose()
	:void
	{
		for (var key:String in mipMaps) {
			var texture:RectangleTexture = (mipMaps[key] as RectangleTexture);
			texture.dispose(); // Release GPU resources.
			delete mipMaps[key];
			// trace ("Texture", key, "disposed.");
		}
	} // End of dispose().

	public function
	getMap (size:uint)
	:RectangleTexture
	{
		return (mipMaps[size] as RectangleTexture);
	} // End of.

	private function
	paintText (thisW:Number, thisH:Number, thisTextSize:Number, text:String)
	:BitmapData
	{
		var buf:Sprite = new Sprite();
		if (textB == null) {
			textB = new TextBlock();
			textB.applyNonLinearFontScaling = true
			fontD = new FontDescription();
			fontD.fontLookup = FontLookup.EMBEDDED_CFF;
			fontD.fontName = "Palatino_BI_4";
			fontD.fontPosture = FontPosture.ITALIC;
			fontD.renderingMode = RenderingMode.CFF;
		}
		var ef:ElementFormat = new ElementFormat (fontD);
		ef.color = fontColor;
		ef.fontSize = thisTextSize;
		ef.dominantBaseline = TextBaseline.IDEOGRAPHIC_CENTER;

		textB.content =  new TextElement (text, ef);
		var lineX:Number = 0.0;
		var lineY:Number = 0.0;
		var prevL:TextLine = null;
		while (true) {
			var tl:TextLine = textB.createTextLine (prevL, 1000); // Beware of this width.
			prevL = tl;
			if (tl == null) break;
			if (tl.hasTabs) {
				lineX += thisTextSize;
				lineY = (thisTextSize * 0.6);
				continue;
			}
			tl.x = lineX;
			tl.y = lineY;
			lineY += (thisTextSize * 0.6);
			buf.addChild (tl);
		}
		textB.releaseLineCreationData();

		var bmd:BitmapData = new BitmapData (thisW, thisH, true, (fillColor | 0xff000000));

		var mat:Matrix = new Matrix();
		// These x-y adjustments depend entirely upon the use case.
		mat.translate ((thisTextSize * xAdjust), (thisTextSize * yAdjust));
		bmd.drawWithQuality (buf, mat, null, null, null, true, StageQuality.BEST);
		trace ("Created Mip '", text.substr (0, 10), "' Width", thisW, "Height", thisH, "Text Size", thisTextSize);
		return (bmd);
	} // End of paintText().

} // End of Texturizer Class.

} // End of Package Declaration.
