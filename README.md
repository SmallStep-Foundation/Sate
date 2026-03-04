# SmallAdvancedTextEditor

A text editor with syntax highlighting for GNUstep (Linux) and macOS. Uses [SmallStepLib](../SmallStepLib) for app lifecycle, menus, window style, and file dialogs.

## Supported languages

Syntax highlighting is applied automatically from the file extension when you open or save a file.

- **Top languages:** C, C++, Java, C#, JavaScript, TypeScript, Python, PHP, Ruby, Swift, Go  
- **Additional:** Objective-C, Makefile, Scala, Raku, Lua, Godot Script (.gd), Assembly (.s, .asm, .as)  
- **Kotlin + next top 10:** Kotlin (.kt, .kts), Rust (.rs), Dart (.dart), R (.r), Perl (.pl, .pm), Haskell (.hs), Julia (.jl), Elixir (.ex, .exs), Clojure (.clj, .cljs, .cljc), F# (.fs, .fsi, .fsx), Zig (.zig)

## Build

1. Build and install SmallStepLib:
   ```bash
   cd ../SmallStepLib && make && make install
   ```
2. Build the app:
   ```bash
   cd ../SmallAdvancedTextEditor && make
   ```

Run with `openapp SmallAdvancedTextEditor` (GNUstep) or run the app bundle on macOS.

## Usage

- **New** – new untitled document  
- **Open…** – open a file (language detected from extension)  
- **Save** / **Save As…** – save as UTF-8  
- **Theme** menu – switch editor theme: **Dark**, **High Contrast**, **Sepia**, **Classic**, or **Customize…** to manage custom themes.

Highlighting uses fixed-width font, with colors for keywords, strings, comments, numbers, and (for C/C++/ObjC) preprocessor directives. The editor background and text colors follow the selected theme.

### Themes

- **Built-in:** Dark, High Contrast, Sepia, Classic.  
- **Customize…** opens a panel where you can: **Apply** the selected theme, **Duplicate** (copy a theme to customize), **Delete** (custom themes only), **New from current** (save the current theme as a new custom theme). Custom themes are stored in Application Support and persist across launches.
