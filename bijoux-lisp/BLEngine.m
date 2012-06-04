//
//  BLEngine.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Daniel Drzimotta. All rights reserved.
//

#import "BLEngine.h"

#import "BLCons.h"
#import "BLLambda.h"


@interface NSMutableArray (BLAdditions)
-(id) nextToken;
@end

@implementation NSMutableArray (BLAdditions)
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

-(id) parseAndEval:(id)input {
    if (!input) {
	return @"";
    }
    
    id tokens = [self tokenize:input];
    
    // Creates our internal SEXP representation
    BLCons *formToEval = [self read:tokens];
    
    return [[[BLLambdaEval alloc] init] eval:formToEval];
}

@end
