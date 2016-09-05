//
//  ConversationViewController.m
//  Practice
//
//  Created by Zark on 7/27/16.
//  Copyright © 2016 imzark. All rights reserved.
//

#import "ConversationViewController.h"
#import "UIMessageInputView.h"

@interface ConversationViewController ()<UIMessageInputViewDelegate>
@property UIMessageInputView *myMsgInputView;
@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypePriMsg placeHolder:@"请输入私信内容"];
    _myMsgInputView.isAlwaysShow = YES;
    _myMsgInputView.delegate = self;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [button setBackgroundColor:[UIColor blackColor]];
    button.layer.cornerRadius = 25;
    button.layer.masksToBounds = YES;
    
    [self.view addSubview:button];
    
    [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    if (_myMsgInputView) {
        [_myMsgInputView prepareToShow];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    if (_myMsgInputView) {
        [_myMsgInputView prepareToDismiss];
    }
}

- (void)tap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
