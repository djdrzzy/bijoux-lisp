//
//  BLEngine.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Daniel Drzimotta. All rights reserved.
//

#import "BLEngine.h"

#import "BLCons.h"

@interface NSArray (BLAdditions)
-(id) head;
-(NSArray*) tail;
@end

@implementation NSArray (BLAdditions)
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
@end

@implementation BLEngine

-(id) read:(id)sexp {
    // So we break up by whitespace and ( and )
    
    NSMutableCharacterSet *characters = [[NSMutableCharacterSet alloc] init];
    [characters addCharactersInString:@"()"];
    [characters formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    id brokenUp = [NSMutableArray arrayWithArray:[sexp componentsSeparatedByCharactersInSet:characters]];
    [brokenUp removeObject:@""];

    // Return the array
    return brokenUp;
}

-(id) parseToClose:(NSArray*)tokens {
    id head = tokens.head;
    id tail = tokens.tail;
    
    if ([head isEqualToString:@")"]) {
	return nil;
    } else if ([head isEqualToString:@"("]) {
	return [[BLCons alloc] initWithCar:[self parseToClose:head] cdr:[self parseToClose:tail]];
    } else if (head && tail){
	return [[BLCons alloc] initWithCar:head cdr:[self parseToClose:tail]];
    } else {
	return [[BLCons alloc] initWithCar:head cdr:nil];
    }
}

-(id) parse:(NSArray*)tokens {
    // Here we build up our cons cells...
    
    // We eat from the passed in tokens...
    id head = tokens.head;
    id tail = tokens.tail;

    return  [[BLCons alloc] initWithCar:head cdr:[self parseToClose:tail]];
    
}

// TODO: Pretend this is implicitly wrapped in a progn?
-(id) eval:(id)sexp {
    
    id tokens = [self read:sexp];
    
    
    NSLog(@"Cons %@", [self parse:tokens]);
    
    
    id lastEval = nil;
    for (id token in tokens) {
        // So test if a number which eval to themselves. All scanned in as doubles...
        NSScanner *doubleScanner = [NSScanner scannerWithString:token];
        double potentialDouble = 0.0;
        BOOL wasNum = [doubleScanner scanDouble:&potentialDouble];
        lastEval = wasNum ? [NSNumber numberWithDouble:potentialDouble] : lastEval;
	
	
    }
    
    // Here we make our cons that we evaluate. We just eval our numbers right now... And only as NSNumbers.
    // Be nice if they were bignums.
    
    
    return [NSString stringWithFormat:@"Last eval: \"%@\"", lastEval];
}
@end
