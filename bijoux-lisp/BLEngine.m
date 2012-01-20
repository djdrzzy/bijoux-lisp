//
//  BLEngine.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Daniel Drzimotta. All rights reserved.
//

#import "BLEngine.h"

#import "BLCons.h"

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
    // Here we build up our cons cells...
    
    // We eat from the passed in tokens...
    id token = [tokens nextToken];
        
    if ([token isEqualToString:@"("]) {
	return [self readTail:tokens];
    }
    
    return token;
}

-(id) eval:(id)sexp {
    
    id tokens = [self tokenize:sexp];
    
    BLCons *formToEval = [self read:tokens];
    
    return [formToEval description];
}
@end
