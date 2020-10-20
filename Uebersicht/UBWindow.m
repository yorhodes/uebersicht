//
//  UBWindow.m
//  Übersicht
//
//  A window that sits on desktop level, is always fullscreen and doesn't show
//  up in Mission Control
//
//  Created by Felix Hageloh on 20/9/13.
//  Copyright (c) 2013 Felix Hageloh.
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.
//

#import "UBWindow.h"
#import "UBWebViewController.h"

@implementation UBWindow {
    UBWebViewController* webViewController;
    NSTrackingArea* trackingArea;
    BOOL interactionEnabled;
}

- (id)init
{
    self = [super
        initWithContentRect: NSMakeRect(0, 0, 0, 0)
        styleMask: NSBorderlessWindowMask
        backing: NSBackingStoreBuffered
        defer: NO
    ];
    
    if (self) {
        [self setBackgroundColor:[NSColor clearColor]];
        [self setOpaque:NO];
        [self setCollectionBehavior:(
            NSWindowCollectionBehaviorStationary |
            NSWindowCollectionBehaviorCanJoinAllSpaces |
            NSWindowCollectionBehaviorIgnoresCycle
        )];

        [self setRestorable:NO];
        [self disableSnapshotRestoration];
        [self setDisplaysWhenScreenProfileChanges:YES];
        [self setReleasedWhenClosed:NO];
        [self setIgnoresMouseEvents:YES];
        
        webViewController = [[UBWebViewController alloc]
            initWithFrame: [self frame]
        ];
        [self setContentView:webViewController.view];
    }

    return self;
}

- (void)loadUrl:(NSURL*)url
{
    [webViewController load:url];
}

- (void)reload
{
    [webViewController reload];
}

// TODO: check if we can do at least some cleanups in webViewController#destroy
//- (void)close
//{
//    [webViewController destroy];
//    [super close];
//}

- (void)makeBackgroundWindow
{
    [webViewController makeBackground];
}


#
#pragma mark tracking area
#


- (void)setupTrackingArea
{
    trackingArea = [[NSTrackingArea alloc]
        initWithRect: self.contentView.bounds
        options: NSTrackingMouseMoved
            | NSTrackingMouseEnteredAndExited
            | NSTrackingActiveAlways
        owner: nil
        userInfo: nil
    ];
    [self.contentView addTrackingArea:trackingArea];
}

- (void)setFrame:(NSRect)newFrame display:(BOOL)doDisplay
{
    [super setFrame:newFrame display:doDisplay];
    [self updateTrackingArea];
}

- (void)updateTrackingArea
{
    if (trackingArea != nil) {
        [self.contentView removeTrackingArea:trackingArea];
    }
    if (self.contentView) {
        [self setupTrackingArea];
    }
}

#
#pragma mark signals/events
#

- (void)workspaceChanged
{
    [webViewController redraw];
}

- (void)wallpaperChanged
{
    [webViewController redraw];
}

#
#pragma mark interaction
#


- (void)setInteractionEnabled:(BOOL)isEnabled
{
    if (isEnabled) {
        [self setLevel:kCGNormalWindowLevel-1];
        [self updateTrackingArea];
        interactionEnabled = YES;
    } else {
        [self setLevel:kCGDesktopWindowLevel];
        if (trackingArea != nil) {
           [self.contentView removeTrackingArea:trackingArea];
        }
        [self setIgnoresMouseEvents:YES];
        interactionEnabled = NO;
    }
}

- (BOOL)interactionEnabled
{
    return interactionEnabled;
}

#
#pragma mark flags
#

- (BOOL)isKeyWindow { return interactionEnabled; }
- (BOOL)canBecomeKeyWindow { return interactionEnabled; }
- (BOOL)canBecomeMainWindow { return interactionEnabled; }
- (BOOL)acceptsFirstResponder { return interactionEnabled; }
- (BOOL)acceptsMouseMovedEvents { return interactionEnabled; }

@end
