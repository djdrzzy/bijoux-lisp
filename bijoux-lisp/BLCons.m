//
//  BLCons.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Daniel Drzimotta. All rights reserved.
//

#import "BLCons.h"

#import "BLSymbol.h"

@implementation BLCons
@synthesize car, cdr;
-(id) initWithCar:(id)newCar cdr:(id)newCdr {
    self = [super init];
    
    if (self) {
	self.car = newCar;
	self.cdr = newCdr;
    }
    
    return self;
}

- (id)init {
    return [self initWithCar:nil cdr:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[BLCons alloc] initWithCar:[self.car copy] 
				   cdr:[self.cdr copy]];
}

-(void) replaceSymbolsMatching:(BLSymbol*)match withReplacement:(id)replacement {
    if ([self.car isKindOfClass:BLCons.class]) {
	[self.car replaceSymbolsMatching:match withReplacement:replacement];
    } else {
	if ([self.car isEqualToSymbol:match]) {
	    self.car = replacement;
	}
    }
    
    if ([self.cdr isKindOfClass:BLCons.class]) {
	[self.cdr replaceSymbolsMatching:match withReplacement:replacement];
    } else {
	if ([self.cdr isEqualToSymbol:match]) {
	    self.cdr = replacement;
	}
    }
}

-(void) addToEnd:(id)obj {
    if (self.cdr) {
	[self.cdr addToEnd:obj];
    } else {
	self.cdr = obj;
    }
}

-(NSString*) descriptionWithOpeningParenthesis:(BOOL)openingPar {
    NSString *openingParString = openingPar ? @"(%@" : @"%@";
    
    openingParString = (self.cdr 
			? [openingParString stringByAppendingString:@" "] 
			: [openingParString stringByAppendingString:@""]);
    
    NSString *aCar = [NSString stringWithFormat:openingParString, self.car] ;
    
    NSString *aCdr = self.cdr ? [self.cdr descriptionWithOpeningParenthesis:NO] : @")";
    
    return [NSString stringWithFormat:@"%@%@", aCar, aCdr];
}

-(NSString*) description {
    return [self descriptionWithOpeningParenthesis:YES];
}

@end
