# Cosmicolor

Yet another console output colorizer library!

![Cosmicolor Cheat Sheet](https://imgur.com/SUo3HSz.png)

Cosmicolor is a console output colorizer library for the [D programming language](https://dlang.org/) that lets you paint your terminal text using a simple XML-like syntax. It "just works", even on Windows, without so much as an initialization function & respects [NO_COLOR](https://no-color.org/) out of the box. Its output can also be safely "piped" to other processes or even files and Cosmicolor will simply strip the color tags from format strings without emitting any color escape codes or the like.

## Format

The format of the available tags is pleasingly simple: an opening XML tag with no spaces around the name, followed by some content text, followed by a closing tag of the same name. Most often, you'll want to interpolate some content between tags to colorize only it.

```d
const name = "Mireille";
cwritefln!"<magenta>%s</magenta>"(name);
```

If printing literal "less-than" and "greater-than" characters is needed, escape sequences are available in the form of `&lt;`, `&gt;`, and `&amp;` to escape the ampersand itself.

```d
// This prints the characters < & >
cwritefln!"&lt; &amp; &gt;";
```

If opening and closing color tags are mismatched, Cosmicolor will silently treat the closing tag as if it were closing the last encountered color tag. Furthermore, foreground and background tags are treated as different "categories" for this purpose, so a closing background color tag won't close a previously encountered foreground color tag, which is also true of the inverse case.

```d
// The closing tag here will do nothing & the whole line will be colored red
cwritefln!"<red>Hello</bg_red> World!";
```

Style tags are a bit different in that each one can only match with its corresponding closing tag. Additionally, style tags *do* nest properly, so however many opening tags of a kind are encountered, that many have to be closed to properly terminate the sequence.

```d
cwritefln!"<u>underlined <u>still underlined</u> yet still underlined</u> finally normal!";
```

Finally, if any tags are left unclosed, the entire text is automatically reset at the end.

## Dynamic Tags

Due to how Cosmicolor parses the format string before passing it to the function it wraps, tags themselves cannot have their name determined by the string interpolation.

```d
// This will not work! Do NOT do this!!!
cwritefln!"<%s>%s</%s>"("red", "Hello World!", "red");
```

Achieving this effect is still possible however, it just requires one more level of indirection between the format string and the call to `cwritefln` (or `cwritef`).

```d
import std.format : format;
// Note the double modulo symbol to escape interpolation
const fmt = format!"<%s>%%s</%s>"("red", "red");
cwritefln(fmt, "Hello World!");
```

## API

Cosmicolor provides a mere three functions to write colored text to the console: `cwritef`, `cwritefln`, and `cformat`. The vast majority of the time, you'll probably just use `cwritefln` though.

You may have noticed that there aren't colored equivalents for `write` nor for `writeln`. That's because Cosmicolor only applies colors to the format strings of the functions it does implement! This may seem like an arbitrary limitation, but in practice it eliminates the need to escape argument strings before passing them, as demonstrated in the main "cheat sheet" app where color tags are colorized using themselves with no need to handle them specially.

### `cwritef` - Write a colored, formatted string to `stdout` by default.

- `File file` - Optional file handle, allows the user to call this function like `stdout.cwritef(...)` using UFCS.
- `Char[] fmt` - Format string. Just like with `writef`, it can be passed as a template argument.
- `A...args` - Items to print. No need to escape them in any special way.

### `cwritefln` - Write a colored, formatted line to `stdout` by default.

- `File file` - Optional file handle, allows the user to call this function like `stdout.cwritef(...)` using UFCS.
- `Char[] fmt` - Format string. Just like with `writefln`, it can be passed as a template argument.
- `A...args` - Items to print. No need to escape them in any special way.

### `cformat` - Format & return a colored string in advance.

- `Char[] fmt` - Format string. Just like with `format`, it can be passed as a template argument.
- `A...args` - Items to print. No need to escape them in any special way.

## Available Tags

### Colors

As many colorizing libraries do, the colors provided correspond to basic ANSI escape code colors. They are listed here for the sake of completeness and convenience, though they are also visible in the cheat sheet above.

- `black`
- `red`
- `green`
- `orange` (dark yellow)
- `blue`
- `magenta`
- `cyan`
- `lgrey` (dim white)
- `grey` (bright black, somehow)
- `lred`
- `lgreen`
- `yellow`
- `lblue`
- `lmagenta`
- `lcyan`
- `white` (bright white, again somehow)

### Styles

Additionally, some style tags are available.

- `bold`
- `italic`
- `underline`
- `strike`