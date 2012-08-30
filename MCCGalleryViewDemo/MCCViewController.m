//
//  MCCViewController.m
//  MCCGalleryViewDemo
//
//  Created by Thierry Passeron on 29/08/12.
//  Copyright (c) 2012 Monte-Carlo Computing. All rights reserved.
//

#import "MCCViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "MCCGalleryView.h"
#import "MCCZImageView.h"

@implementation MCCViewController

/* 
 
 Let's create a gallery view and display some images

 (1) create the galleryView
 (2) set required properties
 (3) set optional properties
 (4) load pages and attach the views
 
 Notice that you can experiment in (3) or even comment out (3). Only (1), (2) and (4) are required to have the gallery running.
 
*/
- (void)viewDidLoad {
  static NSString *identifier = @"MyPagesCache"; // a reuse identifier
  
  [super viewDidLoad];
  
  /*******/
  /* (1) */
  /*******/
  
  __block MCCGalleryView *gv = [[[MCCGalleryView alloc]initWithFrame:self.view.bounds]autorelease];
  
  
  /*******/
  /* (2) */
  /*******/
  
  gv.pagesCount = 7;
  
  gv.pageBlock = ^id(NSUInteger pageIndex) {
    UIView *page = [gv dequeueReusablePageWithIdentifier:identifier];
    
    if (!page) { /* Create a new page */
      page = [[[MCCZImageView alloc]initWithFrame:self.view.bounds]autorelease];
      page.layer.borderWidth = 5.0;
      page.layer.borderColor = [UIColor whiteColor].CGColor;
      page.backgroundColor = [UIColor darkGrayColor];
    }
    
    /* Populate the page */
    
    NSNumber *index = [NSNumber numberWithInt:pageIndex];
    [page.layer setValue:index forKey:@"pageIndex"]; // Async flag
    
    /* Load the image asynchronously */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      if ([page.layer valueForKey:@"pageIndex"] == index) { // Check the async flag
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%u.jpg", pageIndex]];
        
        forceImageDecompression(image);
        
        dispatch_async(dispatch_get_main_queue(), ^{
          if ([page.layer valueForKey:@"pageIndex"] == index) [((MCCZImageView*)page)setImage:image];
        });
      }
    });
    
    return page;
  };
  
  gv.recycleBlock = ^NSString *(id page) {
    [((UIView*)page).layer setValue:nil forKey:@"pageIndex"]; // Release async flag
    [((MCCZImageView *)page)setImage:nil]; // Release image data
    return identifier;
  };
  
  
  /*******/
  /* (3) */
  /*******/

  // Add a label to show the page number
  __block UILabel *label = [self labelViewForGallery:gv];
  
  // Set extra visual properties of the gallery
  gv.backgroundColor = [UIColor blackColor];
  gv.horizontalPadding = 20;
  
  // For extra fun on the ipad, let the pages flow...
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    gv.pagingEnabled = NO;
    gv.decelerationRate = UIScrollViewDecelerationRateNormal;
  }

  // Register for some events
  gv.onVisibleRangeChanged = ^(NSRange range) {
    // Reset the zoomScale of unvisible pages
    [gv enumerateCachedIndexesAndPagesUsingBlock:^(NSInteger index, UIView *page, BOOL *stop) {
      if (!CGRectIntersectsRect(gv.bounds, page.frame))[(MCCZImageView*)page setZoomScaleForContentMode:UIViewContentModeScaleAspectFit animated:NO];
    }];
    
    // Set the label's text
    [label setText:[NSString stringWithFormat:@"Page #%u", range.location]];
  };
  gv.onVisibleRangeChanged(gv.visiblePagesRange); // Set the label's text
  
  gv.onSingleTap = ^{ [label setHidden:!label.hidden]; };
  
  
  /*******/
  /* (4) */
  /*******/

  // Load the pages
  [gv loadPages];
    
  // Attach views
  [self.view addSubview:gv];
  [self.view addSubview:label];
}

- (UILabel *)labelViewForGallery:(MCCGalleryView *)gv {
  CGRect labelFrame = self.view.bounds;
  labelFrame.size.height = 50.0f;
  labelFrame.origin.y += 10.0f;
  labelFrame.origin.x += ((CGFloat)gv.horizontalPadding / 2.0) + 5.0f + (CGFloat)gv.innerWidth / 4.0f;
  labelFrame.size.width -= gv.horizontalPadding + 10.0f + (CGFloat)gv.innerWidth / 2.0f;
  
  UILabel *label = [[[UILabel alloc]initWithFrame:labelFrame]autorelease];
  label.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  label.textColor = [UIColor whiteColor];
  label.textAlignment = UITextAlignmentCenter;
  label.font = [UIFont boldSystemFontOfSize:20];
  label.layer.cornerRadius = 25.0f;
  
  return label;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

@end
