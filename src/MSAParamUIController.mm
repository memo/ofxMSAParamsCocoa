//
//  MSAParamUIController.m
//  Bindings Test
//
//  Created by Mehmet Akten on 21/08/2009.
//  Copyright 2009 MSA Visuals Ltd.. All rights reserved.
//

#import "MSAParamUIController.h"
#import "MSAParamManager.h"


@implementation MSAParamUIController

@synthesize params;

-(void)createButton:(NSString*)title at:(int)x{
	NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(x, 0, 100, 30)];
	[button setButtonType:NSMomentaryPushInButton];
	[button setBezelStyle:NSRoundedBezelStyle];
	[button setTitle:title];
	[rootView addSubview:button];
	[button release];

}

-(void)setup {
	tabView = [[NSTabView alloc] initWithFrame:rootView.bounds];
	[tabView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
//	[tabView setTabViewType:NSLeftTabsBezelBorder];
	[rootView addSubview:tabView];
	[tabView release];
	
	params->height = tabView.bounds.size.height;
	
	
	//		int x = 0;	[self createButton:@"qsave" at:x];
	//		x += 100;	[self createButton:@"qload" at:x];
	//		x += 120;	[self createButton:@"Save" at:x];
	//		x += 100;	[self createButton:@"Load" at:x];
	
}


-(void)awakeFromNib {
	NSLog(@"MSAParamUIController::awakeFromNib");
	params = new MSAParamManager();
	params->controller = self;
	[self setup];
}


-(id)initWithNib:(NSString*)nibName andManager:(MSAParamManager*)m {
	if(self = [super init]) {
		NSLog(@"MSAParamUIController::initWithNib");
		[NSBundle loadNibNamed:nibName owner:self];
		params = m;
		[self setup];
	}
	return self;
}

-(id)initWithView:(NSView*)view andManager:(MSAParamManager*)m {
	if(self = [super init]) {
		NSLog(@"MSAParamUIController::initWithView");
		rootView = view;
		params = m;
		[self setup];
	}
	return self;
}


-(NSView*)addTab:(NSString*)tabTitle {
	NSTabViewItem *newTabViewItem = [[[NSTabViewItem alloc] initWithIdentifier:nil] autorelease];
	[newTabViewItem setLabel:tabTitle];
	[tabView addTabViewItem:newTabViewItem];

	
//	NSView *retView = [[[NSView alloc] initWithFrame:NSMakeRect(0, 0, [newTabViewItem.view frame].size.width, [newTabViewItem.view frame].size.height * 3)] autorelease];
//	NSScrollView *scrollView = [[[NSScrollView alloc] initWithFrame:[newTabViewItem.view bounds]] autorelease];
//	[scrollView setHasVerticalScroller:YES];
//	[scrollView setHasHorizontalScroller:NO];
//	[scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
//	[scrollView setDocumentView:retView];
//	[scrollView setBorderType:NSNoBorder];
//	[scrollView setDrawsBackground:NO];
//	[scrollView setAutohidesScrollers:YES];
//	[newTabViewItem.view addSubview:scrollView];

	NSView* retView = newTabViewItem.view;
	[retView translateOriginToPoint:NSMakePoint(0, retView.bounds.size.height - 10)];
	
	return retView;
}

-(void)dealloc {
	[super dealloc];
}

@end
