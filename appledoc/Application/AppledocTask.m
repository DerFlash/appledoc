//
//  AppledocTask.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings+Appledoc.h"
#import "Objects.h"
#import "Store.h"
#import "AppledocTask.h"

@interface AppledocTask ()
@property (nonatomic, strong, readwrite) GBSettings *settings;
@property (nonatomic, strong, readwrite) Store *store;
@end

#pragma mark -

@implementation AppledocTask

#pragma mark - Running the task

- (GBResult)runWithSettings:(GBSettings *)settings store:(Store *)store {
	self.settings = settings;
	self.store = store;
	return [self runTask];
}

#pragma mark - Properties

- (NSFileManager *)fileManager {
	if (_fileManager) return _fileManager;
	LogDebug(@"Initializing file manager due to first access...");
	_fileManager = [NSFileManager defaultManager];
	return _fileManager;
}

@end