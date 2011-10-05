//
//  CKOptionCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-11.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKOptionCellController.h"

@implementation CKOptionCellController

@synthesize values = _values;
@synthesize labels = _labels;
@synthesize multiSelectionEnabled = _multiSelectionEnabled;


- (id)initWithTitle:(NSString *)title values:(NSArray *)values labels:(NSArray *)labels {
	if (labels) NSAssert(labels.count == values.count, @"labels.count != values.count");

	if (self = [super initWithText:title]) {
		self.values = values;
		self.labels = labels;
		self.style = UITableViewCellStyleValue1;
	}
	return self;
}

- (id)initWithTitle:(NSString *)title values:(NSArray *)values labels:(NSArray *)labels multiSelectionEnabled:(BOOL)multiSelectionEnabled{
	[self initWithTitle:title values:values labels:labels];
	self.multiSelectionEnabled = multiSelectionEnabled;
	return self;
}

- (void)dealloc {
	self.values = nil;
	self.labels = nil;
	[super dealloc];
}

- (NSString *)labelForValue:(id)value {
	if (value == nil) return nil;
	if(self.multiSelectionEnabled){
		NSMutableString* str = [NSMutableString string];
		NSInteger intValue = [value intValue];
		for(int i= 0;i < [self.values count]; ++i){
			NSNumber* v = [self.values objectAtIndex:i];
			NSString* l = [self.labels objectAtIndex:i];
			if(intValue & [v intValue]){
				if([str length] > 0){
					[str appendFormat:@" | %@",l];
				}
				else{
					[str appendString:l];
				}
			}
		}
	}
	else{
		NSInteger index = [self.values indexOfObject:value];
		return (self.labels && index != NSNotFound) ? [self.labels objectAtIndex:index] : [NSString stringWithFormat:@"%@", value];
	}
	return nil;
}

- (NSArray*)indexesForValue:(NSInteger) value{
	NSMutableArray* indexes = [NSMutableArray array];
	NSInteger intValue = value;
	for(int i= 0;i < [self.values count]; ++i){
		NSNumber* v = [self.values objectAtIndex:i];
		if(intValue & [v intValue]){
			[indexes addObject:[NSNumber numberWithInt:i]];
		}
	}
	return indexes;
}

//

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	cell.textLabel.text = self.text;
	cell.detailTextLabel.text = [self labelForValue:self.value];
}

- (void)didSelectRow {
	[super didSelectRow];
	CKOptionTableViewController *optionTableController = nil;
	if(self.multiSelectionEnabled){
		optionTableController = [[[CKOptionTableViewController alloc] initWithValues:self.values labels:self.labels selected:[self indexesForValue:[self.value intValue]] multiSelectionEnabled:YES] autorelease];
	}
	else{
		optionTableController = [[[CKOptionTableViewController alloc] initWithValues:self.values labels:self.labels selected:self.value] autorelease];
	}
	optionTableController.title = self.text;
	optionTableController.optionTableDelegate = self;
	[self.parentController.navigationController pushViewController:optionTableController animated:YES];
}

//

- (void)optionTableViewController:(CKOptionTableViewController *)tableViewController didSelectValueAtIndex:(NSInteger)index {
	if(self.multiSelectionEnabled){
		NSArray* indexes = tableViewController.selectedIndexes;
		NSInteger v = 0;
		for(NSNumber* index in indexes){
			v |= [[self.values objectAtIndex:[index intValue]]intValue];
		}
		self.value = [NSNumber numberWithInt:v];
	}
	else{
		self.value = [self.values objectAtIndex:tableViewController.selectedIndex];
	}
	
	if(self.tableViewCell){
		self.tableViewCell.detailTextLabel.text = [self labelForValue:self.value];
	}
	
	if(!self.multiSelectionEnabled){
		[self.parentController.navigationController popViewControllerAnimated:YES];
	}
}

@end
