module goldpot;

import std.array;
import std.ascii;
import std.format;
import std.process;
import std.range;
import std.stdio;
import std.traits;

const bool enable_color;

void cwritef(alias fmt, A...)(A args) if (isSomeString!(typeof(fmt)))
{
	static if (is(T[0] : File))
	{
		args[0].writef!fmt(args[1 .. $]);
	}
	else
	{
		writef!fmt(args);
	}
}

void cwritef(Char, A...)(in Char[] fmt, A args) if (isSomeString!(Char[]))
{
	static if (is(T[0] : File))
	{
		args[0].writef(fmt, args[1 .. $]);
	}
	else
	{
		writef(fmt, args);
	}
}

void cwritefln(alias fmt, A...)(A args) if (isSomeString!(typeof(fmt)))
{
	static if (is(T[0] : File))
	{
		args[0].writefln!fmt(args[1 .. $]);
	}
	else
	{
		writefln!fmt(args);
	}
}

void cwritefln(Char, A...)(in Char[] fmt, A args) if (isSomeString!(Char[]))
{
	static if (is(T[0] : File))
	{
		args[0].writefln(fmt, args[1 .. $]);
	}
	else
	{
		writefln(fmt, args);
	}
}

shared static this()
{
	if (!environment.get("NO_COLOR", "").empty)
	{
		enable_color = false;
		return;
	}
	else
	{
		version (Windows)
		{
			import core.sys.windows.windows;

			enable_color = isStdHandleCharFile(STD_OUTPUT_HANDLE)
				&& isStdHandleCharFile(STD_ERROR_HANDLE);
		}
		else version (Posix)
		{
			import core.sys.posix.unistd;

			enable_color = isatty(STDOUT_FILENO)
				&& isatty(STDERR_FILENO);
		}
	}
}

version (Windows)
{
	import core.sys.windows.windows;

	bool isStdHandleCharFile(in DWORD nStdHandle)
	{
		if (auto hstdout = GetStdHandle(nStdHandle))
		{
			if (GetFileType(hstdout) == FILE_TYPE_CHAR)
			{
				DWORD mode;
				return GetConsoleMode(hstdout, &mode)
					&& SetConsoleMode(hstdout, mode & ENABLE_VIRTUAL_TERMINAL_PROCESSING);
			}
		}

		return false;
	}
}
