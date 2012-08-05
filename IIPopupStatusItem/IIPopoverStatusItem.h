//
//  NSPopoverStatusItem.h
//
//  Created by Tom Adriaenssen on 05/08/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IIPopoverStatusItem : NSStatusItem

@property (nonatomic, strong, readonly) NSPopover* popover;

@end

@interface NSStatusBar (PopoverStatusItem)

- (IIPopoverStatusItem*)popoverStatusItemWithImage:(NSImage*)image alternateImage:(NSImage*)alternateImage;

@end