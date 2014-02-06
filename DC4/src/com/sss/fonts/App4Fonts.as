/*
** Copyright (c) - 2014
** Systems Strategies & Solutions (S), Pte. Ltd.
** All Rights Reserved under international copyright laws.
*/
package com.sss.fonts
{
import flash.text.Font;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-17
*/
public final class App4Fonts
{
	public function
	App4Fonts()
	{
		super();
	} // End of Constructor for App4Fonts.

	[Embed (source = "C:/Windows/Fonts/pala.ttf", fontName="Palatino_RG_4",
		fontStyle = "regular",
		fontWeight = "normal",
		mimeType = "application/x-font",
		embedAsCFF = true,
		unicodeRange = "U+0021-U+00ff, U+2212-U+2212")]
	public const Palatino_RG_4:Class;

	[Embed (source = "C:/Windows/Fonts/palab.ttf", fontName="Palatino_BD_4",
		fontStyle = "regular",
		fontWeight = "bold",
		mimeType = "application/x-font",
		embedAsCFF = true,
		unicodeRange = "U+0021-U+00ff, U+2212-U+2212")]
	public const Palatino_BD_4:Class;

	[Embed (source = "C:/Windows/Fonts/palai.ttf", fontName="Palatino_IT_4",
		fontStyle = "italic",
		fontWeight = "normal",
		mimeType = "application/x-font",
		embedAsCFF = true,
		unicodeRange = "U+0021-U+00ff")]
	public const Palatino_IT_4:Class;

	[Embed (source = "C:/Windows/Fonts/palabi.ttf", fontName="Palatino_BI_4",
		fontStyle = "italic",
		fontWeight = "bold",
		mimeType = "application/x-font",
		embedAsCFF = true,
		unicodeRange = "U+0021-U+00ff")]
	public const Palatino_BI_4:Class;

} // End of App4Fonts Class.

} // End of Packgage Declaration.