import std.stdio;
import cosmicolor;

void main()
{
	if (enable_color)
	{
		writeln("\x1B[31mEdit\x1B[0m source/app.d to start your project.");
	}
	else
	{
		writeln("Edit source/app.d to start your project.");
	}
}
