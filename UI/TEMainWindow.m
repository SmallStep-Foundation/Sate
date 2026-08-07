//
//  TEMainWindow.m
//  SmallAdvancedTextEditor
//

#import "TEMainWindow.h"
#import "SyntaxHighlighterTextStorage.h"
#import "SATEThemeManager.h"
#import "SATETheme.h"
#import "SSWindowStyle.h"
#import "SSFileDialog.h"

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@interface TEMainWindow ()
@property (nonatomic, retain) NSScrollView *scrollView;
@property (nonatomic, retain) NSTextView *textView;
@property (nonatomic, retain) SyntaxHighlighterTextStorage *textStorage;
@property (nonatomic, copy) NSString *documentPath;
@property (nonatomic, assign) BOOL dirty;
@end
#else
@interface TEMainWindow ()
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSTextView *textView;
@property (nonatomic, strong) SyntaxHighlighterTextStorage *textStorage;
@property (nonatomic, copy) NSString *documentPath;
@property (nonatomic, assign) BOOL dirty;
@end
#endif

@implementation TEMainWindow

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize scrollView = _scrollView;
@synthesize textView = _textView;
@synthesize textStorage = _textStorage;
@synthesize documentPath = _documentPath;
@synthesize dirty = _dirty;
#endif

- (instancetype)init {
    NSUInteger style = [SSWindowStyle standardWindowMask];
    NSRect frame = NSMakeRect(100, 100, 800, 600);
    self = [super initWithContentRect:frame
                            styleMask:style
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        [self setTitle:@"Untitled - SmallAdvancedTextEditor"];
        [self setReleasedWhenClosed:NO];
        _documentPath = nil;
        _dirty = NO;
        [self buildContent];
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    /* _scrollView/_textView are owned by the view hierarchy (released in
     * buildContent after addSubview:/setDocumentView:); [super dealloc]
     * tears them down via the content view. Only owned objects are released. */
    [_textStorage release];
    [_documentPath release];
    [super dealloc];
}
#endif

- (void)buildContent {
    NSView *content = [self contentView];
    NSRect contentBounds = [content bounds];

    _scrollView = [[NSScrollView alloc] initWithFrame:contentBounds];
    [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setHasHorizontalScroller:YES];
    [_scrollView setBorderType:NSBezelBorder];
    [_scrollView setAutohidesScrollers:YES];
    [_scrollView setRulersVisible:NO];

    SyntaxHighlighterTextStorage *storage = [[SyntaxHighlighterTextStorage alloc] init];
    NSTextContainer *container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
    NSLayoutManager *layout = [[NSLayoutManager alloc] init];
    [layout addTextContainer:container];
    [storage addLayoutManager:layout];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [layout release];
#endif

    _textView = [[NSTextView alloc] initWithFrame:NSZeroRect textContainer:container];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [container release];
    /* GNUstep's text view does not retain the storage it is given through an
     * existing container (owns_text_network == NO); keep it alive here for
     * the lifetime of the text network. */
    self.textStorage = storage;
    [storage release];
#else
    self.textStorage = storage;
#endif
    [_textView setMinSize:NSMakeSize(0, 0)];
    [_textView setMaxSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
    [_textView setVerticallyResizable:YES];
    [_textView setHorizontallyResizable:YES];
    [_textView setAutoresizingMask:NSViewWidthSizable];
    [[_textView textContainer] setWidthTracksTextView:NO];
    [[_textView textContainer] setContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
    [_textView setFont:[NSFont userFixedPitchFontOfSize:12]];
    [_textView setRichText:NO];
    [_textView setAllowsUndo:YES];
    if ([_textView respondsToSelector:@selector(setUsesFindBar:)]) {
        [_textView setUsesFindBar:NO];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification
                                               object:_textView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeDidChange:)
                                                 name:SATEThemeDidChangeNotification
                                               object:[SATEThemeManager sharedManager]];

    [self applyCurrentTheme];

    [_scrollView setDocumentView:_textView];
    [content addSubview:_scrollView];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_scrollView release];
    [_textView release];
#endif
}

- (void)textDidChange:(NSNotification *)note {
    (void)note;
    _dirty = YES;
    [self updateTitle];
}

- (void)themeDidChange:(NSNotification *)note {
    (void)note;
    [self applyCurrentTheme];
}

- (void)applyCurrentTheme {
    SATETheme *theme = [[SATEThemeManager sharedManager] currentTheme];
    if (theme && [_textView respondsToSelector:@selector(setBackgroundColor:)]) {
        [_textView setBackgroundColor:[theme backgroundColor]];
        [_textView setDrawsBackground:YES];
    }
    SyntaxHighlighterTextStorage *hl = [self highlighterStorage];
    if (hl) {
        [hl setTheme:theme];
        NSUInteger len = [[hl string] length];
        if (len > 0) {
            [hl applyHighlightingToRange:NSMakeRange(0, len)];
        }
    }
}

- (void)updateTitle {
    NSString *name = _documentPath ? [_documentPath lastPathComponent] : @"Untitled";
    if (_dirty) name = [name stringByAppendingString:@" *"];
    [self setTitle:[NSString stringWithFormat:@"%@ - SmallAdvancedTextEditor", name]];
}

- (NSTextView *)editorTextView {
    return _textView;
}

- (SyntaxHighlighterTextStorage *)highlighterStorage {
    NSTextStorage *storage = [_textView textStorage];
    if ([storage isKindOfClass:[SyntaxHighlighterTextStorage class]]) {
        return (SyntaxHighlighterTextStorage *)storage;
    }
    return nil;
}

- (void)newDocument {
    NSTextView *tv = [self editorTextView];
    [tv setString:@""];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_documentPath release];
#endif
    _documentPath = nil;
    _dirty = NO;
    SyntaxHighlighterTextStorage *hl = [self highlighterStorage];
    if (hl) [hl setLanguage:SATELanguageNone];
    [self setTitle:@"Untitled - SmallAdvancedTextEditor"];
}

- (void)openDocument {
    SSFileDialog *dialog = [SSFileDialog openDialog];
    [dialog setCanChooseFiles:YES];
    [dialog setCanChooseDirectories:NO];
    [dialog setAllowsMultipleSelection:NO];
    NSArray *urls = [dialog showModal];
    if (!urls || [urls count] == 0) return;
    NSURL *url = [urls objectAtIndex:0];
    NSString *path = [url path];
    if (!path || [path length] == 0) return;
    NSError *err = nil;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (!content) {
        content = [NSString stringWithContentsOfFile:path encoding:NSISOLatin1StringEncoding error:&err];
    }
    if (!content) return;
    NSTextView *tv = [self editorTextView];
    [tv setString:content];
    SyntaxHighlighterTextStorage *hl = [self highlighterStorage];
    if (hl) {
        SATELanguage lang = [SyntaxHighlighterTextStorage languageFromFilename:path];
        [hl setLanguage:lang];
    }
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [_documentPath release];
    _documentPath = [path copy];
#else
    _documentPath = [path copy];
#endif
    _dirty = NO;
    [self updateTitle];
}

- (void)saveDocument {
    if (_documentPath && [_documentPath length] > 0) {
        NSTextView *tv = [self editorTextView];
        NSString *content = [[tv textStorage] string];
        NSError *err = nil;
        if ([content writeToFile:_documentPath atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
            _dirty = NO;
            [self updateTitle];
        }
        return;
    }
    [self saveDocumentAs];
}

- (void)saveDocumentAs {
    SSFileDialog *dialog = [SSFileDialog saveDialog];
    [dialog setCanCreateDirectories:YES];
    NSArray *urls = [dialog showModal];
    if (!urls || [urls count] == 0) return;
    NSURL *url = [urls objectAtIndex:0];
    NSString *path = [url path];
    if (!path || [path length] == 0) return;
    NSTextView *tv = [self editorTextView];
    NSString *content = [[tv textStorage] string];
    NSError *err = nil;
    if ([content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
        [_documentPath release];
        _documentPath = [path copy];
#else
        _documentPath = [path copy];
#endif
        SyntaxHighlighterTextStorage *hl = [self highlighterStorage];
        if (hl) {
            SATELanguage lang = [SyntaxHighlighterTextStorage languageFromFilename:path];
            [hl setLanguage:lang];
        }
        _dirty = NO;
        [self updateTitle];
    }
}

/* "Export a Copy…": write the current text to a new file at a chosen location
 * without changing the open document's path or dirty state (unlike Save As…,
 * which adopts the new file). */
- (BOOL)writeCopyToPath:(NSString *)path error:(NSError **)outError {
    NSTextView *tv = [self editorTextView];
    NSString *content = [[tv textStorage] string];
    return [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:outError];
}

- (void)exportACopy {
    SSFileDialog *dialog = [SSFileDialog saveDialog];
    [dialog setCanCreateDirectories:YES];
    NSArray *urls = [dialog showModal];
    if (!urls || [urls count] == 0) return;
    NSURL *url = [urls objectAtIndex:0];
    NSString *path = [url path];
    if (!path || [path length] == 0) return;
    NSError *err = nil;
    if (![self writeCopyToPath:path error:&err]) {
        NSString *detail = [err localizedDescription];
        if (!detail || [detail length] == 0)
            detail = [NSString stringWithFormat:@"Could not write %@.", path];
        /* detail passed as an argument, not a format string (may contain %) */
        NSRunAlertPanel(@"Export Failed", @"%@", @"OK", nil, nil, detail);
    }
}

@end
