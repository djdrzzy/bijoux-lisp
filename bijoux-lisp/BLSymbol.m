//
//  BLSymbol.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-13.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import "BLSymbol.h"


@interface NSObject (BLSymbolAddition)
-(BOOL) isEqualToSymbol:(BLSymbol*)symbol;
@end

@implementation NSObject (BLSymbolAddition)
-(BOOL) isEqualToSymbol:(BLSymbol*)symbol {
    return NO;
}
@end

@implementation BLSymbol
@synthesize name = _name;
@synthesize value = _value;
@synthesize function = _function;

-(id) initWithName:(NSString*)name {
    self = [super init];
    
    if (self) {
	_name = [name copy];
    }
    
    return self;
}

-(id) init {
    return [self initWithName:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    BLSymbol *newSymbol = [[BLSymbol alloc] initWithName:self.name];
    newSymbol.value = _value;
    newSymbol.function = _function;
    
    return newSymbol;
}

-(BOOL) isEqualToSymbol:(BLSymbol*)symbol {
    return [symbol.name isEqualToString:_name];
}

-(NSString*) description {
    return _name;
}

@end
