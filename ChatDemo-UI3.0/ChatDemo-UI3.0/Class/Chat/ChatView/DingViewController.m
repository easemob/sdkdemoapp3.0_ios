//
//  DingViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 12/01/2018.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "DingViewController.h"

#import "EMDingMessageHelper.h"

@interface DingViewController ()

@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSString *to;
@property (nonatomic) EMChatType chatType;
@property (nonatomic, copy) void (^finishCompletion)(EMMessage *aMessage);

@property (nonatomic, strong) UITextView *textView;

@end

@implementation DingViewController

- (instancetype)initWithConversationId:(NSString *)aConversationId
                                    to:(NSString *)aTo
                              chatType:(EMChatType)aChatType
                      finishCompletion:(void (^)(EMMessage *aMessage))aCompletion
{
    self = [super init];
    if (self) {
        _conversationId = aConversationId;
        _to = aTo;
        _chatType = aChatType;
        _finishCompletion = aCompletion;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    self.title = NSLocalizedString(@"title.notifMsg", @"Notification message");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"send", @"Send") style:UIBarButtonItemStylePlain target:self action:@selector(sendAction)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, 150)];
    self.textView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.textView.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:self.textView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (void)sendAction
{
    [self.view endEditing:YES];
    
    if ([self.textView.text length] == 0) {
        return;
    }
    
    if (self.finishCompletion) {
        EMMessage *message = [[EMDingMessageHelper sharedHelper] createDingMessageWithText:self.textView.text conversationId:self.conversationId to:self.to chatType:self.chatType];
        self.finishCompletion(message);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
