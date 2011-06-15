//
//  CKFeedViewControllerFactory.m
//  FeedView
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectViewControllerFactory.h"
#import "CKObjectController.h"
#import "CKDocumentCollectionCellController.h"
#import "CKDocumentCollection.h"
#import <objc/runtime.h>

#import "CKStyles.h"
#import "CKStyleManager.h"
#import "CKTableViewCellController+Style.h"
#import "CKTableViewCellController+StyleManager.h"

@interface CKObjectViewControllerFactory ()

@property (nonatomic, retain, readwrite) NSMutableArray* mappings;
@property (nonatomic, assign, readwrite) id objectController;
@end


@implementation CKObjectViewControllerFactory
@synthesize mappings = _mappings;
@synthesize objectController = _objectController;

- (void)dealloc{
	[_mappings release];
	_mappings = nil;
	_objectController = nil;
	[super dealloc];
}

+ (CKObjectViewControllerFactory*)factoryWithMappings:(NSArray*)mappings {
	return [CKObjectViewControllerFactory factoryWithMappings:mappings withFactoryClass:[CKObjectViewControllerFactory class]];
}

+ (id)factoryWithMappings:(NSArray*)mappings withFactoryClass:(Class)type{
	CKObjectViewControllerFactory* factory = (CKObjectViewControllerFactory*)[[[type alloc]init]autorelease];
	factory.mappings = [NSMutableArray arrayWithArray:mappings];
	return factory;
}

- (void)setMappings:(id)theMappings{
	NSMutableArray* res = [NSMutableArray array];
	[res mapControllerClass:[CKDocumentCollectionViewCellController class] withObjectClass:[CKDocumentCollection class]];
	[res addObjectsFromArray:theMappings];
	
	[_mappings release];
	_mappings = [res retain];
}

- (CKObjectViewControllerFactoryItem*)factoryItemAtIndexPath:(NSIndexPath*)indexPath{
	id object = [_objectController objectAtIndexPath:indexPath];
	for(CKObjectViewControllerFactoryItem* item in _mappings){
		if([item matchWithObject:object]){
			return item;
		}
	}
	NSAssert(NO,@"controller factory could not find matching item for object '%@'",object);
	return nil;
}


- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	CKObjectViewControllerFactoryItem* item = [self factoryItemAtIndexPath:indexPath];
	return [item controllerForObject:object atIndexPath:indexPath];
}

- (CKItemViewFlags)flagsForControllerIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params{
	CKObjectViewControllerFactoryItem* item = [self factoryItemAtIndexPath:indexPath];
	id object = [_objectController objectAtIndexPath:indexPath];
	[params setObject:object forKey:CKTableViewAttributeObject];
	return [item flagsForObject:object atIndexPath:indexPath withParams:params];
}

- (CGSize)sizeForControllerAtIndexPath:(NSIndexPath*)indexPath  params:(NSMutableDictionary*)params{
	CKObjectViewControllerFactoryItem* item = [self factoryItemAtIndexPath:indexPath];
	id object = [_objectController objectAtIndexPath:indexPath];
	[params setObject:object forKey:CKTableViewAttributeObject];
	return [item sizeForObject:object atIndexPath:indexPath withParams:params];
}

@end



NSString* CKObjectViewControllerFactoryItemCreate = @"CKObjectViewControllerFactoryItemCreate";
NSString* CKObjectViewControllerFactoryItemInit = @"CKObjectViewControllerFactoryItemInit";
NSString* CKObjectViewControllerFactoryItemSetup = @"CKObjectViewControllerFactoryItemSetup";
NSString* CKObjectViewControllerFactoryItemSelection = @"CKObjectViewControllerFactoryItemSelection";
NSString* CKObjectViewControllerFactoryItemAccessorySelection = @"CKObjectViewControllerFactoryItemAccessorySelection";
NSString* CKObjectViewControllerFactoryItemFlags = @"CKObjectViewControllerFactoryItemFlags";
NSString* CKObjectViewControllerFactoryItemFilter = @"CKObjectViewControllerFactoryItemFilter";
NSString* CKObjectViewControllerFactoryItemSize = @"CKObjectViewControllerFactoryItemSize";
NSString* CKObjectViewControllerFactoryItemBecomeFirstResponder = @"CKObjectViewControllerFactoryItemBecomeFirstResponder";
NSString* CKObjectViewControllerFactoryItemResignFirstResponder = @"CKObjectViewControllerFactoryItemResignFirstResponder";

@implementation CKObjectViewControllerFactoryItem
@synthesize controllerClass = _controllerClass;
@synthesize params = _params;

- (id)init{
	[super init];
	self.params = [NSMutableDictionary dictionary];
	return self;
}

- (void)dealloc{
	[_params release];
	_params = nil;
	_controllerClass = nil;
	[super dealloc];
}

- (BOOL)matchWithObject:(id)object{
	id filter = [_params objectForKey:CKObjectViewControllerFactoryItemFilter];
	if(filter != nil){
		id filter = [_params objectForKey:CKObjectViewControllerFactoryItemFilter];
		if([filter isKindOfClass:[CKCallback class]]){
			CKCallback* callback = (CKCallback*)filter;
			id returnValue = [callback execute:object];
			NSAssert([returnValue isKindOfClass:[NSNumber class]],@"filter callback should return BOOL as an NSNumber");
			NSNumber* number = (NSNumber*)returnValue;
			return [number boolValue];
		}
		else if([filter isKindOfClass:[NSPredicate class]]){
			NSPredicate* predicate = (NSPredicate*)filter;
			return [predicate evaluateWithObject:object];
		}
	}
	return NO;
}

- (CKCallback*)createCallback{
	return [_params objectForKey:CKObjectViewControllerFactoryItemCreate];
}

- (CKCallback*)initCallback{
	return [_params objectForKey:CKObjectViewControllerFactoryItemInit];
}

- (CKCallback*)setupCallback{
	return [_params objectForKey:CKObjectViewControllerFactoryItemSetup];
}

- (CKCallback*)selectionCallback{
	return [_params objectForKey:CKObjectViewControllerFactoryItemSelection];
}

- (CKCallback*)accessorySelectionCallback{
	return [_params objectForKey:CKObjectViewControllerFactoryItemAccessorySelection];
}

- (CKCallback*)becomeFirstResponderCallback{
	return [_params objectForKey:CKObjectViewControllerFactoryItemBecomeFirstResponder];
}

- (CKCallback*)resignFirstResponderCallback{
	return [_params objectForKey:CKObjectViewControllerFactoryItemResignFirstResponder];
}

- (CKItemViewFlags)flagsForObject:(id)object atIndexPath:(NSIndexPath*)indexPath  withParams:(NSMutableDictionary*)params{
	//Style size first
	NSMutableDictionary* controllerStyle = [CKItemViewController styleForItem:self object:object indexPath:indexPath parentController:[params parentController]];
	if([controllerStyle isEmpty] == NO){
		if([controllerStyle containsObjectForKey:CKStyleCellFlags]){
			return [controllerStyle cellFlags];
		}
	}
	
	id flagsObject = [_params objectForKey:CKObjectViewControllerFactoryItemFlags];
	if(flagsObject != nil){
		if([flagsObject isKindOfClass:[CKCallback class]]){
			CKCallback* flagsCallBack = (CKCallback*)flagsObject;
			if(flagsCallBack != nil){
				NSNumber* number = [flagsCallBack execute:params];
				CKItemViewFlags flags = (CKItemViewFlags)[number intValue];
				return flags;
			}
		}
		else if([flagsObject isKindOfClass:[NSNumber class]]){
			NSNumber* number = (NSNumber*)flagsObject;
			CKItemViewFlags flags = (CKItemViewFlags)[number intValue];
			return flags;
		}
		else{
			NSAssert(NO,@"invalid type for controller mappings for key '%@' controllerClass '%@'",CKObjectViewControllerFactoryItemFlags,self.controllerClass);
		}
	}
	else{
		Class theClass = self.controllerClass;
		if(theClass && [theClass respondsToSelector:@selector(flagsForObject:withParams:)]){
			CKItemViewFlags flags = [theClass flagsForObject:object withParams:params];
			return flags;
		}
	}
	return CKItemViewFlagNone;
}

- (CGSize)sizeForObject:(id)object atIndexPath:(NSIndexPath*)indexPath withParams:(NSMutableDictionary*)params{
	//Style size first
	NSMutableDictionary* controllerStyle = [CKItemViewController styleForItem:self object:object indexPath:indexPath parentController:[params parentController]];
	if([controllerStyle isEmpty] == NO){
		if([controllerStyle containsObjectForKey:CKStyleCellSize]){
			return [controllerStyle cellSize];
		}
	}
	
	id sizeObject = [_params objectForKey:CKObjectViewControllerFactoryItemSize];
	if(sizeObject != nil){
		if([sizeObject isKindOfClass:[CKCallback class]]){
			CKCallback* sizeCallBack = (CKCallback*)sizeObject;
			if(sizeCallBack != nil){
				NSValue* value = [sizeCallBack execute:params];
				CGSize size = [value CGSizeValue];
				return size;
			}
		}
		else if([sizeObject isKindOfClass:[NSValue class]]){
			NSValue* value = (NSValue*)sizeObject;
			CGSize size = [value CGSizeValue];
			return size;
		}
		else{
			NSAssert(NO,@"invalid type for controller mappings for key '%@' controllerClass '%@'",CKObjectViewControllerFactoryItemFlags,self.controllerClass);
		}
	}
	else{
		Class theClass = self.controllerClass;
		if(theClass && [theClass respondsToSelector:@selector(viewSizeForObject:withParams:)]){
			NSValue* v = (NSValue*) [theClass performSelector:@selector(viewSizeForObject:withParams:) withObject:object withObject:params];
			CGSize size = [v CGSizeValue];
			return size;
		}
	}
	return CGSizeMake(100,44);
}

- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	CKItemViewController* controller = [[[self.controllerClass alloc]init]autorelease];
	controller.initCallback = [self initCallback];
	controller.setupCallback = [self setupCallback];
	controller.selectionCallback = [self selectionCallback];
	controller.accessorySelectionCallback = [self accessorySelectionCallback];
	controller.becomeFirstResponderCallback = [self becomeFirstResponderCallback];
	controller.resignFirstResponderCallback = [self resignFirstResponderCallback];
	
	[controller performSelector:@selector(setIndexPath:) withObject:indexPath];
	[controller setValue:object];
	
	id createObject = [_params objectForKey:CKObjectViewControllerFactoryItemCreate];
	if(createObject != nil && [createObject isKindOfClass:[CKCallback class]]){
		CKCallback* createCallBack = (CKCallback*)createObject;
		[createCallBack execute:controller];
	}
	
	return controller;
}

- (void)setCreateBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKObjectViewControllerFactoryItemCreate];
}

- (void)setInitBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKObjectViewControllerFactoryItemInit];
}

- (void)setSetupBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKObjectViewControllerFactoryItemSetup];
}

- (void)setSelectionBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKObjectViewControllerFactoryItemSelection];
}

- (void)setAccessorySelectionBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKObjectViewControllerFactoryItemAccessorySelection];
}

- (void)setFlagsBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKObjectViewControllerFactoryItemFlags];
}

- (void)setFilterBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKObjectViewControllerFactoryItemFilter];
}

- (void)setSizeBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKObjectViewControllerFactoryItemSize];
}

- (void)setBecomeFirstResponderBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKObjectViewControllerFactoryItemBecomeFirstResponder];
}

- (void)setResignFirstResponderBlock:(CKCallbackBlock)block{
	[self.params setObject:[CKCallback callbackWithBlock:block] forKey:CKObjectViewControllerFactoryItemResignFirstResponder];
}


- (void)setCreateTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKObjectViewControllerFactoryItemCreate];
}

- (void)setInitTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKObjectViewControllerFactoryItemInit];
}

- (void)setSetupTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKObjectViewControllerFactoryItemSetup];
}

- (void)setSelectionTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKObjectViewControllerFactoryItemSelection];
}

- (void)setAccessorySelectionTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKObjectViewControllerFactoryItemAccessorySelection];
}

- (void)setFlagsTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKObjectViewControllerFactoryItemFlags];
}

- (void)setFilterTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKObjectViewControllerFactoryItemFilter];
}

- (void)setSizeTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKObjectViewControllerFactoryItemSize];
}

- (void)setBecomeFirstResponderTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKObjectViewControllerFactoryItemBecomeFirstResponder];
}

- (void)setResignFirstResponderTarget:(id)target action:(SEL)action{
	[self.params setObject:[CKCallback callbackWithTarget:target action:action] forKey:CKObjectViewControllerFactoryItemResignFirstResponder];
}

- (void)setFlags:(CKItemViewFlags)flags{
	[self.params setObject:[NSNumber numberWithInt:flags] forKey:CKObjectViewControllerFactoryItemFlags];
}

- (void)setFilterPredicate:(NSPredicate*)predicate{
	[self.params setObject:predicate forKey:CKObjectViewControllerFactoryItemFilter];
}

- (void)setSize:(CGSize)size{
	[self.params setObject:[NSValue valueWithCGSize:size] forKey:CKObjectViewControllerFactoryItemSize];
}


@end

@implementation NSMutableArray (CKObjectViewControllerFactory)


- (CKObjectViewControllerFactoryItem*)mapControllerClass:(Class)controllerClass withParams:(NSMutableDictionary*)params{
	CKObjectViewControllerFactoryItem* item = [[[CKObjectViewControllerFactoryItem alloc]init]autorelease];
	item.controllerClass = controllerClass;
	item.params = params;
	[self addObject:item];
	return item;
}

- (CKObjectViewControllerFactoryItem*)mapControllerClass:(Class)controllerClass withObjectClass:(Class)objectClass{
	return [self mapControllerClass:controllerClass withParams:[NSMutableDictionary dictionaryWithObject:
														 [CKCallback callbackWithBlock:^(id object){return (id)[NSNumber numberWithBool:[object isKindOfClass:objectClass]];}] 
																					forKey:CKObjectViewControllerFactoryItemFilter]];
}

@end


