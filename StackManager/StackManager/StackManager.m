//
//  StackManager.m
//  VideoOnDemand
//
//  Created by MarioHahn on 04/02/15.
//  Copyright (c) 2015 Mario Hahn. All rights reserved.
//

#import "StackManager.h"
#import "Masonry.h"

@implementation StackManagerTapGestureRecognizer

@end

@interface StackManager()
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
    
    BOOL hasGesture = NO;
    for (UIGestureRecognizer *gesture in lastViewController.view.gestureRecognizers) {
        if ([gesture isKindOfClass:StackManagerTapGestureRecognizer.class]) {
            hasGesture = YES;
            break;
        }
    }
    if (!hasGesture) {
        [lastViewController.view addGestureRecognizer:[StackManagerTapGestureRecognizer.alloc initWithTarget:self action:@selector(dismissLast)]];
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
    
    
    [self setTransFormForViewControllerpositiv:NO];
    
    viewControllerToPresent.view.alpha = 0;
    viewControllerToPresent.view.userInteractionEnabled = YES;
    
    
    [self.viewControllers addObject:viewControllerToPresent];
    [self.viewController willMoveToParentViewController:viewControllerToPresent];
    [self.containerView addSubview:viewControllerToPresent.view];
    [self.viewController addChildViewController:viewControllerToPresent];
    [viewControllerToPresent didMoveToParentViewController:self.viewController];

    [viewControllerToPresent.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.center.mas_equalTo(self.containerView);
    }];
    
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

-(void)removeViewController:(UIViewController*)viewController adjustOtherViewControllers:(BOOL)adjust removeShodow:(BOOL)removeShadow animationDuration:(CGFloat)duration{
    
    [viewController willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:duration animations:^{
        viewController.view.alpha = 0;
        if (removeShadow) {self.shadowView.alpha = 0;}
        
    } completion:^(BOOL finished) {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
        if (removeShadow) {[self.containerView removeFromSuperview];}
        [self.viewControllers removeObject:viewController];
        
        if (adjust) {
            UIView *gestureView = [self.viewControllers.lastObject view];
            for (UIGestureRecognizer *gesture in gestureView.gestureRecognizers) {
                if ([gesture isKindOfClass:StackManagerTapGestureRecognizer.class]) {
                    [gestureView removeGestureRecognizer:gesture];
                }
            }
            [self setTransFormForViewControllerpositiv:YES];
        }
    }];
}

-(void)setTransFormForViewControllerpositiv:(BOOL)positiv{
    for (UIViewController *viewController in self.viewControllers) {
        
        CGFloat width = CGRectGetWidth(viewController.view.bounds) + self.paddingBetweenViewControllers;
        [UIView animateWithDuration:0.2 animations:^{
            viewController.view.transform = CGAffineTransformTranslate(viewController.view.transform, positiv ? width : -width , 0);
        }];
    }
}

@end
