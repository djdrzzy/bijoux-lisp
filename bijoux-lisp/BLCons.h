//
//  BLCons.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 11-11-28.
//  Copyright (c) 2011 Daniel Drzimotta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLCons : NSObject <NSCopying>
@property (strong, nonatomic) id car;
@property (strong, nonatomic) id cdr;
-(id) initWithCar:(id)car cdr:(id)cdr;
-(void) replaceAtomsMatching:(id)match withReplacement:(id)replacement;
-(void) addToEnd:(id)obj;
@end
