//
//  Settings.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Settings.h"

@interface Settings ()
- (BOOL)isKeyArray:(NSString *)key;
@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, strong) Settings *parent;
@property (nonatomic, strong) NSMutableSet *arrayKeys;
@property (nonatomic, strong) NSMutableDictionary *storage;
@end

#pragma mark -

@implementation Settings

@synthesize name = _name;
@synthesize parent = _parent;
@synthesize arrayKeys = _arrayKeys;
@synthesize storage = _storage;

#pragma mark - Initialization & disposal

+ (id)settingsWithName:(NSString *)name parent:(Settings *)parent {
	return [[self alloc] initWithName:name parent:parent];
}

- (id)initWithName:(NSString *)name parent:(Settings *)parent {
	self = [super init];
	if (self) {
		self.name = name;
		self.parent = parent;
		self.arrayKeys = [NSMutableSet set];
		self.storage = [NSMutableDictionary dictionary];
	}
	return self;
}

#pragma mark - Optional registration helpers

- (void)registerArrayForKey:(NSString *)key {
	[self.arrayKeys addObject:key];
}

#pragma mark - Values handling

- (id)objectForKey:(NSString *)key {
	if ([self isKeyArray:key]) {
		NSMutableArray *allValues = [NSMutableArray array];
		Settings *settings = self;
		while (settings) {
			NSArray *currentLevelValues = [settings.storage objectForKey:key];
			[allValues addObjectsFromArray:currentLevelValues];
			settings = settings.parent;
		}
		return allValues;
	}
	Settings *level = [self settingsForKey:key];
	return [level.storage objectForKey:key];
}
- (void)setObject:(id)value forKey:(NSString *)key {
	if ([self isKeyArray:key] && ![key isKindOfClass:[NSArray class]]) {
		NSMutableArray *array = [NSMutableArray array];
		if ([value isKindOfClass:[NSArray class]])
			[array addObjectsFromArray:value];
		else
			[array addObject:value];
		[self.storage setObject:array forKey:key];
		return;
	}
	return [self.storage setObject:value forKey:key];
}

- (BOOL)boolForKey:(NSString *)key {
	NSNumber *number = [self objectForKey:key];
	return [number boolValue];
}
- (void)setBool:(BOOL)value forKey:(NSString *)key {
	NSNumber *number = [NSNumber numberWithBool:value];
	[self setObject:number forKey:key];
}

- (NSInteger)integerForKey:(NSString *)key {
	NSNumber *number = [self objectForKey:key];
	return [number integerValue];
}
- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
	NSNumber *number = [NSNumber numberWithInteger:value];
	[self setObject:number forKey:key];
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key {
	NSNumber *number = [self objectForKey:key];
	return [number unsignedIntegerValue];
}
- (void)setUnsignedInteger:(NSUInteger)value forKey:(NSString *)key {
	NSNumber *number = [NSNumber numberWithUnsignedInteger:value];
	[self setObject:number forKey:key];
}

- (CGFloat)floatForKey:(NSString *)key {
	NSNumber *number = [self objectForKey:key];
	return [number doubleValue];
}
- (void)setFloat:(CGFloat)value forKey:(NSString *)key {
	NSNumber *number = [NSNumber numberWithDouble:value];
	[self setObject:number forKey:key];
}

#pragma mark - Introspection

- (void)enumerateSettings:(void(^)(Settings *settings, BOOL *stop))handler {
	Settings *settings = self;
	BOOL stop = NO;
	while (settings) {
		handler(settings, &stop);
		if (stop) break;
		settings = settings.parent;
	}
}

- (Settings *)settingsForKey:(NSString *)key {
	Settings *level = self;
	while (level) {
		if ([level.storage objectForKey:key]) break;
		level = level.parent;
	}
	return level;
}

- (BOOL)isKeyPresentAtThisLevel:(NSString *)key {
	if ([self.storage objectForKey:key]) return YES;
	return NO;
}

- (BOOL)isKeyArray:(NSString *)key {
	return [self.arrayKeys containsObject:key];
}

@end