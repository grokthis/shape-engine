// Package window is the thinnest possible platform shim.
// On macOS: WebKit via cgo. No framework. No dependency.
// The OS provides a rendering surface. We fill it with shapes.
package window

/*
#cgo CFLAGS: -x objective-c
#cgo LDFLAGS: -framework Cocoa -framework WebKit

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

// Borderless NSWindow subclass that accepts keyboard input.
// Default NSWindow with NSWindowStyleMaskBorderless returns NO
// from canBecomeKeyWindow, which blocks all keyboard events.
@interface ShapeWindow : NSWindow
@end

@implementation ShapeWindow
- (BOOL)canBecomeKeyWindow { return YES; }
- (BOOL)canBecomeMainWindow { return YES; }
@end

static WKWebView *webView;
static NSWindow *mainWindow;

void windowOpen(const char* url, const char* title, int width, int height, int fullscreen) {
	[NSApplication sharedApplication];
	[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

	// Menu bar — Edit menu is required for Cmd+C/V/X to reach the WebView.
	NSMenu *menuBar = [[NSMenu alloc] init];

	// App menu.
	NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
	[menuBar addItem:appMenuItem];
	NSMenu *appMenu = [[NSMenu alloc] init];
	[appMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
	[appMenuItem setSubmenu:appMenu];

	// Edit menu — routes Cmd+C/V/X/A/Z to the first responder (WebView).
	NSMenuItem *editMenuItem = [[NSMenuItem alloc] init];
	[menuBar addItem:editMenuItem];
	NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
	[editMenu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
	[editMenu addItemWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:@"Z"];
	[editMenu addItem:[NSMenuItem separatorItem]];
	[editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
	[editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
	[editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
	[editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
	[editMenuItem setSubmenu:editMenu];

	[NSApp setMainMenu:menuBar];

	// Window.
	NSRect frame;
	NSUInteger style;
	if (fullscreen) {
		// Borderless fullscreen. The Shape OS desktop IS the chrome.
		frame = [[NSScreen mainScreen] frame];
		style = NSWindowStyleMaskBorderless;
	} else {
		frame = NSMakeRect(0, 0, width, height);
		style = NSWindowStyleMaskTitled
			| NSWindowStyleMaskClosable
			| NSWindowStyleMaskResizable
			| NSWindowStyleMaskMiniaturizable;
	}
	mainWindow = [[ShapeWindow alloc]
		initWithContentRect:frame
		styleMask:style
		backing:NSBackingStoreBuffered
		defer:NO];
	[mainWindow setTitle:[NSString stringWithUTF8String:title]];
	if (!fullscreen) {
		[mainWindow center];
	}

	// WebKit view fills the window and autoresizes with it.
	WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
	NSRect contentFrame = [[mainWindow contentView] bounds];
	webView = [[WKWebView alloc] initWithFrame:contentFrame configuration:config];
	[webView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[mainWindow setContentView:webView];

	// Load the shape browser.
	NSURL *nsurl = [NSURL URLWithString:[NSString stringWithUTF8String:url]];
	[webView loadRequest:[NSURLRequest requestWithURL:nsurl]];

	[mainWindow makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];

	[NSApp run];
}
*/
import "C"

import "unsafe"

// Open launches a native window with the shape browser.
// Blocks until the window is closed. Call from main goroutine.
// If fullscreen is true, launches in native macOS fullscreen mode.
func Open(url, title string, width, height int, fullscreen bool) {
	curl := C.CString(url)
	ctitle := C.CString(title)
	defer C.free(unsafe.Pointer(curl))
	defer C.free(unsafe.Pointer(ctitle))
	fs := C.int(0)
	if fullscreen {
		fs = 1
	}
	C.windowOpen(curl, ctitle, C.int(width), C.int(height), fs)
}
