//
//  BLLambda.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-04.
//  Copyright (c) 2012 Daniel Drzimotta. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol BLLambda <NSObject>
@required
+(id) symbolName;
-(id) eval:(id)form;
@end


@interface BLLambdaAdd : NSObject <BLLambda>
@end

@interface BLLambdaSubtract : NSObject <BLLambda>
@end

@interface BLLambdaEval : NSObject <BLLambda>
@end

@interface BLLambdaAtom : NSObject <BLLambda>
@end

@interface BLLambdaQuote : NSObject <BLLambda>
@end

@interface BLLambdaCar : NSObject <BLLambda>
@end

@interface BLLambdaCdr : NSObject <BLLambda>
@end

@interface BLLambdaEqual : NSObject <BLLambda>
@end

@interface BLLambdaCons : NSObject <BLLambda> 
@end

@interface BLLambdaLambda : NSObject <BLLambda>
@end

@interface BLLambdaLabel : NSObject <BLLambda>
@end

@interface BLLambdaCond : NSObject <BLLambda>
@end