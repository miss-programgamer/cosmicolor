module cosmicolor.parser;

import std.range.primitives;
import std.typecons;

import cosmicolor : enable_color;
import std.algorithm.searching;
import std.stdio;

package struct Parser(Char) if (isSomeString!(Char[]))
{
	private Expect expect;

	private Appender!(Char[]) content;

	private Appender!(Char[]) result;

	private FgColor[] foregrounds;

	private BgColor[] backgrounds;

	private int bold_count;

	private int italic_count;

	private int underline_count;

	private int strike_count;

	this()
	{
		expect = Expect.Text;
		foregrounds = [];
		backgrounds = [];
		bold_count = 0;
		italic_count = 0;
		underline_count = 0;
		strike_count = 0;
	}

	Char[] parseFmt(in Char[] fmt)
	{
		foreach (c; fmt)
		{
			switch (expect)
			{
				case Expect.Text:
					handleText(c);
					break;

				case Expect.Tag:
					handleTag(c);
					break;

				case Expect.Esc:
					handleEsc(c);
					break;
			}
		}

		expect = Expect.Text;
		return content.toString();
	}

	private void handleText(Char c)
	{
		if (c == '<')
		{
			content ~= c;
			expect = Expect.Tag;
		}
		else if (c == '&')
		{
			content ~= c;
			expect = Expect.Esc;
		}
		else
		{
			result ~= c;
		}
	}

	private void handleTag(Char c)
	{
		if (c.isalpha || (c == '/' && content == "<"))
		{
			content ~= c;
		}
		else if (c == '>')
		{
			content ~= c;
			expect = Expect.Text;

			if (content.startsWith("</"))
			{
				auto tag = content[2 .. $ - 1];

				if (auto rendition = renditionFromTag(tag))
				{
					if (auto color = fgColorFromRendition(rendition.get))
					{
						if (!foregrounds.empty)
						{
							debug if (foregrounds.back != color.get)
							{
								stderr.writefln!"[Cosmicolor]: closing color tag mismatch (expected %s, got %s)"(
									foregrounds.back, color.get);
							}

							foregrounds.popBack();

							if (foregrounds.empty)
							{
								if (enable_color)
								{
									content ~= "\xB1[%sm".format();
								}
							}
						}
						else
						{
							debug
							{
								stderr.writefln!"[Cosmicolor]: unexpected closing tag (%s)"(
									color.get);
							}
						}
					}
					else if (auto color = bgColorFromRendition(rendition.get))
					{
						// 
					}
				}
			}
			else if (content.startsWith("<"))
			{
				auto tag = content[1 .. $ - 1];

				if (auto rendition = renditionFromTag(tag))
				{
					if (auto color = colorFromRendition(rendition.get))
					{

					}
				}
			}
		}
		else
		{
			content ~= c;
			result ~= content;
			expect = Expect.Text;
		}
	}

	private void handleEsc(Char c)
	{
		if (c.isalpha)
		{
			content ~= c;
		}
		else if (c == ';')
		{
			content ~= c;
			expect = Expect.Text;
		}
		else
		{
			content ~= c;
			result ~= content;
			expect = Expect.Text;
		}
	}
}

package enum Expect
{
	Text,
	Tag,
	Esc
}

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

	BgBlack = 40,
	BgRed = 41,
	BgGreen = 42,
	BgOrange = 43,
	BgBlue = 44,
	BgMagenta = 45,
	BgCyan = 46,
	BgLGrey = 47,

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
	FgBlack = 30,
	FgRed = 31,
	FgGreen = 32,
	FgOrange = 33,
	FgBlue = 34,
	FgMagenta = 35,
	FgCyan = 36,
	FgLGrey = 37,

	FgGrey = 90,
	FgLRed = 91,
	FgLGreen = 92,
	FgYellow = 93,
	FgLBlue = 94,
	FgLMagenta = 95,
	FgLCyan = 96,
	FgWhite = 97,
}

package enum BgColor
{
	BgBlack = 40,
	BgRed = 41,
	BgGreen = 42,
	BgOrange = 43,
	BgBlue = 44,
	BgMagenta = 45,
	BgCyan = 46,
	BgLGrey = 47,

	BgGrey = 100,
	BgLRed = 101,
	BgLGreen = 102,
	BgYellow = 103,
	BgLBlue = 104,
	BgLMagenta = 105,
	BgLCyan = 106,
	BgWhite = 107,
}

package Nullable!Rendition renditionFromTag(Char)(in Char[] tag)
{
	switch (tag)
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
			return Rendition.Fglblue.nullable;
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
			return Rendition.Bglblue.nullable;
		case "bg_lmagenta":
			return Rendition.BgLMagenta.nullable;
		case "bg_lcyan":
			return Rendition.BgLCyan.nullable;
		case "bg_white":
			return Rendition.BgWhite.nullable;
	}
}

package Nullable!FgColor fgColorFromRendition(Rendition rendition)
{
	if (rendition >= 30 && rendition < 38)
	{
		return nullable(cast(FgColor) rendition);
	}
	else if (rendition >= 90 && rendition < 98)
	{
		return nullable(cast(FgColor) rendition);
	}

	return Nullable!FgColor.init;
}

package Nullable!BgColor bgColorFromRendition(Rendition rendition)
{
	if (rendition >= 40 && rendition < 48)
	{
		return nullable(cast(BgColor) rendition);
	}
	else if (rendition >= 100 && rendition < 108)
	{
		return nullable(cast(BgColor) rendition);
	}

	return Nullable!BgColor.init;
}
