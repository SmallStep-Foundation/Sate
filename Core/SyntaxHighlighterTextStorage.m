//
//  SyntaxHighlighterTextStorage.m
//  SmallAdvancedTextEditor
//
//  Applies syntax highlighting per language using regexes for comments,
//  strings, numbers, and keywords. Language set from file extension.
//

#import "SyntaxHighlighterTextStorage.h"
#import "SATETheme.h"

@interface SyntaxHighlighterTextStorage (Private)
- (NSArray *)keywordsForCurrentLanguage;
@end

@implementation SyntaxHighlighterTextStorage

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize language = _language;
@synthesize theme = _theme;
#endif

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_backing release];
    [_theme release];
    [super dealloc];
}
#endif

- (NSString *)string {
    return [_backing string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [_backing attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    [_backing replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)[str length] - (NSInteger)range.length];
    [self applyHighlightingToRange:NSMakeRange(range.location, [str length])];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
    [_backing setAttributes:attrs range:range];
}

- (void)processEditing {
    [super processEditing];
    if ([self editedMask] & NSTextStorageEditedCharacters) {
        NSRange range = [self editedRange];
        NSInteger delta = [self changeInLength];
        NSUInteger len = [[self string] length];
        if (len == 0) return;
        NSUInteger rangeEnd = range.location + range.length + (NSUInteger)delta;
        if (range.location >= len) return;
        if (rangeEnd > len) rangeEnd = len;
        NSRange extended = NSMakeRange(0, rangeEnd);
        [self applyHighlightingToRange:extended];
    }
}

+ (SATELanguage)languageFromFilename:(NSString *)filename {
    if (!filename || [filename length] == 0) return SATELanguageNone;
    NSString *ext = [[filename pathExtension] lowercaseString];
    NSString *base = [[filename lastPathComponent] lowercaseString];
    if ([base isEqual:@"makefile"] || [base hasPrefix:@"makefile."]) return SATELanguageMakefile;
    if ([ext isEqual:@"c"] || [ext isEqual:@"h"]) return SATELanguageC;
    if ([ext isEqual:@"cpp"] || [ext isEqual:@"cc"] || [ext isEqual:@"cxx"] || [ext isEqual:@"hpp"] || [ext isEqual:@"hxx"]) return SATELanguageCpp;
    if ([ext isEqual:@"m"] || [ext isEqual:@"mm"]) return SATELanguageObjectiveC;
    if ([ext isEqual:@"java"]) return SATELanguageJava;
    if ([ext isEqual:@"cs"]) return SATELanguageCSharp;
    if ([ext isEqual:@"js"]) return SATELanguageJavaScript;
    if ([ext isEqual:@"ts"]) return SATELanguageTypeScript;
    if ([ext isEqual:@"py"]) return SATELanguagePython;
    if ([ext isEqual:@"php"]) return SATELanguagePHP;
    if ([ext isEqual:@"rb"]) return SATELanguageRuby;
    if ([ext isEqual:@"swift"]) return SATELanguageSwift;
    if ([ext isEqual:@"go"]) return SATELanguageGo;
    if ([ext isEqual:@"scala"]) return SATELanguageScala;
    if ([ext isEqual:@"lua"]) return SATELanguageLua;
    if ([ext isEqual:@"raku"] || [ext isEqual:@"rakumod"] || [ext isEqual:@"rakutest"] || [ext isEqual:@"nqp"]) return SATELanguageRaku;
    if ([ext isEqual:@"gd"]) return SATELanguageGodotScript;
    if ([ext isEqual:@"mk"]) return SATELanguageMakefile;
    if ([ext isEqual:@"s"] || [ext isEqual:@"asm"] || [ext isEqual:@"as"]) return SATELanguageAssembly;
    if ([ext isEqual:@"kt"] || [ext isEqual:@"kts"]) return SATELanguageKotlin;
    if ([ext isEqual:@"rs"]) return SATELanguageRust;
    if ([ext isEqual:@"dart"]) return SATELanguageDart;
    if ([ext isEqual:@"r"]) return SATELanguageR;
    if ([ext isEqual:@"pl"] || [ext isEqual:@"pm"]) return SATELanguagePerl;
    if ([ext isEqual:@"hs"]) return SATELanguageHaskell;
    if ([ext isEqual:@"jl"]) return SATELanguageJulia;
    if ([ext isEqual:@"ex"] || [ext isEqual:@"exs"]) return SATELanguageElixir;
    if ([ext isEqual:@"clj"] || [ext isEqual:@"cljs"] || [ext isEqual:@"cljc"]) return SATELanguageClojure;
    if ([ext isEqual:@"fs"] || [ext isEqual:@"fsi"] || [ext isEqual:@"fsx"]) return SATELanguageFSharp;
    if ([ext isEqual:@"zig"]) return SATELanguageZig;
    return SATELanguageNone;
}

- (void)applyHighlightingToRange:(NSRange)range {
    if (_language == SATELanguageNone) return;
    NSString *s = [self string];
    NSUInteger len = [s length];
    if (len == 0) return;
    if (range.location >= len) return;
    NSUInteger end = NSMaxRange(range);
    if (end > len) end = len;
    range.length = end - range.location;

    NSFont *baseFont = [NSFont userFixedPitchFontOfSize:12];
    NSColor *fgColor = _theme ? [_theme foregroundColor] : [NSColor blackColor];
    NSDictionary *baseAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
        baseFont, NSFontAttributeName,
        fgColor, NSForegroundColorAttributeName,
        nil];
    [self addAttributes:baseAttrs range:range];

    NSColor *commentColor = _theme ? [_theme commentColor] : [NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    NSColor *stringColor = _theme ? [_theme stringColor] : [NSColor colorWithCalibratedRed:0.8 green:0.0 blue:0.0 alpha:1.0];
    NSColor *keywordColor = _theme ? [_theme keywordColor] : [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.8 alpha:1.0];
    NSColor *numberColor = _theme ? [_theme numberColor] : [NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.6 alpha:1.0];
    NSColor *preprocessorColor = _theme ? [_theme preprocessorColor] : [NSColor colorWithCalibratedRed:0.5 green:0.3 blue:0.0 alpha:1.0];

    /* Block comments first so they take precedence over line comments */
    BOOL useCBlock = (_language == SATELanguageC || _language == SATELanguageCpp || _language == SATELanguageObjectiveC ||
                      _language == SATELanguageJava || _language == SATELanguageCSharp || _language == SATELanguageJavaScript ||
                      _language == SATELanguageTypeScript || _language == SATELanguageGo || _language == SATELanguageScala ||
                      _language == SATELanguageSwift || _language == SATELanguageGodotScript || _language == SATELanguageKotlin ||
                      _language == SATELanguageRust || _language == SATELanguageDart || _language == SATELanguageZig);
    if (useCBlock) {
        NSRegularExpression *blockComment = [NSRegularExpression regularExpressionWithPattern:@"(/\\*[\\s\\S]*?\\*/)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
        if (blockComment) {
            NSArray *matches = [blockComment matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:commentColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }
    /* F# block comments (* *) */
    if (_language == SATELanguageFSharp) {
        NSRegularExpression *fsBlock = [NSRegularExpression regularExpressionWithPattern:@"(\\(\\*[\\s\\S]*?\\*\\))" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
        if (fsBlock) {
            NSArray *matches = [fsBlock matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:commentColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }
    /* Haskell block comments {- -} */
    if (_language == SATELanguageHaskell) {
        NSRegularExpression *hsBlock = [NSRegularExpression regularExpressionWithPattern:@"(\\{-[\\s\\S]*?-\\})" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
        if (hsBlock) {
            NSArray *matches = [hsBlock matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:commentColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }
    /* Julia block comments #= =# */
    if (_language == SATELanguageJulia) {
        NSRegularExpression *jlBlock = [NSRegularExpression regularExpressionWithPattern:@"(#=[\\s\\S]*?=#)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
        if (jlBlock) {
            NSArray *matches = [jlBlock matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:commentColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }

    /* Line comments - language-specific */
    NSString *lineCommentPattern = nil;
    switch (_language) {
        case SATELanguageC:
        case SATELanguageCpp:
        case SATELanguageObjectiveC:
        case SATELanguageJava:
        case SATELanguageCSharp:
        case SATELanguageJavaScript:
        case SATELanguageTypeScript:
        case SATELanguageGo:
        case SATELanguageScala:
        case SATELanguageSwift:
        case SATELanguageGodotScript:
            lineCommentPattern = @"(//[^\n]*)";
            break;
        case SATELanguageKotlin:
        case SATELanguageRust:
        case SATELanguageDart:
        case SATELanguageZig:
            lineCommentPattern = @"(//[^\n]*)";
            break;
        case SATELanguagePython:
        case SATELanguageRuby:
        case SATELanguagePHP:
        case SATELanguageMakefile:
        case SATELanguageRaku:
            lineCommentPattern = @"(#[^\n]*)";
            break;
        case SATELanguageR:
        case SATELanguagePerl:
        case SATELanguageJulia:
        case SATELanguageElixir:
            lineCommentPattern = @"(#[^\n]*)";
            break;
        case SATELanguageLua:
            lineCommentPattern = @"(--[^\n]*)";
            break;
        case SATELanguageHaskell:
            lineCommentPattern = @"(--[^\n]*)";
            break;
        case SATELanguageClojure:
            lineCommentPattern = @"(;[^\n]*)";
            break;
        case SATELanguageAssembly:
            lineCommentPattern = @"(;[^\n]*)";
            break;
        case SATELanguageFSharp:
            lineCommentPattern = @"(//[^\n]*)";
            break;
        default:
            break;
    }
    if (lineCommentPattern) {
        NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:lineCommentPattern options:NSRegularExpressionAnchorsMatchLines error:NULL];
        if (re) {
            NSArray *matches = [re matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:commentColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }

    /* Python/Ruby multi-line string """ or ''' */
    if (_language == SATELanguagePython || _language == SATELanguageRuby) {
        NSRegularExpression *triple = [NSRegularExpression regularExpressionWithPattern:@"(\"\"\"[\\s\\S]*?\"\"\"|'''[\\s\\S]*?''')" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
        if (triple) {
            NSArray *matches = [triple matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:stringColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }

    /* Double-quoted strings (skip escaped quotes) */
    NSRegularExpression *dq = [NSRegularExpression regularExpressionWithPattern:@"(\"(?:[^\"\\\\]|\\\\.)*\")" options:0 error:NULL];
    if (dq) {
        NSArray *matches = [dq matchesInString:s options:0 range:range];
        for (NSTextCheckingResult *res in matches) {
            [self addAttributes:[NSDictionary dictionaryWithObject:stringColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
        }
    }
    /* Single-quoted strings */
    NSRegularExpression *sq = [NSRegularExpression regularExpressionWithPattern:@"('(?:[^'\\\\]|\\\\.)*')" options:0 error:NULL];
    if (sq) {
        NSArray *matches = [sq matchesInString:s options:0 range:range];
        for (NSTextCheckingResult *res in matches) {
            [self addAttributes:[NSDictionary dictionaryWithObject:stringColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
        }
    }

    /* Numbers */
    NSRegularExpression *num = [NSRegularExpression regularExpressionWithPattern:@"\\b([0-9]+(?:\\.[0-9]+)?(?:[eE][+-]?[0-9]+)?)\\b" options:0 error:NULL];
    if (num) {
        NSArray *matches = [num matchesInString:s options:0 range:range];
        for (NSTextCheckingResult *res in matches) {
            [self addAttributes:[NSDictionary dictionaryWithObject:numberColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
        }
    }

    /* Keywords - language-specific word boundary list */
    NSArray *keywords = [self keywordsForCurrentLanguage];
    if ([keywords count] > 0) {
        NSMutableString *kwPattern = [NSMutableString stringWithString:@"\\b("];
        NSUInteger i = 0;
        for (NSString *w in keywords) {
            if (i++) [kwPattern appendString:@"|"];
            [kwPattern appendString:[NSRegularExpression escapedPatternForString:w]];
        }
        [kwPattern appendString:@")\\b"];
        NSRegularExpression *kwRe = [NSRegularExpression regularExpressionWithPattern:kwPattern options:0 error:NULL];
        if (kwRe) {
            NSArray *matches = [kwRe matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:keywordColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }

    /* Preprocessor (#include etc) for C/C++/ObjC */
    if (_language == SATELanguageC || _language == SATELanguageCpp || _language == SATELanguageObjectiveC) {
        NSRegularExpression *pre = [NSRegularExpression regularExpressionWithPattern:@"^(\\s*#[^\n]*)" options:NSRegularExpressionAnchorsMatchLines error:NULL];
        if (pre) {
            NSArray *matches = [pre matchesInString:s options:0 range:range];
            for (NSTextCheckingResult *res in matches) {
                [self addAttributes:[NSDictionary dictionaryWithObject:preprocessorColor forKey:NSForegroundColorAttributeName] range:[res rangeAtIndex:0]];
            }
        }
    }
}

- (NSArray *)keywordsForCurrentLanguage {
    switch (_language) {
        case SATELanguageC:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"sizeof", @"struct", @"union", @"enum", @"typedef", @"extern", @"static", @"const", @"volatile", @"goto", @"void", @"int", @"long", @"short", @"char", @"float", @"double", @"signed", @"unsigned", @"true", @"false", nil];
        case SATELanguageCpp:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"sizeof", @"struct", @"union", @"enum", @"typedef", @"extern", @"static", @"const", @"volatile", @"goto", @"void", @"int", @"long", @"short", @"char", @"float", @"double", @"signed", @"unsigned", @"true", @"false", @"class", @"namespace", @"public", @"private", @"protected", @"virtual", @"override", @"template", @"typename", @"new", @"delete", @"this", @"operator", @"bool", @"throw", @"try", @"catch", @"const_cast", @"dynamic_cast", @"static_cast", @"reinterpret_cast", @"explicit", @"mutable", @"friend", @"inline", @"typeid", @"using", @"wchar_t", nil];
        case SATELanguageObjectiveC:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"sizeof", @"struct", @"union", @"enum", @"typedef", @"extern", @"static", @"const", @"volatile", @"goto", @"void", @"int", @"long", @"short", @"char", @"float", @"double", @"signed", @"unsigned", @"true", @"false", @"class", @"interface", @"implementation", @"protocol", @"end", @"self", @"super", @"nil", @"YES", @"NO", @"@interface", @"@implementation", @"@protocol", @"@end", @"@class", @"@selector", @"@property", @"@synthesize", @"@dynamic", @"@optional", @"@required", @"@try", @"@catch", @"@finally", @"@throw", @"@autoreleasepool", @"in", @"out", @"inout", @"bycopy", @"byref", nil];
        case SATELanguageJava:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"try", @"catch", @"finally", @"throw", @"throws", @"new", @"class", @"interface", @"extends", @"implements", @"import", @"package", @"public", @"private", @"protected", @"static", @"final", @"abstract", @"void", @"int", @"long", @"short", @"byte", @"char", @"float", @"double", @"boolean", @"true", @"false", @"null", @"super", @"this", @"synchronized", @"volatile", @"transient", @"native", @"strictfp", @"assert", @"enum", @"instanceof", nil];
        case SATELanguageCSharp:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"try", @"catch", @"finally", @"throw", @"new", @"class", @"interface", @"struct", @"enum", @"namespace", @"using", @"public", @"private", @"protected", @"internal", @"static", @"readonly", @"const", @"void", @"int", @"long", @"short", @"byte", @"char", @"float", @"double", @"decimal", @"bool", @"true", @"false", @"null", @"base", @"this", @"virtual", @"override", @"abstract", @"sealed", @"partial", @"async", @"await", @"var", @"in", @"out", @"ref", @"params", @"get", @"set", @"value", @"event", @"delegate", @"operator", @"implicit", @"explicit", @"checked", @"unchecked", @"fixed", @"lock", @"is", @"as", nil];
        case SATELanguageJavaScript:
        case SATELanguageTypeScript:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"try", @"catch", @"finally", @"throw", @"new", @"function", @"var", @"let", @"const", @"true", @"false", @"null", @"undefined", @"this", @"typeof", @"instanceof", @"in", @"of", @"class", @"extends", @"super", @"import", @"export", @"from", @"default", @"async", @"await", @"yield", @"delete", @"void", @"get", @"set", @"static", @"async", @"interface", @"type", @"enum", @"implements", @"protected", @"private", @"public", @"abstract", nil];
        case SATELanguagePython:
            return [NSArray arrayWithObjects:@"if", @"else", @"elif", @"while", @"for", @"in", @"break", @"continue", @"return", @"pass", @"try", @"except", @"finally", @"raise", @"with", @"as", @"def", @"class", @"lambda", @"and", @"or", @"not", @"True", @"False", @"None", @"yield", @"async", @"await", @"from", @"import", @"global", @"nonlocal", @"assert", @"del", nil];
        case SATELanguagePHP:
            return [NSArray arrayWithObjects:@"if", @"else", @"elseif", @"while", @"for", @"foreach", @"do", @"switch", @"case", @"break", @"continue", @"return", @"default", @"try", @"catch", @"finally", @"throw", @"new", @"function", @"class", @"interface", @"extends", @"implements", @"public", @"private", @"protected", @"static", @"final", @"abstract", @"const", @"true", @"false", @"null", @"and", @"or", @"xor", @"not", @"clone", @"instanceof", @"echo", @"print", @"die", @"exit", @"include", @"require", @"include_once", @"require_once", @"namespace", @"use", @"as", @"var", @"global", @"isset", @"empty", @"unset", @"list", @"array", @"eval", nil];
        case SATELanguageRuby:
            return [NSArray arrayWithObjects:@"if", @"else", @"elsif", @"unless", @"while", @"until", @"for", @"do", @"begin", @"end", @"case", @"when", @"break", @"next", @"redo", @"retry", @"return", @"yield", @"def", @"class", @"module", @"def", @"undef", @"defined?", @"self", @"super", @"true", @"false", @"nil", @"and", @"or", @"not", @"in", @"alias", @"begin", @"rescue", @"ensure", @"raise", @"include", @"extend", @"require", @"load", @"attr", @"attr_reader", @"attr_writer", @"attr_accessor", @"private", @"public", @"protected", nil];
        case SATELanguageSwift:
            return [NSArray arrayWithObjects:@"if", @"else", @"switch", @"case", @"default", @"for", @"in", @"while", @"repeat", @"break", @"continue", @"return", @"fallthrough", @"throw", @"defer", @"guard", @"func", @"class", @"struct", @"enum", @"protocol", @"extension", @"import", @"let", @"var", @"true", @"false", @"nil", @"self", @"super", @"Self", @"as", @"is", @"try", @"catch", @"async", @"await", @"throws", @"rethrows", @"where", @"associatedtype", @"init", @"convenience", @"required", @"static", @"final", @"override", @"lazy", @"mutating", @"nonmutating", @"subscript", @"get", @"set", @"willSet", @"didSet", @"open", @"public", @"internal", @"fileprivate", @"private", @"weak", @"unowned", @"optional", nil];
        case SATELanguageGo:
            return [NSArray arrayWithObjects:@"if", @"else", @"switch", @"case", @"default", @"for", @"range", @"break", @"continue", @"return", @"fallthrough", @"func", @"type", @"struct", @"interface", @"var", @"const", @"package", @"import", @"go", @"chan", @"select", @"defer", @"goto", @"map", @"nil", @"true", @"false", @"iota", nil];
        case SATELanguageScala:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"match", @"case", @"yield", @"return", @"try", @"catch", @"finally", @"throw", @"class", @"object", @"trait", @"extends", @"with", @"implicit", @"val", @"var", @"def", @"type", @"lazy", @"override", @"abstract", @"final", @"sealed", @"private", @"protected", @"import", @"package", @"new", @"this", @"super", @"true", @"false", @"null", @"None", @"Some", @"Nil", @"Unit", @"Nothing", @"Any", @"AnyRef", @"Option", @"Either", @"forSome", @"=>", nil];
        case SATELanguageLua:
            return [NSArray arrayWithObjects:@"if", @"then", @"else", @"elseif", @"end", @"while", @"do", @"for", @"in", @"break", @"return", @"function", @"local", @"nil", @"true", @"false", @"and", @"or", @"not", @"repeat", @"until", nil];
        case SATELanguageRaku:
            return [NSArray arrayWithObjects:@"if", @"else", @"elsif", @"unless", @"while", @"until", @"for", @"loop", @"given", @"when", @"default", @"return", @"sub", @"method", @"submethod", @"class", @"role", @"grammar", @"module", @"package", @"my", @"our", @"has", @"state", @"constant", @"true", @"false", @"Nil", @"self", @"Mu", @"Any", @"Cool", @"Str", @"Int", @"Num", @"Rat", @"Bool", @"Array", @"Hash", @"Block", @"Routine", @"do", @"end", @"begin", @"gather", @"take", @"make", @"made", @"temp", @"let", @"require", @"use", @"import", @"export", @"enum", @"subset", @"multi", @"proto", @"only", @"regex", @"token", @"rule", @"macro", @"quasi", @"quote", @"undef", @"so", @"not", @"and", @"or", @"xor", @"orelse", @"andthen", nil];
        case SATELanguageGodotScript:
            return [NSArray arrayWithObjects:@"if", @"else", @"elif", @"for", @"while", @"match", @"break", @"continue", @"return", @"pass", @"class", @"class_name", @"extends", @"func", @"signal", @"const", @"var", @"enum", @"export", @"onready", @"static", @"tool", @"breakpoint", @"preload", @"yield", @"assert", @"true", @"false", @"null", @"and", @"or", @"not", @"in", @"as", @"self", @"void", nil];
        case SATELanguageMakefile:
            return [NSArray arrayWithObjects:@"ifdef", @"ifndef", @"ifeq", @"ifneq", @"else", @"endif", @"include", @"define", @"endef", @"export", @"unexport", @"vpath", @".PHONY", @"@", @"$@", @"$<", @"$^", nil];
        case SATELanguageAssembly:
            return [NSArray arrayWithObjects:@"section", @"text", @"data", @"bss", @"global", @"extern", @"align", @"db", @"dw", @"dd", @"dq", @"resb", @"resw", @"resd", @"resq", @"equ", @"times", @"mov", @"push", @"pop", @"call", @"ret", @"add", @"sub", @"mul", @"div", @"inc", @"dec", @"cmp", @"jmp", @"je", @"jne", @"jg", @"jge", @"jl", @"jle", @"int", @".intel_syntax", @".att_syntax", @".globl", @".type", @".size", @".string", @".asciz", @".byte", @".word", @".long", @".quad", @".text", @".data", @".bss", nil];
        case SATELanguageKotlin:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"do", @"when", @"try", @"catch", @"finally", @"throw", @"return", @"break", @"continue", @"class", @"interface", @"object", @"fun", @"val", @"var", @"true", @"false", @"null", @"this", @"super", @"in", @"is", @"as", @"package", @"import", @"typealias", @"data", @"sealed", @"enum", @"companion", @"init", @"constructor", @"open", @"override", @"abstract", @"final", @"internal", @"private", @"protected", @"public", @"by", @"reified", @"inline", @"noinline", @"crossinline", @"suspend", @"operator", @"infix", nil];
        case SATELanguageRust:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"loop", @"match", @"fn", @"struct", @"enum", @"impl", @"trait", @"mod", @"use", @"pub", @"mut", @"ref", @"self", @"Self", @"async", @"await", @"move", @"static", @"const", @"let", @"return", @"break", @"continue", @"true", @"false", @"type", @"where", @"unsafe", @"extern", @"crate", @"super", @"dyn", @"box", @"virtual", @"default", nil];
        case SATELanguageDart:
            return [NSArray arrayWithObjects:@"if", @"else", @"for", @"while", @"do", @"switch", @"case", @"default", @"try", @"catch", @"finally", @"throw", @"return", @"break", @"continue", @"class", @"extends", @"implements", @"with", @"abstract", @"static", @"final", @"const", @"var", @"void", @"dynamic", @"get", @"set", @"super", @"this", @"new", @"true", @"false", @"null", @"async", @"await", @"yield", @"sync", @"external", @"factory", @"operator", @"part", @"import", @"export", @"library", @"show", @"hide", @"on", @"rethrow", @"assert", @"late", @"required", @"covariant", @"mixin", @"extension", @"typedef", @"enum", nil];
        case SATELanguageR:
            return [NSArray arrayWithObjects:@"if", @"else", @"for", @"while", @"repeat", @"break", @"next", @"return", @"function", @"in", @"TRUE", @"FALSE", @"NULL", @"NA", @"Inf", @"NaN", @"T", @"F", @"library", @"require", @"source", @"UseMethod", @"NextMethod", @"class", @"structure", @"attr", @"attributes", @"missing", nil];
        case SATELanguagePerl:
            return [NSArray arrayWithObjects:@"if", @"else", @"elsif", @"unless", @"while", @"until", @"for", @"foreach", @"do", @"given", @"when", @"default", @"sub", @"my", @"our", @"local", @"state", @"use", @"require", @"package", @"return", @"last", @"next", @"redo", @"goto", @"undef", @"bless", @"ref", @"q", @"qq", @"qw", @"qx", @"tr", @"y", @"s", @"m", @"qr", @"split", @"join", @"grep", @"map", @"sort", @"keys", @"values", @"each", @"exists", @"defined", @"delete", @"shift", @"unshift", @"push", @"pop", @"splice", @"scalar", @"array", @"hash", @"eq", @"ne", @"lt", @"le", @"gt", @"ge", @"cmp", @"and", @"or", @"not", @"xor", @"true", @"false", @"BEGIN", @"END", @"INIT", @"CHECK", @"DESTROY", @"AUTOLOAD", nil];
        case SATELanguageHaskell:
            return [NSArray arrayWithObjects:@"if", @"then", @"else", @"case", @"of", @"let", @"in", @"where", @"do", @"mdo", @"rec", @"data", @"type", @"newtype", @"class", @"instance", @"deriving", @"default", @"import", @"hiding", @"qualified", @"as", @"module", @"where", @"infix", @"infixl", @"infixr", @"forall", @"foreign", @"export", @"safe", @"unsafe", @"ccall", @"stdcall", @"cplusplus", @"dotnet", @"jvm", @"family", @"role", @"pattern", @"static", @"group", @"by", @"using", @"True", @"False", @"Nothing", @"Just", @"Maybe", @"Either", @"Left", @"Right", @"IO", @"return", @"pure", @"fmap", @">>=", @">>", @"=", @"<-", @"->", @"::", @"\\", @"@", @"!", @"~", @"as", @"qualified", nil];
        case SATELanguageJulia:
            return [NSArray arrayWithObjects:@"if", @"else", @"elseif", @"end", @"for", @"while", @"break", @"continue", @"function", @"return", @"struct", @"mutable", @"abstract", @"type", @"primitive", @"quote", @"try", @"catch", @"finally", @"global", @"local", @"const", @"let", @"begin", @"do", @"using", @"import", @"export", @"in", @"isa", @"where", @"macro", @"module", @"baremodule", @"true", @"false", @"nothing", @"missing", @"undef", @"ans", @"outer", nil];
        case SATELanguageElixir:
            return [NSArray arrayWithObjects:@"def", @"defp", @"defmodule", @"defprotocol", @"defimpl", @"defstruct", @"defmacro", @"defmacrop", @"defdelegate", @"defoverridable", @"defexception", @"if", @"unless", @"case", @"cond", @"receive", @"after", @"when", @"and", @"or", @"not", @"in", @"true", @"false", @"nil", @"when", @"do", @"end", @"else", @"rescue", @"catch", @"raise", @"import", @"require", @"alias", @"use", @"quote", @"unquote", @"super", @"with", @"for", @"fn", @"->", nil];
        case SATELanguageClojure:
            return [NSArray arrayWithObjects:@"def", @"defn", @"defn-", @"defmacro", @"defmulti", @"defmethod", @"defonce", @"defprotocol", @"defrecord", @"defstruct", @"deftype", @"definterface", @"reify", @"extend", @"extend-type", @"extend-protocol", @"fn", @"if", @"when", @"when-not", @"when-let", @"if-let", @"cond", @"condp", @"case", @"for", @"doseq", @"dotimes", @"while", @"loop", @"recur", @"let", @"letfn", @"binding", @"do", @"try", @"catch", @"finally", @"throw", @"ns", @"in-ns", @"refer", @"require", @"use", @"import", @"load", @"load-file", @"eval", @"quote", @"var", @"deref", @"ref", @"atom", @"swap!", @"reset!", @"alter", @"commute", @"delay", @"future", @"promise", @"true", @"false", @"nil", @"and", @"or", @"not", @"some", @"if-some", @"when-some", @"when-first", @"comment", @"declare", @"proxy", @"gen-class", @"gen-delegate", @"repeatedly", @"replicate", @"iterate", @"range", @"merge", @"merge-with", @"zipmap", @"first", @"rest", @"next", @"last", @"nth", @"get", @"assoc", @"dissoc", @"contains?", @"find", @"keys", @"vals", @"name", @"namespace", @"keyword", @"symbol", @"str", @"format", @"count", @"empty?", @"not-empty", @"into", @"apply", @"map", @"filter", @"remove", @"reduce", @"take", @"drop", @"take-while", @"drop-while", @"partition", @"group-by", @"sort", @"sort-by", @"seq?", @"sequential?", @"list?", @"vector?", @"set?", @"map?", @"coll?", @"count", @"get-in", @"assoc-in", @"update-in", @"peek", @"pop", @"conj", @"persistent!", @"transient", @"lazy-cat", @"lazy-seq", @"force", @"realized?", @"deref", @"ref-set", @"alter", @"commute", @"ensure", @"send", @"send-off", @"add-watch", @"remove-watch", @"agent-error", @"restart-agent", @"shutdown-agents", @"await", @"promise", @"deliver", @"future", @"future-cancel", @"future-cancelled?", @"future-done?", @"future?", @"pcalls", @"pmap", @"derive", @"isa?", @"parents", @"ancestors", @"descendants", @"underive", nil];
        case SATELanguageFSharp:
            return [NSArray arrayWithObjects:@"if", @"then", @"else", @"elif", @"match", @"with", @"when", @"for", @"in", @"do", @"while", @"try", @"catch", @"finally", @"raise", @"let", @"mutable", @"rec", @"and", @"or", @"not", @"fun", @"function", @"type", @"module", @"namespace", @"open", @"exception", @"class", @"interface", @"inherit", @"default", @"override", @"abstract", @"member", @"static", @"val", @"new", @"typeof", @"typedefof", @"null", @"true", @"false", @"lazy", @"yield", @"return", @"use", @"assert", @"begin", @"end", @"done", @"to", @"downto", @"as", @"box", @"unbox", @"ref", @"sig", @"struct", @"include", @"const", @"external", @"inline", @"private", @"public", @"internal", @"global", @"delegate", @"base", @"this", @"operator", @"enum", @"union", @"record", @"and", @"as", @"asr", @"begin", @"class", @"const", @"do", @"done", @"downto", @"elif", @"else", @"end", @"exception", @"extern", @"false", @"finally", @"for", @"fun", @"function", @"functor", @"global", @"if", @"in", @"include", @"inherit", @"inline", @"interface", @"internal", @"land", @"lazy", @"let", @"load", @"lor", @"lsl", @"lsr", @"lxor", @"match", @"method", @"mod", @"module", @"mutable", @"namespace", @"new", @"not", @"null", @"of", @"open", @"or", @"override", @"private", @"public", @"rec", @"return", @"sig", @"static", @"struct", @"then", @"to", @"true", @"try", @"type", @"val", @"virtual", @"void", @"volatile", @"when", @"while", @"with", @"yield", nil];
        case SATELanguageZig:
            return [NSArray arrayWithObjects:@"if", @"else", @"while", @"for", @"switch", @"inline", @"var", @"const", @"volatile", @"export", @"extern", @"packed", @"noalias", @"comptime", @"nakedcc", @"stdcallcc", @"async", @"fn", @"return", @"break", @"continue", @"asm", @"defer", @"errdefer", @"try", @"catch", @"async", @"await", @"suspend", @"resume", @"cancel", @"noinline", @"callconv", @"linksection", @"align", @"allowzero", @"addrspace", @"call", @"nosuspend", @"anytype", @"anyframe", @"unreachable", @"undefined", @"null", @"true", @"false", @"struct", @"union", @"enum", @"error", @"opaque", @"test", @"pub", @"packed", @"threadlocal", @"export", @"extern", @"inline", @"noinline", @"comptime", @"noalias", @"c_export", @"c_import", @"linksection", @"align", @"allowzero", @"addrspace", @"callconv", @"noinline", @"setCold", @"setRuntimeSafety", @"setEvalBranchQuota", @"setFloatMode", @"setObjectSafety", @"type", @"break", @"return", @"block", @"loop", @"anytype", @"anyframe", @"payload", @"pointer", @"addr", @"len", @"ptr", @"init", @"tag", @"error", @"items", @"values", @"key", @"value", nil];
        default:
            return [NSArray array];
    }
}

@end
