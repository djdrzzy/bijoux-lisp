//
//  BLLambda.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-04.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import "BLLambda.h"

#import "BLCons.h"

@implementation BLLambda {
    BLCons *_args;
    BLCons *_body;
}

+(BLLambda*) lambdaWithArgs:(BLCons*)args body:(BLCons*)body {
    return [[BLLambda alloc] initWithArgs:args body:body];
}

- (id)initWithArgs:(BLCons*)args body:(BLCons*)body {
    self = [super init];
    if (self) {
	_args = args;
	_body = body;
    }
    return self;
}

-(id) eval:(id)sexp {
    return ([sexp isKindOfClass:BLCons.class]
	    ? [self evalCons:sexp]
	    : [sexp description]);
    
}

@end
