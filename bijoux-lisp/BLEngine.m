//
//  BLEngine.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Daniel Drzimotta. All rights reserved.
//

#import "BLEngine.h"

#import "BLCons.h"

// Handy: http://nakkaya.com/2010/08/24/a-micro-manual-for-lisp-implemented-in-c/

@interface NSMutableArray (BLAdditions)
-(id) head;
-(NSMutableArray*) tail;
@end

@implementation NSMutableArray (BLAdditions)
-(id) head {
    return [self objectAtIndex:0];
}

-(NSArray*) tail {
    if (self.count == 1) {
	return nil;
    } else {
	return [self subarrayWithRange:NSMakeRange(1, self.count - 1)];
    }
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
    [characters formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    id brokenUp = [NSMutableArray arrayWithArray:[sexp componentsSeparatedByCharactersInSet:characters]];
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

// TODO: Pretend this is implicitly wrapped in a progn? Probably not... sexp
// might not be a sexp could just be '4' or something so a bad name...
-(id) eval:(id)sexp {
    
    id tokens = [self tokenize:sexp];
    
    
    NSLog(@"Cons %@", [self read:tokens]);
    
    
    id lastEval = nil;
    for (id token in tokens) {
        // So test if a number which eval to themselves. All scanned in as doubles...
        NSScanner *doubleScanner = [NSScanner scannerWithString:token];
        double potentialDouble = 0.0;
        BOOL wasNum = [doubleScanner scanDouble:&potentialDouble];
        lastEval = wasNum ? [NSNumber numberWithDouble:potentialDouble] : lastEval;
    }
    
    return [NSString stringWithFormat:@"Last eval: \"%@\"", lastEval];
}
@end
