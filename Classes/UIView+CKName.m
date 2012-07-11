//
//  UIView+CKName.m
//  CloudKit
//
//  Created by Sebastien Morel on 12-06-26.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "UIView+CKName.h"
#import <objc/runtime.h>
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKDebug.h"

static char kUIViewNameKey;

@implementation UIView (CKName)
@dynamic name;

- (void)setName:(NSString *)name{
    objc_setAssociatedObject(self, 
                             &kUIViewNameKey,
                             name,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*)name{
    return objc_getAssociatedObject(self, &kUIViewNameKey);
}


- (id)viewWithKeyPath:(NSString*)keyPath{
    NSArray* ar = [keyPath componentsSeparatedByString:@"."];
    UIView* currentView = self;
    for(NSString* key in ar){
        UIView* oldCurrentView = currentView;
        
        NSArray* propertyNames = [currentView allPropertyNames];
        if([propertyNames indexOfObject:key] != NSNotFound){
            currentView = [currentView valueForKey:key];
        }else{
            for(UIView* view in [currentView subviews]){
                if([[view name]isEqualToString:key]){
                    currentView = view;
                    break;
                }
            }
        }
        
        if(currentView == oldCurrentView){
            CKDebugLog( @"Could not find view for keypath : %@ in %@",keyPath,self);
        }
    }
    
    return currentView;
}


@end