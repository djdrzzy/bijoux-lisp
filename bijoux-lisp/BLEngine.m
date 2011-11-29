//
//  BLEngine.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Soma Creates. All rights reserved.
//

#import "BLEngine.h"

#import "BLCons.h"

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

-(id)eval:(id)sexp {
    
    id tokens = [self read:sexp];
    
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
