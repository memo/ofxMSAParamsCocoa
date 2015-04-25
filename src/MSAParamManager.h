//
//  MSAParamManager.h
//  Bindings Test
//
//  Created by Mehmet Akten on 21/08/2009.
//  Copyright 2009 MSA Visuals Ltd.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MSAParamUIController.h"

#include <string>

class MSAParamManager {
public:
	int		currentX;
	int		currentY;
	int		height;
	
	int		gridWidth;
	int		padding;
	
	bool	verbose;

	NSView				*view;			// current view
	
	MSAParamManager();
	~MSAParamManager();
	
	void					loadStructure(const char *szFilename);
	
	// pass in an NSView* and a tabview and all controls will be created in it
	void					setRootView(NSView *rootView);
	
	// or load a nib who's owner is an MSAParamUIController and it's rootView is pointing to a view
	void					loadNib(const char *nibName);

	
//	void					setPreset(const char *szFilename);
	void					loadCurrentPreset();
	void					saveCurrentPreset();
	const char*				loadPreset(const char* szFilename = NULL);
	const char*				savePreset();	
	
	void					setAutoSave(bool b);
	
	void set(const char *name, float value);
	float get(const char *name);

	std::string				presetFilename;		// name of the current preset filename

	MSAParamUIController	*controller;		// controller for the actual UI

protected:
	bool					doAutoSave;
	NSMutableDictionary		*params;			// dictionary of MSAParam classes
	
	
	void addPage(const char *name);
//	void addControl(ofxSimpleGuiControl& control);
//	void addContent(const char *name, ofBaseDraws &content, float fixwidth = -1);
//	void addButton(const char *name);
//	void addFPSCounter();
	void addInt(const char *name, int min, int max);
	void addFloat(const char *name, float min, float max);
//	void addFloat2d(const char *name, ofPoint& value, float xmin, float xmax, float ymin, float ymax);
	void addHeader(const char *name);
	void addBool(const char *name);
	
//	void addGap(int gap = 20);
	
	// for saving / loading structure
//	NSMutableArray			*structure;
//	NSMutableArray			*currentPage;
};