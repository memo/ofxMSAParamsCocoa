//
//  MSAParam.h
//  Bindings Test
//
//  Created by Mehmet Akten on 21/08/2009.
//  Copyright 2009 MSA Visuals Ltd.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

class MSAParamManager;

@interface MSAParam : NSObject {
	NSString		*title;
	NSString		*type;
	float			value;
	MSAParamManager *manager;
	NSMutableArray	*controls;		// controls which are linked to the value (e.g. slider, textfield, but NOT the label)
}

@property float					value;

-(id)initWithIntSlider:(NSString*)title andManager:(MSAParamManager*)manager andMin:(float)min andMax:(float)max;
-(id)initWithFloatSlider:(NSString*)title andManager:(MSAParamManager*)manager andMin:(float)min andMax:(float)max;
-(id)initWithToggle:(NSString*)title andManager:(MSAParamManager*)manager;
-(id)initWithHeader:(NSString*)title andManager:(MSAParamManager*)manager;

-(id)get;

@end
