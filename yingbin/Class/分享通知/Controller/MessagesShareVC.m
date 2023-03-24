//
//  MessagesShareVC.m
//  yingbin
//
//  Created by slxk on 2021/5/14.
//  Copyright © 2021 wq. All rights reserved.
//

#import "MessagesShareVC.h"
#import "MessagesShareCell.h"
@interface MessagesShareVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArray;

@end

@implementation MessagesShareVC
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"消息通知");
    [self.view addSubview:self.tableView];
    [self loadSceneList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceInformation) name:DeviceInformation object:nil];

//    [[NSUserDefaults standardUserDefaults]setValue:[NSArray new] forKey:ShareTokenDeviceArr];
    
    // 下拉刷新
    WEAK
    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{
        STRONG
        [self loadSceneList];
    }];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}
-(void)onDeviceInformation{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 获取列表
//{
//    "UserID":"250921057949585408",
//    "FromUserID":"249555369632731136",
//    "MsgID":"258623569464922112",
//    "Category":3,
//    "MsgType":301,
//    "MsgTitle":"分享设备",
//    "MsgContent":"“mobile_8615919832166”将“light”分享给您一起使用。",
//    "MsgTimestamp":1620979063954,
//    "ProductId":"56UED5AJ29",
//    "DeviceName":"dev0001",
//    "DeviceAlias":"light",
//    "FamilyId":"",
//    "FamilyName":"",
//    "RelateUserID":"250921057949585408",
//    "Attachments":
//                {"ShareToken":"0063fa9a7cb04740902480f517794c16"},
//    "CreateAt":"2021-05-14T07:57:43.954Z"
//}
- (void)loadSceneList
{
    WEAK
    //1设备，2家庭，3通知
    NSDictionary *dic = @{@"MsgID":@"",@"MsgTimestamp":@(0),@"Limit":@(100),@"Category":@(3)};
    
    [[TIoTCoreRequestObject shared] post:AppGetMessages Param:dic success:^(id responseObject) {
        STRONG
        NSDictionary *data = responseObject[@"Data"];
        [self.dataArray removeAllObjects];
        if (data[@"Msgs"] && data[@"Msgs"] != nil) {

//            for (NSDictionary *dic in data[@"Msgs"]) {
//                NSInteger msgType = [dic[@"MsgType"] integerValue];
//                if (msgType  == 301) {
//                    [self.dataArray addObject:dic];
//                }
//            }
            [self.dataArray addObjectsFromArray:data[@"Msgs"]];

        }
        
        [self refreshUI];

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];

    }];

    [self.tableView.mj_header endRefreshing];

}

-(void)refreshUI{
    [self.tableView showDataCount:self.dataArray.count Title:LOCSTR(@"暂无数据呦。。。。。。") image:KImage(@"icon_wushuju")];
    [self.tableView reloadData];
}
#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagesShareCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MessagesShareCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dataDic = self.dataArray[indexPath.row];
    return cell;
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
    //删除
    WEAK
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:LOCSTR(@"删除") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        [TLUIUtility showAlertWithTitle:LOCSTR(@"提示") message:LOCSTR(@"确定要删除通知吗？") cancelButtonTitle:LOCSTR(@"取消") otherButtonTitles:@[@"确定"] actionHandler:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                STRONG
                NSNumber *deleteMsgId = self.dataArray[indexPath.row][@"MsgID"];
                NSDictionary *dic = @{@"MsgID":deleteMsgId};
                
                [[TIoTCoreRequestObject shared] post:AppDeleteMessage Param:dic success:^(id responseObject) {
                    STRONG
                    [MBProgressHUD showMessage:LOCSTR(@"删除成功") icon:@""];
                    [self.dataArray removeObjectAtIndex:indexPath.row];
                    [self refreshUI];
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
        [_tableView registerClass:[MessagesShareCell class] forCellReuseIdentifier:NSStringFromClass([MessagesShareCell class])];

    }
    return _tableView;
}
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}
@end
