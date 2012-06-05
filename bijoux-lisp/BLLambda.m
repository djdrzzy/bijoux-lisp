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
    [_symbolLookup setValue:[[BLLambdaAtom alloc] init] forKey:@"atom?"];
    [_symbolLookup setValue:[[BLLambdaQuote alloc] init] forKey:@"quote"];
    [_symbolLookup setValue:[[BLLambdaCar alloc] init] forKey:@"car"];
    [_symbolLookup setValue:[[BLLambdaCdr alloc] init] forKey:@"cdr"];
    [_symbolLookup setValue:[[BLLambdaEqual alloc] init] forKey:@"eq?"];
    [_symbolLookup setValue:[[BLLambdaCons alloc] init] forKey:@"cons"];
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
    return [cons.car isKindOfClass:BLCons.class] ? nil : cons.car;
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

@implementation BLLambdaEqual
-(id) eval:(BLCons*)cons {
    if (!cons) {
	return [NSNumber numberWithBool:YES];
    }
    
    id firstVal = cons.car;
    id secondVal = [[[BLLambdaEqual alloc] init] eval:cons.cdr];
    
    return [firstVal isEqual:secondVal] ? firstVal : nil;
}
@end

@implementation BLLambdaCons

-(id) eval:(BLCons*)cons {
    id first = cons.car;
    id second = [cons.cdr car];
    
    return [[BLCons alloc] initWithCar:first
				   cdr:second];
    
}

@end

@implementation BLLambdaEval

-(id) eval:(id)sexp {
    if (!sexp) {
	return nil;
    }
    
    return ([sexp isKindOfClass:BLCons.class]
	    ? [self evalFunc:sexp]
	    : [self evalAtom:sexp]);
    
}

-(id) evalAtom:(id)atom {
    NSAssert([atom isKindOfClass:NSString.class], @"Atom must be an NSString for now.");
    
    return [NSDecimalNumber decimalNumberWithString:atom];
}

-(id) evalArgs:(BLCons*)cons {
    
    if (!cons) {
	return nil;
    }
    
    id first = [cons car];
    id rest = [cons cdr];
    
    return [[BLCons alloc] initWithCar:[self eval:first] 
				   cdr:[self evalArgs:rest]];
}

-(id) evalFunc:(BLCons*)cons {
    BLLambda *fetchedLambda = [_symbolLookup valueForKey:cons.car];
    
    NSAssert(fetchedLambda, @"Unable to evaluate the form: %@", cons);
    
    NSSet *setToNotEvalArgs = [NSSet setWithObjects:@"quote", nil];
    
    id resultToEval = [setToNotEvalArgs containsObject:cons.car] ? cons.cdr : [self evalArgs:cons.cdr];
        
    if ([fetchedLambda isKindOfClass:BLLambdaEval.class]) {
	return [self eval:[resultToEval car]];
    }
    
    return [fetchedLambda eval:resultToEval];
}
@end