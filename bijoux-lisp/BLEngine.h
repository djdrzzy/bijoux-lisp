//
//  BLEngine.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Daniel Drzimotta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEngine : NSObject
-(id) parseAndEval:(NSString*)input;
@end
