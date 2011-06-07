//
//  CKNSObject+CKStore.m
//  StoreTest
//
//  Created by Sebastien Morel on 11-06-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject+CKStore.h"
#import "CKStoreDataSource.h"
#import <CloudKit/CKItem.h>
#import <CloudKit/CKStore.h>
#import <CloudKit/CKAttribute.h>
#import <CloudKit/CKDebug.h>
#import <CloudKit/CKModelObject.h>
#import <CloudKit/CKObjectProperty.h>
#import <CloudKit/CKNSValueTransformer+Additions.h>
#import <CloudKit/CKNSStringAdditions.h>
#import "MAZeroingWeakRef.h"

NSMutableDictionary* CKModelObjectManager = nil;

@implementation CKModelObject (CKStoreAddition)

- (NSDictionary*) attributesDictionaryForDomainNamed:(NSString*)domain{
	NSMutableDictionary* dico = [NSMutableDictionary dictionary];
	
	NSString* className = [[self class] description];
	className = [className stringByReplacingOccurrencesOfString:@"_MAZeroingWeakRefSubclass" withString:@""];
	[dico setObject:className forKey:@"@class"];
	
	NSArray* allProperties = [self allPropertyNames];
	for(NSString* propertyName in allProperties){
		CKObjectProperty* property = [CKObjectProperty propertyWithObject:self keyPath:propertyName];
		CKClassPropertyDescriptor* descriptor = [property descriptor];
		CKModelObjectPropertyMetaData* metaData = [property metaData];
		if( (metaData  && metaData.serializable == NO) || descriptor.isReadOnly == YES){}
		else{
			id propertyValue = [property value];
			if([propertyValue isKindOfClass:[CKDocumentCollection class]]
			   || [propertyValue isKindOfClass:[NSArray class]]
			   || [propertyValue isKindOfClass:[NSSet class]]){
				NSArray* allObjects = propertyValue;
				if([propertyValue isKindOfClass:[NSArray class]] == NO){
					allObjects = [propertyValue allObjects];
				}
				NSMutableArray* result = [NSMutableArray array];
				for(id subObject in allObjects){
					NSAssert([subObject isKindOfClass:[CKModelObject class]],@"Supports only auto serialization on CKModelObject");
					CKModelObject* model = (CKModelObject*)subObject;
					
					CKItem* item = [model saveToDomainNamed:domain];
					[result addObject:item];
				}
				[dico setObject:result forKey:propertyName];
			}
			else if([propertyValue isKindOfClass:[CKModelObject class]]){
				CKModelObject* model = (CKModelObject*)propertyValue;
				
				NSMutableArray* result = [NSMutableArray array];
				CKItem* item = [model saveToDomainNamed:domain];
				[result addObject:item];
				[dico setObject:result forKey:propertyName];
			}
			else{
				id value = [NSValueTransformer transformProperty:property toClass:[NSString class]];
				if([value isKindOfClass:[NSString class]]){
					[dico setObject:value forKey:propertyName];
				}
			}
		}
	}
	
	return dico;
}

- (void)deleteFromDomainNamed:(NSString*)domain{
	CKItem* item = [CKModelObject itemWithObject:self inDomainNamed:domain];
	if(item){
		CKStore* store = [CKStore storeWithDomainName:domain];
		[store deleteItems:[NSArray arrayWithObject:item]];
	}
}

+ (CKItem *)createItemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain {
	CKStore* store = [CKStore storeWithDomainName:domain];
	BOOL created;
	CKItem *item = [store fetchItemWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (domain == %@)", object.modelName, domain]
				 createIfNotFound:YES wasCreated:&created];
	if (created) {
		item.name = object.modelName;
		item.domain = store.domain;
		[store.domain addItemsObject:item];
	}
	[item updateAttributes:[object attributesDictionaryForDomainNamed:domain]];
	return item;
}

- (CKItem*)saveToDomainNamed:(NSString*)domain{
	if(_saving)
		return nil;
	
	_saving = YES;
	CKItem* item = nil;
	if(self.uniqueId == nil){
		self.uniqueId = [NSString stringWithNewUUID];
		if(self.modelName == nil){
			self.modelName = self.uniqueId;
		}
		[CKModelObject registerObject:self withUniqueId:self.uniqueId];
		item = [CKModelObject createItemWithObject:self inDomainNamed:domain];
	}
	else{
		item = [CKModelObject itemWithObject:self inDomainNamed:domain];
		if(item != nil){
			item.name = self.modelName;
			[item updateAttributes:[self attributesDictionaryForDomainNamed:domain]];
		}
	}		
	_saving = NO;
	return item;
}

+ (CKItem*)itemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain{
	return [CKModelObject itemWithObject:object inDomainNamed:domain createIfNotFound:NO];
}

+ (CKItem*)itemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain createIfNotFound:(BOOL)createIfNotFound{
	CKItem* item = [CKModelObject itemWithUniqueId:object.uniqueId inDomainNamed:domain];
	if(item == nil && createIfNotFound){
		return [object saveToDomainNamed:domain];
	}
	return item;
}

+ (CKItem*)itemWithUniqueId:(NSString*)theUniqueId inDomainNamed:(NSString*)domain{
	CKStore* store = [CKStore storeWithDomainName:domain];
	NSArray *res = [store fetchAttributesWithFormat:[NSString stringWithFormat:@"(name == 'uniqueId' AND value == '%@')",theUniqueId] arguments:nil];
	if([res count] != 1){
		//CKDebugLog(@"Warning : no object found in domain '%@' with uniqueId '%@'",domain,theUniqueId);
		return nil;
	}
	return [[res lastObject]item];	
}

+ (void)releaseObject:(id)sender target:(id)target{
	//CKDebugLog(@"delete object <%p> of type <%@> with id %@",target,[target class],[target uniqueId]);
	[CKModelObjectManager removeObjectForKey:[target uniqueId]];
}

+ (CKModelObject*)objectWithUniqueId:(NSString*)uniqueId{
	MAZeroingWeakRef* objectRef = [CKModelObjectManager objectForKey:uniqueId];
	id object = [objectRef target];
	if(objectRef != nil){
		//CKDebugLog(@"Found registered object <%p> of type <%@> with uniqueId : %@",object,[object class],uniqueId);
	}
	return object;
}

+ (CKModelObject*)loadObjectWithUniqueId:(NSString*)uniqueId{
	CKModelObject* obj = [self objectWithUniqueId:uniqueId];
	if(obj != nil)
		return obj;
	
	CKStore* store = [CKStore storeWithDomainName:@"whatever"];
	NSArray *res = [store fetchAttributesWithFormat:[NSString stringWithFormat:@"(name == 'uniqueId' AND value == '%@')",uniqueId] arguments:nil];
	if([res count] == 1){
		CKItem* item = (CKItem*)[[res lastObject]item];
		return [NSObject objectFromDictionary:[item propertyListRepresentation]];
	}
	return nil;
}

+ (void)registerObject:(CKModelObject*)object withUniqueId:(NSString*)uniqueId{
	if(uniqueId == nil){
		//CKDebugLog(@"Trying to register an object with no uniqueId : %@",object);
		return;
	}
	
	if(CKModelObjectManager == nil){
		CKModelObjectManager = [[NSMutableDictionary alloc]init];
	}
	
	MAZeroingWeakRef* objectRef = [[MAZeroingWeakRef alloc]initWithTarget:object];
	[objectRef setDelegate:self action:@selector(releaseObject:target:)];
	[CKModelObjectManager setObject:objectRef forKey:uniqueId];
	
	//CKDebugLog(@"Register object <%p> of type <%@> with id %@",object,[object class],uniqueId);
}

@end