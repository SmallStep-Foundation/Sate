//
//  SmallAdvancedTextEditorTests.m — SmallAdvancedTextEditor unit tests
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SSTestMacros.h"
#import "../App/TEAppDelegate.h"
#import "../UI/TEMainWindow.h"

static BOOL sateMenuContains(NSMenu *menu, NSString *title)
{
    for (NSMenuItem *i in [menu itemArray]) {
        if ([[i title] isEqualToString:title]) return YES;
        if ([i submenu] && sateMenuContains([i submenu], title)) return YES;
    }
    return NO;
}

static void testTEAppDelegateMenuBuild(void)
{
    CREATE_AUTORELEASE_POOL(pool);
    TEAppDelegate *d = [[TEAppDelegate alloc] init];
    [d buildMenu];
    SS_TEST_ASSERT([NSApp mainMenu] != nil, "main menu built");
    SS_TEST_ASSERT(sateMenuContains([NSApp mainMenu], @"Export a Copy…"),
        "File > Export a Copy… present");
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [d release];
#endif
    RELEASE(pool);
}

static void testTEMainWindowExportCopy(void)
{
    CREATE_AUTORELEASE_POOL(pool);
    TEMainWindow *win = [[TEMainWindow alloc] init];
    [[win editorTextView] setString:@"hello export copy"];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SateTests_copy.txt"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    NSError *err = nil;
    SS_TEST_ASSERT([win writeCopyToPath:path error:&err], "export a copy writes a file");
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    SS_TEST_ASSERT_EQUAL_STR(content, @"hello export copy", "copy contains the editor text");
    /* Non-destructive: the window title is untouched by the copy */
    SS_TEST_ASSERT([[win title] hasPrefix:@"Untitled"],
        "export a copy does not change the window/document state");
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [win release];
#endif
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    RELEASE(pool);
}

int main(int argc, char **argv) {
    (void)argc;(void)argv;
    CREATE_AUTORELEASE_POOL(pool);
    [NSApplication sharedApplication];
    testTEAppDelegateMenuBuild();
    testTEMainWindowExportCopy();
    SS_TEST_SUMMARY();
    RELEASE(pool);
    return SS_TEST_RETURN();
}
