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
	
	NSArray *arrayOfInitialLambdaClasses = [[NSArray alloc] initWithObjects:
						BLLambdaAdd.class,
						BLLambdaSubtract.class,
						BLLambdaEval.class,
						BLLambdaAtom.class,
						BLLambdaQuote.class,
						BLLambdaCar.class,
						BLLambdaCdr.class,
						BLLambdaEqual.class,
						BLLambdaCons.class,
						BLLambdaLambda.class,
						BLLambdaLabel.class,
						BLLambdaCond.class,
						nil];
	
	for (Class lambdaClass in arrayOfInitialLambdaClasses) {
	    [self addSymbolForLambdaClass:lambdaClass];
	}
	
    }
    return self;
}

-(void) addSymbolForLambdaClass:(Class)class {
    id lambdaObj = [class new];
    
    NSAssert([lambdaObj conformsToProtocol:@protocol(BLLambda)],
	     @"Should conform to the BLLambda protocol...");
    
    id symbolLabel = [class symbolLabel];
    
    [_symbolLookup setValue:lambdaObj forKey:symbolLabel];
}

-(id) valueForSymbol:(id)symbol {
    return [_symbolLookup valueForKey:symbol];
}

-(void) setValue:(id)value forSymbol:(id)symbol {
    [_symbolLookup setValue:value forKey:symbol];
}

@end
