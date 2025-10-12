module cosmicolor;

import std.format : format;
import std.stdio;
import std.traits;

import cosmicolor.parser;

/** 
 * Whether STDOUT supports colors & the user wants them.
 * 
 * On Unix platforms, this is checked using `isatty` and `$NO_COLOR`.
 * 
 * On Windows, the library tries to enable virtual terminal processing to
 *   enable ANSI escape sequences. That is, if the output stream is determined
 *   to be `FILE_TYPE_CHAR` and `$env:NO_COLOR` is not set, of course.
 */
const bool enable_color_out;

/** 
 * Whether STDERR supports colors & the user wants them.
 * 
 * On Unix platforms, this is checked using `isatty` and `$NO_COLOR`.
 * 
 * On Windows, the library tries to enable virtual terminal processing to
 *   enable ANSI escape sequences. That is, if the output stream is determined
 *   to be `FILE_TYPE_CHAR` and `$env:NO_COLOR` is not set, of course.
 */
const bool enable_color_err;

/** 
 * Behaves the same as $(D writef) except for colorizing its output.
 * 
 * Params:
 *   fmt = The format string. When passed as a compile-time argument, it will be parsed & statically checked against the types of items to write.
 *   args = Items to write.
 */
void cwritef(alias fmt, A...)(A args) @safe
	if (isSomeString!(typeof(fmt)) && !is(A[0] : File))
{
	if (enable_color_out)
	{
		enum cfmt = parseFmt(true, fmt);
		writef!cfmt(args);
	}
	else
	{
		enum cfmt = parseFmt(false, fmt);
		writef!cfmt(args);
	}
}

/** ditto */
void cwritef(alias fmt, A...)(File file, A args) @safe
	if (isSomeString!(typeof(fmt)))
{
	if (file.enable_color)
	{
		enum cfmt = parseFmt(true, fmt);
		file.writef!cfmt(args);
	}
	else
	{
		enum cfmt = parseFmt(false, fmt);
		file.writef!cfmt(args);
	}
}

/** ditto */
void cwritef(Char, A...)(in Char[] fmt, A args) @safe
	if (isSomeString!(typeof(fmt)) && !is(A[0] : File))
{
	auto cfmt = parseFmt(enable_color_out, fmt);
	writef(cfmt, args);
}

/** ditto */
void cwritef(Char, A...)(File file, in Char[] fmt, A args) @safe
	if (isSomeString!(typeof(fmt)))
{
	auto cfmt = parseFmt(file.enable_color, fmt);
	file.writef(cfmt, args);
}

/** 
 * Behaves the same as $(D writefln) except for colorizing its output.
 * 
 * Params:
 *   fmt = The format string. When passed as a compile-time argument, it will be parsed & statically checked against the types of items to write.
 *   args = Items to write.
 */
void cwritefln(alias fmt, A...)(A args) @safe
	if (isSomeString!(typeof(fmt)) && !is(A[0] : File))
{
	if (enable_color_out)
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
	if (file.enable_color)
	{
		enum cfmt = parseFmt(true, fmt);
		file.writefln!cfmt(args);
	}
	else
	{
		enum cfmt = parseFmt(false, fmt);
		file.writefln!cfmt(args);
	}
}

/** ditto */
void cwritefln(Char, A...)(in Char[] fmt, A args) @safe
	if (isSomeString!(typeof(fmt)) && !is(A[0] : File))
{
	auto cfmt = parseFmt(enable_color_out, fmt);
	writefln(cfmt, args);
}

/** ditto */
void cwritefln(Char, A...)(File file, in Char[] fmt, A args) @safe
	if (isSomeString!(typeof(fmt)))
{
	auto cfmt = parseFmt(file.enable_color, fmt);
	file.writefln(cfmt, args);
}

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
{
	enum cfmt = parseFmt(enable_color, fmt);
	return format!cfmt(args);
}

/** ditto */
auto cformat(Char, A...)(in Char[] fmt, A args) @safe
	if (isSomeString!(typeof(fmt)))
{
	auto cfmt = parseFmt(enable_color, fmt);
	return format(cfmt, args);
}

/** 
 * Check whether colors should be enabled for a given file.
 * 
 * Params:
 *   file = The file to check.
 * 
 * Returns: whether the file should receive colored output.
 */
private @property bool enable_color(File file) @trusted
{
	version (Windows)
	{
		if (file.windowsHandle == GetStdHandle(STD_ERROR_HANDLE))
		{ return enable_color_err; }
		else
		{ return enable_color_out; }
	}
	else version (Posix)
	{
		import core.sys.posix.stdio;
		import core.sys.posix.unistd;

		if (file.fileno == STDERR_FILENO)
		{ return enable_color_err; }
		else
		{ return enable_color_out; }
	}
}

shared static this() @trusted
{
	import std.process : environment;
	import std.range : empty;

	const no_color = !environment.get("NO_COLOR", "").empty;

	enable_color_out = !no_color;
	enable_color_err = !no_color;

	version (Windows)
	{
		import core.sys.windows.windows;

		enable_color_out &= isCharFile(STD_OUTPUT_HANDLE);
		enable_color_err &= isCharFile(STD_ERROR_HANDLE);

		if (!isVirtualTerminal(STD_OUTPUT_HANDLE))
		{ cast(void) setVirtualTerminal(STD_OUTPUT_HANDLE); }

		if (!isVirtualTerminal(STD_ERROR_HANDLE))
		{ cast(void) setVirtualTerminal(STD_ERROR_HANDLE); }

		SetConsoleOutputCP(CP_UTF8);
	}
	else version (Posix)
	{
		import core.sys.posix.unistd;

		enable_color_out &= isatty(STDOUT_FILENO);
		enable_color_err &= isatty(STDERR_FILENO);
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
