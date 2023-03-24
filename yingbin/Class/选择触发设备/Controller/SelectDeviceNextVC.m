//
//  SelectDeviceNextVC.m
//  yingbin
//
//  Created by slxk on 2021/5/7.
//  Copyright © 2021 wq. All rights reserved.
//

#import "SelectDeviceNextVC.h"
#import "AddSceneViewController.h"
@interface SelectDeviceNextVC ()
@property (nonatomic, strong)UILabel *devName;
@property (nonatomic, strong)UIButton *button;
@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation SelectDeviceNextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"添加触发设备");
    self.navigationItem.rightBarButtonItem = self.saveButtonItem;

    [self createSubviews];
    //编辑和新建 传过来的model结构不一样
    if (self.isEdit == YES) {
        self.devName.text = [MethodTool isBlankString:self.model.Property.AliasName]?self.model.Property.DeviceName:self.model.Property.AliasName;
//        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.model.Property.IconUrl]];
        self.imageView.image = KImage(@"icon_devimage");

    }else{
        self.devName.text = [MethodTool isBlankString:self.model.AliasName]?self.model.DeviceName:self.model.AliasName;
//        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.model.IconUrl]];
        self.imageView.image = KImage(@"icon_devimage");

    }
    

}
-(void)createSubviews{
    
    self.imageView = self.view
    .addImageView(1)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(35);
        make.top.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(25, 38));
    })
    .view;
    
    self.devName = self.view
    .addLabel(1)
    .font(KFont(14))
    .textColor(KColor333333)
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView.mas_right).mas_offset(8);
        make.right.mas_equalTo(15);
        make.centerY.mas_equalTo(self.imageView);
    })
    .view;
    
//    WEAK
    self.button = self.view
    .addButton(1)
    .image(KImage(@"icon_wxz"))
    .imageSelected(KImage(@"icon_xz"))
    .selected(YES)
    .titleFont(KFont(14))
    .titleColor(KColor999999)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
//        STRONG
     
    })
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.devName);
        make.top.mas_equalTo(self.devName.mas_bottom).mas_offset(20);
//        make.size.mas_equalTo(CGSizeMake(200, 50));
    })
    .view;
    [self.button setTitle:LOCSTR(@"人体感应触发") forState:UIControlStateNormal];
    [self.button layoutButtonWithImageStyle:ZJButtonImageStyleRight imageTitleToSpace:10];

}

- (void)saveItemClick:(UIBarButtonItem *)btn{
    NSString *timeTamp = [NSString getNowTimeString];
    
    if (self.isEdit) {//编辑

        self.model.Property.PropertyId = @"Detect";//后期需要知道 这个”人体感应触发“传那个参数
        [self.navigationController popViewControllerAnimated:YES];
        if (self.actionBlock){
            self.actionBlock(self.model);
        }
    }else{//创建
        NSDictionary *SelectDic = @{@"ProductId":self.model.ProductId,@"DeviceName":self.model.DeviceName,@"Op":@"eq",@"Value":@1,@"PropertyId":@"Detect"};
        NSDictionary *Dic = @{@"CondId":timeTamp,@"CondType":@(0),@"Property":SelectDic,@"type":@"0",@"AliasName":self.model.AliasName};//后期需要知道 这个”人体感应触发“传那个参数
        TIoTAutoIntelligentModel *timerModel = [TIoTAutoIntelligentModel yy_modelWithJSON:Dic];

        AddSceneViewController *VC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-4];
        VC.addConditionModel = timerModel;
        [[NSNotificationCenter defaultCenter] postNotificationName:CHANGJING_TIAOJIAN object:nil];
        [self.navigationController popToViewController:VC animated:true];

    }
   
}


@end
