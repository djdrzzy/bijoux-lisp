//
//  BLAppDelegate.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Soma Creates. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLViewController;

@interface BLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BLViewController *viewController;

@end
