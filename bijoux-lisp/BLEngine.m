//
//  BLEngine.m
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Soma Creates. All rights reserved.
//

#import "BLEngine.h"

@implementation BLEngine
-(id)eval:(id)sexp {
    return [NSString stringWithFormat:@"You said: \"%@\"", sexp];
}
@end
