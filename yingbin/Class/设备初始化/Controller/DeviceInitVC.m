//
//  DeviceInitVC.m
//  yingbin
//
//  Created by slxk on 2021/6/11.
//  Copyright © 2021 wq. All rights reserved.
//

#import "DeviceInitVC.h"
#import "DeviceInitCell.h"
@interface DeviceInitVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *listArray;

@property (assign, nonatomic)NSInteger index;   //单选选中的行


@end

@implementation DeviceInitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"设备初始化");
    
    [self.view addSubview:self.tableView];
    

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
    DeviceInitCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceInitCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dic = self.listArray[indexPath.row];
    cell.btn.tag = 1000+indexPath.row;
    [cell.btn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)selectAction:(UIButton *)selectBtn {
    self.index = selectBtn.tag-1000;
    //改变数据源
    for (int i = 0; i<self.listArray.count; i++) {
        NSMutableDictionary *model = [NSMutableDictionary dictionaryWithDictionary:self.listArray[i]];
        if (i==self.index) {
            model[@"isSelected"] = @"1";
        } else {
            model[@"isSelected"] = @"0";
        }
        [self.listArray replaceObjectAtIndex:i withObject:model];
    }

    //刷新tableView
    [_tableView reloadData];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
WEAK
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIButton *btn = view
    .addButton(0)
    .backgroundColor(KThemeColor)
    .title(LOCSTR(@"确定"))
    .cornerRadius(5)
    .titleFont(KPingFangFont(15))
    .titleColor(UIColor.whiteColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
            NSMutableDictionary *playDic = [NSMutableDictionary new];
        if (self.index == 2) {
            [playDic setObject:@(3) forKey:@"DeviceInit"];
        }else{
            [playDic setObject:@(self.index) forKey:@"DeviceInit"];
        }

            NSDictionary *tmpDic = @{
                @"ProductId":[UserManageCenter sharedUserManageCenter].deviceModel.ProductId?:@"",
                @"DeviceName":[UserManageCenter sharedUserManageCenter].deviceModel.DeviceName?:@"",
                @"Data":[NSString objectToJson:playDic]?:@""
                
            };
            [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
                [MBProgressHUD showMessage:LOCSTR(@"设置成功") icon:@""];
                [self.navigationController popViewControllerAnimated:YES];
            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                [MBProgressHUD showError:reason];
                [MethodTool judgeUserSignoutWithReturnToken:dic];

            }];

    })
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(40);
    })
    .view;

    [view addSubview:btn];

    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 70;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

   
}


-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-k_Height_NavBar-k_Height_SafetyArea) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.showsHorizontalScrollIndicator=NO;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView registerClass:[DeviceInitCell class] forCellReuseIdentifier:NSStringFromClass([DeviceInitCell class])];

    }
    return _tableView;
}

-(NSMutableArray *)listArray{
    if (!_listArray) {
        _listArray = [NSMutableArray arrayWithArray:@[@{@"title":LOCSTR(@"设备重启"),@"name":@"",@"isSelected":@"1"},
                      @{@"title":LOCSTR(@"设备恢复到出厂状态(不删除SD卡内曲目)"),@"name":@"",@"isSelected":@"0"},
//                      @{@"title":LOCSTR(@"设备恢复到出厂状态(并删除SD卡内自定义曲目)"),@"name":LOCSTR(@"设备播放模式，音量，播放定时设置恢复到出厂状态，请谨慎操作"),@"isSelected":@"0"},
                      @{@"title":LOCSTR(@"设置内置曲目重新下载"),@"name":LOCSTR(@"设备内置曲目全部删除，并重新下载，需要几分钟时间，请谨慎操作"),@"isSelected":@"0"}]];
    }
    return _listArray;
}

@end
