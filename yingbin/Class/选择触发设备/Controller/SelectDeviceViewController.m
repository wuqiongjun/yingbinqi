//
//  SelectDeviceViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/26.
//  Copyright © 2021 wq. All rights reserved.
//

#import "SelectDeviceViewController.h"
#import "SelectDeviceViewCell.h"
#import "TJRenWuViewController.h"
#import "SelectDeviceNextVC.h"
@interface SelectDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *deviceArray;

@end

@implementation SelectDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleStr;

    [self.view addSubview:self.tableView];
    
    //用于 分享过来的设备不可以添加场景
    for (DeviceViewModel *model in [UserManageCenter sharedUserManageCenter].deviceList) {
        if (![MethodTool isBlankString:model.FamilyId]) {
            [self.deviceArray addObject: model];
        }
    }
    
    [self refreshUI];

}
-(void)refreshUI{
    [self.tableView showDataCount:self.deviceArray.count Title:LOCSTR(@"暂无数据呦。。。。。。") image:KImage(@"icon_wushuju")];
    [self.tableView reloadData];
}
#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectDeviceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelectDeviceViewCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.deviceArray[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.titleStr isEqualToString:LOCSTR(@"选择触发设备")]) {
        SelectDeviceNextVC *vc = [[SelectDeviceNextVC alloc]init];
        vc.isEdit = NO;
        vc.model = [TIoTAutoIntelligentModel yy_modelWithJSON:[NSDictionary dictionaryWithDictionary:[MethodTool dicFromObject:self.deviceArray[indexPath.row]]]];
        PushVC(vc);
    }else{
        //任务
        TJRenWuViewController *vc = [[TJRenWuViewController alloc]init];
//        NSDictionary *dic = self.deviceArray[indexPath.row];
        vc.isEdit = NO;
        vc.model = [TIoTAutoIntelligentModel yy_modelWithJSON:[NSDictionary dictionaryWithDictionary:[MethodTool dicFromObject:self.deviceArray[indexPath.row]]]];
        PushVC(vc);
    }
    
}
//添加执行
//TJRenWuViewController *vc = [[TJRenWuViewController alloc] init];
//vc.isEdit = NO;
//vc.addRenWuSuccess = ^(NSMutableArray * _Nonnull listArray, NSString * _Nonnull nameStr) {
//    STRONG
//    self.TJRenWuArray = listArray;
//};
//vc.itemsArray = self.TJRenWuArray;
//PushVC(vc);
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-k_Height_NavBar) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 81;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.showsHorizontalScrollIndicator=NO;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[SelectDeviceViewCell class] forCellReuseIdentifier:NSStringFromClass([SelectDeviceViewCell class])];

    }
    return _tableView;
}
-(NSMutableArray *)deviceArray{
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray new];
    }
    return _deviceArray;
}
@end
