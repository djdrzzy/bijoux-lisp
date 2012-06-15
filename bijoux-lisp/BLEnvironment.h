//
//  BLEnvironment.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-14.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLSymbolTable;

@interface BLEnvironment : NSObject
@property (nonatomic, readwrite) BLSymbolTable *symbolTable;
@end
