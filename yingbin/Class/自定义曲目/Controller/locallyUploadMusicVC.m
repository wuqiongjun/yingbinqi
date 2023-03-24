//
//  locallyUploadMusicVC.m
//  yingbin
//
//  Created by slxk on 2021/5/20.
//  Copyright © 2021 wq. All rights reserved.
//

#import "locallyUploadMusicVC.h"
#import "TextToSpeechVC.h"
#import "locallyMusicModel.h"
#import <AVFoundation/AVFoundation.h>
#import "MyDocument.h"
#import "iCloudManager.h"

FILE *_fpp;
#define UbiquityContainerIdentifier @"iCloud.com.qzzn.damon.iosIcloudDemoa"

@interface locallyUploadMusicVC ()<UITableViewDelegate, UITableViewDataSource,AVAudioPlayerDelegate,UIDocumentPickerDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *listArray;

@property (nonatomic, strong)UIButton *textToSpeechBtn;
@property (nonatomic, strong)UIButton *localUploadBtn;

@property (nonatomic, strong)AVAudioPlayer *avAudioPlayer;


@property(strong,nonatomic) NSUbiquitousKeyValueStore  *myKeyValue; //字符串使用
@property(strong,nonatomic) MyDocument  *myDocument;   //icloud数据处理
@property(strong,nonatomic) NSMetadataQuery *myMetadataQuery;//icloud查询需要用这个类
@property(strong,nonatomic) NSURL *myUrl;

@property (nonatomic, strong)DeviceViewModel *model;
@property (nonatomic, strong)NSString *mp3Name;//mp3固定文件名
@property (nonatomic, strong)NSString *songName;//歌曲名称



@end

@implementation locallyUploadMusicVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadDataClick];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"自定义音乐");
    [self.view addSubview:self.tableView];
    
    self.model = [UserManageCenter sharedUserManageCenter].deviceModel;

    [self createSubviews];
    [self iCloudManager];
    
    
}

-(void)refreshUI{
    [self.tableView showDataCount:self.listArray.count Title:LOCSTR(@"暂无数据呦。。。。。。") image:KImage(@"icon_wushuju")];
    [self.tableView reloadData];
}

-(void)iCloudManager{
    self.myKeyValue = [NSUbiquitousKeyValueStore defaultStore];
    //字符串
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(StringChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:self.myKeyValue];
    //文档
    //数据获取完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MetadataQueryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:self.myMetadataQuery];
    //数据更新通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MetadataQueryDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.myMetadataQuery];
    
    //文档
    self.myMetadataQuery = [[NSMetadataQuery alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataClick) name:@"reloadData" object:nil];
}
-(void)reloadDataClick{
    self.listArray = [UserManageCenter sharedUserManageCenter].devicePlayList;
    [self refreshUI];
}
-(void)StringChange:(NSNotification*)noti
{
    NSLog(@"%@",noti.object);
}
//获取成功
-(void)MetadataQueryDidFinishGathering:(NSNotification*)noti{
    NSLog(@"MetadataQueryDidFinishGathering");
    NSArray *items = self.myMetadataQuery.results;//查询结果集
    //便利结果
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMetadataItem*item =obj;
        //获取文件名
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        //获取文件创建日期
        NSDate *date = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        NSLog(@"%@,%@",fileName,date);
        
        //file:///private/var/mobile/Containers/Shared/AppGroup/AA2BACA6-84BC-4918-8499-AD6BD445EDF6/File%20Provider%20Storage/%E7%83%AD%E8%85%BE%E8%85%BE.pdf
        //读取文件内容
        MyDocument *doc =[[MyDocument alloc] initWithFileURL:[self getUbiquityContainerUrl:fileName]];
        [doc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"读取数据成功.");
                NSString *dataText = [[NSString alloc] initWithData:doc.myData encoding:NSUTF8StringEncoding];
                NSLog(@"数据:%@",dataText);
            }else{
                
            }
        }];
    }];
}

//数据有更新
-(void)MetadataQueryDidUpdate:(NSNotification*)noti{
    NSLog(@"icloud数据有更新");
}
//获取url
-(NSURL*)getUbiquityContainerUrl:(NSString*)fileName{
    if (!self.myUrl) {
        self.myUrl = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:UbiquityContainerIdentifier];//URLForUbiquityContainerIdentifier
        if (!self.myUrl) {
            NSLog(@"未开启iCloud功能");
            return nil;
        }

    }
    NSLog(@"--------myUrl:%@",self.myUrl);
    NSURL *url = [self.myUrl URLByAppendingPathComponent:@"Documents"];
    url = [url URLByAppendingPathComponent:fileName];
    
    NSLog(@"--------url= %@",url);
    return url;
}

-(void)importDocumentFromiCloud{
    
    NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
    
    UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    documentPickerViewController.delegate = self;
    [self presentViewController:documentPickerViewController animated:YES completion:nil];
    
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    
    
    NSArray *array = [[url absoluteString] componentsSeparatedByString:@"/"];
    NSString *fileName = [array lastObject];
    fileName = [fileName stringByRemovingPercentEncoding];
    if ([fileName containsString:@"mp3"] || [fileName containsString:@"wav"] || [fileName containsString:@"m4a"]) {
        if ([iCloudManager iCloudEnable]) {
                [iCloudManager downloadWithDocumentURL:url callBack:^(id obj) {
                    NSData *data = obj;

                    //写入沙盒Documents
                     NSString *path = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",fileName]];
                    [data writeToFile:path atomically:YES];
                    
                    [SVProgressHUD show];
                    //赋值
                    self.songName = fileName;
                    self.mp3Name = [NSString stringWithFormat:@"zd%@.mp3",[MethodTool getNowTimeTimestamp]];
                    [self p_setupFileRename:path];
                }];
            }
    }else{
        [MBProgressHUD showMessage:LOCSTR(@"不支持当前选择的音频文件") icon:@""];
    }
    
    
    
    
    
    NSLog(@"url,fileName:::%@/%@",url,fileName);
   
    
}

/**
 获取Url
 */
- (void)p_setupFileRename:(NSString *)filePath{
    WEAK
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
        unsigned long long fileSize = [attributes fileSize]; // in bytes
        
        NSDictionary *tmpDic = @{
            @"ProductId":self.model.ProductId?:@"",
            @"UserResourceName":self.mp3Name,
            @"RequestId":[[NSUUID UUID] UUIDString],
            @"ResourceVer":@"1.0.0",
            @"FileSize":@(fileSize),
        };
        [[TIoTCoreRequestObject shared] post:@"AppGetResourceUploadURL" Param:tmpDic success:^(id responseObject) {
            STRONG
            /*
            {"code":0,"msg":"","data":
                {"RequestId":"97DEBBD5-0747-4594-828D-6EBA0E335215",
                "ResourceName":"USER_249555369632731136_RES_dev0001",
                "UploadUrl":"https://gz-g-resource-1256872341.cos.ap-guangzhou.myqcloud.com/res%2F100009964656_56UED5AJ29_USER_249555369632731136_RES_dev0001_1.0.0?sign=q-sign-algorithm%3Dsha1%26q-ak%3DAKIDMUM9hdmn35rHZe72Y6UfliNo1PYQFZln%26q-sign-time%3D1622269872%3B1622273472%26q-key-time%3D1622269872%3B1622273472%26q-header-list%3D%26q-url-param-list%3D%26q-signature%3Ddc98d9f6968af6fdadd001fd4268f4f10da83fab"}
            }
            */
            [self uploadFileUploadUrl:responseObject[@"UploadUrl"] FilePath:filePath];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [SVProgressHUD dismiss];
            [MBProgressHUD showError:reason];
            [MethodTool judgeUserSignoutWithReturnToken:dic];

        }];

}

/*
   2.文件上传(put方式)
 */
- (void)uploadFileUploadUrl:(NSString *)url FilePath:(NSString *)filePath{
    WEAK
    //1.创建url对象
    NSURL *nsUrl = [NSURL URLWithString:url];
    
    //2.创建request对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsUrl cachePolicy:0 timeoutInterval:2.0f];
    //设置为put方式
    request.HTTPMethod = @"PUT";
    
    //4.设置授权
    //创建账号NSData
    NSData *accountData = [@"yyh:123456" dataUsingEncoding:NSUTF8StringEncoding];
    //对NSData进行base64编码
    NSString *accountStr = [accountData base64EncodedStringWithOptions:0];
    //生成授权字符串
    NSString *authStr = [NSString stringWithFormat:@"BASIC %@", accountStr];
    //增加授权头字段
    [request setValue:authStr forHTTPHeaderField:@"Authorization"];
    
    //5.获取本地文件
    NSURL *file = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",self.songName]]];

    //6.创建上传任务
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromFile:file completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        STRONG
        NSLog(@"-----%@----%@----%@--",data,response,error);
        if (!error) {
            [self AppCreateProductResourceFilePath:filePath];
        }else{
            [SVProgressHUD dismiss];
        }
    }];
    
    //7.执行上传
    [uploadTask resume];
}

/*
   3.创建登记资源
 */
-(void)AppCreateProductResourceFilePath:(NSString *)filePath{
    WEAK
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
    unsigned long long fileSize = [attributes fileSize];
    NSString *fileHash = [MethodTool computeHashForFile:[NSURL fileURLWithPath:filePath]];
     NSDictionary *tmpDic = @{
         @"ProductId":self.model.ProductId?:@"",
         @"UserResourceName":self.mp3Name,
         @"RequestId":[[NSUUID UUID] UUIDString],
         @"ResourceVer":@"1.0.0",
         @"FileSize":@(fileSize),
         @"ResourceType":@"FILE",
         @"ReadProtect":@(1),
         @"FileHash":fileHash,
     };
     [[TIoTCoreRequestObject shared] post:@"AppCreateProductResource" Param:tmpDic success:^(id responseObject) {
         STRONG
         [self AppControlDeviceData];
//        {"RequestId":"76942558-2DB4-4AD4-A309-E06341B82ADD","ResourceName":"USER_250921057949585408_RES_zd1622785812.mp3"}
     } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
         [MBProgressHUD showError:reason];
         [SVProgressHUD dismiss];
         [MethodTool judgeUserSignoutWithReturnToken:dic];
     }];
}


/*
  4.上传音频

 */
-(void)AppControlDeviceData{
    
    NSMutableDictionary *playDic = [NSMutableDictionary new];
    NSMutableArray *playList = [UserManageCenter sharedUserManageCenter].devicePlayList;
    NSMutableArray *newArr = [NSMutableArray new];
    
    locallyMusicModel *model = [locallyMusicModel new];
    /*
     FN(文件名称) ： fileName
     SN(歌曲名称)： songName
     */
    model.SN = self.songName;
    model.FN = self.mp3Name;

    [playList addObject:model];
    for (locallyMusicModel *modeL in playList) {
        [newArr addObject:[MethodTool dicFromObject:modeL]];
    }
    [playDic setValue:newArr forKey:@"PlayList"];

    
    NSDictionary *tmpDic = @{
        @"ProductId":self.model.ProductId?:@"",
        @"DeviceName":self.model.DeviceName?:@"",
        @"Data":[NSString objectToJson:playDic]?:@""};
//    WEAK
    [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
//        STRONG
        [UserManageCenter sharedUserManageCenter].devicePlayList = playList;
        [MBProgressHUD showMessage:LOCSTR(@"保存成功") icon:@""];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];

    }];
    [SVProgressHUD dismiss];

}
//---------------------------------------------
-(void)createSubviews{
    WEAK
    self.textToSpeechBtn = self.view
    .addButton(14)
    .backgroundColor(KThemeColor)
    .title(LOCSTR(@"文字转语音"))
    .cornerRadius(5)
    .titleFont(KPingFangFont(15))
    .titleColor(UIColor.whiteColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
        TextToSpeechVC *vc = [[TextToSpeechVC alloc] init];
        PushVC(vc);
        
    })
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.view).mas_offset(-k_Height_SafetyArea-10);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(40);
    })
    .view;
    self.localUploadBtn = self.view
    .addButton(14)
    .backgroundColor(KThemeColor)
    .title(LOCSTR(@"本地音乐上传"))
    .cornerRadius(5)
    .titleFont(KPingFangFont(15))
    .titleColor(UIColor.whiteColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
        //设置搜索文档
        [self.myMetadataQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
        [self.myMetadataQuery startQuery];

        [self importDocumentFromiCloud];
        
//        LocalUploadVC *vc = [LocalUploadVC new];
//        PushVC(vc);
        
    })
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.textToSpeechBtn.mas_top).mas_offset(-10);
        make.left.right.mas_equalTo(self.textToSpeechBtn);
        make.height.mas_equalTo(40);
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    locallyMusicModel *model = self.listArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld、%@",indexPath.row+1,model.SN];
    cell.textLabel.font = KFont(14);
    
    UILabel *rLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, 40, 20)];
    rLabel.text = LOCSTR(@"试听");
    rLabel.textColor = KColor999999;
    rLabel.font = KFont(13);
    cell.accessoryView = rLabel;
    return cell;
}
//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
       5.获取下载资源
     */
    locallyMusicModel *model = self.listArray[indexPath.row];

    WEAK
    NSDictionary *tmpDic = @{
        @"UserResourceName":model.FN,
        @"RequestId":[[NSUUID UUID] UUIDString],
        @"ResourceVer":@"1.0.0",
        @"ProductId":[UserManageCenter sharedUserManageCenter].deviceModel.ProductId?:@"",
    };
    [SVProgressHUD show];
    [[TIoTCoreRequestObject shared] post:@"AppGetResourceDownloadUrl" Param:tmpDic success:^(id responseObject) {
        STRONG
        NSLog(@"----获取下载资源----%@",responseObject);
        //            {"DownloadUrl":"https://gz-g-resource-1256872341.cos.ap-guangzhou.myqcloud.com/res/100009964656_56UED5AJ29_USER_250921057949585408_RES_zd1622794571.mp3_1.0.0","RequestId":"2E53FADD-E2AC-44BA-90C2-766426DCE897"}
        [self getDownloadUrl:responseObject[@"DownloadUrl"]];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [SVProgressHUD dismiss];
        [MethodTool judgeUserSignoutWithReturnToken:dic];

    }];
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
    
    WEAK
    
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:LOCSTR(@"删除") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {        
        
        [TLUIUtility showAlertWithTitle:LOCSTR(@"提示") message:LOCSTR(@"确定要删除音乐吗？") cancelButtonTitle:LOCSTR(@"取消") otherButtonTitles:@[@"确定"] actionHandler:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                STRONG
                
                //判断自定义曲目可删不（存在感应播放、仅播放、广告播放中的定时Songs 不允许删除）
                locallyMusicModel *mode = [UserManageCenter sharedUserManageCenter].devicePlayList[indexPath.row];
                NSString *snStr = [NSString new];
                for (NSMutableDictionary *asense in [UserManageCenter sharedUserManageCenter].ASenseList) {
                    snStr = [NSString stringWithFormat:@"%@|%@",snStr,asense[@"Songs"]];
                }
                for (NSMutableDictionary *Psense in [UserManageCenter sharedUserManageCenter].PSenseList) {
                    snStr = [NSString stringWithFormat:@"%@|%@",snStr,Psense[@"Songs"]];
                }
                for (NSMutableDictionary *dapssense in [UserManageCenter sharedUserManageCenter].DAPSenseList) {
                    snStr = [NSString stringWithFormat:@"%@|%@",snStr,dapssense[@"Songs"]];
                }
                
                if ([[snStr componentsSeparatedByString:@"|"] containsObject:mode.FN])
                {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCSTR(@"提示") message:LOCSTR(@"曲目已经在播放设置中使用，如需删除，请先从播放设置中删除该曲目") preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"确定") style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alertController animated:true completion:nil];
                }else
                {
                    NSMutableDictionary *playDic = [NSMutableDictionary new];
                    [self.listArray removeObjectAtIndex:indexPath.row];

                    NSMutableArray *newArr = [NSMutableArray new];
                    
                    for (locallyMusicModel *modeL in self.listArray) {
                        [newArr addObject:[MethodTool dicFromObject:modeL]];
                    }
                    [playDic setValue:newArr forKey:@"PlayList"];

                    
                    NSDictionary *tmpDic = @{
                        @"ProductId":[UserManageCenter sharedUserManageCenter].deviceModel.ProductId?:@"",
                        @"DeviceName":[UserManageCenter sharedUserManageCenter].deviceModel.DeviceName?:@"",
                        @"Data":[NSString objectToJson:playDic]?:@""};
                    
                    [SVProgressHUD show];
                    [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
                        [MBProgressHUD showMessage:LOCSTR(@"删除成功") icon:@""];
//                        NSMutableArray *arr = [UserManageCenter sharedUserManageCenter].devicePlayList;
//                        [[UserManageCenter sharedUserManageCenter].devicePlayList removeObjectAtIndex:indexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexPath.row inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
                        [UIView performWithoutAnimation:^{
                            [self.tableView reloadData];
                        }];
                        if (self.listArray.count<=0) {
                            [self refreshUI];
                        }
                        
                    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                        [MBProgressHUD showError:reason];
                        [MethodTool judgeUserSignoutWithReturnToken:dic];

                    }];
                    [SVProgressHUD dismiss];
                }

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
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-k_Height_NavBar-k_Height_SafetyArea-95) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.showsHorizontalScrollIndicator=NO;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];

    }
    return _tableView;
}
/*
 播放音频（通过下载url获取data 写入本地新建的mp3中 在播放）
 */
-(void)getDownloadUrl:(NSString *)Url{
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
        _fpp = fopen(filePath.UTF8String, "wb+");
        size_t size = fwrite(data.bytes, 1, data.length, _fpp);
        NSLog(@"--下载播放data--%zu---",size);
        if (_fpp) {
            fclose(_fpp);
            _fpp = NULL;
        }
        
        self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
        self.avAudioPlayer.delegate = self;
        [self.avAudioPlayer play];
        [SVProgressHUD dismiss];
    });
}



-(void)goback{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",self.songName]] error:nil];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
