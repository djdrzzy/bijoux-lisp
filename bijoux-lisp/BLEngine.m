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
-(id) cutFirstBalancedExpression;
@end

@implementation NSMutableArray (BLAdditions)
-(id) nextToken {
    id firstElement = [self objectAtIndex:0];
    [self removeObjectAtIndex:0];
    return firstElement;
}
-(id) cutFirstBalancedExpression {
    NSMutableArray *tokensToReturn = [NSMutableArray array];
    int lefties = 0;
    int righties = 0;
    for (NSUInteger i = 0; i < self.count; i++) {
	id fetchedObject = [self objectAtIndex:i];
	NSAssert(i == 0 ? [fetchedObject isEqualToString:@"("] : YES, @"Must start with an opening parenthesis");
	
	if ([fetchedObject isEqualToString:@"("]) {
	    lefties++;
	} else if ([fetchedObject isEqualToString:@")"]) {
	    righties++;
	}
	
	[tokensToReturn addObject:fetchedObject];
	
	if (lefties == righties) {
	    [self removeObjectsInRange:NSMakeRange(0, i + 1)];
	    return tokensToReturn;
	}
    }
    
    return nil;
}
@end

@implementation BLEngine {
    NSMutableArray *_storedTokens;
}

- (id)init
{
    self = [super init];
    if (self) {
        _storedTokens = [[NSMutableArray alloc] init];
    }
    return self;
}

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

-(id) parseAndEval:(NSString*)input {
    if (!input) {
        return @"";
    }
    
    // We only continue if we have a balanced amount of ( and )
    // else we save what we have so far and wait for more input
    // We return nil if we are waiting else we return the result
    id tokens = [self tokenize:input];
    
    [_storedTokens addObjectsFromArray:tokens];
    
    id tokensToEval = nil;
    id result = nil;
    
    while ((tokensToEval = [_storedTokens cutFirstBalancedExpression])) {
	BLCons *formToEval = [self read:tokensToEval];
	result = [[[BLLambdaEval alloc] init] eval:formToEval];
    }
    
    return result;
}

@end
