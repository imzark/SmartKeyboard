//
//  ViewController.m
//  Practice
//
//  Created by Zark on 7/21/16.
//  Copyright © 2016 imzark. All rights reserved.
//

#import "ViewController.h"
#import "ConversationViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] init];
    button.center = self.view.center;
    [button setHeight:50];
    [button setWidth:50];
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [button setBackgroundColor:[UIColor blackColor]];
    button.layer.cornerRadius = 25;
    button.layer.masksToBounds = YES;
    
    [self.view addSubview:button];
    
    [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)tap: (id)sender {
    ConversationViewController *ConVC = [[ConversationViewController alloc] init];
    [self presentViewController:ConVC animated:YES completion:^(void){}];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
