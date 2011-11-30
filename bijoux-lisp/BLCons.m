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

-(NSString*) description {
    return [NSString stringWithFormat:@"(%@ %@)", self.car, self.cdr];
}

@end
