//
//  ViewController.m
//  StackManager
//
//  Created by MarioHahn on 05/02/15.
//  Copyright (c) 2015 Mario Hahn. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.manager) {
        self.manager = [StackManager.alloc initWithViewController:self];
    }
}
- (IBAction)stackPresentAction:(id)sender {
    ViewController *present = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    present.manager = self.manager;
    present.view.backgroundColor = UIColor.redColor;
    [self.manager presentViewController:present];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
