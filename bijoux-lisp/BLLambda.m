//
//  BLLambda.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-04.
//  Copyright (c) 2012 Daniel Drzimotta. All rights reserved.
//

#import "BLLambda.h"

#import "BLCons.h"
#import "BLEnvironment.h"
#import "BLSymbol.h"
#import "BLSymbolTable.h"

@interface BLLambdaClosure : BLLambdaLambda 
-(id) initWithArgs:(BLCons*)args body:(BLCons*)body;
@end

@implementation BLLambdaClosure {
    BLCons *_args;
    BLCons *_body;
}

// We will also later put the environment that we created this in. This is where
// we 'close' around those.
-(id) initWithArgs:(BLCons*)args body:(BLCons*)body {
    self = [super init];
    
    if (self) {
        _args = args;
        _body = body;
    }
    
    return self;
}

-(id) eval:(BLCons*)sexp withEnvironment:(BLEnvironment*)environment {
    
    BLCons *sexpCopy = [sexp copy];
    BLCons *argsCopy = [_args copy];
    BLCons *bodyCopy = [_body.car copy];
    
    while (argsCopy) {
        id argsHead = argsCopy.car;
        id sexpHead = sexpCopy.car;
        
        argsCopy = argsCopy.cdr;
        sexpCopy = sexpCopy.cdr;
        
        [bodyCopy replaceSymbolsMatching:argsHead withReplacement:sexpHead];
    }
    
    return [[BLLambdaEval new] eval:bodyCopy withEnvironment:environment];
}
@end


@implementation BLLambdaAdd

+(id) symbolName {
    return @"+";
}

-(id) eval:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    if (!cons) {
        return [NSDecimalNumber numberWithDouble:0.0];
    }
    
    NSDecimalNumber *firstVal = cons.car;
    NSDecimalNumber *secondVal = [[BLLambdaAdd new] eval:cons.cdr 
					 withEnvironment:environment];
    
    return [firstVal decimalNumberByAdding:secondVal];
}
@end

@implementation BLLambdaSubtract

+(id) symbolName {
    return @"-";
}

-(id) eval:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    if (!cons) {
        return [NSDecimalNumber numberWithDouble:0.0];
    }
    
    NSDecimalNumber *firstVal = cons.car;
    NSDecimalNumber *secondVal = [[BLLambdaAdd new] eval:cons.cdr 
					 withEnvironment:environment];
    
    return [firstVal decimalNumberBySubtracting:secondVal];
}
@end

@implementation BLLambdaApply

+(id) symbolName {
    return @"apply";
}

// Weirdly this works here but not in SBCL. I don't know why it is bad to have
// so it is kept in... (apply (quote +) (quote (5 5 5 5 (6 6))))
-(id) evalArgs:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    
    if (!cons) {
        return nil;
    }
    
    id first = [cons car];
    id rest = [cons cdr];
    
    if (!rest) {
	if ([first isKindOfClass:BLCons.class]) {
	    rest =  [first cdr];
	    first = [first car];
	}	
    }
    
    return [[BLCons alloc] initWithCar:[[BLLambdaEval new] eval:first withEnvironment:environment] 
                                   cdr:[self evalArgs:rest withEnvironment:environment]];
}

-(id) eval:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    id key = ([cons.car isKindOfClass:BLCons.class] 
	      ? [self eval:cons.car withEnvironment:environment] 
	      : cons.car);
    
    id<BLLambda> fetchedLambda = ([key conformsToProtocol:@protocol(BLLambda)] 
				  ? key 
				  : [environment.symbolTable functionForSymbol:key]);
    
    NSAssert(fetchedLambda, @"Unable to evaluate the form: %@", cons);
    
    NSSet *setToNotEvalArgs = [NSSet setWithObjects:
			       [BLLambdaQuote symbolName], 
			       [BLLambdaLambda symbolName], 
			       [BLLambdaLabel symbolName], 
			       [BLLambdaCond symbolName], 
			       nil];
    
    id resultToEval = ([setToNotEvalArgs containsObject:cons.car] 
		       ? cons.cdr 
		       : [self evalArgs:cons.cdr withEnvironment:environment]);
    
    if ([fetchedLambda isKindOfClass:BLLambdaEval.class]) {
        return [self eval:[resultToEval car] withEnvironment:environment];
    }
    
    return [fetchedLambda eval:resultToEval withEnvironment:environment];
}
@end


// Reimplement this onces we get our reader either knowing what nil is or we
// get our list function
// http://www.lispworks.com/documentation/lw60/CLHS/Body/f_funcal.htm#funcall
@implementation BLLambdaFuncall

+(id) symbolName {
    return @"funcall";
}

-(id) evalArgs:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    
    if (!cons) {
        return nil;
    }
    
    id first = [cons car];
    id rest = [cons cdr];
    
    return [[BLCons alloc] initWithCar:[[BLLambdaEval new] eval:first withEnvironment:environment] 
                                   cdr:[self evalArgs:rest withEnvironment:environment]];
}

-(id) eval:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    
    id key = ([cons.car isKindOfClass:BLCons.class] 
	      ? [self eval:cons.car withEnvironment:environment] 
	      : cons.car);
    
    id<BLLambda> fetchedLambda = ([key conformsToProtocol:@protocol(BLLambda)] 
				  ? key 
				  : [environment.symbolTable functionForSymbol:key]);
    
    NSAssert(fetchedLambda, @"Unable to evaluate the form: %@", cons);
    
    NSSet *setToNotEvalArgs = [NSSet setWithObjects:
			       [BLLambdaQuote symbolName], 
			       [BLLambdaLambda symbolName],
			       [BLLambdaLabel symbolName], 
			       [BLLambdaCond symbolName], 
			       nil];
    
    id resultToEval = ([fetchedLambda isKindOfClass:BLLambdaClosure.class] || [setToNotEvalArgs containsObject:[cons.car name]] 
		       ? cons.cdr 
		       : [self evalArgs:cons.cdr withEnvironment:environment]);

    if ([fetchedLambda isKindOfClass:BLLambdaEval.class]) {
        return [self eval:[resultToEval car] withEnvironment:environment];
    }
    

    
    // I should apply this at this point...?
    return [fetchedLambda eval:resultToEval withEnvironment:environment];
}
@end

@implementation BLLambdaAtom

+(id) symbolName {
    return @"atom";
}

-(id) eval:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    return [cons.car isKindOfClass:BLCons.class] ? nil : cons.car;
}
@end

@implementation BLLambdaQuote

+(id) symbolName {
    return @"quote";
}

-(id) eval:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    return [cons car];
}
@end

@implementation BLLambdaCar

+(id) symbolName {
    return @"car";
}

-(id) eval:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    return [[cons car] car];
}
@end

@implementation BLLambdaCdr

+(id) symbolName {
    return @"cdr";
}

-(id) eval:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    return [[cons car] cdr];
}
@end

@implementation BLLambdaEqual

+(id) symbolName {
    return @"eq";
}

-(id) eval:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    if (!cons) {
        return [NSNumber numberWithBool:YES];
    }
    
    id firstVal = [cons car];
    id secondVal = [[cons cdr] car];
    
    return [firstVal isEqual:secondVal] ? firstVal : nil; // Should be our T value later...
}
@end

@implementation BLLambdaCons

+(id) symbolName {
    return @"cons";
}

-(id) eval:(BLCons*)cons withEnvironment:(BLEnvironment*)environment {
    id first = cons.car;
    id second = [cons.cdr car];
    
    return [[BLCons alloc] initWithCar:first
                                   cdr:second];
    
}

@end

@implementation BLLambdaLambda

+(id) symbolName {
    return @"lambda";
}

-(id) eval:(id)sexp withEnvironment:(BLEnvironment *)environment {
    return [[BLLambdaClosure alloc] initWithArgs:[sexp car] body:[sexp cdr]];
}
@end

@implementation BLLambdaLabel 

+(id) symbolName {
    return @"defparameter";
}

-(id) eval:(BLCons*)sexp withEnvironment:(BLEnvironment*)environment {
    
    BLSymbol *label = sexp.car; // When we get symbols change this to one
    id value = [[BLLambdaEval new] eval:[[sexp cdr] car] withEnvironment:environment];
    
    NSAssert([label isKindOfClass:BLSymbol.class], @"Label must be an BLSymbol");
    
    [environment.symbolTable ensureSymbolForValue:value name:label.name];
        
    return value;
}
@end

@implementation BLLambdaCond 

+(id) symbolName {
    return @"cond";
}

-(id) evalConditionResultPair:(BLCons*)conditionResultPair
                othersToCheck:(BLCons*)othersToCheck
	      withEnvironment:(BLEnvironment*)environment{
    
    if (!conditionResultPair) {
        return nil;
    }
    
    BLCons *condition = conditionResultPair.car;
    BLCons *resultToReturn = [[conditionResultPair cdr] car];
    
    return ([[BLLambdaEval new] eval:condition withEnvironment:environment]
            ? [[BLLambdaEval new] eval:resultToReturn withEnvironment:environment]
            : [self evalConditionResultPair:othersToCheck.car othersToCheck:othersToCheck.cdr withEnvironment:environment]);
}

-(id) eval:(BLCons*)sexp withEnvironment:(BLEnvironment*)environment {
    return [self evalConditionResultPair:sexp.car
                           othersToCheck:sexp.cdr
			 withEnvironment:environment];
}
@end

@implementation BLLambdaEval

+(id) symbolName {
    return @"eval";
}

-(id) eval:(id)sexp withEnvironment:(BLEnvironment*)environment {    
    return ([sexp isKindOfClass:BLCons.class]
            ? [[BLLambdaFuncall new] eval:sexp withEnvironment:environment]
            : [self evalAtom:sexp withEnvironment:environment]);
    
}

-(id) evalAtom:(id)atom withEnvironment:(BLEnvironment*)environment {
    if ([atom isKindOfClass:BLSymbol.class]) {
	BLSymbol *symbolFetched =  [environment.symbolTable symbolForName:[atom name]];
        if (symbolFetched) {
            return symbolFetched.value;
        }
    }
    
    return atom;
}

@end
