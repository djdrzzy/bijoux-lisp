//
//  BLSymbolTable.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-12.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLSymbolTable : NSObject
+(id) sharedInstance;
-(id) valueForSymbol:(id)symbol;
-(void) setValue:(id)value forSymbol:(id)symbol;
@end
