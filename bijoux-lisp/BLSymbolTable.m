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
	
	[_symbolLookup setValue:[[BLLambdaAdd alloc] init] forKey:@"+"];
	[_symbolLookup setValue:[[BLLambdaEval alloc] init] forKey:@"eval"];
	[_symbolLookup setValue:[[BLLambdaAtom alloc] init] forKey:@"atom?"];
	[_symbolLookup setValue:[[BLLambdaQuote alloc] init] forKey:@"quote"];
	[_symbolLookup setValue:[[BLLambdaCar alloc] init] forKey:@"car"];
	[_symbolLookup setValue:[[BLLambdaCdr alloc] init] forKey:@"cdr"];
	[_symbolLookup setValue:[[BLLambdaEqual alloc] init] forKey:@"eq?"];
	[_symbolLookup setValue:[[BLLambdaCons alloc] init] forKey:@"cons"];
	[_symbolLookup setValue:[[BLLambdaLambda alloc] init] forKey:@"lambda"];
	[_symbolLookup setValue:[[BLLambdaLabel alloc] init] forKey:@"label"];
	[_symbolLookup setValue:[[BLLambdaCond alloc] init] forKey:@"cond"];
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
