module cosmicolor.parser;

import std.algorithm;
import std.algorithm.searching;
import std.array;
import std.ascii;
import std.format;
import std.range.primitives;
import std.traits;

import cosmicolor.rendition;


package auto parseFmt(Char)(in bool enable_color, in Char[] fmt)
{
	return Parser!Char(enable_color).parseFmt(fmt);
}


package struct Parser(Char) if (isSomeString!(Char[]))
{
	private bool enable_color;

	private Expect expect;

	private Appender!(Char[]) content;

	private Appender!(Char[]) result;

	private FgColor[] foregrounds;

	private BgColor[] backgrounds;

	private int bold_count;

	private int italic_count;

	private int underline_count;

	private int strike_count;


	this(in bool enable_color)
	{
		this.enable_color = enable_color;
		foregrounds = [];
		backgrounds = [];
	}

	Char[] parseFmt(in Char[] fmt)
	{
		foreach (c; fmt)
		{
			final switch (expect)
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
		content.clear();

		if (!foregrounds.empty || !backgrounds.empty || bold_count || italic_count || underline_count || strike_count)
		writeEscapeCode(0);

		return result[];
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
		if (c.isAlpha || c == '_' || (c == '/' && content[] == "<"))
		{
			content ~= c;
		}
		else if (c == '>')
		{
			handleTagValue(content[] ~ c);
			expect = Expect.Text;
			content.clear();
		}
		else
		{
			result ~= content[] ~ c;
			expect = Expect.Text;
			content.clear();
		}
	}

	private void handleEsc(Char c)
	{
		if (c.isAlpha)
		{
			content ~= c;
		}
		else if (c == ';')
		{
			handleEscValue(content[] ~ c);
			expect = Expect.Text;
			content.clear();
		}
		else
		{
			result ~= content[] ~ c;
			expect = Expect.Text;
			content.clear();
		}
	}

	private void handleTagValue(Char[] tag)
	{
		final switch (tagPair(tag))
		{
			case TagPair.Opening:
				if (auto rend = renditionFromTagName(tag))
				{
					if (auto fg = fgColorFromRendition(rend.get))
					{
						const foreground = fg.get;
						writeEscapeCode(foreground);
						foregrounds = foregrounds ~ [foreground];
					}
					else if (auto bg = bgColorFromRendition(rend.get))
					{
						const background = bg.get;
						writeEscapeCode(background);
						backgrounds = backgrounds ~ [background];
					}
					else
					{
						writeEscapeCode(rend.get);

						switch (rend.get)
						{
							case Rendition.Bold:
								bold_count += 1;
								break;

							case Rendition.Italic:
								italic_count += 1;
								break;

							case Rendition.Underline:
								underline_count += 1;
								break;

							case Rendition.Strike:
								strike_count += 1;
								break;

							default:
								break;
						}
					}
				}
				break;

			case TagPair.Closing:
				if (auto rend = renditionFromTagName(tag))
				{
					if (auto color = fgColorFromRendition(rend.get))
					{
						if (!foregrounds.empty)
						{
							foregrounds.popBack();

							if (!foregrounds.empty)
							{ writeEscapeCode(foregrounds.back); }
							else
							{ writeEscapeCode(FgColor.FgNone); }
						}
					}
					else if (auto color = bgColorFromRendition(rend.get))
					{
						if (!backgrounds.empty)
						{
							backgrounds.popBack();

							if (!backgrounds.empty)
							{ writeEscapeCode(backgrounds.back); }
							else
							{ writeEscapeCode(BgColor.BgNone); }
						}
					}
					else
					{
						switch (rend.get)
						{
							case Rendition.Bold:
								if (bold_count)
								{
									bold_count -= 1;
									if (!bold_count)
									{ writeEscapeCode(Rendition.NotBold); }
								}
								break;

							case Rendition.Italic:
								if (italic_count)
								{
									italic_count -= 1;
									if (!italic_count)
									{ writeEscapeCode(Rendition.NotItalic); }
								}
								break;

							case Rendition.Underline:
								if (underline_count)
								{
									underline_count -= 1;
									if (!underline_count)
									{ writeEscapeCode(Rendition.NotUnderline); }
								}
								break;

							case Rendition.Strike:
								if (strike_count)
								{
									strike_count -= 1;
									if (!strike_count)
									{ writeEscapeCode(Rendition.NotStrike); }
								}
								break;

							default:
								break;
						}
					}
				}
				break;
		}
	}

	private void handleEscValue(Char[] esc)
	{
		switch (esc)
		{
			case "&lt;":
				result ~= "<";
				break;

			case "&gt;":
				result ~= ">";
				break;

			case "&amp;":
				result ~= "&";
				break;

			default:
				result ~= esc;
				break;
		}
	}

	private void writeEscapeCode(T)(T code)
	{
		if (enable_color)
		{ result ~= format!"\x1B[%dm"(code); }
	}

	private static TagPair tagPair(Char)(ref Char[] tag)
	{
		if (tag.startsWith("</"))
		{
			tag = tag[2 .. $ - 1];
			return TagPair.Closing;
		}
		else
		{
			tag = tag[1 .. $ - 1];
			return TagPair.Opening;
		}
	}

	private enum TagPair
	{
		Opening,
		Closing,
	}

	private enum Expect
	{
		Text,
		Tag,
		Esc
	}
}

@"Opening and closing color tags works."
unittest
{
	import fluentasserts.core.base;

	auto result = parseFmt(true, "<red>Foo</red>");

	expect(cast(char[]) result)
		.equal(cast(char[]) "\x1B[31mFoo\x1B[39m");
}

@"Opening and closing multiple color tags works."
unittest
{
	import fluentasserts.core.base;

	auto result = parseFmt(true, "<red><blue><orange>Foo</orange></blue></red>");

	expect(cast(ubyte[]) result)
		.equal(cast(ubyte[]) "\x1B[31m\x1B[34m\x1B[33mFoo\x1B[34m\x1B[31m\x1B[39m");
}