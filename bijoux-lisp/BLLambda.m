//
//  BLLambda.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-04.
//  Copyright (c) 2012 Daniel Drzimotta. All rights reserved.
//

#import "BLLambda.h"

#import "BLCons.h"
#import "BLSymbol.h"
#import "BLSymbolTable.h"

@implementation BLLambdaAdd

+(id) symbolName {
    return @"+";
}

-(id) eval:(BLCons*)cons {
    if (!cons) {
        return [NSDecimalNumber numberWithDouble:0.0];
    }
    
    NSDecimalNumber *firstVal = cons.car;
    NSDecimalNumber *secondVal = [[BLLambdaAdd new] eval:cons.cdr];
    
    return [firstVal decimalNumberByAdding:secondVal];
}
@end

@implementation BLLambdaSubtract

+(id) symbolName {
    return @"-";
}

-(id) eval:(BLCons*)cons {
    if (!cons) {
        return [NSDecimalNumber numberWithDouble:0.0];
    }
    
    NSDecimalNumber *firstVal = cons.car;
    NSDecimalNumber *secondVal = [[BLLambdaAdd new] eval:cons.cdr];
    
    return [firstVal decimalNumberBySubtracting:secondVal];
}
@end


@implementation BLLambdaAtom

+(id) symbolName {
    return @"atom?";
}

-(id) eval:(BLCons*)cons {
    return [cons.car isKindOfClass:BLCons.class] ? nil : cons.car;
}
@end

@implementation BLLambdaQuote

+(id) symbolName {
    return @"quote";
}

-(id) eval:(BLCons*)cons {
    return [cons car];
}
@end

@implementation BLLambdaCar

+(id) symbolName {
    return @"car";
}

-(id) eval:(BLCons*)cons {
    return [[cons car] car];
}
@end

@implementation BLLambdaCdr

+(id) symbolName {
    return @"cdr";
}

-(id) eval:(BLCons*)cons {
    return [[cons car] cdr];
}
@end

@implementation BLLambdaEqual

+(id) symbolName {
    return @"eq?";
}

-(id) eval:(BLCons*)cons {
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

-(id) eval:(BLCons*)sexp {
    
    BLCons *argsCopy = [_args copy];
    BLCons *bodyCopy = [_body.car copy];
    
    while (argsCopy) {
        id argsHead = argsCopy.car;
        id sexpHead = sexp.car;
        
        argsCopy = argsCopy.cdr;
        sexp = sexp.cdr;
        
        [bodyCopy replaceAtomsMatching:argsHead withReplacement:sexpHead];
    }
    
    
    return [[BLLambdaEval new] eval:bodyCopy];
}
@end

@implementation BLLambdaLambda

+(id) symbolName {
    return @"lambda";
}

-(id) eval:(id)sexp {
    return [[BLLambdaLambdaLambda alloc] initWithArgs:[sexp car] body:[sexp cdr]];
}
@end

@implementation BLLambdaLabel 

+(id) symbolName {
    return @"label";
}

-(id) eval:(BLCons*)sexp {
    
    id label = sexp.car; // When we get symbols change this to one
    id value = [[BLLambdaEval new] eval:[[sexp cdr] car]];
    
    NSAssert([label isKindOfClass:NSString.class], @"Label must be an NSString");
    
    [[BLSymbolTable sharedInstance] ensureSymbolForValue:value name:label];
        
    return value;
}
@end

@implementation BLLambdaEval

+(id) symbolName {
    return @"eval";
}

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
             || [atom isKindOfClass:NSDecimalNumber.class], @"Atom must be an NSString, NSDecimalNumber or lambda for now.");
    
    if ([atom isKindOfClass:NSDecimalNumber.class]) {
        return atom;
    } else if ([atom isKindOfClass:NSString.class]) {
        id val =  [[BLSymbolTable sharedInstance] symbolForName:atom].value;
        if (val) {
            return val;
        }
    }
    
    // This conversion here really should be going through a lisp reader of sorts
    // Following the common lisp reader would be cool.
    NSDecimalNumber *wasANum = [NSDecimalNumber decimalNumberWithString:atom];
    
    return [wasANum isEqual:[NSDecimalNumber notANumber]] ? atom : wasANum;
}

// This should be its own BLLambdaApply
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
    
    id key = [cons.car isKindOfClass:BLCons.class] ? [self eval:cons.car] : cons.car;
    
    id<BLLambda> fetchedLambda = [key conformsToProtocol:@protocol(BLLambda)] ? key : [[BLSymbolTable sharedInstance] symbolForName:key].value;
    
    NSAssert(fetchedLambda, @"Unable to evaluate the form: %@", cons);
    
    NSSet *setToNotEvalArgs = [NSSet setWithObjects:
			       [BLLambdaQuote symbolName], 
			       [BLLambdaLambda symbolName], 
			       [BLLambdaLabel symbolName], 
			       [BLLambdaCond symbolName], 
			       nil];
    
    id resultToEval = [setToNotEvalArgs containsObject:cons.car] ? cons.cdr : [self evalArgs:cons.cdr];
    
    if ([fetchedLambda isKindOfClass:BLLambdaEval.class]) {
        return [self eval:[resultToEval car]];
    }
    
    return [fetchedLambda eval:resultToEval];
}
@end

@implementation BLLambdaCond 

+(id) symbolName {
    return @"cond";
}

-(id) evalConditionResultPair:(BLCons*)conditionResultPair
                othersToCheck:(BLCons*)othersToCheck {
    
    if (!conditionResultPair) {
        return nil;
    }
    
    BLCons *condition = conditionResultPair.car;
    BLCons *resultToReturn = [[conditionResultPair cdr] car];
    
    return ([[BLLambdaEval new] eval:condition]
            ? [[BLLambdaEval new] eval:resultToReturn]
            : [self evalConditionResultPair:othersToCheck.car othersToCheck:othersToCheck.cdr]);
}

-(id) eval:(BLCons*)sexp {
    return [self evalConditionResultPair:sexp.car
                           othersToCheck:sexp.cdr];
}
@end