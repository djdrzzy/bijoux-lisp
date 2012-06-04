//
//  BLLambda.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-04.
//  Copyright (c) 2012 Daniel Drzimotta. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BLCons.h"

@interface BLLambda : NSObject
-(id) eval:(id)sexp;
@end

@interface BLLambdaAdd : BLLambda
@end

@interface BLLambdaEval : BLLambda
@end

@interface BLLambdaAtom :BLLambda
@end