//
//  RedpacketMessageCell.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/28.
//


#import "RedpacketMessageCell.h"
#import "RedpacketOpenConst.h"
#import "EaseMob.h"
#import "RedpacketMessageModel.h"
#import "RedpacketDefines.h"


@interface RedpacketMessageCell ()

@property (nonatomic, assign)   IBOutlet UILabel *titleLabel;
@property (nonatomic, assign)   IBOutlet UIImageView *icon;
@property (nonatomic, assign)   IBOutlet UIView *backView;

@property (nonatomic, assign)   IBOutlet NSLayoutConstraint *widthContraint;

@end

@implementation RedpacketMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel.textColor = [UIColor grayColor];
    
    self.backView.layer.cornerRadius = 3.0f;
    self.backView.layer.masksToBounds = YES;
    self.backView.backgroundColor = rpHexColor(0xe3e3e3);
    [self.icon setImage:RedpacketImage(@"redpacket_smallIcon")];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTaped)];
    [self.backView addGestureRecognizer:tap];
}

- (void)setModel:(id<IMessageModel>)model
{
    _model = model;
    /*-------为了兼容红包2.0版本--------*/
    NSString *text = model.text;
    if (model.bodyType == eMessageBodyType_Text) {
        NSDictionary *dict = model.message.ext;
        NSString *currentUserId = [[[[EaseMob sharedInstance] chatManager] loginInfo] objectForKey:kSDKUsername];
        NSString *receiverId = [dict valueForKey:RedpacketKeyRedpacketReceiverId];
        
        BOOL isReceiver = [receiverId isEqualToString:currentUserId];
        if (isReceiver) {
            NSString *sender = [dict valueForKey:RedpacketKeyRedpacketSenderNickname];
            NSString *senderID = [dict valueForKey:RedpacketKeyRedpacketSenderId];
            if (sender.length == 0) {
                sender = senderID;
            }
            if ([senderID isEqualToString:receiverId]) {
                text = [NSString stringWithFormat:@"你领取了自己的红包"];
            }else {
                text = [NSString stringWithFormat:@"你领取了%@的红包", sender];
            }
        }else {
            NSString *receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverNickname];
            if (receiver.length == 0) {
                receiver = [dict valueForKey:RedpacketKeyRedpacketReceiverId];
            }
            text = [NSString stringWithFormat:@"%@领取了你的红包", receiver];
        }
    }
    
    /*--------兼容结束-----------------*/
    
    self.titleLabel.text = text;
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
