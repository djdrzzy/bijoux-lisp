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

@interface NSString (BLAdditions)
-(BOOL) balancedParentheses;
- (NSUInteger)occurrenceOfString:(NSString *)substring;
@end

@implementation NSString (BLAdditions)
-(BOOL) balancedParentheses {
    NSUInteger countOfLeft = [self occurrenceOfString:@"("];
    NSUInteger countOfRight = [self occurrenceOfString:@")"];
    return countOfLeft == countOfRight;
}

- (NSUInteger)occurrenceOfString:(NSString *)substring {
    NSUInteger count = 0, length = [self length];
    NSRange range = NSMakeRange(0, length); 
    while(range.location != NSNotFound) {
        range = [self rangeOfString:substring options:0 range:range];
        if(range.location != NSNotFound) {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            count++; 
        }
    }
    return count;
}
@end

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

@implementation BLEngine {
    NSString *_storedInput;
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
    
    _storedInput = (_storedInput
                    ? [_storedInput stringByAppendingString:input]
                    : input);
    
    
    if ([_storedInput balancedParentheses]) {
        // We only continue if we have a balanced amount of ( and )
        // else we save what we have so far and wait for more input
        // We return nil if we are waiting else we return the result
        id tokens = [self tokenize:_storedInput];
        
        _storedInput = nil;
        
        // Creates our internal SEXP representation
        BLCons *formToEval = [self read:tokens];
        
        id result = [[[BLLambdaEval alloc] init] eval:formToEval];
        
        return result;
    } else {
        return nil;
    }
}

@end
