//
//  QuMuViewController.m
//  yingbin
//
//  Created by slxk on 2021/5/21.
//  Copyright © 2021 wq. All rights reserved.
//

#import "QuMuViewController.h"
#import "QuMuViewCell.h"
#import "locallyMusicModel.h"


@interface QuMuViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, assign)NSInteger integer;

@end

@implementation QuMuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"曲目选择");
    [self.view addSubview:self.tableView];

    for (NSMutableDictionary *dic in self.songDevArray) {
        if ([dic boolForKey:@"selected"]) {
            self.integer ++;
        }
        
    }
}

#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 21;

    }else{
        return self.songDevArray.count-21;

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAK
    QuMuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QuMuViewCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectMusicSuccess = ^(UIButton * _Nonnull btn) {
        STRONG
        if (btn.selected) {
            if (self.integer > 4) {
                [MBProgressHUD showMessage:LOCSTR(@"最多选择5首歌曲") icon:@""];
                btn.selected = NO;
                [self.tableView reloadData];
                return;
            }else{
                self.integer ++;
            }
        }else{
            self.integer --;
        }
        //曲目选择
        if (indexPath.section == 0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.songDevArray[indexPath.row]];
            [dic setBool:btn.selected forKey:@"selected"];
            [self.songDevArray replaceObjectAtIndex:indexPath.row withObject:dic];
        }else{
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.songDevArray[indexPath.row+21]];
            [dic addEntriesFromDictionary:@{@"selected":@(btn.selected)}];
            [self.songDevArray replaceObjectAtIndex:indexPath.row+21 withObject:dic];
        }
    };
    cell.integer = indexPath.row+1;

    if (indexPath.section == 0) {
        cell.quMuDic = self.songDevArray[indexPath.row];
    }else{
        cell.quMuDic = self.songDevArray[indexPath.row+21];
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 150, 20)];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = KColor333333;
    if (section == 0) {
        label.text = LOCSTR(@"设备自带曲目");
    }else{
        label.text = LOCSTR(@"自定义曲目");
    }

    [view addSubview:label];

    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-k_Height_NavBar-k_Height_SafetyArea) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.showsHorizontalScrollIndicator=NO;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView registerClass:[QuMuViewCell class] forCellReuseIdentifier:NSStringFromClass([QuMuViewCell class])];

    }
    return _tableView;
}


//返回保存
-(void)goback{
    if (self.selectMusic) {
        self.selectMusic(self.songDevArray);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSMutableArray *)songDevArray{
    if (!_songDevArray) {
        _songDevArray = [NSMutableArray new];
    }
    return _songDevArray;
}



@end
