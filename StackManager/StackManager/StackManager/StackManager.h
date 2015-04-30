//
//  StackManager.h
//
//  Created by MarioHahn on 04/02/15.
//  Copyright (c) 2015 Mario Hahn. All rights reserved.
//


@import Foundation;
@import UIKit;

@class StackManager;

@protocol StackManagerDelegate <NSObject>

@optional
-(void)stackManager:(StackManager*)manager didAddViewController:(UIViewController*)viewController;

-(void)stackManager:(StackManager*)manager willRemoveViewController:(UIViewController*)viewController;
-(void)stackManager:(StackManager*)manager didRemoveViewController:(UIViewController*)viewController;
@end

@interface StackManagerTapGestureRecognizer : UITapGestureRecognizer
@end

@interface StackManager : NSObject
@property (nonatomic,strong) NSMutableArray *viewControllers;
@property (nonatomic) CGFloat paddingBetweenViewControllers;

@property (nonatomic, assign)   id <StackManagerDelegate> delegate;

-(instancetype)initWithViewController:(UIViewController*)viewController;

-(void)presentViewController:(UIViewController*)viewControllerToPresent; //Default Size CGSizeMake(540, 620)
-(void)presentViewController:(UIViewController*)viewControllerToPresent withSize:(CGSize)size;

-(void)dismissViewController:(UIViewController*)viewControllerToDismiss;

@end