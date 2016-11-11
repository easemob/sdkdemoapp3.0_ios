//
//  EMContactsSelectViewController.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/10/6.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMMemberSelectViewController.h"
#import "EMUserModel.h"
#import "EMGroupMemberCell.h"
#import "EMMemberCollectionCell.h"
#import "EMRealtimeSearchUtils.h"
#import "NSArray+EMSortContacts.h"


#define NEXT_TITLE   NSLocalizedString(@"common.next", @"Next")
#define DONE_TITLE   NSLocalizedString(@"common.done", @"Done")

@interface EMMemberSelectViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, EMGroupUIProtocol>
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UICollectionView *selectConllection;

@property (strong, nonatomic) IBOutlet UITableView *tableView;


@property (strong, nonatomic) NSMutableArray<EMUserModel *> *selectContacts;

@property (strong, nonatomic) NSMutableArray<NSMutableArray *> *unselectedContacts;

@end

@interface EMSectionTitleHeader : UIView

@property (nonatomic, strong) NSString *title;

+ (CGFloat)sectionHeight;

@end

@implementation EMMemberSelectViewController
{
    UIButton *_doneBtn;
    NSMutableArray *_hasInvitees;
    NSMutableArray *_sectionTitles;
    NSMutableArray *_searchSource;
    NSMutableArray *_searchResults;
    BOOL _isSearchState;
}

- (instancetype)initWithInvitees:(NSArray *)hasInvitees {
    self = [super initWithNibName:@"EMMemberSelectViewController" bundle:nil];
    if (self) {
        _selectContacts = [NSMutableArray array];
        _unselectedContacts = [NSMutableArray array];
        _hasInvitees = [NSMutableArray arrayWithArray:hasInvitees];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.selectConllection registerNib:[UINib nibWithNibName:@"EMMemberCollection_Edit_Cell" bundle:nil] forCellWithReuseIdentifier:@"EMMemberCollection_Edit_Cell"];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    [self setupNavBar];
    [self loadUnSelectContacts];
    [self setupSearchBar];
}
    
- (void)setupSearchBar {
    CGRect frame = _searchBar.frame;
    frame.size.height = 30;
    _searchBar.frame = frame;
    _searchBar.placeholder = NSLocalizedString(@"common.search", @"Search");
    _searchBar.showsCancelButton = NO;
    _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:_searchBar.bounds.size];
    [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, 0)];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:RGBACOLOR(228, 233, 236, 1) size:_searchBar.bounds.size] forState:UIControlStateNormal];
    _searchBar.tintColor = RGBACOLOR(12, 18, 24, 1);
}


- (void)setupNavBar {
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, 44, 44);
    [cancelBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateNormal];
    [cancelBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateHighlighted];
    [cancelBtn setTitle:NSLocalizedString(@"common.cancel", @"Cancel") forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"common.cancel", @"Cancel") forState:UIControlStateHighlighted];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancelBtn addTarget:self action:@selector(cancelSelectContacts) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneBtn.frame = CGRectMake(0, 0, 44, 44);
    [self updateDoneUserInteractionEnabled:NO];
    NSString *title = NEXT_TITLE;
    if (_style == EMContactSelectStyle_Invite) {
        title = DONE_TITLE;
    }
    [_doneBtn setTitle:title forState:UIControlStateNormal];
    [_doneBtn setTitle:title forState:UIControlStateHighlighted];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_doneBtn addTarget:self action:@selector(selectDoneAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:_doneBtn];
    [self.navigationItem setRightBarButtonItem:rightBar];
}

- (void)updateHeaderView:(BOOL)isAdd {
    if (_selectContacts.count > 0 && self.selectConllection.hidden) {
        CGFloat height = self.selectConllection.frame.size.height;
        CGRect frame = self.headerView.frame;
        frame.size.height += height;
        self.headerView.frame = frame;
        
        frame = self.tableView.frame;
        frame.origin.y += height;
        frame.size.height -= height;
        self.tableView.frame = frame;
        [_selectConllection reloadData];
        self.selectConllection.hidden = NO;
        
        return;
    }
    if (_selectContacts.count == 0 && !self.selectConllection.hidden) {
        self.selectConllection.hidden = YES;
        CGFloat height = self.selectConllection.frame.size.height;
        CGRect frame = self.headerView.frame;
        frame.size.height -= height;
        self.headerView.frame = frame;
        
        frame = self.tableView.frame;
        frame.origin.y -= height;
        frame.size.height += height;
        self.tableView.frame = frame;
        [_selectConllection reloadData];
        return;
    }
    if (isAdd) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_selectContacts.count - 1 inSection:0];
        [_selectConllection insertItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
    }
}

- (void)updateDoneUserInteractionEnabled:(BOOL)userInteractionEnabled {
    _doneBtn.userInteractionEnabled = userInteractionEnabled;
    if (userInteractionEnabled) {
        [_doneBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateNormal];
        [_doneBtn setTitleColor:KermitGreenTwoColor forState:UIControlStateHighlighted];
    }
    else {
        [_doneBtn setTitleColor:CoolGrayColor forState:UIControlStateNormal];
        [_doneBtn setTitleColor:CoolGrayColor forState:UIControlStateHighlighted];
    }
}

- (void)loadUnSelectContacts {
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:[[EMClient sharedClient].contactManager getContacts]];
    NSArray *blockList = [[EMClient sharedClient].contactManager getBlackList];
    [contacts removeObjectsInArray:blockList];
    [contacts removeObjectsInArray:_hasInvitees];
    [_hasInvitees removeAllObjects];
    
    NSMutableArray *sectionTitles = nil;
    NSMutableArray *searchSource = nil;
    NSArray *sortArray = [NSArray sortContacts:contacts
                                 sectionTitles:&sectionTitles
                                  searchSource:&searchSource];
    [self.unselectedContacts addObjectsFromArray:sortArray];
    _sectionTitles = [NSMutableArray arrayWithArray:sectionTitles];
    _searchSource = [NSMutableArray arrayWithArray:searchSource];
}

- (void)removeOccupantsFromDataSource:(NSArray<EMUserModel *> *)modelArray {
    __block NSMutableArray *array = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    __weak NSMutableArray *weakHasInvitees = _hasInvitees;
    [modelArray enumerateObjectsUsingBlock:^(EMUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([weakSelf.selectContacts containsObject:obj]) {
            NSUInteger index = [weakSelf.selectContacts indexOfObject:obj];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [array addObject:indexPath];
            [weakHasInvitees removeObject:obj.hyphenateId];
            [weakSelf.selectContacts removeObjectsInArray:modelArray];
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (array.count > 0) {
            [weakSelf.selectConllection deleteItemsAtIndexPaths:array];
        }
        if (weakSelf.selectContacts.count == 0) {
            [self updateDoneUserInteractionEnabled:NO];
        }
        [weakSelf updateHeaderView:NO];
    });
}

#pragma mark - Action

- (void)cancelSelectContacts {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectDoneAction {
    if (_delegate && [_delegate respondsToSelector:@selector(addSelectOccupants:)]) {
        [_delegate addSelectOccupants:_selectContacts];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isSearchState) {
        return 1;
    }
    return _sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearchState) {
        return _searchResults.count;
    }
    return [(NSArray *)_unselectedContacts[section] count];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (_isSearchState) {
        return @[];
    }
    return _sectionTitles;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EMGroupMember_Invite_Cell";
    EMGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    
    EMUserModel *model = nil;
    if (_isSearchState) {
        model = _searchResults[indexPath.row];
    }
    else {
        NSMutableArray *array = _unselectedContacts[indexPath.section];
        model = array[indexPath.row];
    }
    cell.isSelected = [_hasInvitees containsObject:model.hyphenateId];
    cell.isEditing = YES;
    cell.model = model;
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_isSearchState) {
        return 0;
    }
    return [EMSectionTitleHeader sectionHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    EMSectionTitleHeader *headerView = [[EMSectionTitleHeader alloc] init];
    headerView.title = _sectionTitles[section];
    return headerView;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && scrollView.contentOffset.y < 0) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
    if (scrollView == self.selectConllection && scrollView.contentOffset.x < 0) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectContacts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EMMemberCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EMMemberCollection_Edit_Cell" forIndexPath:indexPath];
    cell.model = _selectContacts[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    EMUserModel *model = _selectContacts[indexPath.row];
    [self removeOccupantsFromDataSource:@[model]];
    [self.tableView reloadData];
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / 5, collectionView.frame.size.height);
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    _isSearchState = YES;
    self.tableView.scrollEnabled = !_isSearchState;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.tableView.scrollEnabled = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length == 0) {
        _isSearchState = NO;
        self.tableView.scrollEnabled = NO;
        [_searchResults removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    _isSearchState = YES;
    __weak typeof(self) weakSelf = self;
    [[EMRealtimeSearchUtils defaultUtil] realtimeSearchWithSource:_searchSource searchString:searchText resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _searchResults = [NSMutableArray arrayWithArray:results];
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:NO];
    self.tableView.scrollEnabled = YES;
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    [[EMRealtimeSearchUtils defaultUtil] realtimeSearchDidFinish];
    _isSearchState = NO;
    self.tableView.scrollEnabled = !_isSearchState;
    [self.tableView reloadData];
}

#pragma mark - EMGroupUIProtocol

- (void)addSelectOccupants:(NSArray<EMUserModel *> *)modelArray {
    [self.selectContacts addObjectsFromArray:modelArray];
    for (EMUserModel *model in modelArray) {
        [_hasInvitees addObject:model.hyphenateId];
    }
    [self updateDoneUserInteractionEnabled:YES];
    [self updateHeaderView:YES];
}

- (void)removeSelectOccupants:(NSArray<EMUserModel *> *)modelArray {
    [self removeOccupantsFromDataSource:modelArray];
}

@end


@implementation EMSectionTitleHeader
{
    UILabel *_titleLabel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        self.frame = CGRectMake(0, 0, screenFrame.size.width, [EMSectionTitleHeader sectionHeight]);
        self.backgroundColor = CoolGrayColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_titleLabel) {
        CGFloat x = 15;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.frame.size.width - x, self.frame.size.height)];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
    }
    _titleLabel.text = _title;
}

+ (CGFloat)sectionHeight {
    return 20;
}
@end
