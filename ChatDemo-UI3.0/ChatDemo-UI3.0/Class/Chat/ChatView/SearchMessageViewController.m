/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "SearchMessageViewController.h"

#import "EMSearchBar.h"
#import "EMSearchDisplayController.h"
#import "UIImageView+HeadImage.h"

#define SEARCHMESSAGE_PAGE_SIZE 30

@interface SearchMessageViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
{
    dispatch_queue_t _searchQueue;
    void* _queueTag;
}

@property (strong, nonatomic) EMConversation *conversation;

@property (strong, nonatomic) EMSearchBar *searchBar;

@property (strong, nonatomic) EMSearchDisplayController *searchController;

@end

@implementation SearchMessageViewController

- (instancetype)initWithConversationId:(NSString *)conversationId
                      conversationType:(EMConversationType)conversationType
{
    self = [super init];
    if (self) {
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationId type:conversationType createIfNotExist:NO];
        _searchQueue = dispatch_queue_create("com.easemob.search.message", DISPATCH_QUEUE_SERIAL);
        _queueTag = &_queueTag;
        dispatch_queue_set_specific(_searchQueue, _queueTag, _queueTag, NULL);
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    self.title = NSLocalizedString(@"title.groupSearchMessage", @"Search Message from History");
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    [self searchController];
    self.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [self.view addSubview:self.searchBar];
}

- (EMSearchBar*)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    return _searchBar;
}

- (EMSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _searchController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
        
        __weak SearchMessageViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            NSString *CellIdentifier = [EaseConversationCell cellIdentifierWithModel:nil];
            EaseConversationCell *cell = (EaseConversationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[EaseConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            EMMessage *message = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            
            cell.titleLabel.text = message.from;
            cell.detailLabel.text = [weakSelf getContentFromMessage:message];
            [cell.avatarView.imageView imageWithUsername:message.from placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
            return cell;

        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return [EaseConversationCell cellHeightWithModel:nil];
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
    }
    
    return _searchController;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^{ @autoreleasepool {
        NSArray *results = [weakSelf.conversation loadMoreMessagesContain:searchBar.text before:[[NSDate date] timeIntervalSince1970]*1000 limit:SEARCHMESSAGE_PAGE_SIZE];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.searchController.resultsSource removeAllObjects];
            [weakSelf.searchController.resultsSource addObjectsFromArray:results];
            [weakSelf.searchController.searchResultsTableView reloadData];
        });
    }};
    
    dispatch_async(_searchQueue, block);
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (NSString*)getContentFromMessage:(EMMessage*)message
{
    NSString *content = @"";
    if (message) {
        EMMessageBody *messageBody = message.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                content = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case EMMessageBodyTypeText:{
                // 表情映射。
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                content = didReceiveText;
                if ([message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
                    content = @"[动画表情]";
                }
            } break;
            case EMMessageBodyTypeVoice:{
                content = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case EMMessageBodyTypeLocation: {
                content = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case EMMessageBodyTypeVideo: {
                content = NSLocalizedString(@"message.video1", @"[video]");
            } break;
            case EMMessageBodyTypeFile: {
                content = NSLocalizedString(@"message.file1", @"[file]");
            } break;
            default: {
            } break;
        }
    }
    return content;
}

#pragma mark - action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
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
