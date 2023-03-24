//
//  DeviceBringMusicVC.m
//  yingbin
//
//  Created by slxk on 2021/5/20.
//  Copyright © 2021 wq. All rights reserved.
//

#import "DeviceBringMusicVC.h"
#import <AVFoundation/AVFoundation.h>

FILE *_fpmy;

@interface DeviceBringMusicVC ()<UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *listArray;
@property (nonatomic, strong)NSMutableArray *songUrlArray;

@property (nonatomic, strong)AVAudioPlayer *avAudioPlayer;

@end

@implementation DeviceBringMusicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"设备自带音乐");
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.listArray[indexPath.row];
    cell.textLabel.font = KFont(14);
    cell.textLabel.numberOfLines = 0;
    
    UILabel *rLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, 40, 20)];
    rLabel.text = LOCSTR(@"试听");
    rLabel.textColor = KColor999999;
    rLabel.font = KFont(13);
    rLabel.textAlignment = NSTextAlignmentRight;
    cell.accessoryView = rLabel;
    return cell;
}
/*
播放音频（通过下载url获取data 写入本地新建的mp3中 在播放）
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [SVProgressHUD show];
    NSString *Url;
    NSString *https = @"https://gz-g-resource-1256872341.cos.ap-guangzhou.myqcloud.com/res/100009964656_56UED5AJ29_USER_250921057949585408_RES_";
    if(indexPath.row == 19){
        Url = [NSString stringWithFormat:@"%@%@_1.0.0",https,@"d000000002.mp3"];

    }else if (indexPath.row == 20){
        Url = [NSString stringWithFormat:@"%@%@_1.0.0",https,@"d000000003.mp3"];

    }else if (indexPath.row>=9 && indexPath.row<19) {
        Url = [NSString stringWithFormat:@"%@%@_1.0.0",https,[NSString stringWithFormat:@"a0000000%ld.mp3",indexPath.row+1]];
    } else{
        Url = [NSString stringWithFormat:@"%@%@_1.0.0",https,[NSString stringWithFormat:@"a00000000%ld.mp3",indexPath.row+1]];
    }
    
    WEAK
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        STRONG
        NSURL *url = [NSURL URLWithString:Url];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        NSString *name;
        if ([Url isEqualToString:@".mp3"]) {
            name = @"ios.mp3";
        }else{
            name = @"ios.wav";
        }
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDirPath , name];
        _fpmy = fopen(filePath.UTF8String, "wb+");
        size_t size = fwrite(data.bytes, 1, data.length, _fpmy);
        NSLog(@"--下载播放data--%zu---",size);
        if (_fpmy) {
            fclose(_fpmy);
            _fpmy = NULL;
        }
        
        self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
        self.avAudioPlayer.delegate = self;
        [self.avAudioPlayer play];
        [SVProgressHUD dismiss];

    });
    
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-k_Height_NavBar) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.showsHorizontalScrollIndicator=NO;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];

    }
    return _tableView;
}



-(NSMutableArray *)listArray{
    if (!_listArray) {
        _listArray = [NSMutableArray arrayWithArray:@[LOCSTR(@"1、叮咚"),LOCSTR(@"2、叮咚叮咚"),LOCSTR(@"3、叮咚您好欢迎光临"),LOCSTR(@"4、叮咚hellowelcome"),LOCSTR(@"5、叮咚恭喜发财"),LOCSTR(@"6、叮咚您好欢迎光临祝您节日快乐"),LOCSTR(@"7、叮咚您好请随手关门"),LOCSTR(@"8、叮咚您好主人主人来客人啦"),LOCSTR(@"9、小主您稍后一下店家马上就来"),LOCSTR(@"10、请小心台阶"),LOCSTR(@"11、上下班请打卡"),LOCSTR(@"12、出入请戴口罩谢谢"),LOCSTR(@"13、公共场合请勿吸烟"),LOCSTR(@"14、您已进入监控区域"),LOCSTR(@"15、欢迎光临，请带好口罩"),LOCSTR(@"16、您好，请带好口罩，出示健康码，谢谢"),LOCSTR(@"17、您好，请带好口罩，出示健康码，测量体温，谢谢"),LOCSTR(@"18、您好，请带好口罩，出示健康码，配合工作人员测量体温，谢谢"),LOCSTR(@"19、您好，请带好口罩，出示健康码，测量体温，配合工作人员登记信息，谢谢"),LOCSTR(@"20、报警声1"),LOCSTR(@"21、报警声2")]];
    }
    return _listArray;
}
-(NSMutableArray *)songUrlArray{
    if (!_songUrlArray) {
        _songUrlArray = [NSMutableArray new];
    }
    return _songUrlArray;
}

-(void)goback{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/ios.mp3"] error:nil];
}
@end
