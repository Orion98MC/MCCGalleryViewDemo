//
//  MCCViewController.h
//  MCCGalleryViewDemo
//
//  Created by Thierry Passeron on 29/08/12.
//  Copyright (c) 2012 Monte-Carlo Computing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_INLINE void forceImageDecompression(UIImage *image) {
  CGImageRef imageRef = [image CGImage];
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(NULL, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8, CGImageGetWidth(imageRef) * 4, colorSpace,kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
  CGColorSpaceRelease(colorSpace);
  if (!context) { NSLog(@"Could not create context for image decompression"); return; }
  CGContextDrawImage(context, (CGRect){{0.0f, 0.0f}, {CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)}}, imageRef);
  CFRelease(context);
}

@interface MCCViewController : UIViewController
@end
