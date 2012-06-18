//
//  BLEngine.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Daniel Drzimotta. All rights reserved.
//

#import "BLEngine.h"

#import "BLCons.h"
#import "BLEnvironment.h"
#import "BLLambda.h"
#import "BLReader.h"
#import "BLSymbolTable.h"

@interface BLEngine ()<BLReaderDelegate>
@end

@implementation BLEngine {
    BLEnvironment *_environment;
    BLReader *_reader;
    
    NSString *_parsingReturnValue;
}

- (id)init {
    self = [super init];
    if (self) {
	_environment = [BLEnvironment new];
	_environment.symbolTable = [BLSymbolTable new]; // <- This ain't my responsibility...
	
	_reader = [BLReader new];
	_reader.delegate = self;
	
    }
    return self;
}

-(id) parseAndEval:(NSString*)input {
    _parsingReturnValue = @"";
    
    if (!input) {
        return _parsingReturnValue;
    }
    
    [_reader read:input];
    
    return _parsingReturnValue;
}

-(void) reader:(BLReader*)reader didReadNewForm:(BLCons*)form {
    NSString *evalResult = [[BLLambdaEval new] eval:form withEnvironment:_environment];
    _parsingReturnValue = [evalResult description];
}

@end
