//
//  NSPopoverStatusItem.m
//
//  Created by Tom Adriaenssen on 05/08/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "IIPopoverStatusItem.h"
#import <objc/runtime.h>

@interface IIPopoverStatusItem () <NSPopoverDelegate>

@property (nonatomic, strong) id popoverTransiencyMonitor;

- (void)showPopover;

@end

@interface IIPopoverStatusItemView : NSView

- (id)initWithStatusItem:(IIPopoverStatusItem*)statusItem image:(NSImage*)image alternateImage:(NSImage*)alternateImage;

@end

@interface IIStatusItemPopover : NSPopover

@property (nonatomic, assign) id<NSPopoverDelegate> externalDelegate;

@end

@implementation IIPopoverStatusItem

@dynamic popover;

static const char* PopoverKey = "Popover";
static const char* PopoverTransiencyMonitorKey = "PopoverTransiencyMonitor";


- (void)showPopover {
    if (self.popover.shown) {
        if (self.popoverTransiencyMonitor) {
            [NSEvent removeMonitor:self.popoverTransiencyMonitor];
            self.popoverTransiencyMonitor  = nil;
        }
        [self.popover close];
        return;
    }
    
    [self.popover showRelativeToRect:self.view.frame ofView:self.view preferredEdge:CGRectMaxYEdge];
}

- (void)preparePopoverOpen {
    if (!self.popoverTransiencyMonitor) {
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(spacesChanged:) name:NSWorkspaceActiveSpaceDidChangeNotification object:nil];

        self.popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseUp handler:^(NSEvent* event) {
            [self.popover close];
        }];
    }
    
    self.popover.contentSize = self.popover.contentViewController.view.frame.size;
}

- (void)cleanupAfterPopoverClosed {
    if (self.popoverTransiencyMonitor) {
        [NSEvent removeMonitor:self.popoverTransiencyMonitor];
        self.popoverTransiencyMonitor  = nil;
    }
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceActiveSpaceDidChangeNotification object:nil];
}


- (BOOL)popoverShouldClose:(NSPopover *)popover {
    if ([self.popover.delegate respondsToSelector:@selector(popoverShouldClose:)])
        return [self.popover.delegate popoverShouldClose:popover];
    return YES;
}

- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover {
    if ([self.popover.delegate respondsToSelector:@selector(detachableWindowForPopover:)])
        return [self.popover.delegate detachableWindowForPopover:popover];
    return nil;
}

- (void)popoverWillShow:(NSNotification *)notification {
    if ([self.popover.delegate respondsToSelector:@selector(popoverWillShow:)])
        [self.popover.delegate popoverWillShow:notification];
}

- (void)popoverDidShow:(NSNotification *)notification {
    [self preparePopoverOpen];
    if ([self.popover.delegate respondsToSelector:@selector(popoverDidShow:)])
        [self.popover.delegate popoverDidShow:notification];
}

- (void)popoverDidClose:(NSNotification *)notification {
    [self cleanupAfterPopoverClosed];
    if ([self.popover.delegate respondsToSelector:@selector(popoverDidClose:)])
        [self.popover.delegate popoverDidClose:notification];
}


- (void)popoverWillClose:(NSNotification *)notification {
    if ([self.popover.delegate respondsToSelector:@selector(popoverWillClose:)])
        [self.popover.delegate popoverWillClose:notification];
}


- (void)spacesChanged:(NSNotification*)notification {
    [self.popover close];
}

- (void)dealloc {
    if (self.popoverTransiencyMonitor) {
        [NSEvent removeMonitor:self.popoverTransiencyMonitor];
        self.popoverTransiencyMonitor  = nil;
    }
    if (self.popover) {
        [self.popover close];
        self.popover = nil;
    }
}

- (void)setPopover:(NSPopover *)popover {
    objc_setAssociatedObject(self, PopoverKey, popover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSPopover *)popover {
    return objc_getAssociatedObject(self, PopoverKey);
}

- (void)setPopoverTransiencyMonitor:(id)popoverTransiencyMonitor {
    objc_setAssociatedObject(self, PopoverTransiencyMonitorKey, popoverTransiencyMonitor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSPopover *)popoverTransiencyMonitor {
    return objc_getAssociatedObject(self, PopoverTransiencyMonitorKey);
}
@end

@implementation NSStatusBar (PopoverStatusItem)

- (IIPopoverStatusItem*)popoverStatusItemWithImage:(NSImage*)image alternateImage:(NSImage*)alternateImage {
    IIPopoverStatusItem* statusItem = (IIPopoverStatusItem*)[self statusItemWithLength:NSSquareStatusItemLength];
    object_setClass(statusItem, [IIPopoverStatusItem class]);
    statusItem.highlightMode = YES;
    
    IIStatusItemPopover* popover = [IIStatusItemPopover new];
    statusItem.popover = popover;

    popover.delegate = statusItem;
    popover.behavior = NSPopoverBehaviorTransient;

    IIPopoverStatusItemView* view = [[IIPopoverStatusItemView alloc] initWithStatusItem:statusItem image:image alternateImage:image];
    statusItem.view = view;
    
    return statusItem;
}


@end


@implementation IIPopoverStatusItemView {
    IIPopoverStatusItem* _statusItem;
    NSImage* _image, *_alternateImage;
}

- (id)initWithStatusItem:(IIPopoverStatusItem*)statusItem image:(NSImage*)image alternateImage:(NSImage*)alternateImage {
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    if ((self = [self initWithFrame:NSMakeRect(0, 0, thickness, thickness)])) {
        _statusItem = statusItem;
        _image = image;
        _alternateImage = alternateImage;
    }
    
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent {
    [_statusItem showPopover];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[_statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:NO];
    
    NSImage *icon = NO ? _alternateImage : _image;
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);
    [icon compositeToPoint:iconPoint operation:NSCompositeSourceOver];
}

@end


@implementation IIStatusItemPopover

@synthesize externalDelegate = _externalDelegate;

- (void)setDelegate:(id<NSPopoverDelegate>)delegate {
    id current = [super delegate];
    if ([delegate isKindOfClass:[IIPopoverStatusItem class]]) {
        if (current && ![current isKindOfClass:[IIPopoverStatusItem class]]) {
            self.externalDelegate = current;
        }
        
        [super setDelegate:delegate];
    }
    else if (!current)
        [super setDelegate:delegate];
    else
        self.externalDelegate = delegate;
}

- (id<NSPopoverDelegate>)delegate {
    return self.externalDelegate;
}

@end
