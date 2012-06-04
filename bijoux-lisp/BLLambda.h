//
//  BLLambda.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-04.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLLambda : NSObject
+(BLLambda*) lambdaWithArgs:(BLCons*)args body:(BLCons*)body;
-(id) eval:(id)sexp;
@end
