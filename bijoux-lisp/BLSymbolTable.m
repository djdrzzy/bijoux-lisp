//
//  BLSymbolTable.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-12.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import "BLSymbolTable.h"

#import "BLLambda.h"

@implementation BLSymbolTable {
    NSMutableDictionary *_symbolLookup;
}
+(id) sharedInstance {
    static id shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
	shared = [[BLSymbolTable alloc] init];
    });
    return shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        _symbolLookup = [NSMutableDictionary dictionary];
	
	[_symbolLookup setValue:[BLLambdaAdd new] forKey:[BLLambdaAdd symbolLabel]];
	[_symbolLookup setValue:[BLLambdaEval new] forKey:[BLLambdaEval symbolLabel]];
	[_symbolLookup setValue:[BLLambdaAtom new] forKey:[BLLambdaAtom symbolLabel]];
	[_symbolLookup setValue:[BLLambdaQuote new] forKey:[BLLambdaQuote symbolLabel]];
	[_symbolLookup setValue:[BLLambdaCar new] forKey:[BLLambdaCar symbolLabel]];
	[_symbolLookup setValue:[BLLambdaCdr new] forKey:[BLLambdaCdr symbolLabel]];
	[_symbolLookup setValue:[BLLambdaEqual new] forKey:[BLLambdaEqual symbolLabel]];
	[_symbolLookup setValue:[BLLambdaCons new] forKey:[BLLambdaCons symbolLabel]];
	[_symbolLookup setValue:[BLLambdaLambda new] forKey:[BLLambdaLambda symbolLabel]];
	[_symbolLookup setValue:[BLLambdaLabel new] forKey:[BLLambdaLabel symbolLabel]];
	[_symbolLookup setValue:[BLLambdaCond new] forKey:[BLLambdaCond symbolLabel]];
    }
    return self;
}

-(id) valueForSymbol:(id)symbol {
    return [_symbolLookup valueForKey:symbol];
}

-(void) setValue:(id)value forSymbol:(id)symbol {
    [_symbolLookup setValue:value forKey:symbol];
}

@end
