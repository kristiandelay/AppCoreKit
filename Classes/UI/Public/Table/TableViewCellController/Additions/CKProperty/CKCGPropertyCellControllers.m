//
//  CKCGPropertyCellControllers.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCGPropertyCellControllers.h"
#import "CKProperty.h"
#import <CoreLocation/CoreLocation.h>

//CGSIZE

@interface CGSizeWrapper : NSObject{}
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat height;
@end
@implementation CGSizeWrapper
@synthesize width,height;
@end

@implementation CKCGSizePropertyCellController

- (void)postInit{
	[super postInit];
	self.multiFloatValue = [[[CGSizeWrapper alloc]init]autorelease];
    self.size = CGSizeMake(100,44 + 2 * 44);
}

- (void)propertyChanged{
    CKProperty* p = (CKProperty*)self.objectProperty;
	CGSize size = [[p value]CGSizeValue];
	
	CGSizeWrapper* sizeWrapper = (CGSizeWrapper*)self.multiFloatValue;
	sizeWrapper.width = size.width;
	sizeWrapper.height = size.height;
}

- (void)valueChanged{
	CKProperty* p = (CKProperty*)self.objectProperty;
	CGSizeWrapper* sizeWrapper = (CGSizeWrapper*)self.multiFloatValue;
	[p setValue:[NSValue valueWithCGSize:CGSizeMake(MAX(1,[sizeWrapper width]),MAX(1,[sizeWrapper height]))]];
}

@end

//CGPOINT

@interface CGPointWrapper : NSObject{}
@property(nonatomic,assign)CGFloat x;
@property(nonatomic,assign)CGFloat y;
@end
@implementation CGPointWrapper
@synthesize x,y;
@end

@implementation CKCGPointPropertyCellController

- (void)postInit{
	[super postInit];
	self.multiFloatValue = [[[CGPointWrapper alloc]init]autorelease];
    self.size = CGSizeMake(100,44 + 2 * 44);
}

- (void)propertyChanged{
    CKProperty* p = (CKProperty*)self.objectProperty;
	
	CGPoint point = [[p value]CGPointValue];
	
	CGPointWrapper* pointWrapper = (CGPointWrapper*)self.multiFloatValue;
	pointWrapper.x = point.x;
	pointWrapper.y = point.y;
}

- (void)valueChanged{
	CKProperty* p = (CKProperty*)self.objectProperty;
	CGPointWrapper* pointWrapper = (CGPointWrapper*)self.multiFloatValue;
	[p setValue:[NSValue valueWithCGPoint:CGPointMake(MAX(1,[pointWrapper x]),MAX(1,[pointWrapper y]))]];
}

@end

//CGRect

@interface CGRectWrapper : NSObject{}
@property(nonatomic,assign)CGFloat x;
@property(nonatomic,assign)CGFloat y;
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat height;
@end
@implementation CGRectWrapper
@synthesize x,y;
@synthesize width,height;
@end

@implementation CKCGRectPropertyCellController

- (void)postInit{
	[super postInit];
	self.multiFloatValue = [[[CGRectWrapper alloc]init]autorelease];
    self.size = CGSizeMake(100,44 + 4 * 44);
}

- (void)propertyChanged{
    CKProperty* p = (CKProperty*)self.objectProperty;
	
	CGRect rect = [[p value]CGRectValue];
	
	CGRectWrapper* rectWrapper = (CGRectWrapper*)self.multiFloatValue;
	rectWrapper.x = rect.origin.x;
	rectWrapper.y = rect.origin.y;
	rectWrapper.width = rect.size.width;
	rectWrapper.height = rect.size.height;
}

- (void)valueChanged{
	CKProperty* p = (CKProperty*)self.objectProperty;
	CGRectWrapper* rectWrapper = (CGRectWrapper*)self.multiFloatValue;
	[p setValue:[NSValue valueWithCGRect:CGRectMake([rectWrapper x],[rectWrapper y],MAX(1,[rectWrapper width]),MAX(1,[rectWrapper height]))]];
}

@end

//UIEdgeInsets

@interface UIEdgeInsetsWrapper : NSObject{}
@property(nonatomic,assign)CGFloat top;
@property(nonatomic,assign)CGFloat left;
@property(nonatomic,assign)CGFloat bottom;
@property(nonatomic,assign)CGFloat right;
@end
@implementation UIEdgeInsetsWrapper
@synthesize top,left;
@synthesize bottom,right;
@end

@implementation CKUIEdgeInsetsPropertyCellController

- (void)postInit{
	[super postInit];
	self.multiFloatValue = [[[UIEdgeInsetsWrapper alloc]init]autorelease];
    self.size = CGSizeMake(100,44 + 4 * 44);
}

- (void)propertyChanged{
    CKProperty* p = (CKProperty*)self.objectProperty;
	
	UIEdgeInsets insets = [[p value]UIEdgeInsetsValue];
	
	UIEdgeInsetsWrapper* insetsWrapper = (UIEdgeInsetsWrapper*)self.multiFloatValue;
	insetsWrapper.top = insets.top;
	insetsWrapper.left = insets.left;
	insetsWrapper.bottom = insets.bottom;
	insetsWrapper.right = insets.right;

}

- (void)valueChanged{
	CKProperty* p = (CKProperty*)self.objectProperty;
	UIEdgeInsetsWrapper* insetsWrapper = (UIEdgeInsetsWrapper*)self.multiFloatValue;
	[p setValue:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake([insetsWrapper top],[insetsWrapper left],[insetsWrapper bottom],[insetsWrapper right])]];
}

@end


//CGPOINT

@interface CLLocationCoordinate2DWrapper : NSObject{}
@property(nonatomic,assign)CGFloat latitude;
@property(nonatomic,assign)CGFloat longitude;
@end
@implementation CLLocationCoordinate2DWrapper
@synthesize latitude,longitude;
@end

@implementation CKCLLocationCoordinate2DPropertyCellController

- (void)postInit{
	[super postInit];
	self.multiFloatValue = [[[CLLocationCoordinate2DWrapper alloc]init]autorelease];
    self.size = CGSizeMake(100,44 + 2 * 44);
}

- (void)propertyChanged{
    CKProperty* p = (CKProperty*)self.objectProperty;
	
	CLLocationCoordinate2D coord;
    NSValue* value = [p value];
    if(value){
        [[p value]getValue:&coord];
        
        CLLocationCoordinate2DWrapper* coordWrapper = (CLLocationCoordinate2DWrapper*)self.multiFloatValue;
        coordWrapper.latitude = coord.latitude;
        coordWrapper.longitude = coord.longitude;
    }
}

- (void)valueChanged{
	CKProperty* p = (CKProperty*)self.objectProperty;
	CLLocationCoordinate2DWrapper* coordWrapper = (CLLocationCoordinate2DWrapper*)self.multiFloatValue;
	
	CLLocationCoordinate2D coord;
	coord.latitude = coordWrapper.latitude;
	coord.longitude = coordWrapper.longitude;
	[p setValue:[NSValue value:&coord withObjCType:@encode(CLLocationCoordinate2D)]];
}

@end



//CGAffineTransform

@interface CKCGAffineTransformWrapper : NSObject{}
@property(nonatomic,assign)CGFloat x;
@property(nonatomic,assign)CGFloat y;
@property(nonatomic,assign)CGFloat angle;
@property(nonatomic,assign)CGFloat scaleX;
@property(nonatomic,assign)CGFloat scaleY;
@end
@implementation CKCGAffineTransformWrapper
@synthesize x,y,angle,scaleX,scaleY;
@end

@implementation CKCGAffineTransformPropertyCellController

- (void)postInit{
	[super postInit];
	self.multiFloatValue = [[[CKCGAffineTransformWrapper alloc]init]autorelease];
    self.size = CGSizeMake(100,44 + 5 * 44);
}

- (id)init{
	if (self =[super init]) {
      	self.multiFloatValue = [[[CKCGAffineTransformWrapper alloc]init]autorelease];  
    }
	return self;
}

- (void)propertyChanged{
    CKProperty* p = (CKProperty*)self.objectProperty;
	
	CGAffineTransform transform;
    id value = [p value];
    if([value isKindOfClass:[NSValue class]]){
        [value getValue:&transform];
        
        CKCGAffineTransformWrapper* wrapper = (CKCGAffineTransformWrapper*)self.multiFloatValue;
        
        wrapper.x = CKCGAffineTransformGetTranslateX(transform);
        wrapper.y = CKCGAffineTransformGetTranslateY(transform);
        wrapper.angle =  CKCGAffineTransformGetRotation(transform) * 180 / M_PI;
        wrapper.scaleX = CKCGAffineTransformGetScaleX(transform);
        wrapper.scaleY = CKCGAffineTransformGetScaleY(transform);
    }
}

- (void)valueChanged{
	CKProperty* p = (CKProperty*)self.objectProperty;
	CKCGAffineTransformWrapper* wrapper = (CKCGAffineTransformWrapper*)self.multiFloatValue;
	
	CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, wrapper.scaleX,wrapper.scaleY);
    transform = CGAffineTransformRotate(transform, wrapper.angle * M_PI / 180.0 );
    transform = CGAffineTransformTranslate(transform, wrapper.x, wrapper.y);
	[p setValue:[NSValue value:&transform withObjCType:@encode(CGAffineTransform)]];
}

@end