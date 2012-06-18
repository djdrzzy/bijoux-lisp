//
//  BLSymbolTable.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-12.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import "BLSymbolTable.h"

#import "BLLambda.h"
#import "BLSymbol.h"

@implementation BLSymbolTable {
    NSMutableDictionary *_symbolLookup;
}

- (id)init
{
    self = [super init];
    if (self) {
        _symbolLookup = [NSMutableDictionary dictionary];
		
	NSArray *arrayOfInitialLambdaClasses = [[NSArray alloc] initWithObjects:
						BLLambdaAdd.class,
						BLLambdaSubtract.class,
						BLLambdaFuncall.class,
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
						BLLambdaApply.class,
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
    
    id symbolName = [class symbolName];

    [self ensureSymbolForValue:lambdaObj name:symbolName];
}

-(void) ensureSymbolForValue:(id)value name:(NSString*)name {
    BLSymbol *symbolToAdd = [_symbolLookup valueForKey:name];
    symbolToAdd = symbolToAdd ?: ([_symbolLookup setValue:[BLSymbol new] forKey:name], [_symbolLookup valueForKey:name]);
    
    if ([value conformsToProtocol:@protocol(BLLambda)]) {
	symbolToAdd.value = value; // TODO: Should be function? See comments in BLSymbol...
    } else {
	symbolToAdd.value = value;
    }
}

-(void) addSymbol:(BLSymbol*)symbol {
    [_symbolLookup setValue:symbol forKey:symbol.name];
}

-(BLSymbol*) symbolForName:(NSString*)name {
    return [_symbolLookup valueForKey:name];
}

-(id<BLLambda>) functionForName:(NSString*)name {
    BLSymbol *symbol = [self symbolForName:name];
    return symbol.value;
}

-(id<BLLambda>) functionForSymbol:(BLSymbol*)symbol {
    return [self functionForName:symbol.name];
}
-(id) valueForSymbol:(BLSymbol*)symbol {
    return [self symbolForName:symbol.name].value;
}

@end
