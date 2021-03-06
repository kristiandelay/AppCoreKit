//
//  CKUIImagePropertyCellController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIImagePropertyCellController.h"


@implementation CKUIImagePropertyCellController

- (void)setupCell:(UITableViewCell *)cell{
    [super setupCell:cell];
    CKProperty* property = self.value;
    UIImage* image = [property value];
    cell.imageView.image = image;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
}


- (void)postInit{
    [super postInit];
    
    self.cellStyle = CKTableViewCellStyleSubtitle;
    self.flags = CKItemViewFlagNone;
}

@end
