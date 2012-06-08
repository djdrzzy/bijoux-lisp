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
    [_symbolLookup setValue:[[BLLambdaLambda alloc] init] forKey:@"lambda"];
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

@interface BLLambdaLambdaLambda : BLLambdaLambda 
-(id) initWithArgs:(BLCons*)args body:(BLCons*)body;
@end

@implementation BLLambdaLambdaLambda {
    BLCons *_args;
    BLCons *_body;
}

-(id) initWithArgs:(BLCons*)args body:(BLCons*)body {
    self = [super init];
    
    if (self) {
	_args = args;
	_body = body;
    }
    
    return self;
}


// We need to replace the parameter values with their parameters here...
// Then we can try this out...
// > ((lambda (x) (+ x x x)) 5) => 15
-(id) eval:(BLCons*)sexp {
    
    BLCons *argsCopy = [_args copy];
    BLCons *bodyCopy = [_body.car copy];
    
    while (argsCopy) {
	id argsHead = argsCopy.car;
	id sexpHead = sexp.car;
	
	argsCopy = argsCopy.cdr;
	sexp = sexp.cdr;
	
	[bodyCopy replaceAtomsMatching:argsHead withReplacement:sexpHead];
	
	NSLog(@"argsHEad: %@", argsHead);
	NSLog(@"sexpHead: %@", sexpHead);
	NSLog(@"bodyCopy: %@", bodyCopy);
    }
    
    
    return [[[BLLambdaEval alloc] init] eval:bodyCopy];
}
@end

@implementation BLLambdaLambda 
-(id) eval:(id)sexp {
    return [[BLLambdaLambdaLambda alloc] initWithArgs:[sexp car] body:[sexp cdr]];
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
    NSAssert([atom isKindOfClass:NSString.class]
	     || [atom isKindOfClass:BLLambdaLambdaLambda.class]
	     || [atom isKindOfClass:NSDecimalNumber.class], @"Atom must be an NSString or lambda for now.");
    
    if ([atom isKindOfClass:NSDecimalNumber.class]) {
	return atom;
    }
    
    return [atom isKindOfClass:NSString.class] ? [NSDecimalNumber decimalNumberWithString:atom] : atom;
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
    
    id key = nil;
    if ([cons.car isKindOfClass:BLCons.class]) {
	// attempt to eval it
	key = [self eval:cons.car];
	NSLog(@"aKey: %@", key);
    } else {
	key = cons.car;
    }
    
    BLLambda *fetchedLambda = [key isKindOfClass:BLLambda.class] ? key : [_symbolLookup valueForKey:key];
    
    NSAssert(fetchedLambda, @"Unable to evaluate the form: %@", cons);
    
    NSSet *setToNotEvalArgs = [NSSet setWithObjects:@"quote", @"lambda", nil];
    
    id resultToEval = [setToNotEvalArgs containsObject:cons.car] ? cons.cdr : [self evalArgs:cons.cdr];
        
    if ([fetchedLambda isKindOfClass:BLLambdaEval.class]) {
	return [self eval:[resultToEval car]];
    }
    
    return [fetchedLambda eval:resultToEval];
}
@end