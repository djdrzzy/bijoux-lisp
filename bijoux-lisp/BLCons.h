//
//  BLCons.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Soma Creates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLCons : NSObject
@property (strong, nonatomic) id car;
@property (strong, nonatomic) id cdr;
@end
