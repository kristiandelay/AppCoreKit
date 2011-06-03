//
//  CKObjectCarouselViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKItemViewContainerController.h"
#import "CKCarouselView.h"
#import "CKObjectController.h"
#import "CKObjectViewControllerFactory.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKDocumentCollection.h"

@interface CKObjectCarouselViewController : CKItemViewContainerController<CKCarouselViewDataSource,CKCarouselViewDelegate,UIScrollViewDelegate> {
	CKCarouselView* _carouselView;
	
	int _numberOfObjectsToprefetch;
	NSMutableDictionary* _headerViewsForSections;
	
	UIPageControl* _pageControl;
}

@property (nonatomic,retain) IBOutlet CKCarouselView* carouselView;
@property (nonatomic,retain) IBOutlet UIPageControl* pageControl;
@property (nonatomic, assign) int numberOfObjectsToprefetch;

- (void)postInit;
- (void)fetchMoreIfNeededAtIndexPath:(NSIndexPath*)indexPath;
- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

@end