//
//  BLEnvironment.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-14.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLSymbolTable;


// Eventually you will be able to have sub-environments and parent environments
// that allow us to look up the environments with lexical scoping.
@interface BLEnvironment : NSObject
@property (nonatomic, readwrite, strong) BLSymbolTable *symbolTable;
@end
