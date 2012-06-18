//
//  BLSymbol.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-13.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import <Foundation/Foundation.h>

// From: http://en.wikipedia.org/wiki/Common_Lisp
@interface BLSymbol : NSObject <NSCopying>
@property (copy) id name;
@property (strong) id value;
@property (strong) id function; // Unused till...

// Unused till be get defun? How does common lisp do it? Checked it out... yup.
// Look I learned something~! Weirdly in common lisp if we have not done a defun
// for say the symbol '*y*' but we have assigned a lambda to '*y*' we can not
// go (*y* args). It will say undefined function.

// Weirdly we can go: ((lambda (x) (+ x x)) 5) and it will give '10'. I wonder
// what decision led to that.

// Well our goal is to follow common lisp as close as possible... but lets defer
// this decision till we do get a defun... Until that happens we will be able to
// go (label *y* (lambda (x) (+ x x))) and then (*y* 5) => 10.

// Maybe we will make a precedence choice later where if there is not a function
// on that symbol we will check if there is a lambda...

-(id) initWithName:(NSString*)name;
-(BOOL) isEqualToSymbol:(BLSymbol*)symbol;
@end
