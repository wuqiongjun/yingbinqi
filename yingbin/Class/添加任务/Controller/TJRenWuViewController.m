//
//  TJRenWuViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/26.
//  Copyright © 2021 wq. All rights reserved.
//

#import "TJRenWuViewController.h"
#import "AddSceneViewController.h"
#import "BoFangDingShiCell.h"
@interface TJRenWuViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;
KASSIGN NSInteger playModeInt;//什么模式

KASSIGN NSInteger row;//单选，当前选中的行

@property (nonatomic, strong)NSMutableDictionary *weekSelectDIC;
@property (nonatomic, strong)UILabel *deviceNameLabel;

@property (nonatomic, assign)NSInteger integer;

@property (nonatomic, strong)NSMutableArray *listArray;

@end

@implementation TJRenWuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"添加任务");
    [self.view addSubview:self.tableView];
    [self loadData];

    [self createSubviews];
    self.deviceNameLabel.text = self.model.AliasName;

    self.navigationItem.rightBarButtonItem = self.saveButtonItem;
    

}

-(void)loadData{
    if (self.isEdit == YES) {
       //json字符串转子字典
        self.weekSelectDIC = [NSString jsonToObject:self.model.Data];
        
       
    }else{
        self.integer = 10;

    }
    
    //用于 分享过来的设备不可以添加场景
    for (DeviceViewModel *model in [UserManageCenter sharedUserManageCenter].deviceList) {
        if (![MethodTool isBlankString:model.FamilyId]) {
            if ([self.model.DeviceName isEqualToString:model.DeviceName]) {
                self.listArray = model.deviceSetInfo[@"PSense"][@"Value"];
            }
        }
    }
    if (self.listArray.count <= 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCSTR(@"提示") message:LOCSTR(@"\"仅播放模式\"下未添加定时任务，请前往首页，选择设备\"设置\"→\"播放设置\"→\"仅播放\"设置定时任务") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *b = [UIAlertAction actionWithTitle:LOCSTR(@"知道了") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert addAction:b];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        for (int i = 0; i < self.listArray.count; i++) {
            NSMutableDictionary *dic = self.listArray[i];

            if ([self.weekSelectDIC[@"PlayTimer"] integerValue] == i+1) {
                dic[@"Status"] = @1;
            }else{
                dic[@"Status"] = @0;
            }
            [self.listArray replaceObjectAtIndex:i withObject:dic];
        }
        [self.tableView reloadData];

    }
        
        
}
//保存
- (void)saveItemClick:(UIBarButtonItem *)btn{
    if (@(self.integer) == nil || self.integer == 10) {
        [MBProgressHUD showMessage:LOCSTR(@"请勾选曲目") icon:@""];
        return;
    }
    NSDictionary *data = @{@"PlayTimer":@(self.integer)};
    //字典转json字符串
    self.model.Data = [NSString objectToJson:data];

    if (self.isEdit == YES) {
        [self.navigationController popViewControllerAnimated:YES];
        if (self.autoUpdateBlock) {
            self.autoUpdateBlock(self.model);
        }
    }else{
        AddSceneViewController *VC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
        self.model.type = @"2";
        VC.addActionModel = self.model;
        [[NSNotificationCenter defaultCenter] postNotificationName:CHANGJING_RENWU object:nil];
        [self.navigationController popToViewController:VC animated:true];
    }
}
-(void)createSubviews{
    
    UIView *bgView = self.view
    .addView(0)
    .backgroundColor(UIColor.groupTableViewBackgroundColor)
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.view).mas_offset(0);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 60));
    })
    .view;
    
    self.deviceNameLabel = self.view
    .addLabel(0)
    .textColor(KColor666666)
    .font(KFont(13))
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make){
        make.left.mas_equalTo(18);
        make.centerY.mas_equalTo(bgView);
        make.right.mas_equalTo(-15);
    })
    .view;
    
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
    BoFangDingShiCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BoFangDingShiCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.integer = indexPath.row+1;
    cell.fromTimeVCBool = NO;
    cell.model = self.listArray[indexPath.row];

    return cell;
}
//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.integer = indexPath.row+1;

    for (int i = 0; i < self.listArray.count; i++) {
        NSMutableDictionary *dic = self.listArray[i];
        if (i == indexPath.row) {
            dic[@"Status"] = @1;
        }else{
            dic[@"Status"] = @0;
        }
        [self.listArray replaceObjectAtIndex:i withObject:dic];
    }
   
    [self.tableView reloadData];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = UIColor.clearColor;
    
    UILabel *tishiLabel = view
    .addLabel(1)
    .numberOfLines(0)
    .text(LOCSTR(@"注：以上定时对应“仅播放”模式的设置，选择后，播放该定时任务的曲目"))
    .textColor(UIColor.redColor)
    .masonry(^(MASConstraintMaker *make){
        make.left.mas_equalTo(18);
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(-18);
    })
    .view;
    tishiLabel.font = KFont(12);
    
    return view;
}
    
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 50;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 60, KScreenW, KScreenH-k_Height_NavBar-60) style:UITableViewStylePlain];
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

- (void)reloadUIWithModelArray:(NSArray *)modelArray
{
    WEAK
    self.clear();
    
    self.addSection(0).sectionInsets(UIEdgeInsetsMake(60, 0, 0, 0));
    self.addCells(@"TJRenWuViewCell")
    .withDataModelArray(modelArray)
    .toSection(0)
    .selectedAction(^ (BaseGeneralModel *model) {
        STRONG
        for (int i = 0; i < self.itemsArray.count; i++) {
            BaseGeneralModel *item = self.itemsArray[i];
            item.selected = (item == model);
            if (item.selected) {
                self.integer = i;
            }
        }
       
        self.row = model.tag;

        [self reloadView];
    });
    [self reloadView];
}

@end
