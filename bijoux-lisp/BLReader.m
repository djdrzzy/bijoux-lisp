//
//  BLReader.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-17.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import "BLReader.h"

#import "BLCons.h"
#import "BLSymbol.h"

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
    // If we start with a "(" we proceed as normal...
    // If we start with a "'" we go a different path... Just checking for the next token and returning those two to eval.
    if (self.count > 0) {
	id firstToken = [self objectAtIndex:0];
	
	if ([firstToken isEqualToString:@"("]) {
	    NSMutableArray *tokensToReturn = [NSMutableArray array];
	    int lefties = 0;
	    int righties = 0;
	    for (NSUInteger i = 0; i < self.count; i++) {
		id fetchedObject = [self objectAtIndex:i];
		
		NSAssert((i == 0 
			  ? [fetchedObject isEqualToString:@"("]
			  : YES), @"Tokens to read did not start with an opening parenthesis.");
		
		
		if ([fetchedObject isEqualToString:@"("]) {
		    lefties++;
		} else if ([fetchedObject isEqualToString:@")"]) {
		    righties++;
		}
		
		[tokensToReturn addObject:fetchedObject];
		
		if (lefties == righties && lefties != 0 && righties != 0) {
		    [self removeObjectsInRange:NSMakeRange(0, i + 1)];
		    return tokensToReturn;
		}
	    }
	} else if ([firstToken isEqualToString:@"'"]) {
	    NSMutableArray *tokensToReturn = [NSMutableArray arrayWithObject:firstToken];
	    
	    id secondtoken = [self objectAtIndex:1];
	    if ([secondtoken isEqualToString:@"("]) {
		[self removeObjectsInRange:NSMakeRange(0, 1)];
		[tokensToReturn addObjectsFromArray:[self cutFirstBalancedExpression]];
		return tokensToReturn;
	    } else {
		[tokensToReturn addObject:[self objectAtIndex:1]];
		[self removeObjectsInRange:NSMakeRange(0, 2)];
		return tokensToReturn;
	    }	    
	}
    }
    
    return nil;
}
@end

@implementation BLReader {
    NSMutableArray *_storedTokens;
}
@synthesize delegate = _delegate;

- (id)init {
    self = [super init];
    if (self) {
        _storedTokens = [NSMutableArray new];
    }
    return self;
}

-(id) tokenize:(id)sexp {
    sexp = [sexp stringByReplacingOccurrencesOfString:@"(" 
                                           withString:@" ( "];
    
    sexp = [sexp stringByReplacingOccurrencesOfString:@"'" 
                                           withString:@" ' "];
    
    sexp = [sexp stringByReplacingOccurrencesOfString:@")" 
                                           withString:@" ) "];
    
    NSMutableCharacterSet *characters = [[NSMutableCharacterSet alloc] init];
    
    [characters formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
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
    } else if ([token isEqualToString:@"'"]) {
	// Not working so far...
	//id first = ;
	
	//id nextToken = [tokens objectAtIndex:0];
	
	id tail = [self readTail:tokens];
	id head = [tail car];
	id rest = [tail cdr];
	
	id first = nil;
	if ([head isKindOfClass:BLCons.class]) {
	    //id tail = [self readTail:tokens];
	    
	    first = [[BLCons alloc] initWithCar:[[BLSymbol alloc] initWithName:@"quote"]
					    cdr:[[BLCons alloc] initWithCar:head
									cdr:nil]];
	    
	    return [[BLCons alloc] initWithCar:first
					   cdr:rest];
	} else {
	    first = [[BLCons alloc] initWithCar:[[BLSymbol alloc] initWithName:@"quote"]
					    cdr:[[BLCons alloc] initWithCar:[[BLSymbol alloc] initWithName:head]
									cdr:nil]];
	    [tokens removeObjectsInRange:NSMakeRange(0, 1)];
	    return [[BLCons alloc] initWithCar:first
					   cdr:rest];
	}
	
//	id first = nil;
//	if ([nextToken isEqualToString:@"("]) {
//	    
//	    id tail = [self readTail:tokens];
//	    
//	    first = [[BLCons alloc] initWithCar:[[BLSymbol alloc] initWithName:@"quote"]
//					    cdr:[[BLCons alloc] initWithCar:[tail car]
//									cdr:nil]];
//	    	    
//	    return [[BLCons alloc] initWithCar:first
//					   cdr:[tail cdr]];
//	} else {
//	    first = [[BLCons alloc] initWithCar:[[BLSymbol alloc] initWithName:@"quote"]
//					    cdr:[[BLCons alloc] initWithCar:[[BLSymbol alloc] initWithName:nextToken]
//									cdr:nil]];
//	    [tokens removeObjectsInRange:NSMakeRange(0, 1)];
//	    return [[BLCons alloc] initWithCar:first
//					   cdr:[self readTail:tokens]];
//	}
    } else {
	id first = nil;
	
	// TODO: Make a converter class for number, string, symbol etc... also handling of "nil" and "t" and any other special symbols...
	
	NSCharacterSet *numSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
	BOOL validNum = [[token stringByTrimmingCharactersInSet:numSet] isEqualToString:@""];

	if (validNum) {
	    first = [[NSDecimalNumber alloc] initWithString:token];
	} else {
	    // We try to make a symbol instead...
	    BLSymbol *newSymbol = [[BLSymbol alloc] initWithName:token];
	    first = newSymbol;
	}
	
	NSAssert(first, @"'first' must have a value");
	
	// TODO maybe... Treat numbers more like this: http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node189.html
	// Right now it is if it can be treated as an NSDecimalNumber
	

        id second = [self readTail:tokens];
        
        return [[BLCons alloc] initWithCar:first 
                                       cdr:second];
    }
}

-(id) nextForm:(NSMutableArray*)tokens {
    id token = [tokens nextToken];
    
    if ([token isEqualToString:@"("]) {
        return [self readTail:tokens];
    } else if ([token isEqualToString:@"'"]) {
	id first = [[BLSymbol alloc] initWithName:@"quote"];
	id second = [[BLCons alloc] initWithCar:[self nextForm:tokens]
					    cdr:nil];
	return [[BLCons alloc] initWithCar:first
				       cdr:second]; 
    }
    
    return token;
}

-(void) read:(id)input {
    id tokenizedInput = [self tokenize:input];
    
    [_storedTokens addObjectsFromArray:tokenizedInput];
    
    id tokensToEval = nil;
    
    while ((tokensToEval = [_storedTokens cutFirstBalancedExpression])) {
	BLCons *formToEval = [self nextForm:tokensToEval];
	if ([_delegate respondsToSelector:@selector(reader:didReadNewForm:)]) {
	    [_delegate reader:self didReadNewForm:formToEval];
	}
    }
}

@end
