//
//  MSAParamManager.m
//  Bindings Test
//
//  Created by Mehmet Akten on 21/08/2009.
//  Copyright 2009 MSA Visuals Ltd.. All rights reserved.
//

#import "MSAParamManager.h"
#import "MSAParam.h"

MSAParamManager::MSAParamManager() {
	currentX		= 0;
	currentY		= 0;
	gridWidth		= 250;
	padding			= 5;
	
	controller		= 0;
	params			= 0;
	
	verbose			= false;
}


MSAParamManager::~MSAParamManager() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//	saveCurrentPreset();
	
	[params release];
	[controller release]; 
	[pool release];
}



void MSAParamManager::setAutoSave(bool b) {
	doAutoSave = b;
}


void MSAParamManager::loadNib(const char *nibName) {
	if(controller) [controller release];
	controller	= [[MSAParamUIController alloc] initWithNib:[NSString stringWithCString:nibName] andManager:this];
}

void MSAParamManager::setRootView(NSView *rootView) {
	if(controller) [controller release];
	controller	= [[MSAParamUIController alloc] initWithView:rootView andManager:this];
}



void MSAParamManager::loadStructure(const char * szFilename) {
	if(verbose) NSLog(@"MSAParamManager::loadStructure( %s )", szFilename);
	
	if(params) [params release];
	//	if(structure) [structure release];
	
	params			= [[NSMutableDictionary alloc] init];
	
	NSString *nsFilename			= [NSString stringWithCString: szFilename];
	NSArray *structure				= [[NSArray alloc] initWithContentsOfFile:nsFilename];
	if(structure == nil) structure	= [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:nsFilename ofType:nil]];
	
	if(structure == nil) {
		NSLog(@"*** %@ not found", nsFilename);
		return;
	}
	
	if(verbose) NSLog(@"Structure loaded: %@", structure);
	
	for(id page in structure) {
		NSString *pageName = [page objectAtIndex:0];
		addPage([pageName UTF8String]);
		for(int i=1; i<[page count]; i++) {
			NSDictionary	*control	= [page objectAtIndex:i];
			NSString		*title		= [control objectForKey:@"title"];
			const char		*szTitle	= [title UTF8String];
			NSString		*type		= [control objectForKey:@"type"];
			
			if([type compare:@"float"] == NSOrderedSame) {
				float min	= [[control objectForKey:@"min"] floatValue];
				float max	= [[control objectForKey:@"max"] floatValue];
				addFloat(szTitle, min, max);
			} else if([type compare:@"int"] == NSOrderedSame) {
				float min	= [[control objectForKey:@"min"] floatValue];
				float max	= [[control objectForKey:@"max"] floatValue];
				addInt(szTitle, min, max);
			} else if([type compare:@"header"] == NSOrderedSame) {
				addHeader(szTitle);
			} else if([type compare:@"bool"] == NSOrderedSame) {
				addBool(szTitle);
			}
			
		}
	}
}


//void MSAParamManager::setPreset(const char *szFilename) {
//	this->presetFilename = szFilename;
//}


void MSAParamManager::loadCurrentPreset() {
	if(verbose) NSLog(@"MSAParamManager::loadCurrentPreset( %s )", this->presetFilename.c_str());
	
	NSString *nsFilename	= [NSString stringWithFormat:@"%s", this->presetFilename.c_str()];
	NSDictionary *data		= [[NSDictionary alloc] initWithContentsOfFile:nsFilename];
	if(data == nil) data	= [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:nsFilename ofType:nil]];
	
	if(data == nil) {
		NSLog(@" *** %@ not found", nsFilename);
		return;
		//		std::exit(0);
	}
	
	for(id key in params) {
		MSAParam *param = [params objectForKey:key];
		param.value = [[data objectForKey:key] floatValue];
	}
	
	[data release];
}



void MSAParamManager::saveCurrentPreset() {
	if(verbose) NSLog(@"MSAParamManager::saveCurrentPreset( %s )", this->presetFilename.c_str());
	
	NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
	for(id key in params) {
		MSAParam *param = [params objectForKey:key];
		[temp setObject:[param get] forKey:key];
	}
	if(verbose) NSLog(@"saving settings: %@", temp);
	[temp writeToFile:[NSString stringWithFormat:@"%s", this->presetFilename.c_str()] atomically:YES];
	
}




const char* MSAParamManager::loadPreset(const char *szFilename) {
	if(szFilename) {
		this->presetFilename = szFilename;
		loadCurrentPreset();
	} else {
		NSOpenPanel* panel = [NSOpenPanel openPanel];
		
		[panel setCanChooseFiles:YES];
		[panel setCanChooseDirectories:NO];
		[panel setAllowsMultipleSelection:NO];
		[panel setTitle:@"Select preset to load"];
		[panel setRequiredFileType:@"plist"];
		[panel setAllowedFileTypes:[NSArray arrayWithObject:@"plist"]];
		[panel setAllowsOtherFileTypes:NO];
		
		NSString *nsPresetPath = [NSString stringWithUTF8String:presetFilename.c_str()];

		if([panel runModalForDirectory:[nsPresetPath stringByDeletingLastPathComponent] file:[nsPresetPath lastPathComponent]] == NSOKButton) {
			NSString* f = [[panel filenames] objectAtIndex:0];
			this->presetFilename = [f UTF8String];
			loadCurrentPreset();
		}
	}
	
	return presetFilename.c_str();
}



const char* MSAParamManager::savePreset() {
	NSSavePanel* panel = [NSSavePanel savePanel];
	
	[panel setTitle:@"Select preset to save"];
	[panel setRequiredFileType:@"plist"];
	[panel setAllowedFileTypes:[NSArray arrayWithObject:@"plist"]];
	[panel setAllowsOtherFileTypes:NO];
	
	NSString *nsPresetPath = [NSString stringWithUTF8String:presetFilename.c_str()];
	if([panel runModalForDirectory:[nsPresetPath stringByDeletingLastPathComponent] file:[nsPresetPath lastPathComponent]] == NSOKButton) {
		NSString* f = [panel filename];
		this->presetFilename = [f UTF8String];
		saveCurrentPreset();
	}
	
	return presetFilename.c_str();
}



void MSAParamManager::set(const char *name, float value) {
	MSAParam *p = [params objectForKey:[NSString stringWithCString:name]];
	if(p==NULL) {
		NSLog(@" *** WARNING: asking for property which doesn't exist: %s", name);
		return;
	}
	p.value = value;
}


float MSAParamManager::get(const char *name) {
	MSAParam *p = [params objectForKey:[NSString stringWithCString:name]];
	if(p==NULL) {
		NSLog(@" *** WARNING: asking for property which doesn't exist: %s", name);
		return 0;
	}
	return p.value;
}


void MSAParamManager::addPage(const char *name) {
	NSString *key = [NSString stringWithCString:name];
	view = [controller addTab:key];
	currentX		= padding;
	currentY		= padding;
	
	//	if(updatePreset) {
	//		currentPage		= [NSMutableArray arrayWithCapacity:0];
	//		[structure addObject:currentPage];
	//		[currentPage addObject:key];
	//	}
}


//	void addControl(ofxSimpleGuiControl& control);
//	void addContent(const char *name, ofBaseDraws &content, float fixwidth = -1);
//void MSAParamManager::addButton(const char *name);
//void MSAParamManager::addFPSCounter();

void MSAParamManager::addInt(const char *name, int min, int max) {
	if(verbose) NSLog(@"MSAParamManager::addInt %s %f %f", name, min, max);
	NSString *key = [NSString stringWithCString:name];
	MSAParam *param = [[MSAParam alloc] initWithIntSlider:key andManager:this andMin:min andMax:max];
	[params setObject:param forKey:key];
	[param release];
}


void MSAParamManager::addFloat(const char *name, float min, float max) {
	if(verbose) NSLog(@"MSAParamManager::addFloat %s %f %f", name, min, max);
	NSString *key = [NSString stringWithCString:name];
	MSAParam *param = [[MSAParam alloc] initWithFloatSlider:key andManager:this andMin:min andMax:max];
	[params setObject:param forKey:key];
	[param release];
	//	
	//	[currentPage addObject:[NSDictionary dictionaryWithObjectsAndKeys:
	//							key, @"title",
	//							@"f", @"type",		// float
	//							[NSNumber numberWithFloat:value], @"value",
	//							[NSNumber numberWithFloat:min], @"min",
	//							[NSNumber numberWithFloat:max], @"max",
	//							nil]];
}

//	void addFloat2d(const char *name, ofPoint& value, float xmin, float xmax, float ymin, float ymax);
void MSAParamManager::addHeader(const char *name) {
	if(verbose) NSLog(@"MSAParamManager::addHeader %s", name);
	NSString *key = [NSString stringWithCString:name];
	MSAParam *param = [[MSAParam alloc] initWithHeader:key andManager:this];
	[params setObject:param forKey:key];
	[param release];
}


void MSAParamManager::addBool(const char *name) {
	if(verbose) NSLog(@"MSAParamManager::addBool %s", name);
	NSString *key = [NSString stringWithCString:name];
	MSAParam *param = [[MSAParam alloc] initWithToggle:key andManager:this];
	[params setObject:param forKey:key];
	[param release];
	//	
	//	[currentPage addObject:[NSDictionary dictionaryWithObjectsAndKeys:
	//							key, @"title",
	//							@"t", @"type",		// toggle
	//							[NSNumber numberWithBool:value], @"value",
	//							nil]];
	//	
}
/*
 void MSAParamManager::addGap(int gap) {
 currentY -= gap;
 }
 */