//
//  BLSymbolTable.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-12.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLSymbol;
@protocol BLLambda;

@interface BLSymbolTable : NSObject
// If value is lambda it makes sure the symbol exists with that function. If it
// is anything else it ensures that symbol is for that value.
-(void) ensureSymbolForValue:(id)value name:(NSString*)name;
-(void) addSymbol:(BLSymbol*)symbol;
-(BLSymbol*) symbolForName:(NSString*)name;
-(id<BLLambda>) functionForName:(NSString*)name;
@end
