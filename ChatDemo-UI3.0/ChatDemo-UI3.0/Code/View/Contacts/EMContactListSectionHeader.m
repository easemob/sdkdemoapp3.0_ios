//
//  EMContactListSectionHeader.m
//  Hyphenate_Demo
//
//  Created by EaseMob on 16/9/21.
//  Copyright © 2016年 EaseMob. All rights reserved.
//

#import "EMContactListSectionHeader.h"

#define KEM_CONTACTREQUESTS_TITLE            NSLocalizedString(@"contact.requests", @"Contact Requests")
#define KEM_GROUPNOTIFICATIONS_TITLE         NSLocalizedString(@"group.notifications", @"Group Notifications")

@interface EMContactListSectionHeader()

@property (strong, nonatomic) IBOutlet UIImageView *icon;

@property (strong, nonatomic) IBOutlet UILabel *title;

@property (strong, nonatomic) IBOutlet UILabel *unhandledCount;

@end

@implementation EMContactListSectionHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = DenimColor;
    _icon.image = [UIImage imageNamed:@"Icon_Invitations"];
    _title.text = KEM_GROUPNOTIFICATIONS_TITLE;
    _unhandledCount.text = @"";
}

- (void)updateInfo:(NSInteger)unhandleCount section:(NSInteger)section {
    switch (section) {
        case 0:
            _title.text = KEM_GROUPNOTIFICATIONS_TITLE;
            _icon.image = [UIImage imageNamed:@"Icon_Invitations.png"];
            break;
        case 1:
            _title.text = KEM_CONTACTREQUESTS_TITLE;
            _icon.image = [UIImage imageNamed:@"Icon_Requests.png"];
            break;
        default:
            _icon.hidden = _title.hidden = _unhandledCount.hidden = YES;
            self.backgroundColor = PaleGrayColor;
            _unhandledCount.hidden = YES;
            break;
    }
    _unhandledCount.text = [NSString stringWithFormat:@"(%d)",(int)unhandleCount];
}


@end
