//
//  EMContactListSectionHeader.m
//  Hyphenate_Demo
//
//  Created by EaseMob on 16/9/21.
//  Copyright © 2016年 EaseMob. All rights reserved.
//

#import "EMContactListSectionHeader.h"
#import "EMColorUtils.h"

#define KEM_REQUESTS_TITLE            @"Requests"
#define KEM_GROUPREQUESTS_TITLE       @"Group Requests"
#define KEM_GROUPINVITATIONS_TITLE    @"Group Invitations"

@interface EMContactListSectionHeader()

@property (strong, nonatomic) IBOutlet UIImageView *icon;

@property (strong, nonatomic) IBOutlet UILabel *title;

@property (strong, nonatomic) IBOutlet UILabel *unhandledCount;

@end

@implementation EMContactListSectionHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = DenimColor;
    _icon.image = [UIImage imageNamed:@"requestIcon"];
    _title.text = KEM_REQUESTS_TITLE;
    _unhandledCount.text = @"";
}

- (void)updateInfo:(NSInteger)unhandleCount section:(NSInteger)section {
    switch (section) {
        case 0:
            break;
        case 1:
            _title.text = KEM_GROUPREQUESTS_TITLE;
            break;
        case 2:
            _title.text = KEM_GROUPINVITATIONS_TITLE;
            _icon.image = [UIImage imageNamed:@"invitationsIcon"];
            break;
        default:
            _icon.hidden = _title.hidden = _unhandledCount.hidden = YES;
            self.backgroundColor = PaleGrayColor;
            break;
    }
    _unhandledCount.text = [NSString stringWithFormat:@"(%d)",(int)unhandleCount];
}


@end
