//
//  TEAppDelegate.m
//  SmallAdvancedTextEditor
//

#import "TEAppDelegate.h"
#import "TEMainWindow.h"
#import "SSAppDelegate.h"
#import "SSHostApplication.h"
#import "SSMainMenu.h"
#import "SSAboutPanel.h"
#import "SATEThemeManager.h"
#import "TEThemePanel.h"

@implementation TEAppDelegate

- (void)applicationWillFinishLaunching {
    [self buildMenu];
}

- (void)applicationDidFinishLaunching {
    _mainWindow = [[TEMainWindow alloc] init];
    [_mainWindow makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender {
    (void)sender;
    return YES;
}

- (void)buildMenu {
#if !TARGET_OS_IPHONE
    SSMainMenu *menu = [[SSMainMenu alloc] init];
    [menu setAppName:@"SmallAdvancedTextEditor"];
    [menu setAboutAppName:@"SmallAdvancedTextEditor"];
    [menu setAboutVersion:@"1.0"];
    [menu setAboutTarget:self];
    NSArray *items = [NSArray arrayWithObjects:
        [SSMainMenuItem itemWithTitle:@"New" action:@selector(newDocument:) keyEquivalent:@"n" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Open…" action:@selector(openDocument:) keyEquivalent:@"o" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Save" action:@selector(saveDocument:) keyEquivalent:@"s" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Save As…" action:@selector(saveDocumentAs:) keyEquivalent:@"" modifierMask:0 target:self],
        nil];
    [menu buildMenuWithItems:items quitTitle:@"Quit SmallAdvancedTextEditor" quitKeyEquivalent:@"q"];
    [menu install];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [menu release];
#endif
    [self addThemeMenu];
#endif
}

- (void)newDocument:(id)sender {
    (void)sender;
    [_mainWindow newDocument];
}

- (void)openDocument:(id)sender {
    (void)sender;
    [_mainWindow openDocument];
}

- (void)saveDocument:(id)sender {
    (void)sender;
    [_mainWindow saveDocument];
}

- (void)saveDocumentAs:(id)sender {
    (void)sender;
    [_mainWindow saveDocumentAs];
}

- (void)addThemeMenu {
    NSMenu *main = [NSApp mainMenu];
    if (!main) return;
    NSMenuItem *themeItem = [[NSMenuItem alloc] initWithTitle:@"Theme" action:NULL keyEquivalent:@""];
    NSMenu *themeMenu = [[NSMenu alloc] initWithTitle:@"Theme"];
    NSMenuItem *dark = [[NSMenuItem alloc] initWithTitle:@"Dark" action:@selector(themeDark:) keyEquivalent:@""];
    [dark setTarget:self];
    [themeMenu addItem:dark];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [dark release];
#endif
    NSMenuItem *hc = [[NSMenuItem alloc] initWithTitle:@"High Contrast" action:@selector(themeHighContrast:) keyEquivalent:@""];
    [hc setTarget:self];
    [themeMenu addItem:hc];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [hc release];
#endif
    NSMenuItem *sepia = [[NSMenuItem alloc] initWithTitle:@"Sepia" action:@selector(themeSepia:) keyEquivalent:@""];
    [sepia setTarget:self];
    [themeMenu addItem:sepia];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [sepia release];
#endif
    NSMenuItem *classic = [[NSMenuItem alloc] initWithTitle:@"Classic" action:@selector(themeClassic:) keyEquivalent:@""];
    [classic setTarget:self];
    [themeMenu addItem:classic];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [classic release];
#endif
    [themeMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *custom = [[NSMenuItem alloc] initWithTitle:@"Customize…" action:@selector(themeCustomize:) keyEquivalent:@""];
    [custom setTarget:self];
    [themeMenu addItem:custom];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [custom release];
#endif
    [themeItem setSubmenu:themeMenu];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [themeMenu release];
#endif
    [main addItem:themeItem];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [themeItem release];
#endif
}

- (void)themeDark:(id)sender { (void)sender; [[SATEThemeManager sharedManager] applyBuiltInThemeWithName:@"Dark"]; }
- (void)themeHighContrast:(id)sender { (void)sender; [[SATEThemeManager sharedManager] applyBuiltInThemeWithName:@"High Contrast"]; }
- (void)themeSepia:(id)sender { (void)sender; [[SATEThemeManager sharedManager] applyBuiltInThemeWithName:@"Sepia"]; }
- (void)themeClassic:(id)sender { (void)sender; [[SATEThemeManager sharedManager] applyBuiltInThemeWithName:@"Classic"]; }

- (void)themeCustomize:(id)sender {
    (void)sender;
    [TEThemePanel showPanel];
}

- (void)showAbout:(id)sender {
    (void)sender;
    [SSAboutPanel showWithAppName:@"SmallAdvancedTextEditor" version:@"1.0"];
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_mainWindow release];
    [super dealloc];
}
#endif

@end
