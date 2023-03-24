//
//  AddSceneViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "AddSceneViewController.h"
#import "SelectTiaojianViewController.h"
#import "AddSceneViewCell.h"
#import "TJRenWuViewController.h"
#import "TimingViewController.h"

#import "TIoTAutoIntelligentModel.h"
#import "SelectDeviceViewController.h"
#import "SelectDeviceNextVC.h"
@interface AddSceneViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *TJRenWuArray;

@property (nonatomic, strong) NSDictionary *sceneDataDic;

@property (nonatomic, strong) NSMutableArray *conditionArray;//条件
@property (nonatomic, strong) NSMutableArray *actionArray;//任务

@property (nonatomic, assign) NSInteger selectedConditonNum;
@property (nonatomic, strong) NSString *effectDayIDString;  //重复周期对应天 ID
@property (nonatomic, strong) NSString *effectBeginTimeString; //有效时间段起始时间
@property (nonatomic, strong) NSString *effectEndTimeString; //有效时间段结束时间

//创建的时候背景图
@property (nonatomic, strong)NSArray *imageArray;
@property (nonatomic, strong)NSString *image_str;
@end

@implementation AddSceneViewController


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
//任务通知
-(void)onRenWuNotification{
    if ([self.addActionModel.type isEqualToString:@"2"]) {
        
        if (self.actionArray.count+1 > 20) {
            [MBProgressHUD showMessage:LOCSTR(@"任务最多添加20个") icon:@""];
        }else{
            [self.actionArray addObject:self.addActionModel];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
        

    }
}
//条件通知
-(void)onTiaoJianNotification{
    if ([self.addConditionModel.type isEqualToString:@"0"] || [self.addConditionModel.type isEqualToString:@"1"]) {
        
        if (self.conditionArray.count+1 > 20) {
            [MBProgressHUD showMessage:LOCSTR(@"条件最多添加20个") icon:@""];
        }else{
            [self.conditionArray addObject:self.addConditionModel];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
        

    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.isSceneDetail? LOCSTR(@"编辑场景"):LOCSTR(@"添加场景");
    self.navigationItem.rightBarButtonItem = self.saveButtonItem;
    
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRenWuNotification) name:CHANGJING_RENWU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTiaoJianNotification) name:CHANGJING_TIAOJIAN object:nil];

    
    self.selectedConditonNum = 1;
    self.effectDayIDString = @"1111111";
    self.effectBeginTimeString = @"00:00";
    self.effectEndTimeString = @"23:59";
    
    if (self.isSceneDetail == YES) {
        [self loadAutoSceneDetailData];
    }
    
    

}
//{
//    Data =     {
//        Actions = (
//                        {
//                ActionType = 3;
//                Data = 0;
//            }
//        );
//        AutomationId = "a_8df6d87902794523a28928a83b71fbc9";
//        Conditions =(
//                        {
//                CondId = 1619597456173;
//                CondType = 1;
//                Timer =                 {
//                    Days = 0000000;
//                    Expire = 1619683800;
//                    TimePoint = "16:10";
//                };
//            }
//        );
//        EffectiveBeginTime = "00:00";
//        EffectiveDays = 1111111;
//        EffectiveEndTime = "23:59";
//        FilterType = "";
//        Icon = "https://main.qcloudimg.com/raw/9c04afe82f2d18448efa45e239ee1244/scene6.jpg";
//        MatchType = 0;
//        Name = hjj;
//        Status = 1;
//    };
//    RequestId = "180961DC-11BD-44D5-84C4-7695F2863307";
//}
- (void)loadAutoSceneDetailData {
    
    NSDictionary *dic = @{@"AutomationId":self.autoSceneInfoDic[@"AutomationId"]?:@""};
    WEAK
    [[TIoTCoreRequestObject shared] post:AppDescribeAutomation Param:dic success:^(id responseObject) {
        STRONG
        self.sceneDataDic = [[NSDictionary alloc]initWithDictionary:responseObject[@"Data"]?:@{}];
        NSMutableArray *conArray = [NSMutableArray new];
        NSMutableArray *actArray = [NSMutableArray new];
        
//        //用于首页删掉设备时 接口还是有数据（我们需要自己判断）
        for (NSDictionary *dic in self.sceneDataDic[@"Conditions"]) {
            NSMutableDictionary *DIC = [NSMutableDictionary dictionaryWithDictionary:dic];
            if ([DIC[@"CondType"] isEqual: @(0)]) {
                for (DeviceViewModel *model in [UserManageCenter sharedUserManageCenter].deviceList) {
                    if ([model.DeviceName isEqualToString:DIC[@"Property"][@"DeviceName"]]) {
                        [DIC setValue:model.AliasName forKey:@"AliasName"];
                        [conArray addObject:DIC]; //condition 数组
                    }
                }
            }else{
                [conArray addObject:DIC];
            }

        }
        /*
        NSMutableArray *array = model.deviceSetInfo[@"PSense"][@"Value"];
//            for (NSMutableDictionary *PSenseDIC in array) {
//                if ([[PSenseDIC allKeys] containsObject:@"Name"]) {
//                    NSString *newStr = newDIC[@"Name"];
//                    NSString *PSenseStr = PSenseDIC[@"Name"];
//                    if ([newStr isEqualToString:PSenseStr]) {
//                        self.titleContentLabel.text = newDIC[@"Name"];
//                        self.titleLabel.text = [NSString stringWithFormat:@"%@",model.AliasName];
//                        self.cancelBtn.hidden = NO;
//                    }else{
//                        self.cancelBtn.hidden = YES;
//                    }
//
//                }
//            }
        
        if (array.count >= [newDIC[@"PlayTimer"] integerValue]) {
            NSInteger integer = [newDIC[@"PlayTimer"] integerValue]-1;
            NSDictionary *psenseDic = model.deviceSetInfo[@"PSense"][@"Value"][integer];
            self.titleContentLabel.text = psenseDic[@"Name"];
            self.titleLabel.text = [NSString stringWithFormat:@"%@",model.AliasName];
        }
         */
        for (DeviceViewModel *model in [UserManageCenter sharedUserManageCenter].deviceList) {
            for (NSMutableDictionary *dic in self.sceneDataDic[@"Actions"]) {
                NSMutableDictionary *DIC = [NSMutableDictionary dictionaryWithDictionary:dic];
                if ([[NSString stringWithFormat:@"%@",DIC[@"ActionType"]] isEqualToString:@"0"]) {
                    NSData *jsonData = [DIC[@"Data"] dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *err;
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&err];
                    NSMutableDictionary *newDIC = [NSMutableDictionary dictionaryWithDictionary:dic];
                    NSMutableArray *array = model.deviceSetInfo[@"PSense"][@"Value"];
                    if ([model.DeviceName isEqualToString:DIC[@"DeviceName"]] && array.count >= [newDIC[@"PlayTimer"] integerValue]) {
                        [DIC setValue:model.AliasName forKey:@"AliasName"];
                        [DIC setValue:model.deviceSetInfo forKey:@"deviceSetInfo"];
                        [actArray addObject:DIC]; //Actions 数组
                    }
                }
                
            }
        }
//        NSMutableArray *conArray = [NSMutableArray arrayWithArray:self.sceneDataDic[@"Conditions"]?:@[]]; //保存原始condition 数组
//        NSMutableArray *actArray = [NSMutableArray arrayWithArray:self.sceneDataDic[@"Actions"]?:@[]]; //保存原始action 数组
        
        //条件
        NSArray *conditionTempArray = [conArray copy];
        for (int j = 0;j<conditionTempArray.count;j++) {
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:conditionTempArray[j]];
            TIoTAutoIntelligentModel *model = [TIoTAutoIntelligentModel yy_modelWithJSON:dic];
            model.type = [NSString stringWithFormat:@"%ld",(long)model.CondType];
            [self.conditionArray addObject:model];
            
        }
        //任务
        NSArray *actionTempArray = [actArray copy];
        for (int j = 0;j<actionTempArray.count;j++) {
            NSDictionary *acDic = [NSDictionary dictionaryWithDictionary:actionTempArray[j]];
            TIoTAutoIntelligentModel *model = [TIoTAutoIntelligentModel yy_modelWithJSON:acDic];
            if (model.ActionType == 0) {
                model.type = [NSString stringWithFormat:@"%ld",model.ActionType+2];
                [self.actionArray addObject:model];
            }
        }

        [self.tableView reloadData];
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];
    }];
}

//保存
- (void)saveItemClick:(UIBarButtonItem *)btn{
    
    WEAK
    if (self.isSceneDetail == YES) {
        //编辑场景
        if (self.conditionArray.count == 0 && self.actionArray.count != 0) {
            [MBProgressHUD showMessage:LOCSTR(@"请添加条件") icon:@""];
        }else if (self.conditionArray.count != 0 && self.actionArray.count == 0) {
            [MBProgressHUD showMessage:LOCSTR(@"请添加任务") icon:@""];
        }else if (self.conditionArray.count == 0 && self.actionArray.count == 0) {
            [MBProgressHUD showMessage:LOCSTR(@"请添加任务和条件") icon:@""];
        }else {
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCSTR(@"提示") message:LOCSTR(@"请输入您要创建的场景名称") preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"取消") style:UIAlertActionStyleDefault handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                STRONG
                UITextField *TextField = alertController.textFields.firstObject;
                NSString *moneyStr = TextField.text;
                if ([MethodTool isBlankString:moneyStr])
                {
                    [MBProgressHUD showError:LOCSTR(@"请输入场景名称")];
                }
                else
                {
                    if ([self.dataNameArr containsObject:moneyStr] && ![self.autoSceneInfoDic[@"Name"] isEqualToString:moneyStr]) {
                        [MBProgressHUD showError:LOCSTR(@"场景名称已存在")];
                    }else{
                        TIoTAutoIntelligentModel *model = self.actionArray.lastObject;
                        if (model.ActionType == 1) {
                            [MBProgressHUD showMessage:LOCSTR(@"延时不能设置为最后一个任务") icon:@""];
                        }else {
                            //MARK:请求修改自动场景接口
                            [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
                            
                            NSDictionary *paramDic = @{@"Actions":[self.actionArray yy_modelToJSONObject],
                                                       @"Conditions":[self.conditionArray yy_modelToJSONObject],
                                                       @"AutomationId":self.autoSceneInfoDic[@"AutomationId"]?:@"",
                                                       @"Icon":self.autoSceneInfoDic[@"Icon"]?:@"",
                                                       @"Name":moneyStr,
                                                       @"Status":self.autoSceneInfoDic[@"Status"]?:@"",
                                                       @"MatchType":@(self.selectedConditonNum),
                                                       @"EffectiveDays":self.effectDayIDString,
                                                       @"EffectiveBeginTime":self.effectBeginTimeString,
                                                       @"EffectiveEndTime":self.effectEndTimeString,};
                            
                            [[TIoTCoreRequestObject shared] post:AppModifyAutomation Param:paramDic success:^(id responseObject) {
                                STRONG
                                [MBProgressHUD showMessage:LOCSTR(@"修改成功") icon:@""];
                                [self.navigationController popViewControllerAnimated:YES];
                                [[NSNotificationCenter defaultCenter] postNotificationName:AddSceneNotify object:nil];

                            } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
                                [MBProgressHUD showError:reason];
                                [MethodTool judgeUserSignoutWithReturnToken:dic];
                            }];
                        }
                    }
                    
                }
                
            }]];
            
            //定义第一个输入框；
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                STRONG
                textField.placeholder = LOCSTR(@"请输入场景名称");
                textField.text = self.autoSceneInfoDic[@"Name"]?:@"";
            }];
            
            [self presentViewController:alertController animated:true completion:nil];
            
        }
    }else{
        //添加场景
        if (self.conditionArray.count == 0 && self.actionArray.count != 0) {
            [MBProgressHUD showMessage:LOCSTR(@"请添加条件") icon:@""];
        }else if (self.conditionArray.count != 0 && self.actionArray.count == 0) {
            [MBProgressHUD showMessage:LOCSTR(@"请添加任务") icon:@""];
        }else if (self.conditionArray.count == 0 && self.actionArray.count == 0) {
            [MBProgressHUD showMessage:LOCSTR(@"请添加任务和条件") icon:@""];
        }else {
            
            [self TIoTCoreRequestObject];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCSTR(@"提示") message:LOCSTR(@"请输入您要创建的场景名称") preferredStyle:UIAlertControllerStyleAlert];
            //增加取消按钮
            [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"取消") style:UIAlertActionStyleDefault handler:nil]];
            //增加确定按钮
            [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                STRONG
                //获取第1个输入框；
                UITextField *TextField = alertController.textFields.firstObject;
                NSString *moneyStr = TextField.text;
                if ([MethodTool isBlankString:moneyStr])
                {
                    [MBProgressHUD showError:LOCSTR(@"请输入场景名称")];
                }
                else
                {
                    if ([self.dataNameArr containsObject:moneyStr]) {
                        [MBProgressHUD showError:LOCSTR(@"场景名称已存在")];
                    }else{
                        TIoTAutoIntelligentModel *model = self.actionArray.lastObject;
                        if (model.ActionType == 1) {
                            [MBProgressHUD showMessage:NSLocalizedString(@"donot_setDelay_atLeast", @"延时不能设置为最后一个任务") icon:@""];
                        }else  {
                            //MARK:组装好条件、任务、生效时间段 的请求参数 model，跳转到完善页面，添加场景背景URL和名称
                            
                            NSMutableDictionary *autoDic = [NSMutableDictionary new];
                            [autoDic setValue:moneyStr forKey:@"Name"];
                            [autoDic setValue:self.image_str forKey:@"Icon"];
                            [autoDic setValue:@(1) forKey:@"Status"];
                            [autoDic setValue:@(self.selectedConditonNum) forKey:@"MatchType"];
                            [autoDic setValue:[self.conditionArray yy_modelToJSONObject]?:@"" forKey:@"Conditions"];
                            [autoDic setValue:[self.actionArray yy_modelToJSONObject]?:@"" forKey:@"Actions"];
                            [autoDic setValue:self.paramDic[@"FamilyId"]?:@"" forKey:@"FamilyId"];
                            
                            [autoDic setValue:self.effectDayIDString?:@"" forKey:@"EffectiveDays"];
                            [autoDic setValue:self.effectBeginTimeString?:@"" forKey:@"EffectiveBeginTime"];
                            [autoDic setValue:self.effectEndTimeString?:@"" forKey:@"EffectiveEndTime"];

                            [[TIoTCoreRequestObject shared] post:AppCreateAutomation Param:autoDic success:^(id responseObject) {
                                STRONG
                                
                                [MBProgressHUD showMessage:LOCSTR(@"添加成功") icon:@""];
                                [self.navigationController popViewControllerAnimated:YES];
                                [[NSNotificationCenter defaultCenter] postNotificationName:AddSceneNotify object:nil];
                            } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
                                [MBProgressHUD showError:reason];
                                [MethodTool judgeUserSignoutWithReturnToken:dic];
                            }];
                            
                        }
                    }
                    
                }
                
                
            }]];
            
            //定义第一个输入框；
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = LOCSTR(@"请输入场景名称");
            }];
            
            [self presentViewController:alertController animated:true completion:nil];
            
        }
    }
    
    
}
//创建的时候 按理是列表自己选择的背景图片 -- 现固定
- (void)TIoTCoreRequestObject {
//    WEAK
//    [[TIoTCoreRequestObject shared] getRequestURLString:@"https://imgcache.qq.com/qzone/qzactStatics/qcloud/data/39/config2.js" success:^(id responseObject) {
//            STRONG
//        self.imageArray = [responseObject yy_modelToJSONObject];
        self.image_str = @"https://main.qcloudimg.com/raw/c05e0ef33ff62962a089649800cd5ce9/scene1.jpg";
//
//    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
//
//    }];
}
#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.conditionArray.count;
    }else{
        return self.actionArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAK
    AddSceneViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddSceneViewCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.model = self.conditionArray[indexPath.row];
    }else{
        cell.model = self.actionArray[indexPath.row];
    }
    cell.cancelBlock = ^(UIButton * _Nonnull btn) {
        //删除
        STRONG
        if (indexPath.section == 0) {
            [self.conditionArray removeObjectAtIndex:indexPath.row];
        }else{
            [self.actionArray removeObjectAtIndex:indexPath.row];
        }
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section],nil] withRowAnimation:UITableViewRowAnimationNone];
        [UIView performWithoutAnimation:^{
            [self.tableView reloadData];
        }];

    };
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAK
    if (indexPath.section == 0) {
        TIoTAutoIntelligentModel *model = self.conditionArray[indexPath.row];
        if (model.CondType == 0) {//设备
            SelectDeviceNextVC *vc = [[SelectDeviceNextVC alloc] init];
            vc.isEdit = YES;
            vc.model = model;
            vc.actionBlock = ^(TIoTAutoIntelligentModel * _Nonnull timerModel) {
                STRONG
                [self.conditionArray replaceObjectAtIndex:indexPath.row withObject:timerModel];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            };
            PushVC(vc);
        }
        else if(model.CondType == 1)//定时
        {
            TimingViewController *vc = [[TimingViewController alloc]init];
            vc.isEdit = YES;
            vc.model = model;
            vc.updateTimerBlock = ^(TIoTAutoIntelligentModel * _Nonnull timerModel) {
                STRONG
                [self.conditionArray replaceObjectAtIndex:indexPath.row withObject:timerModel];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                
            };
            PushVC(vc);
        }
    }
    else//执行
    {
        TIoTAutoIntelligentModel *acmodel = self.actionArray[indexPath.row];
        TJRenWuViewController *vc = [[TJRenWuViewController alloc]init];
        vc.isEdit = YES;
        vc.model = acmodel;
        vc.autoUpdateBlock = ^(TIoTAutoIntelligentModel * _Nonnull model) {
            STRONG
            [self.actionArray replaceObjectAtIndex:indexPath.row withObject:model];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        };
        PushVC(vc);
    }
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 150, 20)];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = KColor333333;
    if (section == 0) {
        label.text = LOCSTR(@"满足任一条件时");
    }else{
        label.text = LOCSTR(@"将执行以下任务");
    }

    [view addSubview:label];

    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 70;
}
//点击footer添加
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    //编辑
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenW-24, 55)];
    view.backgroundColor = UIColor.whiteColor;
    view.layer.cornerRadius = 3;

    UIButton *button = view
    .addButton(0)
    .title(@"+")
    .titleFont(KFont(20))
    .titleColor(KColor999999)
    .backgroundColor([UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0])
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        [self addButtonClick:x];
    })
    .masonry(^(MASConstraintMaker *make){
        make.centerY.mas_equalTo(view.mas_centerY);
        make.centerX.mas_equalTo(view);
        make.size.mas_equalTo(CGSizeMake(96, 30));
    })
    .view;
    button.tag = section;
    
    //添加
    UIView *addView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenW-24, 150)];
    addView.backgroundColor = UIColor.whiteColor;
    view.layer.cornerRadius = 3;
    
    UIButton *addButton = addView
    .addButton(1)
    .image(KImage(@"icon_changjing_add"))
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        [self addButtonClick:x];
    })
    .masonry(^(MASConstraintMaker *make){
        make.centerY.mas_equalTo(addView.mas_centerY);
        make.centerX.mas_equalTo(addView);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    })
    .view;
    addButton.tag = section;
    
    UILabel *addLabel = addView
    .addLabel(1)
    .textColor([UIColor colorWithRed:142/255.0 green:142/255.0 blue:142/255.0 alpha:1.0])
    .font(KFont(13))
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(addButton.mas_bottom);
        make.centerX.mas_equalTo(addButton.mas_centerX);
    })
    .view;
    addLabel.text = section == 0 ? LOCSTR(@"未添加条件"):LOCSTR(@"未添加任务");
    
    if (self.isSceneDetail == YES) {
        return view;
    }else{
        if (section == 0) {
            if (self.conditionArray.count > 0){
                return view;
            }else{
                return addView;
            }
        }else{
            if (self.actionArray.count > 0){
                return view;
            }else{
                return addView;
            }
        }
    }
    
    
}
-(void)addButtonClick:(UIButton *)but{
    if (but.tag == 0) {
        //添加条件
        SelectTiaojianViewController *vc = [[SelectTiaojianViewController alloc]init];
        PushVC(vc);
    }else{
        //添加执行
        SelectDeviceViewController *vc = [[SelectDeviceViewController alloc] init];
        vc.isEdit = NO;
        vc.titleStr = LOCSTR(@"选择执行设备");
        PushVC(vc);
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.isSceneDetail == YES) {
        return 55;
    }else{
        if (section == 0) {
            if (self.conditionArray.count > 0){
                return 55;
            }else{
                return 150;
            }
        }else{
            if (self.actionArray.count > 0){
                return 55;
            }else{
                return 150;
            }
        }
    }
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(12, 0, KScreenW-24, KScreenH-k_Height_NavBar) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 40;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.showsHorizontalScrollIndicator=NO;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[AddSceneViewCell class] forCellReuseIdentifier:NSStringFromClass([AddSceneViewCell class])];

    }
    return _tableView;
}

-(NSMutableArray *)conditionArray{
    if (!_conditionArray) {
        _conditionArray = [[NSMutableArray alloc] init];
    }
    return _conditionArray;
}
-(NSMutableArray *)actionArray{
    if (!_actionArray) {
        _actionArray = [[NSMutableArray alloc] init];
    }
    return _actionArray;
}
-(NSMutableArray *)dataNameArr{
    if (!_dataNameArr) {
        _dataNameArr = [[NSMutableArray alloc] init];
    }
    return _dataNameArr;
}


@end
