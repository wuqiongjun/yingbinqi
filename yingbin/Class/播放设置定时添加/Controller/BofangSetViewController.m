//
//  BofangSetViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/23.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BofangSetViewController.h"
#import "ZZFLEXEditModel.h"
#import "UIExPickerView.h"
#import "QuMuViewController.h"
#import "locallyMusicModel.h"
#import "BoFangCell.h"
@interface BofangSetViewController ()<TimePickerViewDelegate,pickerDelegate,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *hour;
@property (nonatomic, strong) NSString *min;

@property (nonatomic, strong) NSString *hourE;
@property (nonatomic, strong) NSString *minE;

@property (strong, nonatomic)  UIButton *meitButton;
@property (strong, nonatomic)  UIButton *zhouyiButton;
@property (strong, nonatomic)  UIButton *zhouerButton;
@property (strong, nonatomic)  UIButton *zhousanButton;
@property (strong, nonatomic)  UIButton *zhousiButton;
@property (strong, nonatomic)  UIButton *zhouwuButton;
@property (strong, nonatomic)  UIButton *zhouliuButton;
@property (strong, nonatomic)  UIButton *zhouriButton;

@property (nonatomic, strong)BaseGeneralModel *timeModel;
@property (nonatomic, strong)BaseGeneralModel *OpenModel;
@property (nonatomic, strong)BaseGeneralModel *EndModel;

@property (nonatomic, strong)NSMutableArray *weekSelect;//日期数组

@property (nonatomic, strong)UILabel *xhNumber;
@property (nonatomic, strong)UILabel *jgTime;
@property (nonatomic, strong)NSString *xhNumberSTR;
@property (nonatomic, strong)NSString *jgTimeSTR;

@property (nonatomic, strong)NSArray *jgTimeArray;//间隔时间数组
@property (nonatomic, strong)NSArray *xhNumberArray;//循环次数数组

@property (nonatomic, assign)NSInteger jgTimeIndexSelect;//间隔次数选中下标
@property (nonatomic, assign)NSInteger xhNumberIndexSelect;//循环时间选中下标

@property (nonatomic,strong) NSString *timerName;//定时名称


@property (nonatomic, strong)UITableView *musicTableView;
@property (nonatomic, strong)NSMutableArray *musicArray;//音乐列表数组 musicArray = [@{@"叮咚"},@{@"叮咚叮咚"}]
@property (nonatomic, strong)NSMutableArray *musicListArray;//音乐传值数组 musicListArray = [@{@"a000000001.mp3"},@{@"a000000002.mp3"}]

@property (nonatomic, strong)NSMutableArray *titleArr;

// songDevArray = @[@{@"name":LOCSTR(@"叮咚"),@"aName":@"a000000001.mp3",@"selected":YES},@{@"name":LOCSTR(@"叮咚叮咚"),@"aName":@"a000000002.mp3",@"selected":NO}]
@property (nonatomic, strong)NSMutableArray *songDevArray;

@property (nonatomic, strong)UIView *bgVIEW;

@property (nonatomic, assign)BOOL isGuangGaoBool;


@end

@implementation BofangSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleStr;
    self.navigationItem.rightBarButtonItem = self.saveButtonItem;

    [self.view addSubview:self.musicTableView];
    
    if ([self.titleStr containsString:LOCSTR(@"广告播放")]) {
        self.isGuangGaoBool = YES;
    }else{
        self.isGuangGaoBool = NO;

    }
    if (self.isEdit) {

        self.timerName = self.model[@"TimerName"];
        
        self.OpenModel.itemSubName = self.model[@"StartTime"];
        self.EndModel.itemSubName = self.model[@"EndTime"];
        
        self.hour = [self.model[@"StartTime"] componentsSeparatedByString:@":"][0];
        self.min = [self.model[@"StartTime"] componentsSeparatedByString:@":"][1];
        self.hourE = [self.model[@"EndTime"] componentsSeparatedByString:@":"][0];
        self.minE = [self.model[@"EndTime"] componentsSeparatedByString:@":"][1];
        
        self.xhNumberSTR = [NSString stringWithFormat:@"%@%@",self.model[@"Repeat"],LOCSTR(@"次")];
        self.jgTimeSTR = [NSString stringWithFormat:@"%@%@",self.model[@"Interval"],LOCSTR(@"秒")];
        
        self.xhNumberIndexSelect = [self.model[@"Repeat"] integerValue]-1;
        self.jgTimeIndexSelect = [self.model[@"Interval"] integerValue];
        [self configData];

    }else{
        self.xhNumberIndexSelect = 0;
        self.jgTimeIndexSelect = 3;
        self.xhNumberSTR = LOCSTR(@"1次");
        self.jgTimeSTR = LOCSTR(@"3秒");
    }
    
    [self setUIBGView];
    [self configSongData];

}
#pragma mark - 铺 tableView 第一个cell

-(void)setUIBGView{
    WEAK
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.isGuangGaoBool?(490+5):(490+5+54+10))];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.bgVIEW = view;
#pragma mark - 时间选择
    UIView *bgView = view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, 162));
    })
    .view;
    bgView.layer.cornerRadius = 9;
    

    NSMutableArray *array = [NSMutableArray arrayWithArray:@[self.timeModel,self.OpenModel,self.EndModel]];
    [view addSubview:self.collectionView];
    self.collectionView.scrollEnabled = NO;
    self.addSection(0).sectionInsets(UIEdgeInsetsMake(10, 0, 0, 0));
    self.addCells(@"BoFangViewCell")
    .toSection(0).withDataModelArray(array)
    .selectedAction(^(BaseGeneralModel *model){
        STRONG
        NSUInteger typeUI = [model.type unsignedIntegerValue];
        switch (typeUI) {
            case 0:
            {

            }
                break;
            case 1:
            {
                WQTimePickerView *picker = [[WQTimePickerView alloc]initDatePackerWithStartHour:@"00" endHour:@"24" period:1 selectedHour:self.hour selectedMin:self.min tag:@"0" title:LOCSTR(@"开始时间")];
                picker.delegate = self;
                [picker show];
            }
                break;
            case 2:
            {
                WQTimePickerView *picker = [[WQTimePickerView alloc]initDatePackerWithStartHour:@"00" endHour:@"24" period:1 selectedHour:self.hourE selectedMin:self.minE tag:@"1" title:LOCSTR(@"结束时间")];
                picker.delegate = self;
                [picker show];

            }
                break;

            default:
                break;
        }
    });
    
#pragma mark - 日期选择
    UIView *bgDataView = view
    .addView(1)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(182);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, 186));
    })
    .view;
    bgDataView.layer.cornerRadius = 9;
    
    //防止点击日期选择出现整个界面有阴影
    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Actiondo:)];
    [bgDataView addGestureRecognizer:tapGesture];
    
    UILabel *title = bgDataView
    .addLabel(1)
    .font(KBFont(15))
    .text(LOCSTR(@"日期选择"))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(20);
        make.right.mas_lessThanOrEqualTo(-15.0f);
    })
    .view;
    

    NSArray *arr = @[@"每天",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    CGFloat T = 20;
    CGFloat w = (SCREEN_WIDTH-24)/4;
    CGFloat h = 40;
        for (int i = 0; i < arr.count; i++) {
            UIButton *button = bgDataView
            .addButton(i)
            .image(KImage(@"icon_wxz"))
            .imageSelected(KImage(@"icon_xz"))
            .title(arr[i])
            .titleColor(KColor333333)
            .titleFont(KFont(14))
            .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
                STRONG
                x.selected = !x.selected;
                if (x.tag == 0) {
                    if(x.selected){
                        self.zhouyiButton.selected = YES;
                        self.zhouerButton.selected = YES;
                        self.zhousanButton.selected = YES;
                        self.zhousiButton.selected = YES;
                        self.zhouwuButton.selected = YES;
                        self.zhouliuButton.selected = YES;
                        self.zhouriButton.selected = YES;
                        self.weekSelect = [NSMutableArray arrayWithArray:@[@"1",@"1",@"1",@"1",@"1",@"1",@"1"]];
                    }else{
                        self.zhouyiButton.selected = NO;
                        self.zhouerButton.selected = NO;
                        self.zhousanButton.selected = NO;
                        self.zhousiButton.selected = NO;
                        self.zhouwuButton.selected = NO;
                        self.zhouliuButton.selected = NO;
                        self.zhouriButton.selected = NO;
                        self.weekSelect = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];

                    }
                }else{
                    if (i==1 || i==2 || i==3|| i==4|| i==5|| i==6) {
                        //修改重复
                        if (x.selected) {
                            [self.weekSelect replaceObjectAtIndex:i withObject:@"1"];
                        }else{
                            [self.weekSelect replaceObjectAtIndex:i withObject:@"0"];
                        }
                    }else{
                        if (x.selected) {
                            [self.weekSelect replaceObjectAtIndex:0 withObject:@"1"];
                        }else{
                            [self.weekSelect replaceObjectAtIndex:0 withObject:@"0"];
                        }
                    }
                    
                }
                if(self.zhouyiButton.selected&&self.zhouerButton.selected&&self.zhousanButton.selected&&self.zhousiButton.selected&&self.zhouwuButton.selected&&self.zhouliuButton.selected&&self.zhouriButton.selected) {
                    self.meitButton.selected = YES;
                    self.weekSelect = [NSMutableArray arrayWithArray:@[@"1",@"1",@"1",@"1",@"1",@"1",@"1"]];
                }else{
                    self.meitButton.selected = NO;
                }
                
                
            })
            .masonry(^(MASConstraintMaker *make) {
                if (i == 0) {
                    make.left.mas_equalTo(0);
                    make.top.mas_equalTo(title.mas_bottom).mas_offset(T);
                }if (i == 1) {
                    make.left.mas_equalTo(0);
                    make.top.mas_equalTo(title.mas_bottom).mas_offset(T+h);
                }if (i == 2) {
                    make.left.mas_equalTo((i-1)*w);
                    make.top.mas_equalTo(title.mas_bottom).mas_offset(T+h);
                }if (i == 3) {
                    make.left.mas_equalTo((i-1)*w);
                    make.top.mas_equalTo(title.mas_bottom).mas_offset(T+h);
                }if (i == 4) {
                    make.left.mas_equalTo((i-1)*w);
                    make.top.mas_equalTo(title.mas_bottom).mas_offset(T+h);
                }if (i == 5) {
                    make.left.mas_equalTo(0);
                    make.top.mas_equalTo(title.mas_bottom).mas_offset(T+2*h);
                }if (i == 6) {
                    make.left.mas_equalTo((i-5)*w);
                    make.top.mas_equalTo(title.mas_bottom).mas_offset(T+2*h);
                }if (i == 7) {
                    make.left.mas_equalTo((i-5)*w);
                    make.top.mas_equalTo(title.mas_bottom).mas_offset(T+2*h);
                }
                make.size.mas_equalTo(CGSizeMake(w, 35));
            })
            .view;
            
            if (i == 0) {
                self.meitButton = button;
                    if (![self.weekSelect containsObject:@"0"]) {
                        button.selected = YES;
                    }else{
                        button.selected = NO;
                    }

            }if (i == 1) {
                self.zhouyiButton = button;
                    if ([self.weekSelect[i] integerValue] == 1) {
                        button.selected = YES;
                    }else{
                        button.selected = NO;
                    }

            }if (i == 2) {
                self.zhouerButton = button;
                    if ([self.weekSelect[i] integerValue] == 1) {
                        button.selected = YES;
                    }else{
                        button.selected = NO;
                    }

            }if (i == 3) {
                self.zhousanButton = button;
                    if ([self.weekSelect[i] integerValue] == 1) {
                        button.selected = YES;
                    }else{
                        button.selected = NO;
                    }

            }if (i == 4) {
                self.zhousiButton = button;
                    if ([self.weekSelect[i] integerValue] == 1) {
                        button.selected = YES;
                    }else{
                        button.selected = NO;
                    }

            }if (i == 5) {
                self.zhouwuButton = button;
                    if ([self.weekSelect[i] integerValue] == 1) {
                        button.selected = YES;
                    }else{
                        button.selected = NO;
                    }

            }if (i == 6) {
                self.zhouliuButton = button;
                    if ([self.weekSelect[i] integerValue] == 1) {
                        button.selected = YES;
                    }else{
                        button.selected = NO;
                    }

            }if (i == 7) {
                self.zhouriButton = button;
                    if ([self.weekSelect[0] integerValue] == 1) {
                        button.selected = YES;
                    }else{
                        button.selected = NO;
                    }

            }
            
            [button layoutButtonWithImageStyle:ZJButtonImageStyleLeft imageTitleToSpace:10];
            button.tag = i;
            [bgDataView addSubview:button];
        }
    
    
#pragma mark - 第三个view 循环 间隔

    UIView *bgNumberTime = view
    .addView(3)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(bgDataView.mas_bottom).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, self.isGuangGaoBool?0:54));
    })
    .view;
    bgNumberTime.layer.cornerRadius = 9;
    
    if (!self.isGuangGaoBool) {
        UIButton *bgBottomView = bgNumberTime
        .addButton(1)
        .backgroundColor(UIColor.clearColor)
        .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
            STRONG
            //循环次数
            UIExPickerView *pView = [[UIExPickerView alloc ] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH) titleStr:LOCSTR(@"循环次数设置") indexSelect:self.xhNumberIndexSelect arr:self.xhNumberArray devModel:[UserManageCenter sharedUserManageCenter].deviceModel];
            pView.delegate = self;
            [self.view addSubview:pView];
        })
        .masonry(^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.height.mas_offset(54);
        })
        .view;
        
        
        UILabel *bottonLabel = bgBottomView
        .addLabel(1)
        .font(KBFont(15))
        .text(LOCSTR(@"循环次数"))
        .textColor(KColor333333)
        .masonry(^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.centerY.mas_equalTo(bgBottomView.mas_centerY);
        })
        .view;
        
        self.xhNumber = bgBottomView
        .addLabel(5)
        .font(KBFont(15))
        .text(self.xhNumberSTR)
        .textColor([UIColor grayColor])
        .masonry(^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.centerY.mas_equalTo(bottonLabel.mas_centerY);
        })
        .view;
         
    }

    UIView *bgTime = view
    .addView(3)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(bgNumberTime.mas_bottom).mas_offset(self.isGuangGaoBool?0:10);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24,54));
    })
    .view;
    bgTime.layer.cornerRadius = 9;
    
    
    UIButton *bgTimeBottomView = bgTime
    .addButton(1)
    .backgroundColor(UIColor.clearColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
//间隔时间
        UIExPickerView *pView = [[UIExPickerView alloc ] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH) titleStr:LOCSTR(@"间隔时间设置") indexSelect:self.jgTimeIndexSelect arr:self.jgTimeArray devModel:[UserManageCenter sharedUserManageCenter].deviceModel];
        pView.delegate = self;
        [self.view addSubview:pView];
    })
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_offset(54);
    })
    .view;

    
    UILabel *bottonTimeLabel = bgTimeBottomView
    .addLabel(1)
    .font(KBFont(15))
    .text(LOCSTR(@"间隔时间"))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(bgTimeBottomView.mas_centerY);
    })
    .view;
    
    self.jgTime = bgTimeBottomView
    .addLabel(5)
    .font(KBFont(15))
    .textColor([UIColor grayColor])
    .text(self.jgTimeSTR)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(bottonTimeLabel.mas_centerY);
    })
    .view;
#pragma mark - 曲目
    
    UIView *bgQMView = view
    .addView(3)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(bgTime.mas_bottom).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, 54));
    })
    .view;
    bgQMView.layer.cornerRadius = 9;
    
    UIButton *QMBottomView = bgQMView
    .addButton(2)
    .backgroundColor(UIColor.clearColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
        
        //点击曲目 返回选中歌曲
        QuMuViewController *vc = [QuMuViewController new];
        vc.songDevArray = self.songDevArray;
        vc.selectMusic = ^(NSMutableArray * _Nonnull array) {
            STRONG
            NSMutableArray *songArr = [NSMutableArray new];
            NSMutableArray *songListArr = [NSMutableArray new];

            for (NSMutableDictionary *devDic in array) {
                if ([devDic boolForKey:@"selected"]) {
                    [songArr addObject:devDic[@"name"]];
                    [songListArr addObject:devDic[@"aName"]];
                }
            }
            self.musicArray  = songArr;
            self.musicListArray  = songListArr;

            [self.musicTableView reloadData];
        };
        PushVC(vc);

    })
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_offset(54);
    })
    .view;

    
    UILabel *QmTimeLabel = QMBottomView
    .addLabel(1)
    .font(KBFont(15))
    .text(LOCSTR(@"曲目"))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(QMBottomView.mas_centerY);
    })
    .view;
    
    UIImageView *image = QMBottomView
    .addImageView(5)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(QmTimeLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(13, 13));
    })
    .view;
    image.image = KImage(@"icon_jiantou");
}
-(void)Actiondo:(id)sender{}
#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.musicArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAK
    BoFangCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BoFangCell class]) forIndexPath:indexPath];
    cell.btnSelected = ^(NSInteger btn) {
        STRONG
        NSMutableDictionary *nameDic = self.musicArray[indexPath.row-1];
        NSMutableDictionary *nameListDic = self.musicListArray[indexPath.row-1];

        if (btn == 1) { //btn = 1:向上
            if (indexPath.row-1 == 0) {
                [MBProgressHUD showMessage:LOCSTR(@"已经是第一位了") icon:@""];
            }else{
                [self.musicArray removeObject:nameDic];
                [self.musicArray insertObject:nameDic atIndex:indexPath.row-1-1];
                [self.musicListArray removeObject:nameListDic];
                [self.musicListArray insertObject:nameListDic atIndex:indexPath.row-1-1];
            }
        }else{ //btn = 2:向下
            if (indexPath.row-1 == self.musicArray.count-1) {
                [MBProgressHUD showMessage:LOCSTR(@"已经是最后了") icon:@""];
            }else{
                [self.musicArray removeObject:nameDic];
                [self.musicArray insertObject:nameDic atIndex:indexPath.row-1+1];
                [self.musicListArray removeObject:nameListDic];
                [self.musicListArray insertObject:nameListDic atIndex:indexPath.row-1+1];
            }
            
        }
        [self.musicTableView reloadData];

    };
    if (indexPath.row == 0)
    {
        [cell addSubview:self.bgVIEW];
    }else{
        cell.integer = indexPath.row;
        cell.nameStr = self.musicArray[indexPath.row-1];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return self.isGuangGaoBool?(490+5):(490+5+54+10);
    }else{
        return 50;
    }
}


-(UITableView *)musicTableView{
    if (!_musicTableView) {
        _musicTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-k_Height_NavBar) style:UITableViewStylePlain];
        _musicTableView.delegate = self;
        _musicTableView.dataSource = self;
        _musicTableView.showsVerticalScrollIndicator=NO;
        _musicTableView.showsHorizontalScrollIndicator=NO;
        _musicTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _musicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_musicTableView registerClass:[BoFangCell class] forCellReuseIdentifier:NSStringFromClass([BoFangCell class])];

    }
    return _musicTableView;
}


#pragma mark - 赋值
-(void)configData{
    if (self.model[@"Days"]) {
        const char *repeats = [self.model[@"Days"] UTF8String];
        
        for (int i = 0; i < 7; i ++) {
            int a = repeats[i] - '0';
            self.weekSelect[i] = [NSString stringWithFormat:@"%i",a];
        }
    }


}

#pragma mark - 保存
- (void)saveItemClick:(UIBarButtonItem *)btn{
    WEAK
    if (![self.weekSelect containsObject:@"1"]) {
        [MBProgressHUD showMessage:LOCSTR(@"请选择重复天数") icon:@""];
        return;
    }
    
    if (self.musicArray.count <= 0) {
        [MBProgressHUD showMessage:LOCSTR(@"请选择曲目") icon:@""];
        return;
    }

    if (([self.hour integerValue] > [self.hourE integerValue]) || ([self.hour integerValue] == [self.hourE integerValue] && [self.minE integerValue] <= [self.min integerValue])) {
        [MBProgressHUD showMessage:LOCSTR(@"开始时间不能大于等于结束时间") icon:@""];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCSTR(@"请输入闹钟名称") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"取消") style:UIAlertActionStyleDefault handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *TextField = alertController.textFields.firstObject;
                
                NSString *moneyStr = TextField.text;
                if ([NSString isNullOrNilWithObject:moneyStr] || [NSString isFullSpaceEmpty:moneyStr]) {
                    [MBProgressHUD showMessage:LOCSTR(@"请输入闹钟名称") icon:@""];
                }else {

                    if (moneyStr.length >20) {
                        [MBProgressHUD showError:LOCSTR(@"名称不能超过20个字符")];
                    }else {
                        NSMutableDictionary *param = [NSMutableDictionary new];

                        NSMutableDictionary *playDic =[NSMutableDictionary dictionaryWithDictionary:
                        @{
                            @"StartTime" :self.OpenModel.itemSubName,
                            @"EndTime"   :self.EndModel.itemSubName,
                            @"Days"      :[self.weekSelect componentsJoinedByString:@""],
                    //        @"Repeat"    :@([[self.xhNumber.text substringToIndex:self.xhNumber.text.length-1] integerValue]),
                            @"Repeat"    : [self.titleStr isEqualToString:LOCSTR(@"广告播放设置")]?@(1):@([[self.xhNumber.text substringToIndex:self.xhNumber.text.length-1] integerValue]),
                            @"Interval"   :@([[self.jgTime.text substringToIndex:self.jgTime.text.length-1] integerValue]),
                            @"Songs"      :[self.musicListArray componentsJoinedByString:@"|"],
                            @"Status"     :self.model[@"Status"]?:@1,
                            @"Name"       :moneyStr
                        }];
                        
                        NSMutableArray *array = [[NSMutableArray alloc]init];
                        NSString *key = [NSString new];
                        
                        if ([self.titleStr containsString:LOCSTR(@"感应播放")])
                        {
                            if ([UserManageCenter sharedUserManageCenter].DAPSenseList.count > 0) {
                                array = [UserManageCenter sharedUserManageCenter].DAPSenseList;
                            }
                            if (self.isEdit) {
                                [array replaceObjectAtIndex:self.integer withObject:playDic];
                            }else{
                                [array addObject:playDic];
                            }
                            key = @"DAPSense";
                        }else if([self.titleStr containsString:LOCSTR(@"仅播放")])
                        {
                            if ([UserManageCenter sharedUserManageCenter].PSenseList.count > 0) {
                                array = [UserManageCenter sharedUserManageCenter].PSenseList;
                            }
                            if (self.isEdit) {
                                [array replaceObjectAtIndex:self.integer withObject:playDic];
                            }else{
                                [array addObject:playDic];
                            }
                            key = @"PSense";
                        }else
                        {
                            if ([UserManageCenter sharedUserManageCenter].ASenseList.count > 0) {
                                array = [UserManageCenter sharedUserManageCenter].ASenseList;
                            }
                            if (self.isEdit) {
                                [array replaceObjectAtIndex:self.integer withObject:playDic];
                            }else{
                                [array addObject:playDic];
                            }
                            key = @"ASense";
                        }
                        [param setValue:array forKey:key];
                        
                        NSDictionary* tmpDic = @{
                            @"ProductId":[UserManageCenter sharedUserManageCenter].deviceModel.ProductId?:@"",
                            @"DeviceName":[UserManageCenter sharedUserManageCenter].deviceModel.DeviceName?:@"",
                            @"Data":[NSString objectToJson:param]?:@""
                        };
                        /*
                           保存或者编辑
                         */
                        if (self.isEdit) {
                            [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
                                STRONG
                                [self setUserManageCenterSenseListDic:playDic];
                                [self AppControlDeviceResource];
                                [MBProgressHUD showMessage:LOCSTR(@"修改成功") icon:@""];
                                [self.navigationController popViewControllerAnimated:YES];
                                [[NSNotificationCenter defaultCenter] postNotificationName:DeviceTimingNotify object:nil];
                                if ([key isEqualToString:@"PSense"]) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceInformation object:nil];
                                }
                            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                                [MBProgressHUD showError:reason];
                                [MethodTool judgeUserSignoutWithReturnToken:dic];
                            }];

                        }else{
                            [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
                                STRONG
                                [self setUserManageCenterSenseListDic:playDic];
                                [self AppControlDeviceResource];
                                [MBProgressHUD showMessage:LOCSTR(@"创建成功") icon:@""];
                                [self.navigationController popViewControllerAnimated:YES];
                                [[NSNotificationCenter defaultCenter] postNotificationName:DeviceTimingNotify object:nil];
                                if ([key isEqualToString:@"PSense"]) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceInformation object:nil];
                                }
                            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                                [MBProgressHUD showError:reason];
                                [MethodTool judgeUserSignoutWithReturnToken:dic];
                            }];

                        }
                    }
                }

            }]];

            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                STRONG
                textField.placeholder = LOCSTR(@"请输入闹钟名称");
                textField.text = self.model[@"Name"]?:@"";
            }];
    
       
            [self presentViewController:alertController animated:true completion:nil];
    
    
    
    
}
/*
   4.下发资源到设备
 */
 
-(void)AppControlDeviceResource{
    NSMutableArray *zdySongArr = [UserManageCenter sharedUserManageCenter].devicePlayList;
    NSMutableArray *arr = [NSMutableArray new];
    
    for (int i = 0; i< self.musicListArray.count; i++) {
        for (int j = 0; j < zdySongArr.count; j++) {
            locallyMusicModel *model = zdySongArr[j];
            if ([self.musicArray[i] isEqualToString:model.SN]) {
                [arr addObject:model.FN];
            }
        }
    }
    NSMutableDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    // 1. 队列
    dispatch_queue_t q = dispatch_queue_create("bingXing", DISPATCH_QUEUE_CONCURRENT);
    // 2. 同步执行
    for (int i = 0; i < arr.count; i++) {
        dispatch_sync(q, ^{
            NSDictionary *tmpDic = @{
                @"ResourceName":[NSString stringWithFormat:@"USER_%@_RES_%@",dic[@"UserID"],arr[i]],
                @"RequestId":[[NSUUID UUID] UUIDString],
                @"ResourceVer":@"1.0.0",
                @"Method":@"update",
                @"DeviceId":[UserManageCenter sharedUserManageCenter].deviceModel.DeviceId,
            };
            [[TIoTCoreRequestObject shared] post:@"AppControlDeviceResource" Param:tmpDic success:^(id responseObject) {
                NSLog(@"-----下发资源到设备成功----------%@",responseObject);
            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            }];
        });
    }


    
    
}
#pragma mark - 修改、新增 刷新数据

-(void)setUserManageCenterSenseListDic:(NSMutableDictionary *)playDic{
    if ([self.titleStr containsString:LOCSTR(@"感应播放")])
    {
        if (self.isEdit) {
            [[UserManageCenter sharedUserManageCenter].DAPSenseList replaceObjectAtIndex:self.integer withObject:playDic];
        }else{
            if ([UserManageCenter sharedUserManageCenter].DAPSenseList.count <= 0) {
                [[UserManageCenter sharedUserManageCenter].DAPSenseList addObject:playDic];
            }
        }

    }else if([self.titleStr containsString:LOCSTR(@"仅播放")])
    {
        if (self.isEdit) {
            [[UserManageCenter sharedUserManageCenter].PSenseList replaceObjectAtIndex:self.integer withObject:playDic];
        }else{
            if ([UserManageCenter sharedUserManageCenter].PSenseList.count <= 0) {
                [[UserManageCenter sharedUserManageCenter].PSenseList addObject:playDic];
            }
        }
        
    }else
    {
        if (self.isEdit) {
            [[UserManageCenter sharedUserManageCenter].ASenseList replaceObjectAtIndex:self.integer withObject:playDic];
        }else{
            if ([UserManageCenter sharedUserManageCenter].ASenseList.count <= 0) {
                [[UserManageCenter sharedUserManageCenter].ASenseList addObject:playDic];
            }
        }
    }
}
#pragma mark - 根据索引取出传入数组的值
-(void)selectIndex:(NSInteger)index title:(NSString *)title devModel:(DeviceViewModel *)model{
    
    if ([title isEqualToString:LOCSTR(@"循环次数设置")]) {
        self.xhNumber.text = self.xhNumberArray[index];
        self.xhNumberIndexSelect = index;
    }else{
        self.jgTime.text = self.jgTimeArray[index];
        self.jgTimeIndexSelect = index;
    }
    
}
#pragma mark - 时间选择后回调
-(void)timePickerViewDidSelectRow:(NSString *)Hour MIN:(NSString *)min tag:(NSString *)tag{
   
    if ([tag isEqualToString:@"0"]) {
        self.hour = Hour;
        self.min = min;
        self.OpenModel.itemSubName = [NSString stringWithFormat:@"%@:%@",Hour,min];

    }else{
        self.hourE = Hour;
        self.minE = min;
        self.EndModel.itemSubName = [NSString stringWithFormat:@"%@:%@",Hour,min];
    }
    [self reloadView];
}
#pragma mark - set

-(NSArray *)xhNumberArray{
    if (!_xhNumberArray) {
        _xhNumberArray = @[LOCSTR(@"1次"),LOCSTR(@"2次"),LOCSTR(@"3次"),LOCSTR(@"4次"),LOCSTR(@"5次"),LOCSTR(@"6次"),LOCSTR(@"7次"),LOCSTR(@"8次"),LOCSTR(@"9次"),LOCSTR(@"10次")];
    }
    return _xhNumberArray;
}

-(NSArray *)jgTimeArray{
    if (!_jgTimeArray) {
        NSMutableArray *mutableArr = [NSMutableArray new];
        for (int i = 0; i < 61; i++) {
            [mutableArr addObject:[NSString stringWithFormat:@"%d%@",i,LOCSTR(@"秒")]];
        }
        _jgTimeArray = [NSArray arrayWithArray:mutableArr];
    }
    return _jgTimeArray;
}

-(BaseGeneralModel *)timeModel{
    if (!_timeModel) {
        _timeModel = [[BaseGeneralModel alloc]init];
        _timeModel.itemSubName = @"";
        _timeModel.itemName = LOCSTR(@"时间选择");
        _timeModel.type = @(0);
        _timeModel.itemImageName = @"";
    }
    return _timeModel;
}
-(BaseGeneralModel *)OpenModel{
    if (!_OpenModel) {
        _OpenModel = [[BaseGeneralModel alloc]init];
        _OpenModel.itemSubName = @"00:00";
        _OpenModel.itemName = LOCSTR(@"开始时间");
        _OpenModel.type = @(1);
        _OpenModel.itemImageName = @"icon_Time";
        if (!self.isEdit) {
            self.hour = @"00";
            self.min = @"00";
        }
    }
    return _OpenModel;
}
-(BaseGeneralModel *)EndModel{
    if (!_EndModel) {
        _EndModel = [[BaseGeneralModel alloc]init];
        _EndModel.itemSubName = @"23:59";
        _EndModel.itemName = LOCSTR(@"结束时间");
        _EndModel.type = @(2);
        _EndModel.itemImageName = @"icon_Time";
        if (!self.isEdit) {
            self.hourE = @"23";
            self.minE = @"59";
        }
    }
    return _EndModel;
}
- (NSMutableArray *)weekSelect
{
    if (!_weekSelect) {
//        if (self.isEdit) {
            _weekSelect = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
//        }else{
//            _weekSelect = [NSMutableArray arrayWithArray:@[@"1",@"1",@"1",@"1",@"1",@"1",@"1"]];
//        }
    }
    return _weekSelect;
}
-(NSMutableArray *)titleArr{
    if (!_titleArr) {
        _titleArr = [NSMutableArray arrayWithArray:@[LOCSTR(@"感应播放"),LOCSTR(@"仅感应"),LOCSTR(@"仅播放"),LOCSTR(@"广告播放")]];
    }
    return _titleArr;
}





#pragma mark - 曲目数组 --赋值--

-(void)configSongData{
    
    
    NSMutableArray *zdySongArr = [UserManageCenter sharedUserManageCenter].devicePlayList;
    NSMutableArray *arr = [NSMutableArray new];
    
        for (int i = 0; i< zdySongArr.count; i++) {
            locallyMusicModel *model = zdySongArr[i];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:[NSString stringWithFormat:@"%@",model.SN] forKey:@"name"];
            [dic setValue:[NSString stringWithFormat:@"%@",model.FN] forKey:@"aName"];
            [dic setBool:NO forKey:@"selected"];
            arr[i] = dic;
        }

    self.songDevArray = [NSMutableArray arrayWithArray:[[NSMutableArray arrayWithArray:self.songDevArray] arrayByAddingObjectsFromArray:[NSMutableArray arrayWithArray:arr]]];
    
    for (NSString *name in [NSMutableArray arrayWithArray:[self.model[@"Songs"] componentsSeparatedByString:@"|"]]) {
        for (int i = 0; i<self.songDevArray.count; i++) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.songDevArray[i]];

            if ([name isEqualToString:dic[@"aName"]]) {
                [dic setBool:YES forKey: @"selected"];
                [self.musicArray addObject:dic[@"name"]];
                [self.musicListArray addObject:dic[@"aName"]];

            }else{
                if ([dic boolForKey:@"selected"]) {
                    [dic setBool:YES forKey:@"selected"];
                }else{
                    [dic setBool:NO forKey:@"selected"];

                }
            }
            self.songDevArray[i] = dic;
        }
    }


}

-(NSMutableArray *)songDevArray{
    if (!_songDevArray) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:@[@{@"name":LOCSTR(@"叮咚"),@"aName":@"a000000001.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"叮咚叮咚"),@"aName":@"a000000002.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"叮咚您好欢迎光临"),@"aName":@"a000000003.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"叮咚hellowelcome"),@"aName":@"a000000004.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"叮咚恭喜发财"),@"aName":@"a000000005.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"叮咚您好欢迎光临祝您节日快乐"),@"aName":@"a000000006.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"叮咚您好请随手关门"),@"aName":@"a000000007.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"叮咚您好主人主人来客人啦"),@"aName":@"a000000008.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"小主您稍后一下店家马上就来"),@"aName":@"a000000009.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"请小心台阶"),@"aName":@"a000000010.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"上下班请打卡"),@"aName":@"a000000011.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"出入请戴口罩谢谢"),@"aName":@"a000000012.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"公共场合请勿吸烟"),@"aName":@"a000000013.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"您已进入监控区域"),@"aName":@"a000000014.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"欢迎光临，请带好口罩"),@"aName":@"a000000015.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"您好，请带好口罩，出示健康码，谢谢"),@"aName":@"a000000016.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"您好，请带好口罩，出示健康码，测量体温，谢谢"),@"aName":@"a000000017.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"您好，请带好口罩，出示健康码，配合工作人员测量体温，谢谢"),@"aName":@"a000000018.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"您好，请带好口罩，出示健康码，测量体温，配合工作人员登记信息，谢谢"),@"aName":@"a000000019.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"报警声1"),@"aName":@"d000000002.mp3",@"selected":@NO},
                                                                 @{@"name":LOCSTR(@"报警声2"),@"aName":@"d000000003.mp3",@"selected":@NO}]];
        _songDevArray = [NSMutableArray arrayWithArray:array];
    }
    return _songDevArray;
}

-(NSMutableArray *)musicArray{
    if (!_musicArray) {
        _musicArray = [NSMutableArray new];
    }
    return _musicArray;
}
-(NSMutableArray *)musicListArray{
    if (!_musicListArray) {
        _musicListArray = [NSMutableArray new];
    }
    return _musicListArray;
}

@end
