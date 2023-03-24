//
//  ChangJingViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "ChangJingViewController.h"
#import "ChangjingViewCell.h"

#import "AddSceneViewController.h"
@interface ChangJingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *autoSceneArray;
@property (nonatomic, strong) UIButton *addbutton;
@property (nonatomic, copy) NSString *productId;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, strong) NSDictionary *sceneParamDic;
@property (nonatomic, strong) NSMutableArray *dataNameArr;


@end

@implementation ChangJingViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
    
    
    [self loadSceneList];

    // 下拉刷新
    WEAK
    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{
        STRONG
        [self loadSceneList];
    }];    
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAddSceneNotify) name:AddSceneNotify object:nil];


}



-(void)onAddSceneNotify{
    [self loadSceneList];
}

#pragma mark - 获取场景列表

- (void)loadSceneList
{
    NSDictionary *dic = @{
        @"FamilyId":[TIoTCoreUserManage shared].familyId,
        @"Offset":@(0),
        @"Limit":@(999)
    };
    self.sceneParamDic = [NSDictionary dictionaryWithDictionary:dic];

    WEAK
    [[TIoTCoreRequestObject shared] post:AppGetAutomationList Param:dic success:^(id responseObject) {
        STRONG
        self.autoSceneArray = [NSMutableArray arrayWithArray:responseObject[@"List"]?:@[]];
        self.dataNameArr = [self.autoSceneArray valueForKey:@"Name"];
        [self refreshUI];

    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];
        [self refreshUI];

    }];
    [self.tableView.mj_header endRefreshing];

    
}
-(void)refreshUI{
    [self.tableView showDataCount:self.autoSceneArray.count Title:LOCSTR(@"暂无数据呦。。。。。。") image:KImage(@"icon_wushuju")];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadData];
    }];
}
#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.autoSceneArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAK
    ChangjingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChangjingViewCell class]) forIndexPath:indexPath];
    cell.isSwitchSuccess = ^(UISwitch * _Nonnull sender, NSDictionary * _Nonnull dic) {
        
         //开关状态
         
        NSString *sceneIDStr = dic[@"AutomationId"]?:@"";
        NSNumber *sceneStatus = dic[@"Status"];
        NSInteger statusNum = 0;
        if (sceneStatus.intValue == 1) {
            statusNum = 0;
        }else if (sceneStatus.intValue == 0) {
            statusNum = 1;
        }
        NSDictionary *paramDic = @{@"AutomationId":sceneIDStr,@"Status":@(statusNum)};

        [[TIoTCoreRequestObject shared] post:AppModifyAutomationStatus Param:paramDic success:^(id responseObject) {
            STRONG
            NSMutableDictionary *dic = [self.autoSceneArray[indexPath.row] mutableCopy];
            if ([dic[@"Status"] isEqual: @(1)]) {
                [dic setValue:@(0) forKey:@"Status"];
                [MBProgressHUD showMessage:LOCSTR(@"关闭成功") icon:nil];
            }else if ([dic[@"Status"] isEqual:@(0)]) {
                [dic setValue:@(1) forKey:@"Status"];
                [MBProgressHUD showMessage:LOCSTR(@"开启成功") icon:nil];
            }

            [self.autoSceneArray replaceObjectAtIndex:indexPath.row withObject:dic];
            
        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            [MBProgressHUD showError:reason];
            [MethodTool judgeUserSignoutWithReturnToken:dic];

        }];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dataDic = self.autoSceneArray[indexPath.row];
    return cell;
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddSceneViewController *vc = [[AddSceneViewController alloc]init];
    vc.paramDic = self.sceneParamDic;
    vc.isSceneDetail = YES;
    vc.dataNameArr = self.dataNameArr;
    vc.autoSceneInfoDic = self.autoSceneArray[indexPath.row];
    PushVC(vc);
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
    //删除
    WEAK
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:LOCSTR(@"删除") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        [TLUIUtility showAlertWithTitle:LOCSTR(@"提示") message:LOCSTR(@"确定要删除场景吗？") cancelButtonTitle:LOCSTR(@"取消") otherButtonTitles:@[@"确定"] actionHandler:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                STRONG
                NSMutableDictionary *dic = [self.autoSceneArray[indexPath.row] mutableCopy];
                NSString *sceneIDStr = dic[@"AutomationId"]?:@"";
                NSDictionary *paramDic = @{@"AutomationId":sceneIDStr};
                [[TIoTCoreRequestObject shared] post:AppDeleteAutomation Param:paramDic success:^(id responseObject) {
                    STRONG
                    [SVProgressHUD showSuccessWithStatus:LOCSTR(@"删除成功")];
                    [self.autoSceneArray removeObjectAtIndex:indexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexPath.row inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
                    [UIView performWithoutAnimation:^{
                        [self.tableView reloadData];
                    }];
                    if (self.autoSceneArray.count<=0) {
                        [self refreshUI];
                    }
                } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
                    [MBProgressHUD showError:reason];
                    [MethodTool judgeUserSignoutWithReturnToken:dic];

                }];

            }
        }];

        completionHandler (YES);
        [self.tableView reloadData];
    }];
    deleteRowAction.image = [UIImage imageNamed:LOCSTR(@"删除")];
    deleteRowAction.backgroundColor = [UIColor redColor];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    return config;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(27, k_STATUSBAR_HEIGHT, 150, 50)];
    label.font = [UIFont boldSystemFontOfSize:26];
    label.textColor = KColor333333;
    label.text = LOCSTR(@"场景联动");
    [view addSubview:label];
    
    WEAK
    self.addbutton = view
    .addButton(1)
    .image(KImage(@"icon_devAdd"))
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
//添加场景
        AddSceneViewController *vc = [[AddSceneViewController alloc]init];
        vc.isSceneDetail = NO;
        vc.paramDic = self.sceneParamDic;
        vc.dataNameArr = self.dataNameArr;
        PushVC(vc);
        
    })
    .masonry(^(MASConstraintMaker *make){
        make.centerY.mas_equalTo(label);
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    })
    .view;
    

    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60+k_STATUSBAR_HEIGHT;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-k_Height_TabBar) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 100;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.showsHorizontalScrollIndicator=NO;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [_tableView registerClass:[ChangjingViewCell class] forCellReuseIdentifier:NSStringFromClass([ChangjingViewCell class])];

    }
    return _tableView;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSMutableArray *)autoSceneArray{
    if (!_autoSceneArray) {
        _autoSceneArray = [NSMutableArray new];
    }
    return _autoSceneArray;
}
-(NSMutableArray *)dataNameArr{
    if (!_dataNameArr) {
        _dataNameArr = [NSMutableArray new];
    }
    return _dataNameArr;
}
@end
