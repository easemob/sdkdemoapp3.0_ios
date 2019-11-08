//
//  readReceiptMsgViewController.m
//  EMiOSDemo
//
//  Created by 娜塔莎 on 2019/10/23.
//  Copyright © 2019 娜塔莎. All rights reserved.
//
#define LRWindowWidth UIScreen.mainScreen.bounds.size.width
#define LRWindowHeight UIScreen.mainScreen.bounds.size.height
#define kColor_Blue [UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0]
#define LRSafeAreaTopHeight ((LRWindowHeight == 812.0 || LRWindowHeight == 896) ? 64 : 40)
#define ktextViewMinHeight 40
#define ktextViewMaxHeight 120
#import "EMReadReceiptMsgViewController.h"
#import "EMTextView.h"
#import "EMMessageCell.h"
#import "EMDateHelper.h"
#import "EMReadReceiptTableViewCell.h"
#import "EMReadReceiptMemberModel.h"

@interface EMReadReceiptMsgViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) EMTextView *textView;
@property (nonatomic, strong) EMMessageCell *msgCell;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSString *groupId;

@property (nonatomic, strong) dispatch_queue_t msgQueue;

//消息格式化
@property (nonatomic) NSTimeInterval msgTimelTag;

@end

@implementation EMReadReceiptMsgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    for (int i=0; i<4; i++) {
        EMReadReceiptMemberModel *model = [[EMReadReceiptMemberModel alloc]initWithInfo:[UIImage imageNamed:@"user_avatar_me"] nick:[NSString stringWithFormat:@"member %d",i] time:@"12:12"];
        [self.dataArray  addObject:model];
    }*/
    self.msgTimelTag = -1;
    self.msgQueue = dispatch_queue_create("EMReadReceipt.com", NULL);
    [self _setupSubviews];
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithMessageCell:(EMMessageCell *)messageCell groupId:(NSString *)groupId {
    self = [super init];
    if(self){
        self.msgCell = messageCell;
        self.groupId = groupId;
        [self getMessage];
    }
    return self;
}

- (void)getMessage
{
    __weak typeof(self) weakself = self;
    void (^block)(NSArray *aMessages, EMError *aError ,int count) = ^(NSArray *aMessages, EMError *aError ,int count) {
        
        if (!aError && [aMessages count]) {
            dispatch_async(self.msgQueue, ^{
                NSArray *formated = [weakself _formatMessages:aMessages];
                [weakself.dataArray insertObjects:formated atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakself.countLable.text = [NSString stringWithFormat:@"已阅读用户：%d",count];
                    [weakself.memberTableView reloadData];
                    
                });
            });
        }
    };
    
    [[EMClient sharedClient].chatManager asyncFetchGroupMessageAcksFromServer:_msgCell.model.emModel.messageId groupId:self.groupId startGroupAckId:nil pageSize:100 completion:^(EMCursorResult *aResult, EMError *error, int totalCount) {
        block(aResult.list,error,totalCount);
    }];
}

- (NSArray *)_formatMessages:(NSArray<EMMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];
    NSString *timeStr;
    for (int i = 0; i < [aMessages count]; i++) {
        EMMessage *msg = aMessages[i];
        CGFloat interval = (self.msgTimelTag - msg.timestamp) / 1000;
        if (self.msgTimelTag < 0 || interval > 60 || interval < -60) {
            timeStr = [EMDateHelper formattedTimeFromTimeInterval:msg.timestamp];
            self.msgTimelTag = msg.timestamp;
        }
        EMReadReceiptMemberModel *model = [[EMReadReceiptMemberModel alloc]initWithInfo:[UIImage imageNamed:@"user_avatar_me"] nick:msg.from time:timeStr];
        [formated addObject:model];
    }
    
    return formated;
}

- (void)_setupSubviews
{
    self.closeButton = [[UIButton alloc] init];
    self.closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 10, 15);
    [self.closeButton setImage:[UIImage imageNamed:@"back_gary"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(LRSafeAreaTopHeight);
        make.left.equalTo(self.view);
        make.width.equalTo(@60);
        make.height.equalTo(@45);
    }];
     
    
    self.titleLabel = [[UILabel alloc] init];
    if(_msgCell) {
        self.titleLabel.text = @"阅读回执详情";
    } else {
        self.titleLabel.text = @"阅读回执";
    }
    [self.titleLabel setTextColor:[UIColor blackColor]];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        //make.top.equalTo(self.view).offset(LRSafeAreaTopHeight);
        make.centerY.equalTo(self.closeButton.imageView);
    }];
    
    self.textView = [[EMTextView alloc] init];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.returnKeyType = UIReturnKeyDone;
    [self.textView setEditable:YES];
    
    
    if (_msgCell) {
        [self _readReceiptDetil];
    } else {
        [self _setupSendReadReceiptView];
    }
}

//阅读回执详情 UI
- (void)_readReceiptDetil {
    
    UIView *msgView = [[UIView alloc]init];
    [self.view addSubview:msgView];
    [msgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.left.equalTo(self.view).offset(10);
        make.height.equalTo(@60);
    }];
    
    UIImageView *img = [[UIImageView alloc]init];
    img.image = [UIImage imageNamed:@"pin-red"];
    [self.view addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(msgView).offset(5);
        make.left.equalTo(msgView.mas_left);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    //发送的信息
    UILabel *msgLable = [[UILabel alloc]init];
    [msgLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    msgLable.textColor = [UIColor blackColor];
    msgLable.numberOfLines = 0;
    EMTextMessageBody *body = (EMTextMessageBody *)_msgCell.model.emModel.body;
    msgLable.text = [EMEmojiHelper convertEmoji:body.text];
    [msgView addSubview:msgLable];
    [msgLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(msgView);
        make.left.equalTo(msgView.mas_left).offset(40);
        make.right.equalTo(msgView);
        make.height.equalTo(@40);
    }];
    //发送的用户信息
    UILabel *personInfoLable = [[UILabel alloc]init];
    personInfoLable.font = [UIFont systemFontOfSize:14];
    personInfoLable.textColor = [UIColor grayColor];
    personInfoLable.numberOfLines = 0;
    NSString *name = _msgCell.model.emModel.from;
    NSString *time = [EMDateHelper formattedTimeFromTimeInterval:_msgCell.model.emModel.localTime];
    NSString *personInfo = [NSString stringWithFormat:@"%@  %@",name,time];
    personInfoLable.text = personInfo;
    [msgView addSubview:personInfoLable];
    [personInfoLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(msgLable.mas_bottom);
        make.left.equalTo(msgView.mas_left).offset(40);
        make.bottom.equalTo(msgView.mas_bottom).offset(-2);
        make.width.equalTo(msgView);
    }];
    //上直线
    UILabel *line = [[UILabel alloc]init];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(msgView.mas_bottom).offset(8);
        make.left.equalTo(msgView.mas_left).offset(40);
        make.height.equalTo(@1);
        make.right.equalTo(msgView);
    }];
    //计数器
    self.countLable = [[UILabel alloc]init];
    self.countLable.text = @"已阅读用户：";
    self.countLable.font = [UIFont systemFontOfSize:14];
    self.countLable.textColor = [UIColor blackColor];
    self.countLable.numberOfLines = 0;
    self.countLable.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.countLable];
    [self.countLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_bottom);
        make.right.equalTo(msgView);
        make.left.equalTo(line);
        make.height.equalTo(@40);
    }];
    
    //下直线
    UILabel *lineBelow = [[UILabel alloc]init];
    lineBelow.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineBelow];
    [lineBelow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.countLable.mas_bottom).offset(10);
        make.left.equalTo(msgView.mas_left);
        make.height.equalTo(@1);
        make.right.equalTo(msgView);
    }];
    /*
    [self.view addSubview:self.textView];
    self.textView.placeholder = @"请输入搜索内容";
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineBelow.mas_bottom).offset(5);
        make.left.right.equalTo(msgView);
        make.height.mas_equalTo(ktextViewMinHeight);
    }];
    */
    
    self.memberTableView.backgroundColor = [UIColor lightTextColor];
    self.memberTableView.backgroundColor = kColor_LightGray;
    self.memberTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.memberTableView setSeparatorColor:[UIColor blackColor]];
    [self.memberTableView setSeparatorInset:UIEdgeInsetsMake(129,10,0,10)];
    self.memberTableView.rowHeight = 60;
    //self.memberTableView.estimatedRowHeight = 130;
    [self.view addSubview:self.memberTableView];
    [self.memberTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineBelow).offset(1);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    self.memberTableView.delegate = self;
    self.memberTableView.dataSource = self;
}

//发送阅读回执信息 UI
- (void)_setupSendReadReceiptView {
    
    [self.view addSubview:self.textView];
    self.textView.placeholder = @"请输入消息内容";
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(LRSafeAreaTopHeight + 50);
        make.left.equalTo(self.view).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.height.mas_equalTo(ktextViewMinHeight);
    }];
    
    UIButton *sendBtn;
    sendBtn = [[UIButton alloc] init];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:kColor_Blue forState:UIControlStateNormal];
    sendBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    sendBtn.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [sendBtn addTarget:self action:@selector(sendMsg) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(LRSafeAreaTopHeight);
        make.right.equalTo(self.view).offset(-10);
        make.width.equalTo(@45);
        make.height.equalTo(@35);
    }];

}

- (void)sendMsg
{
    NSString *str = self.textView.text;
    if([str length] == 0){
        [self showHint:@"请输入消息."];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendReadReceiptMsg:)]) {
        [self.delegate sendReadReceiptMsg:str];
    }
    [self closeButtonAction];
}

- (void)closeButtonAction
{
    //[self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //回收键盘，两者方式
    //UITextView *textView = (UITextView*)[self.view viewWithTag:1001];
    //[textView resignFirstResponder];
    [self.view endEditing:YES];
    NSLog(@"touch");
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"开始编辑");
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"结束编辑");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range

 replacementText:(NSString *)text

{
    NSLog(@"%@",text);
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        
        // Be sure to test for equality using the "isEqualToString" message
        
        [textView resignFirstResponder];

        return FALSE;
    }
    return TRUE;
    
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (UITableView *)memberTableView
{
    if (_memberTableView == nil) {
        _memberTableView = [[UITableView alloc] init];

    }
    return _memberTableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.dataArray objectAtIndex:indexPath.row];
    EMReadReceiptMemberModel *model = (EMReadReceiptMemberModel *)obj;

    EMReadReceiptTableViewCell *cell = (EMReadReceiptTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"member"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMReadReceiptTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"member"];
    }

    cell.model = model;
    return cell;
}

@end
