module cosmicolor.rendition;

import std.typecons;


package enum Rendition
{
	Reset = 0,

	Bold = 1,
	Faint = 2,
	Italic = 3,
	Underline = 4,
	BlinkSlow = 5,
	BlinkFast = 6,
	Invert = 7,
	Conceal = 8,
	Strike = 9,

	NotBold = 22,
	NotItalic = 23,
	NotUnderline = 24,
	NotBlink = 25,
	NotInvert = 27,
	NotConceal = 28,
	NotStrike = 29,

	// Font control

	FgBlack = 30,
	FgRed = 31,
	FgGreen = 32,
	FgOrange = 33,
	FgBlue = 34,
	FgMagenta = 35,
	FgCyan = 36,
	FgLGrey = 37,

	FgNone = 39,

	BgBlack = 40,
	BgRed = 41,
	BgGreen = 42,
	BgOrange = 43,
	BgBlue = 44,
	BgMagenta = 45,
	BgCyan = 46,
	BgLGrey = 47,

	BgNone = 49,

	FgGrey = 90,
	FgLRed = 91,
	FgLGreen = 92,
	FgYellow = 93,
	FgLBlue = 94,
	FgLMagenta = 95,
	FgLCyan = 96,
	FgWhite = 97,

	BgGrey = 100,
	BgLRed = 101,
	BgLGreen = 102,
	BgYellow = 103,
	BgLBlue = 104,
	BgLMagenta = 105,
	BgLCyan = 106,
	BgWhite = 107,
}

package enum FgColor
{
	Black = 30,
	Red = 31,
	Green = 32,
	Orange = 33,
	Blue = 34,
	Magenta = 35,
	Cyan = 36,
	LGrey = 37,

	None = 39,

	Grey = 90,
	LRed = 91,
	LGreen = 92,
	Yellow = 93,
	LBlue = 94,
	LMagenta = 95,
	LCyan = 96,
	White = 97,
}

package enum BgColor
{
	Black = 40,
	Red = 41,
	Green = 42,
	Orange = 43,
	Blue = 44,
	Magenta = 45,
	Cyan = 46,
	LGrey = 47,

	None = 49,

	Grey = 100,
	LRed = 101,
	LGreen = 102,
	Yellow = 103,
	LBlue = 104,
	LMagenta = 105,
	LCyan = 106,
	White = 107,
}

package Nullable!Rendition renditionFromTagName(Char)(in Char[] tag) @safe
{
	final switch (tag)
	{
		case "b":
			return Rendition.Bold.nullable;
		case "i":
			return Rendition.Italic.nullable;
		case "u":
			return Rendition.Underline.nullable;
		case "s":
			return Rendition.Strike.nullable;

		case "black":
			return Rendition.FgBlack.nullable;
		case "red":
			return Rendition.FgRed.nullable;
		case "green":
			return Rendition.FgGreen.nullable;
		case "orange":
			return Rendition.FgOrange.nullable;
		case "blue":
			return Rendition.FgBlue.nullable;
		case "magenta":
			return Rendition.FgMagenta.nullable;
		case "cyan":
			return Rendition.FgCyan.nullable;
		case "lgrey":
			return Rendition.FgLGrey.nullable;

		case "bg_black":
			return Rendition.BgBlack.nullable;
		case "bg_red":
			return Rendition.BgRed.nullable;
		case "bg_green":
			return Rendition.BgGreen.nullable;
		case "bg_orange":
			return Rendition.BgOrange.nullable;
		case "bg_blue":
			return Rendition.BgBlue.nullable;
		case "bg_magenta":
			return Rendition.BgMagenta.nullable;
		case "bg_cyan":
			return Rendition.BgCyan.nullable;
		case "bg_lgrey":
			return Rendition.BgLGrey.nullable;

		case "grey":
			return Rendition.FgGrey.nullable;
		case "lred":
			return Rendition.FgLRed.nullable;
		case "lgreen":
			return Rendition.FgLGreen.nullable;
		case "yellow":
			return Rendition.FgYellow.nullable;
		case "lblue":
			return Rendition.FgLBlue.nullable;
		case "lmagenta":
			return Rendition.FgLMagenta.nullable;
		case "lcyan":
			return Rendition.FgLCyan.nullable;
		case "white":
			return Rendition.FgWhite.nullable;

		case "bg_grey":
			return Rendition.BgGrey.nullable;
		case "bg_lred":
			return Rendition.BgLRed.nullable;
		case "bg_lgreen":
			return Rendition.BgLGreen.nullable;
		case "bg_yellow":
			return Rendition.BgYellow.nullable;
		case "bg_lblue":
			return Rendition.BgLBlue.nullable;
		case "bg_lmagenta":
			return Rendition.BgLMagenta.nullable;
		case "bg_lcyan":
			return Rendition.BgLCyan.nullable;
		case "bg_white":
			return Rendition.BgWhite.nullable;
	}
}

package Nullable!FgColor fgColorFromRendition(Rendition rendition) @safe
{
	if (rendition >= 30 && rendition < 38)
	{ return nullable(cast(FgColor) rendition); }
	else if (rendition >= 90 && rendition < 98)
	{ return nullable(cast(FgColor) rendition); }

	return Nullable!FgColor.init;
}

package Nullable!BgColor bgColorFromRendition(Rendition rendition) @safe
{
	if (rendition >= 40 && rendition < 48)
	{ return nullable(cast(BgColor) rendition); }
	else if (rendition >= 100 && rendition < 108)
	{ return nullable(cast(BgColor) rendition); }

	return Nullable!BgColor.init;
}
