//
//  MSAParam.m
//  Bindings Test
//
//  Created by Mehmet Akten on 21/08/2009.
//  Copyright 2009 MSA Visuals Ltd.. All rights reserved.
//

#import "MSAParam.h"
#import "MSAParamManager.h"



@implementation MSAParam

@synthesize		value;

-(void)addControlToView:(NSControl*)c {
	[c setAutoresizingMask:NSViewMinYMargin];
	[manager->view addSubview:c];
	NSLog(@"**** %@ %i %@", title, manager->currentY, NSStringFromRect(manager->view.frame));
	if(manager->currentY <= -manager->height) {
		manager->currentY = 0;
		manager->currentX += manager->padding + manager->gridWidth;
	}
	[c release];
}


-(void)linkControl:(NSControl*)control {
	if(manager->verbose) NSLog(@"MSAParam::linkControl %@ %@", title, control);
	if(controls == nil) {
		[self addObserver:self forKeyPath:@"value" options:nil context:nil];
		controls = [[NSMutableArray alloc] init];
	}
	
	[control setAction:@selector(controlChanged:)];
	[control setTarget:self];
	[controls addObject:control];
}


-(void)controlChanged:(id)sender {
	self.value = [sender floatValue];
	if(manager->verbose) NSLog(@"MSAParam::controlChanged: %@ %@ %f", title, sender, value);
//	manager->saveCurrentPreset();
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if(manager->verbose) NSLog(@"MSAParam::observeValueForKeyPath %@ %@", title, keyPath);
    if([keyPath isEqualToString:@"value"] ) {
		if(manager->verbose) NSLog(@"change controls: %@", controls);
		for(NSControl *control in controls) {
			control.floatValue = value;
		}
    }
}


-(void)updateView {
	self.value = 0;
//	[manager->view setBounds:NSMakeRect(manager->view.bounds.origin.x, manager->view.bounds.origin.y, manager->view.bounds.size.width, -manager->currentY)];
}



-(void)setupSliderWithTitle:(NSString*)t andManager:(MSAParamManager*)m andMin:(float)min andMax:(float)max {
	title = t;
	controls = nil;
	manager = m;
	
	if(manager->verbose) NSLog(@"MSAParam::initWithSlider %@", title);
	
	float sliderHeight = 45;
	float textWidth = 80;
	
	int curY = manager->currentY - sliderHeight;
	
	NSSlider *slider = [[NSSlider alloc] initWithFrame:NSMakeRect(manager->currentX, curY, manager->gridWidth - textWidth, sliderHeight)];
	[slider setMinValue:min];
	[slider setMaxValue:max];
	if([type compare:@"int"] == NSOrderedSame) {
		[slider setAllowsTickMarkValuesOnly:YES];
		[slider setNumberOfTickMarks: max-min+1];
		[slider setTickMarkPosition:NSTickMarkAbove];

	}
	[self linkControl:slider];
	[self addControlToView:slider];
	
	
	NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(manager->currentX + manager->gridWidth - textWidth, curY+10, textWidth, 20)];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	if([type compare:@"int"] == NSOrderedSame) {
//		[formatter setMaximumFractionDigits:0];
	} else {
		[formatter setUsesSignificantDigits:YES];
		[formatter setMaximumSignificantDigits:6];
	}
	[textField setFormatter:formatter];
	[self linkControl:textField];
	[self addControlToView:textField];
	

	
	NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(manager->currentX, curY, manager->gridWidth, 15)];
	label.stringValue = title;
	[label setEditable:NO];
	[label setDrawsBackground:NO];
	[label setBordered:NO];
	[self addControlToView:label];
	

	manager->currentY -= sliderHeight + manager->padding;
	
	[self updateView];
}

-(id)initWithIntSlider:(NSString*)t andManager:(MSAParamManager*)m andMin:(float)min andMax:(float)max {
	if(self = [super init]) {
		type = @"int";
		[self setupSliderWithTitle:t andManager:m andMin:min andMax:max];
	}
	return self;
}

-(id)initWithFloatSlider:(NSString*)t andManager:(MSAParamManager*)m andMin:(float)min andMax:(float)max {
	if(self = [super init]) {
		type = @"float";
		[self setupSliderWithTitle:t andManager:m andMin:min andMax:max];
	}
	return self;
}


-(id)initWithToggle:(NSString*)t andManager:(MSAParamManager*)m {
	if(self = [super init]) {
		title = t;
		controls = nil;
		manager = m;
		
		if(manager->verbose) NSLog(@"MSAParam::initWithToggle %@", title);
		float height = 20;
		manager->currentY -= manager->padding;
		int curY = manager->currentY - height;
		NSButton *toggleButton = [[NSButton alloc] initWithFrame:NSMakeRect(manager->currentX, curY, manager->gridWidth, height)];
		[toggleButton setTitle:title];
		[toggleButton setButtonType:NSSwitchButton];
		[self linkControl:toggleButton];
		[self addControlToView:toggleButton];
		
		manager->currentY -= height + manager->padding;
		
		type = @"bool";
		
		[self updateView];
	}
	return self;
}

-(id)initWithHeader:(NSString*)t andManager:(MSAParamManager*)m {
	if(self = [super init]) {
		title = t;
		controls = nil;
		manager = m;
		
		if(manager->verbose) NSLog(@"MSAParam::initWithHeader %@", title);
		float height = 30;
		manager->currentY -= manager->padding;
		int curY = manager->currentY - height;
		
		NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(manager->currentX + 30, curY, manager->gridWidth, 15)];
		label.stringValue = title;
		[label setEditable:NO];
		[label setDrawsBackground:NO];
		[label setBordered:NO];
		[self addControlToView:label];
		
		manager->currentY -= height + manager->padding;
		
		type = @"header";
		
		[self updateView];

	}
	return self;
	
}


-(id)get {
	if([type compare:@"float"] == NSOrderedSame) {
		return [NSNumber numberWithFloat:value];
	} else if([type compare:@"int"] == NSOrderedSame) {
		return [NSNumber numberWithInt:value];
	} else if([type compare:@"bool"] == NSOrderedSame) {
		return [NSNumber numberWithBool:value];
	}
	return nil;
}



-(void)dealloc {
//	[self removeObserver:self forKeyPath:@"value"];
	[controls release];
	
	[super dealloc];
}


@end
