module cosmicolor;

import std.format : format;
import std.stdio;
import std.traits;

import cosmicolor.parser;

/** 
 * Whether the environment supports color & the user wants them.
 * 
 * On Unix platforms, this is checked using `isatty` and `NO_COLOR`.
 * 
 * On Windows, the library tries to enable virtual terminal processing to
 *   enable ANSI escape sequences. That is, if the output stream is determined
 *   to be `FILE_TYPE_CHAR` and `NO_COLOR` is not set, of course.
 */
const bool enable_color;

/** 
 * Behaves the same as $(D writef) except for colorizing its output.
 * 
 * Params:
 *   fmt = The format string. When passed as a compile-time argument, it will be parsed & statically checked against the types of items to write.
 *   args = Items to write.
 */
void cwritef(alias fmt, A...)(A args) @safe
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
void cwritef(Char, A...)(in Char[] fmt, A args) @safe
	if (isSomeString!(Char[]))
{ writef(parseFmt(enable_color, fmt), args); }

/** ditto */
void cwritef(Char, A...)(File file, in Char[] fmt, A args) @safe
	if (isSomeString!(Char[]))
{ file.writef(parseFmt(enable_color, fmt), args); }

/** 
 * Behaves the same as $(D writefln) except for colorizing its output.
 * 
 * Params:
 *   fmt = The format string. When passed as a compile-time argument, it will be parsed & statically checked against the types of items to write.
 *   args = Items to write.
 */
void cwritefln(alias fmt, A...)(A args) @safe
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
void cwritefln(alias fmt, A...)(File file, A args) @safe
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
void cwritefln(Char, A...)(in Char[] fmt, A args) @safe
	if (isSomeString!(Char[]))
{ writefln(parseFmt(enable_color, fmt), args); }

/** ditto */
void cwritefln(Char, A...)(File file, in Char[] fmt, A args) @safe
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
auto cformat(alias fmt, A...)(A args) @safe
	if (isSomeString!(typeof(fmt)))
{ return format!(parseFmt(enable_color, fmt))(args); }

/** ditto */
auto cformat(Char, A...)(in Char[] fmt, A args) @safe
	if (isSomeString!(Char[]))
{ return format(parseFmt(enable_color, fmt), args); }

shared static this() @trusted
{
	import std.process : environment;
	import std.range : empty;

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

		SetConsoleOutputCP(CP_UTF8);
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
			enum flags = ENABLE_VIRTUAL_TERMINAL_PROCESSING | ENABLE_PROCESSED_OUTPUT;
			return cast(bool) SetConsoleMode(cast(HANDLE) hConsoleHandle, flags);
		}

		return false;
	}
}
