//
//  SmallAdvancedTextEditorTests.m — SmallAdvancedTextEditor unit tests
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SSTestMacros.h"
#import "../App/TEAppDelegate.h"

static void testTEAppDelegateMenuBuild(void)
{
    CREATE_AUTORELEASE_POOL(pool);
    TEAppDelegate *d = [[TEAppDelegate alloc] init];
    [d buildMenu];
    SS_TEST_ASSERT(YES, "TEAppDelegate buildMenu did not crash");
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [d release];
#endif
    RELEASE(pool);
}

int main(int argc, char **argv) {
    (void)argc;(void)argv;
    CREATE_AUTORELEASE_POOL(pool);
    [NSApplication sharedApplication];
    testTEAppDelegateMenuBuild();
    SS_TEST_SUMMARY();
    RELEASE(pool);
    return SS_TEST_RETURN();
}
