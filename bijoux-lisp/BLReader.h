//
//  BLReader.h
//  bijoux-lisp
//
//  Created by Daniel Drzimotta on 12-06-17.
//  Copyright (c) 2012 Soma Creates. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BLReaderDelegate;

@class BLCons;

@interface BLReader : NSObject
@property (nonatomic, weak) id<BLReaderDelegate> delegate;
-(void) read:(id)input;
@end

@protocol BLReaderDelegate <NSObject>
@required
-(void) reader:(BLReader*)reader didReadNewForm:(BLCons*)form;
@end