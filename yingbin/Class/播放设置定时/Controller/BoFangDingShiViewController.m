//
//  BoFangDingShiViewController.m
//  yingbin
//
//  Created by slxk on 2021/5/17.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BoFangDingShiViewController.h"
#import "BofangSetViewController.h"
#import "BoFangDingShiCell.h"
#import "BofangViewModel.h"
@interface BoFangDingShiViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *listArray;

@property (nonatomic, assign)NSInteger selectIndex;//删除了那个cell

@end

@implementation BoFangDingShiViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleStr;
    [self.view addSubview:self.tableView];
    self.navigationItem.rightBarButtonItem = self.addButtonItem;

    [self getTimerList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceTimingNotify) name:DeviceTimingNotify object:nil];

    
    // 下拉刷新
    WEAK
    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{
        STRONG
        [self getTimerList];
    }];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}
-(void)onDeviceTimingNotify{
    [self getTimerList];
}

#pragma mark - 加号
- (void)addItemClick:(UIBarButtonItem *)btn{
    if (self.listArray.count < 7) {
        BofangSetViewController *vc = [[BofangSetViewController alloc]init];
        vc.titleStr = self.titleStr;
        vc.isEdit = NO;
        PushVC(vc);
    }else{
        [MBProgressHUD showMessage:LOCSTR(@"最多添加7个定时") icon:@""];
    }
    
}
//"TimerList": [{
//          "TimerId": "a1c6939b39d345b897b168313f8ca12c",
//          "TimerName": "timer_test_modify",
//          "ProductId": "US4CJ11DIK",
//          "DeviceName": "dev0001",
//          "Days": "1100000",
//          "TimePoint": "09:30",
//          "Repeat": 0,
//          "Data": "{\"brightness\": 28}",
//          "Status": 0,
//          "CreateTime": 1570786578,
//          "UpdateTime": 1570790807
//      }, {
#pragma mark - 获取定时
-(void)getTimerList{

    if ([self.titleStr containsString:LOCSTR(@"感应播放")]) {
        self.listArray = [UserManageCenter sharedUserManageCenter].DAPSenseList;

    }else if([self.titleStr containsString:LOCSTR(@"仅播放")]){
        self.listArray = [UserManageCenter sharedUserManageCenter].PSenseList;
    }else{
        self.listArray = [UserManageCenter sharedUserManageCenter].ASenseList;
    }
    

    [self.tableView showDataCount:self.listArray.count Title:LOCSTR(@"暂无数据呦。。。。。。") image:KImage(@"icon_wushuju")];
    [self.tableView reloadData];


    [self.tableView.mj_header endRefreshing];

}
#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAK
    BoFangDingShiCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BoFangDingShiCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.fromTimeVCBool = YES;
    cell.integer = indexPath.row+1;
    cell.model = self.listArray[indexPath.row];
    cell.isSwitchClick = ^(UISwitch * _Nonnull button, NSMutableDictionary * _Nonnull dic) {
        STRONG
        //开关
        NSMutableArray *array = self.listArray;
        NSMutableDictionary *param = [NSMutableDictionary new];

        NSMutableDictionary *model = array[indexPath.row];
        model[@"Status"] = button.isOn==YES?@(1):@(0);
        [array replaceObjectAtIndex:indexPath.row withObject:model];
        NSString *key = [NSString new];
        
        if ([self.titleStr containsString:LOCSTR(@"感应播放")])
        {
            key = @"DAPSense";
        }else if([self.titleStr containsString:LOCSTR(@"仅播放")])
        {
            key = @"PSense";
        }else
        {
            key = @"ASense";
        }
        [param setValue:array forKey:key];

        
        NSDictionary* tmpDic = @{
            @"ProductId":[UserManageCenter sharedUserManageCenter].deviceModel.ProductId?:@"",
            @"DeviceName":[UserManageCenter sharedUserManageCenter].deviceModel.DeviceName?:@"",
            @"Data":[NSString objectToJson:param]?:@""
        };
        
        [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
            STRONG
            if ([self.titleStr containsString:LOCSTR(@"感应播放")])
            {
                [UserManageCenter sharedUserManageCenter].DAPSenseList = array;
            }
            else if([self.titleStr containsString:LOCSTR(@"仅播放")])
            {
                [UserManageCenter sharedUserManageCenter].PSenseList = array;
            }else
            {
                [UserManageCenter sharedUserManageCenter].ASenseList = array;
            }
            if (button.isOn) {
                [MBProgressHUD showMessage:LOCSTR(@"开启成功") icon:@""];
            }else{
                [MBProgressHUD showMessage:LOCSTR(@"关闭成功") icon:@""];
            }
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [MBProgressHUD showError:reason];
            [MethodTool judgeUserSignoutWithReturnToken:dic];
        }];
        
    };
    return cell;
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BofangSetViewController *vc = [[BofangSetViewController alloc]init];
    vc.titleStr = self.titleStr;
    vc.isEdit = YES;
    vc.integer = indexPath.row;
    vc.model = self.listArray[indexPath.row];
    PushVC(vc);
}
-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
    //删除
    WEAK
    
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:LOCSTR(@"删除") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        [TLUIUtility showAlertWithTitle:LOCSTR(@"提示") message:LOCSTR(@"确定要删除吗？") cancelButtonTitle:LOCSTR(@"取消") otherButtonTitles:@[@"确定"] actionHandler:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSMutableDictionary *param = [NSMutableDictionary new];
                NSMutableArray *array = self.listArray;
                NSString *key = [NSString new];
                
                if ([self.titleStr containsString:LOCSTR(@"感应播放")])
                {
                    key = @"DAPSense";
                }else if([self.titleStr containsString:LOCSTR(@"仅播放")])
                {
                    key = @"PSense";
                }else
                {
                    key = @"ASense";
                }
                [array removeObjectAtIndex:indexPath.row];
                [param setValue:array forKey:key];
                STRONG
                NSDictionary* tmpDic = @{
                    @"ProductId":[UserManageCenter sharedUserManageCenter].deviceModel.ProductId?:@"",
                    @"DeviceName":[UserManageCenter sharedUserManageCenter].deviceModel.DeviceName?:@"",
                    @"Data":[NSString objectToJson:param]?:@""
                };
                
                [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
                    STRONG
                    if ([self.titleStr containsString:LOCSTR(@"感应播放")])
                    {
                        [UserManageCenter sharedUserManageCenter].DAPSenseList = array;
                    }
                    else if([self.titleStr containsString:LOCSTR(@"仅播放")])
                    {
                        [UserManageCenter sharedUserManageCenter].PSenseList = array;
                    }else
                    {
                        [UserManageCenter sharedUserManageCenter].ASenseList = array;
                    }
                    [MBProgressHUD showMessage:LOCSTR(@"删除成功") icon:@""];
                    if ([key isEqualToString:@"PSense"]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:DeviceInformation object:nil];
                    }
                    [self getTimerList];
                } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
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


-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-k_Height_NavBar) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 100;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.showsHorizontalScrollIndicator=NO;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[BoFangDingShiCell class] forCellReuseIdentifier:NSStringFromClass([BoFangDingShiCell class])];

    }
    return _tableView;
}
-(NSMutableArray *)listArray{
    if (!_listArray) {
        _listArray = [NSMutableArray new];
    }
    return _listArray;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
