//
//  ObjectIntrospection.m
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObject+Introspection.h"
#import <objc/runtime.h>
#import <Foundation/NSKeyValueCoding.h>

@implementation CKObjectProperty
@synthesize name;
@synthesize type;
@synthesize attributes;
@synthesize isObject;
@synthesize isSelector;

- (NSString*) description{
	return [NSString stringWithFormat:@"%@",name];
}

/*
 c : char
 i : int
 s : short
 l : long
 l is treated as a 32-bit quantity on 64-bit programs.
 q : long long
 C : unsigned char
 I : unsigned int
 S : unsigned short
 L : unsigned long
 Q : unsigned long long
 f : float
 d : double
 B : C++ bool or a C99 _Bool
 v : void
 * : character string (char *)
 @ : object (whether statically typed or typed id)
 # : class object (Class)
 : : method selector (SEL)
 [array type] : array
 {name=type...} : structure
 (name=type...) : union
 bnum : bit field of num bits
 ^type : pointer to type
 ? : unknown type (among other things, this code is used for function pointers)
*/ 

-(NSString*)getTypeDescriptor{
	return [attributes substringWithRange: NSMakeRange(1,2)];
}


@end

static const char *getPropertyType(objc_property_t property) {
	if(property){
		const char *attributes = property_getAttributes(property);
		char buffer[1 + strlen(attributes)];
		strcpy(buffer, attributes);
		char *state = buffer, *attribute;
		while ((attribute = strsep(&state, ",")) != NULL) {
			if(strlen(attribute) > 4){
				if (attribute[0] == 'T' && attribute[1] == '@') {
					//ca ca chie !!!!
					NSString* type = [[NSString stringWithUTF8String:attribute] substringWithRange: NSMakeRange (3, strlen(attribute)-4)];
					return [type UTF8String];
				}
			}
		}
	}
    return "";
}

/* Default predicate helpers
 */
#define CKMakeArrayFromArguments(obj1)\
    va_list ArgumentList;\
    va_start(ArgumentList,obj1);\
    NSMutableArray* types = [[NSMutableArray array]autorelease];\
    [types addObject:type1];\
    Class type = nil;\
    while (type = va_arg(ArgumentList, Class)){\
        [types addObject:type];\
    }\
    va_end(ArgumentList);

CKObjectPredicate CKObjectPredicateMakeIsOfType(Class type1,...) {
	CKMakeArrayFromArguments(type1);
	CKObjectPredicate block =  ^(id object) {
		for(Class c in types){
			if([object isKindOfClass:c])
				return YES;
		}
		return NO;
	};
	return Block_copy(block);
}

CKObjectPredicate CKObjectPredicateMakeIsNotOfType(Class type1,...) {
	CKMakeArrayFromArguments(type1);
	CKObjectPredicate block =  ^(id object) {
		for(Class c in types){
			if([object isKindOfClass:c])
				return NO;
		}
		return YES;
	};
	return Block_copy(block);
}

CKObjectPredicate CKObjectPredicateMakeExpandAll() {
	CKObjectPredicate block = ^(id object){
		return YES;
	};
	return Block_copy(block);
}


@interface NSObject ()
- (void)filterProperties:(NSMutableArray*)results 
					explored:(NSMutableSet*)explored 
					instance:(id)instance 
					expandWith:(CKObjectPredicate)expandWith 
					insertWith:(CKObjectPredicate)insertWith;

- (void) filterObjects : (NSMutableArray*)results 
				    explored:(NSMutableSet*)explored 
					instance:(id)instance 
				    expandWith:(CKObjectPredicate)expandWith 
				    insertWith:(CKObjectPredicate)insertWith 
				    addInstance:(BOOL)addInstance;

- (NSString*)concatenateAndUpperCaseFirstChar:(NSString*)input prefix:(NSString*)prefix suffix:(NSString*)suffix;
@end


@implementation NSObject (CKNSObjectIntrospection)

+(CKObjectProperty*)propertyForDescriptor:(objc_property_t)descriptor{
	const char *propName = property_getName(descriptor);
	if(propName) {
		//const char *propType = getPropertyType(property);
		const char *attributes = property_getAttributes(descriptor);
		
		CKObjectProperty* objectProperty = [[[CKObjectProperty alloc]init]autorelease];
		objectProperty.name = [NSString stringWithUTF8String:propName];
		//objectProperty.type = [NSString stringWithUTF8String:propType];
		objectProperty.attributes = [NSString stringWithUTF8String:attributes];
		objectProperty.isObject = [objectProperty.attributes hasPrefix:@"T@"];
		objectProperty.isSelector = [objectProperty.attributes hasPrefix:@"T:"];
		
		const char *propType = getPropertyType(descriptor);
		Class returnType = NSClassFromString([NSString stringWithCString:propType encoding:NSASCIIStringEncoding ]);
		objectProperty.type = returnType;
		return objectProperty;
	}
	return nil;
}

+(CKObjectProperty*) property:(id)object forKeyPath:(NSString*)keyPath{
	id subObject = object;
	
	NSArray * ar = [keyPath componentsSeparatedByString:@"."];
	for(int i=0;i<[ar count]-1;++i){
		NSString* path = [ar objectAtIndex:i];
		subObject = [subObject valueForKey:path];
	}
	NSAssert(subObject,@"unable to find property %@ in %@",keyPath,object);
	return [self property:[subObject class] forKey:[ar objectAtIndex:[ar count] -1 ]];
}

+(CKObjectProperty*) property:(Class)c forKey:(NSString*)name{
	objc_property_t property = class_getProperty(c, [name UTF8String]);
	return [NSObject propertyForDescriptor:property];
}

- (void)introspection:(Class)c array:(NSMutableArray*)array{
	unsigned int outCount, i;
    objc_property_t *ps = class_copyPropertyList(c, &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = ps[i];
        CKObjectProperty* objectProperty = [NSObject propertyForDescriptor:property ];
		[array addObject:objectProperty];
    }
    free(ps);	
	
	Class f = class_getSuperclass(c);
	if(f){
		[self introspection:f array:array];
	}
	
}

- (NSMutableArray*)allProperties{
	NSMutableArray* ar = [NSMutableArray array];
	[self introspection:[self class] array:ar];
	return ar;
}

+ (BOOL)isKindOf:(Class)type parentType:(Class)parentType{
	if(parentType){
		const char* t1 = class_getName(type);
		const char* t2 = class_getName(parentType);
		if(strcmp(t1,t2) == 0)
			return YES;
		Class p = class_getSuperclass(type);
		if(p)
			return [NSObject isKindOf:p parentType:parentType];
		return NO;
	}
	return YES;
}

- (void)filterProperties:(NSMutableArray*)results 
					explored:(NSMutableSet*)explored 
					instance:(id)instance 
					expandWith:(CKObjectPredicate)expandWith 
					insertWith:(CKObjectPredicate)insertWith 
{
	if(instance && [instance conformsToProtocol:@protocol(NSObject)]){
		NSArray* properties = [instance allProperties];
		for(CKObjectProperty* property in properties){
			if(property && property.isObject){
				id instanceProperty = [instance valueForKey:property.name];
				if(instanceProperty){
					[self filterObjects:results explored:explored instance:instanceProperty expandWith:expandWith insertWith:insertWith addInstance:YES];
				}
			}
		}
	}
		
}

- (void) filterObjects : (NSMutableArray*)results 
					 explored:(NSMutableSet*)explored 
					 instance:(id)instance 
				     expandWith:(CKObjectPredicate)expandWith 
				     insertWith:(CKObjectPredicate)insertWith 
				     addInstance:(BOOL)addInstance
{
	if(instance && ![explored containsObject:instance]){//avoid recursions
		[explored addObject:instance];
		if(addInstance && insertWith(instance)){
			[results addObject:instance];
		}
		
		if(expandWith(instance)){
			//Handle collections
			if([instance conformsToProtocol:@protocol(NSFastEnumeration)]){
				for(id subInstance in instance){
					[self filterObjects:results explored:explored instance:subInstance expandWith:expandWith insertWith:insertWith addInstance:YES];
				}
			}
			else{
				//And properties
				[self filterProperties:results explored:explored instance:instance expandWith:expandWith insertWith:insertWith];
			}
		}
	}
}

- (NSMutableArray*)subObjects :(CKObjectPredicate)expandWith insertWith:(CKObjectPredicate)insertWith includeSelf:(BOOL)includeSelf{
	NSMutableSet* objectsExplored = [NSMutableSet set];
	NSMutableArray* results = [NSMutableArray array];
	[self filterObjects:results explored:objectsExplored instance:self expandWith:expandWith insertWith:insertWith addInstance:includeSelf];
	return results;

}

- (NSString*)concatenateAndUpperCaseFirstChar:(NSString*)input prefix:(NSString*)prefix suffix:(NSString*)suffix{
	NSString* firstChar = [input substringWithRange: NSMakeRange (0, 1)];
	NSString* rest = [input substringWithRange: NSMakeRange (1, [input length] - 1)];
	return [NSString stringWithFormat:@"%@%@%@%@",prefix,[firstChar uppercaseString],rest,suffix];
}

- (SEL)insertorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"add" suffix:@"Object:"];
	return NSSelectorFromString(selectorName);
}

- (SEL)keyValueInsertorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"add" suffix:@"Object:forKey:"];
	return NSSelectorFromString(selectorName);
}

- (SEL)typeCheckSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"is" suffix:@"CompatibleWith:"];
	return NSSelectorFromString(selectorName);
}

- (SEL)setSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"set" suffix:@":"];
	return NSSelectorFromString(selectorName);
}

@end
