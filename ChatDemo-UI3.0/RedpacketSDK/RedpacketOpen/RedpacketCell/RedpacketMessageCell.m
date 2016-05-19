//
//  RedpacketMessageCell.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketMessageCell.h"
#import "RedpacketOpenConst.h"
#import "RedpacketMessageModel.h"
#import "EMClient.h"

@interface RedpacketMessageCell ()

@property (nonatomic, assign)   IBOutlet UILabel *titleLabel;
@property (nonatomic, assign)   IBOutlet UIImageView *icon;
@property (nonatomic, assign)   IBOutlet UIView *backView;

@property (nonatomic, assign)   IBOutlet NSLayoutConstraint *widthContraint;

@end

@implementation RedpacketMessageCell

- (void)awakeFromNib {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel.textColor = rp_hexColor(rp_textColorGray);
    
    self.backView.layer.cornerRadius = 3.0f;
    self.backView.layer.masksToBounds = YES;
    
    [self.icon setImage:[UIImage imageNamed:@"RedpacketCellResource.bundle/redpacket_smallIcon"]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTaped)];
    [self.backView addGestureRecognizer:tap];
    
    self.backView.backgroundColor = rp_hexColor(rp_backGroundColorGray);
}

- (void)setModel:(id<IMessageModel>)model
{
    _model = model;
    
    NSDictionary *dict = model.message.ext;
    
    NSString *sender = [dict valueForKey:RedpacketKeyRedpacketSenderNickname];
    NSString *receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverNickname];
    NSString *senderId = [dict valueForKey:RedpacketKeyRedpacketSenderId];
    NSString *receiverId = [dict valueForKey:RedpacketKeyRedpacketReceiverId];
    
    NSString *prompt;
    
    if (model.message.chatType == EMChatTypeChat) {
        /**
         *  点对点红包
         */
        if(model.isSender) {
            prompt = [NSString stringWithFormat:@"你领取了%@的红包", sender];
        }else {
            prompt = [NSString stringWithFormat:@"%@领取了你的红包", receiver];
        }
        
    }else{
        /**
         *  群红包
         */
        NSString *current = [EMClient sharedClient].currentUsername;
        
        if([receiverId isEqualToString:current]) {
            if([senderId isEqualToString:receiverId]) {
                //  自己抢了自己发送的红包
                prompt = [NSString stringWithFormat:@"你领取了自己的红包"];
                
            }else {
                prompt = [NSString stringWithFormat:@"你领取了%@的红包", sender];
            }
        }else{
            prompt = [NSString stringWithFormat:@"%@领取了你的红包", receiver];
        }
    }
    
    model.text = prompt;
    
    self.titleLabel.text = prompt;
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(200, 20)];
    self.widthContraint.constant = size.width + 30;
    [self.backView updateConstraintsIfNeeded];
}


- (void)backViewTaped
{
    if (_redpacketMesageCellTaped) {
        _redpacketMesageCellTaped(_model);
    }
}

@end
