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
    [_symbolLookup setValue:[[BLLambdaEval alloc] init] forKey:@"eval"];
    [_symbolLookup setValue:[[BLLambdaAtom alloc] init] forKey:@"atom"];
    [_symbolLookup setValue:[[BLLambdaQuote alloc] init] forKey:@"quote"];
    [_symbolLookup setValue:[[BLLambdaCar alloc] init] forKey:@"car"];
    [_symbolLookup setValue:[[BLLambdaCdr alloc] init] forKey:@"cdr"];
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


// So two things are going to happen to this function...
// all of the cons.cars are already going to be NSDecimalNumbers...
// All of the sub args will have already been evalled...
-(id) eval:(BLCons*)cons {
    if (!cons) {
	return [NSDecimalNumber numberWithDouble:0.0];
    }
        
    NSDecimalNumber *firstVal = cons.car;
    NSDecimalNumber *secondVal = [[[BLLambdaAdd alloc] init] eval:cons.cdr];
    
    return [firstVal decimalNumberByAdding:secondVal];
}
@end

@implementation BLLambdaAtom
-(id) eval:(BLCons*)cons {
    return [cons isKindOfClass:BLCons.class] ? nil : cons;
}
@end

@implementation BLLambdaQuote
-(id) eval:(BLCons*)cons {
    return [cons car];
}
@end

@implementation BLLambdaCar
-(id) eval:(BLCons*)cons {
    return [[cons car] car];
}
@end

@implementation BLLambdaCdr
-(id) eval:(BLCons*)cons {
    return [[cons car] cdr];
}
@end

@implementation BLLambdaEval
-(id) eval:(id)sexp {
    if (!sexp) {
	return nil;
    }
    
    return ([sexp isKindOfClass:BLCons.class]
	    ? [self evalCons:sexp]
	    : [self evalAtom:sexp]);
    
}

-(id) evalAtom:(id)atom {
    NSAssert([atom isKindOfClass:NSString.class], @"Atom must be an NSString for now.");
    
    return [NSDecimalNumber decimalNumberWithString:atom];
}

-(id) evalCons:(BLCons*)cons {
    if ([_symbolLookup valueForKey:cons.car]) {
	return [self evalFunc:cons];
    } else {
	return [self evalArgs:cons];
    }
}

-(id) evalArgs:(BLCons*)cons {
    
    id first = [cons car];
    id rest = [cons cdr];
    
    return [[BLCons alloc] initWithCar:[[[BLLambdaEval alloc] init] eval:first] 
				   cdr:[[[BLLambdaEval alloc] init] eval:rest]];
}

-(id) evalFunc:(BLCons*)cons {
    BLLambda *fetchedLambda = [_symbolLookup valueForKey:cons.car];
    
    NSAssert(fetchedLambda, @"Unable to evaluate the form: %@", cons);
    
    // Now we need to go through the arguments and evaluate them before we eval
    // this here... How do we do that? Go through the cons and if the current
    // element is a cons then we can try to evaluate that by calling this eval
    // on it. I guess we can actually just eval all of the elements in the cons.
    
    // Add currently does this manually...
    NSLog(@"cons.cdr: %@", cons.cdr); // The list of args that we need to eval...
//    id first = [[cons cdr] car];
//    id rest = [[cons cdr] cdr];
//
//    NSLog(@"first: %@", first);
//    NSLog(@"rest: %@", rest);
//    if (first) {
//	id result = [[[BLLambdaEval alloc] init] eval:first];
//	NSLog(@"result: %@", result);
//    }

//    BLCons *argsToEval = [[cons cdr] car];
//    NSLog(@"evalledArgs: %@", argsToEval);
//    NSLog(@"car: %@", [argsToEval car]);
//    NSLog(@"cdr: %@", [argsToEval cdr]);
    
    NSSet *setToNotEvalArgs = [NSSet setWithObjects:@"quote", nil];
    
    id resultToEval = [setToNotEvalArgs containsObject:cons.car] ? cons.cdr : [self evalArgs:cons.cdr];
    
    NSLog(@"resultToEval: %@", resultToEval);
    
    return [fetchedLambda eval:resultToEval];

}
@end