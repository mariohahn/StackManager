//
//  StackManager.m
//
//  Created by MarioHahn on 04/02/15.
//  Copyright (c) 2015 Mario Hahn. All rights reserved.
//

#import "StackManager.h"
#import "Masonry.h"

@interface StackManagerTapGestureRecognizer()
@end


@implementation StackManagerTapGestureRecognizer

@end

@interface StackManager()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIViewController *viewController;
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) UIView *shadowView;
@end

@implementation StackManager

-(instancetype)initWithViewController:(UIViewController*)viewController{
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.viewControllers = NSMutableArray.new;
        self.paddingBetweenViewControllers = 20;
    }
    return self;
}


-(UIView *)containerView{
    if (!_containerView) {
        _containerView = UIView.new;
        _containerView.userInteractionEnabled = YES;
        _containerView.backgroundColor = UIColor.clearColor;
        [_containerView addSubview:self.shadowView];
        
        [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_containerView);
        }];
    }
    return _containerView;
}

-(UIView *)shadowView{
    if (!_shadowView) {
        _shadowView = UIView.new;
        _shadowView.userInteractionEnabled = YES;
        _shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _shadowView.alpha = 0;
        [_shadowView addGestureRecognizer:[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(dismissAll)]];
    }
    return _shadowView;
}

-(void)presentViewController:(UIViewController*)viewControllerToPresent{
    [self presentViewController:viewControllerToPresent withSize:CGSizeMake(540, 620)];
}

-(void)addGestureToLastViewController{
    UIViewController *lastViewController = self.viewControllers.lastObject;
    if (!lastViewController) {return;}
    
    BOOL hasGesture = NO;
    for (UIGestureRecognizer *gesture in lastViewController.view.gestureRecognizers) {
        if ([gesture isKindOfClass:StackManagerTapGestureRecognizer.class]) {
            hasGesture = YES;
            break;
        }
    }
    if (!hasGesture) {
        StackManagerTapGestureRecognizer *stackTap = [StackManagerTapGestureRecognizer.alloc initWithTarget:self action:@selector(dismissLast)];
        stackTap.delegate = self;
        stackTap.cancelsTouchesInView = YES;
        [lastViewController.view addGestureRecognizer:stackTap];
    }
}

-(void)presentViewController:(UIViewController*)viewControllerToPresent withSize:(CGSize)size{
    
    if (self.containerView.superview == nil) {
        [self.viewController.view addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.viewController.view);
        }];
    }
    [self addGestureToLastViewController];
    
    viewControllerToPresent.view.alpha = 0;
    viewControllerToPresent.view.userInteractionEnabled = YES;
    [self addMotionEffectToView:viewControllerToPresent.view];
    
    [self.viewControllers addObject:viewControllerToPresent];
    
    [self.viewController willMoveToParentViewController:viewControllerToPresent];
    [self.containerView addSubview:viewControllerToPresent.view];
    if (UIDevice.currentDevice.systemVersion.floatValue < 9.0) {
        [self.viewController addChildViewController:viewControllerToPresent];
    }
    [viewControllerToPresent didMoveToParentViewController:self.viewController];
    
    [viewControllerToPresent.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.center.mas_equalTo(self.containerView);
    }];
    
    if (self.viewControllers.count > 1) {
        [self setTransFormForViewControllers];
    }
    
    if ([self.delegate respondsToSelector:@selector(stackManager:didAddViewController:)]) {
        [self.delegate stackManager:self didAddViewController:viewControllerToPresent];
    }
    
    [UIView animateWithDuration:0.4 delay:self.viewControllers.count ==1 ? 0: 0.2 options:0 animations:^{
        viewControllerToPresent.view.alpha = 1;
        self.shadowView.alpha = 1.0;
    } completion:nil];
}

-(void)dismissLast{
    [self removeViewController:self.viewControllers.lastObject adjustOtherViewControllers:YES removeShodow:NO animationDuration:0.2];
}

-(void)dismissAll{
    for (UIViewController *viewController in self.viewControllers) {
        [self removeViewController:viewController adjustOtherViewControllers:NO removeShodow:YES animationDuration:0.4];
    }
    self.viewControllers = NSMutableArray.new;
}

-(void)dismissViewController:(UIViewController*)viewControllerToDismiss{
    [self removeViewController:viewControllerToDismiss
    adjustOtherViewControllers:YES
                  removeShodow:self.viewControllers.count > 1 ? YES :NO
             animationDuration:0.2];
}

-(void)removeViewController:(UIViewController*)viewController adjustOtherViewControllers:(BOOL)adjust removeShodow:(BOOL)removeShadow animationDuration:(CGFloat)duration{
    
    if ([self.delegate respondsToSelector:@selector(stackManager:willRemoveViewController:)]) {
        [self.delegate stackManager:self willRemoveViewController:viewController];
    }
    
    [viewController willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:duration animations:^{
        viewController.view.alpha = 0;
        if (removeShadow) {self.shadowView.alpha = 0;}
        
    } completion:^(BOOL finished) {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
        if (removeShadow) {[self.containerView removeFromSuperview];}
        [self.viewControllers removeObject:viewController];
        
        if ([self.delegate respondsToSelector:@selector(stackManager:didRemoveViewController:)]) {
            [self.delegate stackManager:self didRemoveViewController:viewController];
        }
        
        if (adjust) {
            UIView *gestureView = [self.viewControllers.lastObject view];
            for (UIGestureRecognizer *gesture in gestureView.gestureRecognizers) {
                if ([gesture isKindOfClass:StackManagerTapGestureRecognizer.class]) {
                    [gestureView removeGestureRecognizer:gesture];
                }
            }
            [self setTransFormForViewControllers];
        }
    }];
}

-(void)addMotionEffectToView:(UIView*)view{
    
    UIInterpolatingMotionEffect *motionX = [UIInterpolatingMotionEffect.alloc initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    motionX.minimumRelativeValue = @(-30);
    motionX.maximumRelativeValue = @(30);
    
    UIInterpolatingMotionEffect *motionY = [UIInterpolatingMotionEffect.alloc initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    motionY.minimumRelativeValue = @(-30);
    motionY.maximumRelativeValue = @(30);
    
    UIMotionEffectGroup *motions = UIMotionEffectGroup.new;
    motions.motionEffects = @[motionX,motionY];
    
    [view addMotionEffect:motions];
}

-(void)setTransFormForViewControllers{
    for (UIViewController *viewController in self.viewControllers) {
        
        NSInteger multiplier = [self.viewControllers indexOfObject:viewController]-self.viewControllers.count+1;
        CGFloat offset = (CGRectGetWidth(viewController.view.bounds) + self.paddingBetweenViewControllers)*multiplier;
        
        [viewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.containerView).with.offset(offset);
        }];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.containerView layoutIfNeeded];
    }];
}

@end
