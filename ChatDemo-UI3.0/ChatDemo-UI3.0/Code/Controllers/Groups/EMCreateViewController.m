//
//  EMCreateViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/12.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMCreateViewController.h"
#import "EMCreateNewGroupViewController.h"
#import "EMPublicGroupsViewController.h"
#import "EMRealtimeSearchUtils.h"

@interface EMCreateViewController ()

@property (strong, nonatomic) IBOutlet UILabel *promptLabel;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) EMPublicGroupsViewController *publicGroupsVc;

@end

@implementation EMCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self setupNavBar];
    
    _publicGroupsVc = [[EMPublicGroupsViewController alloc] initWithNibName:@"EMPublicGroupsViewController" bundle:nil];
    [self addChildViewController:_publicGroupsVc];
    [self.view addSubview:_publicGroupsVc.tableView];
    _publicGroupsVc.tableView.frame = CGRectMake(0,
                                                 2*50,
                                                 self.view.bounds.size.width,
                                                 self.view.bounds.size.height - 2*50);
    [self setupSearchBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@",NSStringFromCGRect(_searchBar.frame));
}

- (void)setupSearchBar {
    NSString *promptText = _promptLabel.text;
    CGSize promptSize = [promptText sizeWithAttributes:@{NSFontAttributeName:_promptLabel.font}];
    CGRect frame = _promptLabel.frame;
    frame.size.width = promptSize.width;
    _promptLabel.frame = frame;
    
    frame = _searchBar.frame;
    frame.size.height = 30;
    frame.origin.x = _promptLabel.frame.origin.x + _promptLabel.frame.size.width;
    frame.size.width = KScreenWidth - frame.origin.x;
    _searchBar.frame = frame;
    _searchBar.placeholder = NSLocalizedString(@"common.search", @"Search");
    _searchBar.showsCancelButton = NO;
    _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:_searchBar.bounds.size];
    [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, 0)];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:RGBACOLOR(228, 233, 236, 1) size:_searchBar.bounds.size] forState:UIControlStateNormal];
    _searchBar.tintColor = RGBACOLOR(12, 18, 24, 1);
}
    
- (void)setupNavBar {
    self.title = NSLocalizedString(@"title.create", @"Create");
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, 44, 44);
    [cancelBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateNormal];
    [cancelBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateHighlighted];
    [cancelBtn setTitle:NSLocalizedString(@"common.cancel", @"Cancel") forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"common.cancel", @"Cancel") forState:UIControlStateHighlighted];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [self.navigationItem setRightBarButtonItem:rightBar];
}

- (void)updateSearchBarFrame:(BOOL)isPromptHiden {
    CGRect searchBarFrame = _searchBar.frame;
    CGFloat interval = _promptLabel.frame.size.width + 15;
    _promptLabel.hidden = isPromptHiden;
    if (isPromptHiden) {
        searchBarFrame.origin.x -= interval;
        searchBarFrame.size.width += interval;
    }
    else {
        searchBarFrame.origin.x += interval;
        searchBarFrame.size.width -= interval;
    }
    _searchBar.frame = searchBarFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Method

- (void)cancelAction {
    [_searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createNewGroupAction:(id)sender {
    if (_searchBar.isFirstResponder) {
        [self searchBarCancelButtonClicked:_searchBar];
    }
    EMCreateNewGroupViewController *createVc = [[EMCreateNewGroupViewController alloc] initWithNibName:@"EMCreateNewGroupViewController"
                                                                                                bundle:nil];
    [self.navigationController pushViewController:createVc animated:YES];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self updateSearchBarFrame:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
    [_publicGroupsVc setSearchState:YES];
    _publicGroupsVc.tableView.scrollEnabled = NO;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    _publicGroupsVc.tableView.scrollEnabled = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length == 0) {
        [_publicGroupsVc setSearchState:NO];
        _publicGroupsVc.tableView.scrollEnabled = NO;
        [_publicGroupsVc.searchResults removeAllObjects];
        [_publicGroupsVc.tableView reloadData];
        return;
    }
    [_publicGroupsVc setSearchState:YES];
    __weak typeof(_publicGroupsVc) weakVc = _publicGroupsVc;
    [[EMRealtimeSearchUtils defaultUtil] realtimeSearchWithSource:_publicGroupsVc.publicGroups searchString:searchText resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakVc.searchResults = [NSMutableArray arrayWithArray:results];
                [weakVc.tableView reloadData];
            });
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self updateSearchBarFrame:NO];
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    _publicGroupsVc.tableView.scrollEnabled = YES;
    
    if (_publicGroupsVc.searchResults.count > 0) {
        
        return;
    }
    __weak typeof(_publicGroupsVc) weakVc = _publicGroupsVc;
    WEAK_SELF
    [[EMClient sharedClient].groupManager searchPublicGroupWithId:searchBar.text completion:^(EMGroup *aGroup, EMError *aError) {
        
        EMPublicGroupsViewController *strongVc = weakVc;
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (aGroup) {
                [strongVc.searchResults removeAllObjects];
                EMGroupModel *model = [[EMGroupModel alloc] initWithObject:aGroup];
                [strongVc.searchResults addObject:model];
                [strongVc.tableView reloadData];
            } else {
                [weakSelf showAlertWithMessage:NSLocalizedString(@"common.searchFailure", @"Search failure.")];
            }
        });
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [self updateSearchBarFrame:NO];
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    [[EMRealtimeSearchUtils defaultUtil] realtimeSearchDidFinish];
    [_publicGroupsVc setSearchState:NO];
    _publicGroupsVc.tableView.scrollEnabled = YES;
    [_publicGroupsVc.tableView reloadData];
}

@end
