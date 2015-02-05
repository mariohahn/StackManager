//
//  StackManager.h
//  VideoOnDemand
//
//  Created by MarioHahn on 04/02/15.
//  Copyright (c) 2015 Mario Hahn. All rights reserved.
//
#import <Foundation/Foundation.h>
@import UIKit;

@interface StackManagerTapGestureRecognizer : UITapGestureRecognizer
@end

@interface StackManager : NSObject
@property (nonatomic,strong) NSMutableArray *viewControllers;
@property (nonatomic) CGFloat paddingBetweenViewControllers;

-(instancetype)initWithViewController:(UIViewController*)viewController;

-(void)presentViewController:(UIViewController*)viewControllerToPresent; //Default Size CGSizeMake(540, 620)
-(void)presentViewController:(UIViewController*)viewControllerToPresent withSize:(CGSize)size;
@end