//
//  CKUITableView+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUITableView+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKModelObject.h"


@implementation UITableView (CKIntrospectionAdditions)

- (void)separatorStyleMetaData:(CKModelObjectPropertyMetaData*)metaData{
	metaData.enumDefinition = CKEnumDictionary(UITableViewCellSeparatorStyleNone,
											   UITableViewCellSeparatorStyleSingleLine,
											   UITableViewCellSeparatorStyleSingleLineEtched);
}

@end