//
//  BLLambda.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-04.
//  Copyright (c) 2012 Daniel Drzimotta. All rights reserved.
//

#import "BLLambda.h"

static NSMutableDictionary *_symbolLookup;

@implementation BLLambda {

}

+(void) createInitialSymbolLookup {
    _symbolLookup = [NSMutableDictionary dictionary];
    
    [_symbolLookup setValue:[[BLLambdaAdd alloc] init] forKey:@"+"];
}

- (id)init {
    self = [super init];
    if (self) {
	if (!_symbolLookup) {
	    [BLLambda createInitialSymbolLookup];
	}
    }
    return self;
}

-(id) eval:(id)sexp {
    return sexp;
}

@end


@implementation BLLambdaAdd
-(id) eval:(BLCons*)cons {
    NSAssert([cons isKindOfClass:BLCons.class], @"Can't add a non-BLCons");
        
    double firstVal = ([[[BLLambdaAtom alloc] init] eval:cons.car] 
		       ? [cons.car doubleValue] 
		       : [[[[BLLambdaEval alloc] init] eval:cons.car] doubleValue]);
    
    double secondVal = (cons.cdr ? [[[[BLLambdaAdd alloc] init] eval:cons.cdr] doubleValue] : 0.0);
    double finalVal = firstVal + secondVal;
    return [NSString stringWithFormat:@"%f", finalVal];
}
@end

@implementation BLLambdaAtom
-(id) eval:(BLCons*)cons {
    return [cons isKindOfClass:BLCons.class] ? nil : cons;
}
@end

@implementation BLLambdaEval
-(id) eval:(id)sexp {
    return ([sexp isKindOfClass:BLCons.class]
	    ? [self evalCons:sexp]
	    : [sexp description]);
    
}

-(id) evalFunc:(BLCons*)cons {
    BLLambda *fetchedLambda = [_symbolLookup valueForKey:cons.car];
    
    if (fetchedLambda) {
	return [fetchedLambda eval:cons.cdr];
    } else {
	return [cons description];
    }
}

-(id) evalCons:(BLCons*)cons {
    return [self evalFunc:cons];
}
@end