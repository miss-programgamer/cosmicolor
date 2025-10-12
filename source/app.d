import std.stdio: stderr, writeln;

import cosmicolor;

void main() @safe
{
	writeln();
	cwritefln!"<bg_magenta><b> * %s * </b></bg_magenta>"("Cosmicolor");
	writeln();
	cwritefln!"<black>%-22s</black> <grey>%-22s</grey> <bg_black>%-26s</bg_black> <bg_grey>%s</bg_grey>"(
		"<black></black>", "<grey></grey>", "<bg_black></bg_black>", "<bg_grey></bg_grey>",
	);
	cwritefln!"<red>%-22s</red> <lred>%-22s</lred> <bg_red>%-26s</bg_red> <bg_lred>%s</bg_lred>"(
		"<red></red>", "<lred></lred>", "<bg_red></bg_red>", "<bg_lred></bg_lred>",
	);
	cwritefln!"<green>%-22s</green> <lgreen>%-22s</lgreen> <bg_green>%-26s</bg_green> <bg_lgreen>%s</bg_lgreen>"(
		"<green></green>", "<lgreen></lgreen>", "<bg_green></bg_green>", "<bg_lgreen></bg_lgreen>",
	);
	cwritefln!"<orange>%-22s</orange> <yellow>%-22s</yellow> <bg_orange>%-26s</bg_orange> <bg_yellow>%s</bg_yellow>"(
		"<orange></orange>", "<yellow></yellow>", "<bg_orange></bg_orange>", "<bg_yellow></bg_yellow>",
	);
	cwritefln!"<blue>%-22s</blue> <lblue>%-22s</lblue> <bg_blue>%-26s</bg_blue> <bg_lblue>%s</bg_lblue>"(
		"<blue></blue>", "<lblue></lblue>", "<bg_blue></bg_blue>", "<bg_lblue></bg_lblue>",
	);
	cwritefln!"<magenta>%-22s</magenta> <lmagenta>%-22s</lmagenta> <bg_magenta>%-26s</bg_magenta> <bg_lmagenta>%s</bg_lmagenta>"(
		"<magenta></magenta>", "<lmagenta></lmagenta>", "<bg_magenta></bg_magenta>", "<bg_lmagenta></bg_lmagenta>",
	);
	cwritefln!"<cyan>%-22s</cyan> <lcyan>%-22s</lcyan> <bg_cyan>%-26s</bg_cyan> <bg_lcyan>%s</bg_lcyan>"(
		"<cyan></cyan>", "<lcyan></lcyan>", "<bg_cyan></bg_cyan>", "<bg_lcyan></bg_lcyan>",
	);
	cwritefln!"<lgrey>%-22s</lgrey> <white>%-22s</white> <bg_lgrey>%-26s</bg_lgrey> <bg_white>%s</bg_white>"(
		"<lgrey></lgrey>", "<white></white>", "<bg_lgrey></bg_lgrey>", "<bg_white></bg_white>",
	);
	writeln();
	cwritefln!"<b>%-22s</b> <i>%-22s</i> <u>%-26s</u> <s>%s</s>"(
		"<b>bold</b>", "<i>italic</i>", "<u>underline</u>", "<s>strikethrough</s>",
	);
	writeln();
}
