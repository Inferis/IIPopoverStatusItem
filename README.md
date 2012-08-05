IIPopoverStatusItem
===================

# Abstract

This class tries to encapsulate the mess you need to go through to have a statusitem in OSX with a NSPopover. 
It exposes a new class `IIPopoverStatusItem` which is returned for a new method on `NSStatusBar`:

	- (IIPopoverStatusItem*)popoverStatusItemWithImage:(NSImage*)image alternateImage:(NSImage*)alternateImage;

At the moment, only images as status items are supported. Might add text, but I had no use for it. 

The `IIPopoverStatusItem` manages the popover itself, but you can modify it through the `popover` property on the returned `IIPopoverStatusItem`.

# Caveat

This code is work in progress, has barely and comments and should be tested more. There's also missing stuff. It might not work in your use case.

Feel free to augment or fix stuff. ;)

# Usage

Include the `IIPopoverStatusItem.h` and `IIPopoverStatusItem.m` in your project. 
Then import the header file where you need to use the `IIPopoverStatusItem`.
For example:

	#import "AppDelegate.h"
	#import "IIPopoverStatusItem.h"
	#import "MainViewController.h"

	@implementation AppDelegate {
	    IIPopoverStatusItem * _statusItem;
	    MainViewController* _mainViewController;
	}

	- (void)awakeFromNib {
	    _statusItem = [[NSStatusBar systemStatusBar] popoverStatusItemWithImage:[NSImage imageNamed:@"status0"] alternateImage:nil];

	    _mainViewController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	    _statusItem.popover.animates = YES;
	    _statusItem.popover.contentViewController = _mainViewController;
	    _statusItem.popover.delegate = _mainViewController;
	}

	@end

And that's it.

# Example

There's currently no example to go with this class. I might add one later.

# Credits

I'd appreciate it to mention the use of this code somewhere if you use it in an app. On a website, in an about page, in the app itself, whatever. Or let me know by email or through github. It's nice to know where one's code is used. 

# License

**IIViewDeckController** published under the MIT license:

*Copyright (C) 2012, Tom Adriaenssen*

*Permission is hereby granted, free of charge, to any person obtaining a copy of*
*this software and associated documentation files (the "Software"), to deal in*
*the Software without restriction, including without limitation the rights to*
*use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies*
*of the Software, and to permit persons to whom the Software is furnished to do*
*so, subject to the following conditions:*

*The above copyright notice and this permission notice shall be included in all*
*copies or substantial portions of the Software.*

*THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR*
*IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,*
*FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE*
*AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER*
*LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,*
*OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE*
*SOFTWARE.*

