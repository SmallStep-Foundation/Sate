//
//  TEMainWindow.h
//  SmallAdvancedTextEditor
//
//  Main window: text editor in scroll view with syntax highlighting.
//  Handles New/Open/Save via SSFileDialog; language from file extension.
//

#import <AppKit/AppKit.h>

@class SyntaxHighlighterTextStorage;

@interface TEMainWindow : NSWindow
#if defined(GNUSTEP) && !__has_feature(objc_arc)
{
    NSScrollView *_scrollView;
    NSTextView *_textView;
    SyntaxHighlighterTextStorage *_textStorage;   /* retained: GNUstep's text view does not retain the storage */
    NSString *_documentPath;
    BOOL _dirty;
}
#endif
- (void)newDocument;
- (void)openDocument;
- (void)saveDocument;
- (void)saveDocumentAs;
- (void)exportACopy;
- (BOOL)writeCopyToPath:(NSString *)path error:(NSError **)outError;
- (NSTextView *)editorTextView;
@end
