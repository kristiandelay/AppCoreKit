//
//  CKFormSection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKFormSectionBase.h"

@class CKTableViewCellController;

/**
 */
@interface CKFormSection : CKFormSectionBase

///-----------------------------------
/// @name Creating Section Objects
///-----------------------------------

/**
 */
+ (CKFormSection*)section;

/**
 */
+ (CKFormSection*)sectionWithHeaderTitle:(NSString*)title;

/**
 */
+ (CKFormSection*)sectionWithHeaderView:(UIView*)view;

/**
 */
+ (CKFormSection*)sectionWithFooterTitle:(NSString*)title;

/**
 */
+ (CKFormSection*)sectionWithFooterView:(UIView*)view;

/**
 */
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers;

/**
 */
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers headerTitle:(NSString*)title;

/**
 */
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers headerView:(UIView*)view;

/**
 */
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers footerTitle:(NSString*)title;

/**
 */
+ (CKFormSection*)sectionWithCellControllers:(NSArray*)cellcontrollers footerView:(UIView*)view;


///-----------------------------------
/// @name Initializing Section Objects
///-----------------------------------

/**
 */
- (id)initWithCellControllers:(NSArray*)cellcontrollers headerTitle:(NSString*)title;

/**
 */
- (id)initWithCellControllers:(NSArray*)cellcontrollers headerView:(UIView*)view;

/**
 */
- (id)initWithCellControllers:(NSArray*)cellcontrollers footerTitle:(NSString*)title;

/**
 */
- (id)initWithCellControllers:(NSArray*)cellcontrollers footerView:(UIView*)view;

/**
 */
- (id)initWithCellControllers:(NSArray*)cellcontrollers;

///-----------------------------------
/// @name Querying the Section
///-----------------------------------

/**
 */
@property (nonatomic,retain, readonly) NSArray* cellControllers;

/**
 */
- (NSInteger)count;

///-----------------------------------
/// @name Inserting Cell Controllers
///-----------------------------------

/**
 */
- (void)insertCellController:(CKTableViewCellController *)controller atIndex:(NSUInteger)index;

/**
 */
- (void)addCellController:(CKTableViewCellController *)controller;

///-----------------------------------
/// @name Removing Cell Controllers
///-----------------------------------

/**
 */
- (void)removeCellController:(CKTableViewCellController *)controller;

/**
 */
- (void)removeCellControllerAtIndex:(NSUInteger)index;

@end

#import "CKFormSection+PropertyGrid.h"