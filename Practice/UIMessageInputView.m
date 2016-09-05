//
//  UIMessageInputView.m
//  Practice
//
//  Created by Zark on 7/26/16.
//  Copyright © 2016 imzark. All rights reserved.
//

#define KeyboardView_Height 216.0
#define MessageInputView_Height 50.0
#define MessageInputView_HeightMax 120.0
#define MessageInputView_PadingHeight 7.0
#define MessageInputView_Tool_Width 35.0
#define PaddingLeftWidth 15.0


#import "UIMessageInputView.h"
#import "UIPlaceHolderTextView.h"
#import <Masonry/Masonry.h>

static NSMutableDictionary *_inputStrDict;
static NSString *global_key = @"practice";

@interface UIMessageInputView () <AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>

@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@property (strong, nonatomic) UIScrollView *contentView;
@property (strong, nonatomic) UIPlaceHolderTextView *inputTextView;
@property (strong, nonatomic) UIButton *arrowKeyboardButton;
@property (strong, nonatomic) UIButton *addButton, *emotionButton, *photoButton, *voiceButton;
@property (assign, nonatomic) CGFloat viewHeightOld;
@property (assign, nonatomic) UIMessageInputViewState inputState;
@property (strong, nonatomic) NSString *global_key;

@end

@implementation UIMessageInputView

-(void)setFrame:(CGRect)frame {
    CGFloat oldheightToBottom = Screen_Height - CGRectGetMinY(self.frame);
    CGFloat newheightToBottom = Screen_Height - CGRectGetMinY(frame);
    [super setFrame:frame];
    if (fabs(oldheightToBottom - newheightToBottom) > 0.1) {
        DebugLog(@"heightToBottom-----:%.2f", newheightToBottom);
        if (oldheightToBottom > newheightToBottom) {
            //此时，保存已输入到字典
            [self saveInputStr];
        }

//        if (_delegate && [_delegate respondsToSelector:@selector(messageInputView:heightToBottomChenged:)]) {
//            [self.delegate messageInputView:self heightToBottomChenged:newheightToBottom];
//        }
    }
}

- (void)setInputState:(UIMessageInputViewState)inputState{
    if (_inputState != inputState) {
        _inputState = inputState;
        switch (_inputState) {
            case UIMessageInputViewStateSystem:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateEmotion:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateAdd:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateVoice:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
        
        _contentView.hidden = _inputState == UIMessageInputViewStateVoice;
        _arrowKeyboardButton.hidden = !_contentView.hidden;
        
        [self updateContentView]; //按了某按钮state变了，contentview也要update
        
        _arrowKeyboardButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder{
    if (_inputTextView && ![_inputTextView.placeholder isEqualToString:placeHolder]) {
        _placeHolder = placeHolder;
        _inputTextView.placeholder = placeHolder;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
//        [self addLineUp:YES andDown:NO andColor:[UIColor lightGrayColor]]; // zark: 上下分界线
        _viewHeightOld = CGRectGetHeight(frame);
        _inputState = UIMessageInputViewStateSystem;
        _isAlwaysShow = NO;
        
        
        //zark: 手势
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //zark: dealloc时触发
}

- (void)didPan:(UIPanGestureRecognizer *)panGesture
{
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat verticalDiff = [panGesture translationInView:self].y;
        if (verticalDiff > 60) {
            [self isAndResignFirstResponder];
        }
    }
}

#pragma mark remember input

- (NSMutableDictionary *)shareInputStrDict{
    if (!_inputStrDict) {
        _inputStrDict = [[NSMutableDictionary alloc] init];
    }
    return _inputStrDict;
}

- (NSString *)inputKey{
    _global_key = global_key;
    NSString *inputKey = nil;
    if (_contentType == UIMessageInputViewContentTypePriMsg) {
        inputKey = [NSString stringWithFormat:@"privateMessage_%@", self.global_key];
    }
    return inputKey;
}

- (NSString *)inputStr{
    NSString *inputKey = [self inputKey];
    if (inputKey) {
        return [[self shareInputStrDict] objectForKey:inputKey];
    }
    return nil;
}

- (void)deleteInputData{
    NSString *inputKey = [self inputKey];
    if (inputKey) {
        [[self shareInputStrDict] removeObjectForKey:inputKey];
    }
}

- (void)saveInputStr{
    NSString *inputStr = _inputTextView.text;
    NSString *inputKey = [self inputKey];
    if (inputKey && inputKey.length > 0) {
        if (inputStr && inputStr.length > 0) {
            [[self shareInputStrDict] setObject:inputStr forKey:inputKey];
        }else{
            [[self shareInputStrDict] removeObjectForKey:inputKey];
        }
    }
}

#pragma mark Public

- (void)prepareToShow{
    if ([self superview] == KeyWindow) {
        return;
    }
    
    [self setY:Screen_Height];
    [KeyWindow addSubview:self];
    [KeyWindow addSubview:_emojiKeyboardView];
//    [KeyWindow addSubview:_addKeyboardView];
//    [KeyWindow addSubview:_voiceKeyboardView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    if (_isAlwaysShow && ![self isCustomFirstResponder]) {
        [UIView animateWithDuration:0.25 animations:^{
            [self setY:Screen_Height - CGRectGetHeight(self.frame)];
        }];
    }
}
- (void)prepareToDismiss{
    
    if ([self superview] == nil) {
        return;
    }
    
    [self isAndResignFirstResponder];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self setY:Screen_Height];
    } completion:^(BOOL finished) {
        [_emojiKeyboardView removeFromSuperview];
//        [_addKeyboardView removeFromSuperview];
//        [_voiceKeyboardView removeFromSuperview];
        [self removeFromSuperview];
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)notAndBecomeFirstResponder{
    
    self.inputState = UIMessageInputViewStateSystem;
    if ([_inputTextView isFirstResponder]) {
        return NO;
    }else{
        [_inputTextView becomeFirstResponder];
        return YES;
    }
}

- (BOOL)isAndResignFirstResponder{
    if (self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion || self.inputState == UIMessageInputViewStateVoice) {
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_emojiKeyboardView setY:Screen_Height];
//            [_addKeyboardView setY:kScreen_Height];
//            [_voiceKeyboardView setY:kScreen_Height];
            if (self.isAlwaysShow) {
                [self setY:Screen_Height- CGRectGetHeight(self.frame)];
            }else{
                [self setY:Screen_Height];
            }
        } completion:^(BOOL finished) {
            self.inputState = UIMessageInputViewStateSystem;
        }];
        return YES;
    }else{
        if ([_inputTextView isFirstResponder]) {
            [_inputTextView resignFirstResponder];
            return YES;
        }else{
            return NO;
        }
    }
}

- (BOOL)isCustomFirstResponder{
    return ([_inputTextView isFirstResponder] || self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion || self.inputState == UIMessageInputViewStateVoice);
}

+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type{
    return [self messageInputViewWithType:type placeHolder:nil];
}
+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type placeHolder:(NSString *)placeHolder{
    UIMessageInputView *messageInputView = [[UIMessageInputView alloc] initWithFrame:CGRectMake(0, Screen_Height, Screen_Width, MessageInputView_Height)];
    
    [messageInputView customUIWithType:type];
    
    if (placeHolder) {
        messageInputView.placeHolder = placeHolder;
    }else{
        messageInputView.placeHolder = @"说点什么吧...";
    }
    return messageInputView;
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

- (void)customUIWithType:(UIMessageInputViewContentType)type{
    _contentType = type;

    CGFloat contentViewHeight = MessageInputView_Height -2*MessageInputView_PadingHeight;

    NSInteger toolBtnNum; //zark: 这里指的是右侧按钮数量
    BOOL hasEmotionBtn, hasAddBtn, hasVoiceBtn;
    
    switch (_contentType) {
        case UIMessageInputViewContentTypeTweet: //zark: 评论情况
        {
            toolBtnNum = 1;
            hasEmotionBtn = YES;
            hasAddBtn = NO;
            hasVoiceBtn = NO;
        }
            break;
        case UIMessageInputViewContentTypePriMsg:
        {
            toolBtnNum = 2;
            hasEmotionBtn = YES;
            hasAddBtn = YES;
            hasVoiceBtn = YES;
        }
            break;
        
        default:
            toolBtnNum = 1;
            hasEmotionBtn = NO;
            hasAddBtn = NO;
            hasVoiceBtn = NO;
            break;
    }

    __weak typeof(self) weakSelf = self; // zark: weak self
    
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.borderWidth = 0.5;
        _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _contentView.layer.cornerRadius = contentViewHeight/2;
        _contentView.layer.masksToBounds = YES;
        _contentView.alwaysBounceVertical = YES;
        [self addSubview:_contentView];
        
        //zark: constrains
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat left = hasVoiceBtn ? (7+MessageInputView_Tool_Width+7) : PaddingLeftWidth;
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(MessageInputView_PadingHeight, left, MessageInputView_PadingHeight, PaddingLeftWidth + toolBtnNum * MessageInputView_Tool_Width));
        }];
    }
    
    if (!_inputTextView) {
        _inputTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width - PaddingLeftWidth - toolBtnNum *MessageInputView_Tool_Width - (hasVoiceBtn ? 7+MessageInputView_Tool_Width+7 : PaddingLeftWidth), contentViewHeight)];
        _inputTextView.font = [UIFont systemFontOfSize:16];
        _inputTextView.returnKeyType = UIReturnKeySend;
        _inputTextView.scrollsToTop = NO; //状态栏to top
        
        _inputTextView.delegate = self;
        
        UIEdgeInsets insets = _inputTextView.textContainerInset;
        insets.left += 8.0;
        insets.right += 8.0;
        _inputTextView.textContainerInset = insets;
        
        [self.contentView addSubview:_inputTextView];
    }

    if (hasEmotionBtn && !_emotionButton) {
        _emotionButton = [[UIButton alloc] initWithFrame:CGRectMake(Screen_Width - PaddingLeftWidth/2 - toolBtnNum * MessageInputView_Tool_Width, (MessageInputView_Height - MessageInputView_Tool_Width)/2, MessageInputView_Tool_Width, MessageInputView_Tool_Width)];
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
        [_emotionButton addTarget:self action:@selector(emotionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_emotionButton];
    }
    _emotionButton.hidden = !hasEmotionBtn;
    
    if (hasAddBtn && !_addButton) {
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(Screen_Width - PaddingLeftWidth/2 -MessageInputView_Tool_Width, (MessageInputView_Height - MessageInputView_Tool_Width)/2, MessageInputView_Tool_Width, MessageInputView_Tool_Width)];
        
        [_addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addButton];
    }
    _addButton.hidden = !hasAddBtn;
    
    if (hasVoiceBtn && !_voiceButton) {
        _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(7, (MessageInputView_Height - MessageInputView_Tool_Width)/2, MessageInputView_Tool_Width, MessageInputView_Tool_Width)];
        
        [_voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
        [_voiceButton addTarget:self action:@selector(voiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_voiceButton];
    }
    _voiceButton.hidden = !hasVoiceBtn;
    
    if (hasEmotionBtn && !_emojiKeyboardView) {
        _emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, KeyboardView_Height) dataSource:self];
        
        //zark: AGEmojiKeyboard delegate方法
        _emojiKeyboardView.delegate = self;
        [_emojiKeyboardView setY:Screen_Height];
    }
    
//    if (hasAddBtn && !_addKeyboardView){
//    }
//    if (hasVoiceBtn && !_voiceKeyboardView) {
//    }
    
    if (_inputTextView) {
        [[RACObserve(self.inputTextView, contentSize) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSValue *contentSize) {
            [weakSelf updateContentView];
        }];
    }

}

- (void)updateContentView {
    
    CGSize textSize = _inputTextView.contentSize;
    
    if (ABS(CGRectGetHeight(_inputTextView.frame) - textSize.height) > 0.5) {
        [_inputTextView setHeight:textSize.height];
    }
    if (_contentView.hidden) {
        textSize.height = MessageInputView_Height - 2*MessageInputView_PadingHeight;
    }

    CGSize contentSize = CGSizeMake(textSize.width, textSize.height);
    CGFloat selfHeight = MAX(MessageInputView_Height, contentSize.height + 2*MessageInputView_PadingHeight);
    
    CGFloat maxSelfHeight = Screen_Height/2;
    if (Device_Is_iPhone5){
        maxSelfHeight = 230;
    }else if (Device_Is_iPhone6) {
        maxSelfHeight = 290;
    }else if (Device_Is_iPhone6Plus){
        maxSelfHeight = Screen_Height/2;
    }else{
        maxSelfHeight = 140;
    }
    
    selfHeight = MIN(maxSelfHeight, selfHeight);
    CGFloat diffHeight = selfHeight - _viewHeightOld;
    if (ABS(diffHeight) > 0.5) {
        CGRect selfFrame = self.frame;
        selfFrame.size.height += diffHeight;
        selfFrame.origin.y -= diffHeight;
        [self setFrame:selfFrame];
        self.viewHeightOld = selfHeight;
    }
    [self.contentView setContentSize:contentSize];
    
    CGFloat bottomY = textSize.height;
    CGFloat offsetY = MAX(0, bottomY - (CGRectGetHeight(self.frame)- 2* MessageInputView_PadingHeight));
    [self.contentView setContentOffset:CGPointMake(0, offsetY) animated:YES];
}
    
#pragma mark ButtonAction
- (void)addButtonClicked:(id)sender{
    CGFloat endY = Screen_Height;
    if (self.inputState == UIMessageInputViewStateAdd) {
        self.inputState = UIMessageInputViewStateSystem;
        [_inputTextView becomeFirstResponder];
    }else{
        self.inputState = UIMessageInputViewStateAdd;
        [_inputTextView resignFirstResponder];
        endY = Screen_Height - KeyboardView_Height;
    }
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
//        [_addKeyboardView setY:endY];
//        [_emojiKeyboardView setY:endy];
//        [_voiceKeyboardView setY:kScreen_Height];
        
        if (ABS(Screen_Height - endY) > 0.1) {
            [self setY:endY- CGRectGetHeight(self.frame)];
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)emotionButtonClicked:(id)sender{
    CGFloat endY = Screen_Height;
    if (self.inputState == UIMessageInputViewStateEmotion) {
        self.inputState = UIMessageInputViewStateSystem;
        [_inputTextView becomeFirstResponder];
    }else{
        self.inputState = UIMessageInputViewStateEmotion;
        [_inputTextView resignFirstResponder];
        endY = Screen_Height - KeyboardView_Height;
    }
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_emojiKeyboardView setY:endY];
//        [_addKeyboardView setY:kScreen_Height];
//        [_voiceKeyboardView setY:kScreen_Height];
        if (ABS(Screen_Height - endY) > 0.1) {
            [self setY:endY- CGRectGetHeight(self.frame)];
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)voiceButtonClicked:(id)sender {
    CGFloat endY = Screen_Height;
    if (self.inputState == UIMessageInputViewStateVoice) {
        self.inputState = UIMessageInputViewStateSystem;
        [_inputTextView becomeFirstResponder];
    } else {
        self.inputState = UIMessageInputViewStateVoice;
        [_inputTextView resignFirstResponder];
        endY = Screen_Height - KeyboardView_Height;
    }
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
//        [_voiceKeyboardView setY:endY];
//        [_emojiKeyboardView setY:kScreen_Height];
//        [_addKeyboardView setY:kScreen_Height];
        if (ABS(Screen_Height - endY) > 0.1) {
            [self setY:endY- CGRectGetHeight(self.frame)];
        }
    } completion:^(BOOL finished) {
    }];
    
//    if (_voiceRedpointView) {
//        [_voiceRedpointView removeFromSuperview];
//        self.voiceRedpointView = nil;
//        
//        [[FunctionTipsManager shareManager] markTiped:kFunctionTipStr_VoiceMessage];
//    }
}


#pragma mark UITextViewDelegate 
- (void)sendTextStr{
    [self deleteInputData];
    NSMutableString *sendStr = [NSMutableString stringWithString:self.inputTextView.text];
    
    if (sendStr && ![sendStr isEmpty] && _delegate && [_delegate respondsToSelector:@selector(messageInputView:sendText:)]) {
        [self.delegate messageInputView:self sendText:sendStr];
    }

    _inputTextView.selectedRange = NSMakeRange(0, _inputTextView.text.length);
    [_inputTextView insertText:@""];
    [self updateContentView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self sendTextStr];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (self.inputState != UIMessageInputViewStateSystem) {
        self.inputState = UIMessageInputViewStateSystem;
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_emojiKeyboardView setY:Screen_Height];
//            [_addKeyboardView setY:kScreen_Height];
//            [_voiceKeyboardView setY:kScreen_Height];
        } completion:^(BOOL finished) {
            self.inputState = UIMessageInputViewStateSystem;
        }];
    }
    return YES;
}

#pragma mark - KeyBoard Notification Handlers
- (void)keyboardChange:(NSNotification*)aNotification{
    
    if ([aNotification name] == UIKeyboardDidChangeFrameNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    if (self.inputState == UIMessageInputViewStateSystem && [self.inputTextView isFirstResponder]) {
        NSDictionary* userInfo = [aNotification userInfo];
        
        CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardY =  keyboardEndFrame.origin.y;
        
        CGFloat selfOriginY = keyboardY == Screen_Height? self.isAlwaysShow? Screen_Height - CGRectGetHeight(self.frame): Screen_Height : keyboardY - CGRectGetHeight(self.frame);
        //        if (keyboardY == kScreen_Height) {
        //            if (self.isAlwaysShow) {
        //                selfOriginY = kScreen_Height- CGRectGetHeight(self.frame);
        //            }else{
        //                selfOriginY = kScreen_Height;
        //            }
        //        }else{
        //            selfOriginY = keyboardY-CGRectGetHeight(self.frame);
        //        }
        if (selfOriginY == self.frame.origin.y) {
            return;
        }
        
        
        __weak typeof(self) weakSelf = self;
        void (^endFrameBlock)() = ^(){
            [weakSelf setY:selfOriginY];
        };
        
        if ([aNotification name] == UIKeyboardWillChangeFrameNotification) {
            NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
            [UIView animateWithDuration:animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
                endFrameBlock();
            } completion:nil];
        }else{
            endFrameBlock();
        }
    }
}

#pragma mark AGEmojiKeyboardView
- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    
        [self.inputTextView insertText:emoji];
    
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.inputTextView deleteBackward];
}

- (void)emojiKeyBoardViewDidPressSendButton:(AGEmojiKeyboardView *)emojiKeyBoardView{
    [self sendTextStr];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img;
    
    img = [UIImage imageNamed:@"keyboard_emotion_emoji"];
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    return [self emojiKeyboardView:emojiKeyboardView imageForSelectedCategory:category];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"keyboard_emotion_delete"];
    return img;
}









@end