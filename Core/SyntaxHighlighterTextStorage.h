//
//  SyntaxHighlighterTextStorage.h
//  SmallAdvancedTextEditor
//
//  NSTextStorage subclass that applies syntax highlighting by language.
//  Language is set from file extension; supports C, C++, ObjC, Java, C#,
//  JavaScript, TypeScript, Python, PHP, Ruby, Swift, Go, Scala, Lua,
//  Raku, Godot Script, Makefile, Assembly, Kotlin, Rust, Dart, R, Perl,
//  Haskell, Julia, Elixir, Clojure, F#, Zig.
//

#import <AppKit/AppKit.h>

@class SATETheme;

typedef NS_ENUM(NSInteger, SATELanguage) {
    SATELanguageNone = 0,
    SATELanguageC,
    SATELanguageCpp,
    SATELanguageObjectiveC,
    SATELanguageJava,
    SATELanguageCSharp,
    SATELanguageJavaScript,
    SATELanguageTypeScript,
    SATELanguagePython,
    SATELanguagePHP,
    SATELanguageRuby,
    SATELanguageSwift,
    SATELanguageGo,
    SATELanguageScala,
    SATELanguageLua,
    SATELanguageRaku,
    SATELanguageGodotScript,
    SATELanguageMakefile,
    SATELanguageAssembly,
    SATELanguageKotlin,
    SATELanguageRust,
    SATELanguageDart,
    SATELanguageR,
    SATELanguagePerl,
    SATELanguageHaskell,
    SATELanguageJulia,
    SATELanguageElixir,
    SATELanguageClojure,
    SATELanguageFSharp,
    SATELanguageZig,
};

@interface SyntaxHighlighterTextStorage : NSTextStorage
#if defined(GNUSTEP) && !__has_feature(objc_arc)
{
    NSMutableAttributedString *_backing;
    SATELanguage _language;
    SATETheme *_theme;
}
#endif

@property (nonatomic, assign) SATELanguage language;
/// When set, syntax colors are taken from the theme; otherwise default colors are used.
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, retain) SATETheme *theme;
#else
@property (nonatomic, strong) SATETheme *theme;
#endif

/// Infer language from file extension (e.g. @"file.py" -> SATELanguagePython).
+ (SATELanguage)languageFromFilename:(NSString *)filename;

/// Private: apply highlighting to a range (called from processEditing).
- (void)applyHighlightingToRange:(NSRange)range;

@end
