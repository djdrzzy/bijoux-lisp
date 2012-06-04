//
//  BLCons.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Daniel Drzimotta. All rights reserved.
//

#import "BLCons.h"

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

-(BOOL) atom {
    return NO;
}

-(NSString*) description {
    NSString *aCar = self.car;
    NSString *aCdr = self.cdr ?: @"nil";
    
    return [NSString stringWithFormat:@"(%@ %@)", aCar, aCdr];
}

@end
