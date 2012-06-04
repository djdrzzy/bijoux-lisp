//
//  BLEngine.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Daniel Drzimotta. All rights reserved.
//

#import "BLEngine.h"

#import "BLCons.h"

@interface NSObject (BLAdditions)
-(BOOL) atom;
@end

@implementation NSObject (BLAdditions)
-(BOOL) atom {
    return YES;
}
@end

@interface NSMutableArray (BLAdditions)
-(id) head;
-(NSMutableArray*) tail;
@end

@implementation NSMutableArray (BLAdditions)
-(id) head {
    return [self objectAtIndex:0];
}

-(NSArray*) tail {
    return (self.count == 1 
	    ? nil 
	    : [self subarrayWithRange:NSMakeRange(1, self.count - 1)]);
}

-(id) nextToken {
    id firstElement = [self objectAtIndex:0];
    [self removeObjectAtIndex:0];
    return firstElement;
}

@end

@implementation BLEngine

-(id) tokenize:(id)sexp {
    // So we break up by whitespace and ( and )
        
    // First we see if any of those tokens include a '(' or a ')'. If it does
    // then we break up after the '(' or before the ')'
    sexp = [sexp stringByReplacingOccurrencesOfString:@"(" 
					   withString:@"( "];
    
    sexp = [sexp stringByReplacingOccurrencesOfString:@")" 
					   withString:@" ) "];
    
    
    // then we seperate by whitespace
    NSMutableCharacterSet *characters = [[NSMutableCharacterSet alloc] init];
    
    [characters formUnionWithCharacterSet:
     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    id brokenUp = [NSMutableArray arrayWithArray:
		    [sexp componentsSeparatedByCharactersInSet:characters]];
    
    [brokenUp removeObject:@""];
    
    NSLog(@"brokenUp: %@", brokenUp);
    
    return brokenUp;
}

-(id) readTail:(NSMutableArray*)tokens {
    id token = [tokens nextToken];
    
    if ([token isEqualToString:@")"]) {
	return nil;
    } else if ([token isEqualToString:@"("]) {
	id first = [self readTail:tokens];
	id second = [self readTail:tokens];
	return [[BLCons alloc] initWithCar:first 
				       cdr:second];
    } else {
	id first = token;
	id second = [self readTail:tokens];
	return [[BLCons alloc] initWithCar:first 
				       cdr:second];
    }
}

-(id) read:(NSMutableArray*)tokens {
    id token = [tokens nextToken];
        
    if ([token isEqualToString:@"("]) {
	return [self readTail:tokens];
    }
    
    return token;
}

-(id) car:(BLCons*)cons {
    return cons.car;
}

-(id) cdr:(BLCons*)cons {
    return cons.cdr;
}

-(id) add:(BLCons*)cons {
    NSLog(@"is atom: %i", [cons.car atom]);
    
    double firstVal = [cons.car atom] ? [cons.car doubleValue] : [[self evalCons:cons.car] doubleValue];
    
    
    double secondVal = (cons.cdr ? [[self add:cons.cdr] doubleValue] : 0.0);
    double finalVal = firstVal + secondVal;
    return [NSString stringWithFormat:@"%f", finalVal];
}

-(id) evalFunc:(BLCons*)cons {
    
    if ([cons.car isEqualToString:@"+"]) {
	return [self add:cons.cdr];
    } else {
	// Crash eventually. Not a valid form
	return [cons description];
    }
}

-(id) evalCons:(BLCons*)cons {
    return [self evalFunc:cons];
}

-(id) eval:(id)sexp {
    return ([sexp isKindOfClass:BLCons.class]
	    ? [self evalCons:sexp]
	    : [sexp description]);

}

-(id) parseAndEval:(id)input {
    if (!input) {
	return @"";
    }
    
    id tokens = [self tokenize:input];
    
    id formToEval = [self read:tokens];
    
    NSLog(@"formToEval: %@", formToEval);
    
    
    
    return [self eval:formToEval];
}

@end
