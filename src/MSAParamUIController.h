//
//  MSAParamUIController.h
//  Bindings Test
//
//  Created by Mehmet Akten on 21/08/2009.
//  Copyright 2009 MSA Visuals Ltd.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#include "MSAParamManager.h"
class MSAParamManager;

@interface MSAParamUIController : NSObject {
	IBOutlet NSView		*rootView;
	NSTabView			*tabView;
	MSAParamManager		*params;
}

@property MSAParamManager		*params;


// you can init with a nib name
// it loads the nib, and make sure rootView is pointing to a view in the nib
-(id)initWithNib:(NSString*)nibName andManager:(MSAParamManager*)m;

// or you can init directly by passing a view
// all controls will be created in this view
-(id)initWithView:(NSView*)view andManager:(MSAParamManager*)m;

-(NSView*)addTab:(NSString*)tabTitle;

@end
