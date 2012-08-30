//
//  MCCAppDelegate.m
//  MCCGalleryViewDemo
//
//  Created by Thierry Passeron on 29/08/12.
//  Copyright (c) 2012 Monte-Carlo Computing. All rights reserved.
//

#import "MCCAppDelegate.h"

#import "MCCViewController.h"

@implementation MCCAppDelegate

- (void)dealloc {
  [_window release];
  [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  self.window.rootViewController = [[[MCCViewController alloc]init]autorelease];
  [self.window makeKeyAndVisible];
  return YES;
}

@end
