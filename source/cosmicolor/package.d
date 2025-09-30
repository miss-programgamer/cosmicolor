module cosmicolor;

import std.format : format;
import std.process : environment;
import std.range;
import std.stdio;
import std.traits;

import cosmicolor.parser;

const bool enable_color;

/** 
 * Behaves the same as $(D writef) except for colorizing its output.
 * 
 * Params:
 *   fmt = The format string. When passed as a compile-time argument, it will be parsed & statically checked against the types of items to write.
 *   args = Items to write.
 */
void cwritef(alias fmt, A...)(A args)
	if (isSomeString!(typeof(fmt)))
{
	if (enable_color)
	{
		enum cfmt = parseFmt(true, fmt);
		args[0].writef!cfmt(args[1 .. $]);
	}
	else
	{
		enum cfmt = parseFmt(false, fmt);
		args[0].writef!cfmt(args[1 .. $]);
	}
}

/** ditto */
void cwritef(Char, A...)(in Char[] fmt, A args)
	if (isSomeString!(Char[]))
{ writef(parseFmt(enable_color, fmt), args); }

/** ditto */
void cwritef(Char, A...)(File file, in Char[] fmt, A args)
	if (isSomeString!(Char[]))
{ file.writef(parseFmt(enable_color, fmt), args); }

/** 
 * Behaves the same as $(D writefln) except for colorizing its output.
 * 
 * Params:
 *   fmt = The format string. When passed as a compile-time argument, it will be parsed & statically checked against the types of items to write.
 *   args = Items to write.
 */
void cwritefln(alias fmt, A...)(A args)
	if (isSomeString!(typeof(fmt)))
{
	if (enable_color)
	{
		enum cfmt = parseFmt(true, fmt);
		writefln!cfmt(args);
	}
	else
	{
		enum cfmt = parseFmt(false, fmt);
		writefln!cfmt(args);
	}
}

/** ditto */
void cwritefln(alias fmt, A...)(File file, A args)
	if (isSomeString!(typeof(fmt)))
{
	if (enable_color)
	{
		enum cfmt = parseFmt(true, fmt);
		file.writefln!cfmt(args[1 .. $]);
	}
	else
	{
		enum cfmt = parseFmt(false, fmt);
		file.writefln!cfmt(args[1 .. $]);
	}
}

/** ditto */
void cwritefln(Char, A...)(in Char[] fmt, A args)
	if (isSomeString!(Char[]))
{ writefln(parseFmt(enable_color, fmt), args); }

/** ditto */
void cwritefln(Char, A...)(File file, in Char[] fmt, A args)
	if (isSomeString!(Char[]))
{ file.writefln(parseFmt(enable_color, fmt), args); }

/** 
 * Colorizes a format string and applies the given items to it.
 * 
 * Params:
 *   fmt = The format string. When passed as a compile-time argument, it will be parsed & statically checked against the types of items to write.
 *   args = Items to write.
 * 
 * Returns: the formatted and colorized string.
 */
auto cformat(alias fmt, A...)(A args)
	if (isSomeString!(typeof(fmt)))
{ return format!(parseFmt(enable_color, fmt))(args); }

/** ditto */
auto cformat(Char, A...)(in Char[] fmt, A args)
	if (isSomeString!(Char[]))
{ return format(parseFmt(enable_color, fmt), args); }

shared static this()
{
	enable_color = environment.get("NO_COLOR", "").empty;

	version (Windows)
	{
		import core.sys.windows.windows;

		enable_color = enable_color
			&& isCharFile(STD_OUTPUT_HANDLE)
			&& isCharFile(STD_ERROR_HANDLE);

		if (!isVirtualTerminal(STD_OUTPUT_HANDLE))
		{ cast(void) setVirtualTerminal(STD_OUTPUT_HANDLE); }

		if (!isVirtualTerminal(STD_ERROR_HANDLE))
		{ cast(void) setVirtualTerminal(STD_ERROR_HANDLE); }
	}
	else version (Posix)
	{
		import core.sys.posix.unistd;

		enable_color = enable_color
			&& isatty(STDOUT_FILENO)
			&& isatty(STDERR_FILENO);
	}
}

version (Windows)
{
	import core.sys.windows.windows;

	private bool isCharFile(in DWORD nStdHandle)
	{
		if (auto hstdout = GetStdHandle(nStdHandle))
		{ return GetFileType(hstdout) == FILE_TYPE_CHAR; }

		return false;
	}

	private bool isVirtualTerminal(in DWORD nStdHandle)
	{
		if (const hConsoleHandle = GetStdHandle(nStdHandle))
		{
			DWORD mode;

			if (GetConsoleMode(cast(HANDLE) hConsoleHandle, &mode))
			{ return (mode & ENABLE_VIRTUAL_TERMINAL_PROCESSING) > 0; }
		}

		return false;
	}

	private bool setVirtualTerminal(in DWORD nStdHandle)
	{
		if (const hConsoleHandle = GetStdHandle(nStdHandle))
		{
			enum flag = ENABLE_VIRTUAL_TERMINAL_PROCESSING;
			return cast(bool) SetConsoleMode(cast(HANDLE) hConsoleHandle, flag);
		}

		return false;
	}
}
