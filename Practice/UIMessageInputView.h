//
//  UIMessageInputView.h
//  Practice
//
//  Created by Zark on 7/26/16.
//  Copyright © 2016 imzark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AGEmojiKeyBoard/AGEmojiKeyBoardView.h>

typedef NS_ENUM(NSInteger, UIMessageInputViewContentType) {
    UIMessageInputViewContentTypePriMsg,
    UIMessageInputViewContentTypeTweet
};

typedef NS_ENUM(NSInteger, UIMessageInputViewState) {
    UIMessageInputViewStateSystem,
    UIMessageInputViewStateEmotion,
    UIMessageInputViewStateAdd,
    UIMessageInputViewStateVoice
};

@protocol UIMessageInputViewDelegate;

@interface UIMessageInputView : UIView<UITextViewDelegate>
@property (strong, nonatomic) NSString *placeHolder;
@property (assign, nonatomic) BOOL isAlwaysShow;
@property (assign, nonatomic, readonly) UIMessageInputViewContentType contentType;

@property (nonatomic, weak) id<UIMessageInputViewDelegate> delegate;

+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type;
+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type placeHolder:(NSString *)placeHolder;

- (void)prepareToShow;
- (void)prepareToDismiss;
- (BOOL)notAndBecomeFirstResponder;
- (BOOL)isAndResignFirstResponder;
- (BOOL)isCustomFirstResponder;
@end

@protocol UIMessageInputViewDelegate <NSObject>
@optional
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text;
//- (void)messageInputView:(UIMessageInputView *)inputView sendBigEmotion:(NSString *)emotionName;
- (void)messageInputView:(UIMessageInputView *)inputView sendVoice:(NSString *)file duration:(NSTimeInterval)duration;
- (void)messageInputView:(UIMessageInputView *)inputView addIndexClicked:(NSInteger)index;
- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChanged:(CGFloat)heightToBottom;
@end