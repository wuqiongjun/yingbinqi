//
//  WoDeViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "WoDeViewController.h"
#import "TIoTCoreUserManage.h"
#import <UIImageView+WebCache.h>
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <QCloudCore/QCloudCore.h>
#import "ResetPwdViewController.h"
#import "MessagesShareVC.h"
#import "AboutViewController.h"



@interface WoDeViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,QCloudSignatureProvider>

@property (nonatomic, strong)UIView *bgview;

@property (nonatomic, strong)UILabel *nickName;
@property (nonatomic, strong)UIImageView *avatar;

@property (strong, nonatomic) UIImagePickerController *picker;
@property (nonatomic, copy) NSDictionary *signatureInfo;

@end

@implementation WoDeViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    WEAK
    [[TIoTCoreAccountSet shared] getUserInfoOnSuccess:^(id  _Nonnull responseObject) {
        STRONG
        self.nickName.text = [TIoTCoreUserManage shared].nickName;
        [self.avatar sd_setImageWithURL:[NSURL URLWithString:[TIoTCoreUserManage shared].avatar] placeholderImage:[UIImage imageNamed:@"icon_morentouxiang"]];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LOCSTR(@"我的");
    
    
    [self createSubviews];
    [self setTableViewSubviews];
}

-(void)createSubviews{
    UIView *bgview = [[UIView alloc]initWithFrame:CGRectMake(0, kNavBarHeight, KScreenW, 120)];
    bgview.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:bgview];
    self.bgview = bgview;
    
    UIView *avatarView = bgview
    .addView(0)
    .backgroundColor(RGBAColor(0, 0, 0, 0.04))
    .masonry(^(MASConstraintMaker *make){
        make.centerY.mas_equalTo(bgview.mas_centerY);
        make.left.mas_equalTo(17);
        make.size.mas_equalTo(60);
    })
    .view;
    avatarView.layer.cornerRadius = 30;

    
    self.avatar = bgview
    .addImageView(1)
    .image(KImage(@"icon_morentouxiang"))
    .userInteractionEnabled(YES)
    .cornerRadius(25)
    .contentMode(UIViewContentModeScaleAspectFill)
    .masonry(^(MASConstraintMaker *make){
        make.centerY.mas_equalTo(bgview.mas_centerY);
        make.left.mas_equalTo(22);
        make.size.mas_equalTo(50);
    })
    .view;
    
    
    UITapGestureRecognizer *tapimage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.avatar addGestureRecognizer:tapimage];
    
    self.nickName = bgview
    .addLabel(0)
    .font(KBFont(22))
    .textColor(KColor333333)
    .userInteractionEnabled(YES)
    .masonry(^(MASConstraintMaker *make){
        make.centerY.mas_equalTo(self.avatar);
        make.left.mas_equalTo(self.avatar.mas_right).offset(20);
        make.right.mas_lessThanOrEqualTo(-50);
    })
    .view;
    
    UITapGestureRecognizer *tapnickName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNickNameAction)];
    [self.nickName addGestureRecognizer:tapnickName];
    
    UIImageView *image = bgview
    .addImageView(2)
    .image(KImage(@"icon_edit"))
    .userInteractionEnabled(YES)
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.nickName.mas_bottom);
        make.left.mas_equalTo(self.nickName.mas_right).mas_offset(5);
        make.size.mas_equalTo(10);
    })
    .view;
    UITapGestureRecognizer *tapedit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNickNameAction)];
    [image addGestureRecognizer:tapedit];
    

}
/*
{
    cosConfig =     {
        bucket = "iotexplore-app-1256872341";
        path = "iotexplorer-app-logs/user_275580576679858176/";
        region = "ap-guangzhou";
    };
    credentials =     {
        expiration = "2021-07-13T03:03:40Z";
        expiredTime = 1626145420;
        sessionToken = "EcBY4KbG7sFGmqn2RJFnC5rzaDe8phBa60327403d702cf202c936567c96d328e0vEET3ROzbxVNItDhEWwC26I0ptLdudm5qJx3K5IOsugINI7sl25pfXnfuJTLHv6EGPI1z4o2t43Wa9AkB-5yL8dzcrqk9r_rB3HvJN-ksTAdp3WeoglKjEABPgvNFQwNz_S-bNicyHs59nZe023_CNixcndVQJhR28XkFSyvGF2F38uJbZ6d4MwyFikLlkmG_A76o8yuQkQJoImYgahQqbYSi89eF1qEFxzL7ZimQOtefDIJOp78R5w7ufEiwsVowKYy1g9PAsCtC9CqUHICBqTZmGCdM0q4Ttha5MJUhUgFsWBhVaCYE3P9rDAV6D-Aa82KqRHyqW2WnQAI_UiNy4128eJURZz78KLjN-QxGOjHP0t0nQw7KERTZYivQsS65FMFFHWp6wqQrC1HVE4sMQgGhkexvy4lQVeGeK_Sq47A4tlZ9y9yA4WJXvg44BGS-XZcew6TI7Ke6AVotT3sIMExTCa9vspBJUSvOJ3l6qulDvetrkISv6GKcZZUrVy0-kN-XW-vHy_Rr6wmRlCuEQNWQ0ymQXI_TK73C-e-adwW0KvPX4YRyMzHoEMeN461a7wofxgQOds7lIX6aG8kcXcL2QkluQrU8MuAxA7BlISaY_espxRGXE-l596gBFBk5R-dofwlqg_velnDv9qGwPxnEClvBfCVxK3wYQjSrdB5ecglbWQ37WR5J7jcWXPIQ41Woxn_WccipM39IvUVEAXo8N-QLTqCnU9SzIAcXOj3rnYR7d0sdb4YZu78M-J17H2fiHoaL_3ZEPK7_KJ7sQETCbZGpIoBgRsq7b3xNSQYKugyNRGfjeT--znX35-WO-vHLMhpNeOD4acO3wnJiXMiH6QMRi0d_BICkGQw-7_InWWFkH1sWLg016YmDLd";
        startTime = 1626140020;
        tmpSecretId = "AKIDVkBX79sbm--hY5nxSxq0Bzx95ZFN5aS_MQoK6nU8H90yeXtpv56E6sYzrDbhWH-C";
        tmpSecretKey = "n3KdbH/y/OHggrQgr6WnZZzxT+IOgZKI9n97mKP1bes=";
    };
    expiration = "2021-07-13T03:03:40Z";
    expiredTime = 1626145420;
    requestId = "3afffeac-b0b8-4b67-982c-b7ee03f8aeb9";
    startTime = 1626140020;
}
 */
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
//    获取图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    picker.allowsEditing = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    WEAK
    [[TIoTCoreAccountSet shared] getUploadInfoOnSuccess:^(id  _Nonnull responseObject) {
        STRONG
        self.signatureInfo = responseObject;
        
        NSString *region = responseObject[@"cosConfig"][@"region"];
        NSString *bucket = responseObject[@"cosConfig"][@"bucket"];
        NSString *path = responseObject[@"cosConfig"][@"path"];
        
        [self configWithRegion:region bucket:bucket path:path];
        QCloudCOSXMLUploadObjectRequest *request = [self getRequestObject:image bucket:bucket];
        
        [request setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                STRONG
                if (error) {
                    [MBProgressHUD showError:LOCSTR(@"上传失败") toView:self.view];
                }
                else
                {
                    [MBProgressHUD dismissInView:self.view];
                    self.avatar.image = image;
                    
                    [[TIoTCoreAccountSet shared] updateUserWithNickName:@"" avatar:result.location success:^(id  _Nonnull responseObject) {
                        [MBProgressHUD showSuccess:LOCSTR(@"修改成功")];
                    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                        
                    }];
                    
                }
            });
            
        }];
        
        [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:request];
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
}

//按取消按钮时候的功能
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    返回
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 上传头像

- (UIImagePickerController *)picker
{
    if (!_picker) {
        _picker = [[UIImagePickerController alloc]init];
        _picker.delegate = self;
        _picker.allowsEditing = YES;
    }
    return _picker;
}
//点击头像
-(void)tapAction{
    WEAK
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCSTR(@"设置头像") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:LOCSTR(@"拍照") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONG
        [self openSystemPhotoOrCamara:YES];
    }];
    
    UIAlertAction *photo = [UIAlertAction actionWithTitle:LOCSTR(@"从手机相册选择") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONG
        [self openSystemPhotoOrCamara:NO];
    }];
    
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:LOCSTR( @"取消") style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:camera];
    [alert addAction:photo];
    [alert addAction:cancle];
    [self presentViewController:alert animated:YES completion:nil];
}
//打开系统相册
- (void)openSystemPhotoOrCamara:(BOOL)isCamara{
    if (isCamara) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else{
            [MBProgressHUD showError:NSLocalizedString(@"camera_openFailure", @"相机打开失败")];
            return;
        }
    }
    else{
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    [self presentViewController:self.picker animated:YES completion:nil];
}

- (void)configWithRegion:(NSString *)regionName bucket:(NSString *)bucket path:(NSString *)path{
    NSArray *array = [bucket componentsSeparatedByString:@"-"];
    
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = [array lastObject];
    configuration.signatureProvider = self;
    
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = regionName;//服务地域名称，可用的地域请参考注释
    endpoint.serviceName = [NSString stringWithFormat:@"%@/%@",endpoint.serviceName,path];
    endpoint.useHTTPS = YES;
    configuration.endpoint = endpoint;
    
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
}

- (QCloudCOSXMLUploadObjectRequest *)getRequestObject:(UIImage *)image bucket:(NSString *)bucket {
    NSString* tempPath = QCloudTempFilePathWithExtension(@"jpg");
    
    [UIImageJPEGRepresentation(image, 0.3) writeToFile:tempPath atomically:YES];

    QCloudCOSXMLUploadObjectRequest* upload = [QCloudCOSXMLUploadObjectRequest new];
    
    upload.body = [NSURL fileURLWithPath:tempPath];
    upload.bucket = bucket;
    upload.object = [NSUUID UUID].UUIDString;
    
    [upload setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {

    }];
    
    return upload;
}
//QCloudSignatureProvider
- (void)signatureWithFields:(QCloudSignatureFields*)fileds request:(QCloudBizHTTPRequest*)request urlRequest:(NSURLRequest*)urlRequst compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock{
    //实现签名的过程，我们推荐在服务器端实现签名的过程，具体请参考接下来的 “生成签名” 这一章。
    
    NSTimeInterval timeInterval=[self.signatureInfo[@"credentials"][@"startTime"] doubleValue];

    NSDate *UTCDate=[NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = self.signatureInfo[@"credentials"][@"tmpSecretId"];
    credential.secretKey = self.signatureInfo[@"credentials"][@"tmpSecretKey"];
    credential.token = self.signatureInfo[@"credentials"][@"sessionToken"];
    credential.startDate = UTCDate;
    credential.experationDate = [NSDate dateWithTimeIntervalSince1970:[self.signatureInfo[@"credentials"][@"expiredTime"] doubleValue]];
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    QCloudSignature* signature = [creator signatureForData:(NSMutableURLRequest *)urlRequst];
    continueBlock(signature, nil);
}


#pragma mark - UItableView

-(void)setTableViewSubviews{
    WEAK
    UIView *bgoneView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(self.bgview.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, 162-54));
    })
    .view;
    bgoneView.layer.cornerRadius = 9;
    [self.view sendSubviewToBack:bgoneView];
    
    UIView *bgtwoView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(bgoneView.mas_bottom).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, 216-54));
    })
    .view;
    bgtwoView.layer.cornerRadius = 9;
    [self.view sendSubviewToBack:bgtwoView];
    

    
    NSMutableArray *dateOneArray = [NSMutableArray array];
//    [dateOneArray addObject:@{titleKey   : LOCSTR(@"绑定报警号码"),
//                           imgNameKey : @"icon_wode_1",
//                           selectType  : @(0)
//                           }];
    [dateOneArray addObject:@{titleKey   : LOCSTR(@"消息通知"),
                           imgNameKey : @"icon_wode_8",
                           selectType  : @(0)
    }];
    [dateOneArray addObject:@{titleKey   : LOCSTR(@"修改密码"),
                          imgNameKey : @"icon_wode_2",
                          selectType  : @(1)
    }];
//    [dateOneArray addObject:@{titleKey   : LOCSTR(@"帮助"),
//                           imgNameKey : @"icon_wode_3",
//                           selectType  : @(2)
//                           }];
    NSMutableArray *array = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:dateOneArray] mutableCopy];
    self.collectionView.scrollEnabled = NO;
    self.addSection(0).sectionInsets(UIEdgeInsetsMake(120+kNavBarHeight, 0, 0, 0));
    self.addCells(@"WodeViewCell")
    .toSection(0).withDataModelArray(array)
    .selectedAction(^(BaseGeneralModel *model){
        STRONG
        NSUInteger typeUI = [model.type unsignedIntegerValue];
        switch (typeUI) {
            case 0:
            {
                //分享过来的列表
                    MessagesShareVC *vc = [MessagesShareVC new];
                    PushVC(vc);
            }
                break;
            case 1:
            {//修改密码
                ResetPwdViewController *vc = [[ResetPwdViewController alloc]init];
                LoginViewModel *viewModel = [LoginViewModel new];
                vc.viewModel = viewModel;
                PushVC(vc);
            }
                break;
            case 2:
            {//帮助
                
                
            }
                break;
                
            default:
                break;
        }
    });
    
    NSMutableArray *dateTwoArray = [NSMutableArray array];
    [dateTwoArray addObject:@{titleKey   : LOCSTR(@"关于"),
                           imgNameKey : @"icon_wode_4",
                           selectType  : @(3)
                           }];
    [dateTwoArray addObject:@{titleKey   : LOCSTR(@"软件版本"),
                          imgNameKey : @"icon_wode_5",
                          selectType  : @(4)
    }];
//    [dateTwoArray addObject:@{titleKey   : LOCSTR(@"兼容模式升级"),
//                           imgNameKey : @"icon_wode_6",
//                           selectType  : @(5)
//                           }];
    
    [dateTwoArray addObject:@{titleKey   : LOCSTR(@"退出当前账号"),
                           imgNameKey : @"icon_wode_7",
                           selectType  : @(6)
                           }];
    NSMutableArray *arrayTwo = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:dateTwoArray] mutableCopy];
    self.addSection(1).sectionInsets(UIEdgeInsetsMake(10, 0, 0, 0));
    self.addCells(@"WodeViewCell")
    .toSection(1).withDataModelArray(arrayTwo)
    .selectedAction(^(BaseGeneralModel *model){
        STRONG
        NSUInteger typeUI = [model.type unsignedIntegerValue];
        switch (typeUI) {
            case 3:
            {//关于
                AboutViewController *vc = [AboutViewController new];
                PushVC(vc);
            }
                break;
            case 4:
            {//软件版本
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://apps.apple.com/cn/app/id1576645856"] options:@{} completionHandler:^(BOOL success) {
                                    
                }];
            }
                break;
            case 5:
            {//兼容模式升级
         
            }
                break;
            case 6:
            {//退出当前账号
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCSTR(@"提示") message:LOCSTR(@"您确定退出当前账号吗？") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *a = [UIAlertAction actionWithTitle:LOCSTR(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
                
                UIAlertAction *b = [UIAlertAction actionWithTitle:LOCSTR(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [[TIoTCoreAccountSet shared] signOutOnSuccess:^(id  _Nonnull responseObject) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [TLNotificationCenter postNotificationName:LoginSuccessNotify object:nil];
                        });

                    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                        [MBProgressHUD showError:reason];
                        [MethodTool judgeUserSignoutWithReturnToken:dic];

                    }];
                }];
                
                [alert addAction:a];
                [alert addAction:b];
                [self presentViewController:alert animated:YES completion:nil];
                
                
            }
                break;
            case 7:
            {//分享过来的列表
                MessagesShareVC *vc = [MessagesShareVC new];
                PushVC(vc);
            }
                break;
            default:
                break;
        }
    });
    

}
#pragma mark - req
//修改昵称
-(void)tapNickNameAction{
    WEAK
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCSTR(@"修改昵称") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"取消") style:UIAlertActionStyleDefault handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                STRONG
                UITextField *TextField = alertController.textFields.firstObject;
                
                NSString *nickNameStr = TextField.text;
                if ([NSString isNullOrNilWithObject:nickNameStr] || [NSString isFullSpaceEmpty:nickNameStr]) {
                    [MBProgressHUD showMessage:LOCSTR(@"请输入昵称") icon:@""];
                }else {

                    if (nickNameStr.length >20) {
                        [MBProgressHUD showError:LOCSTR(@"昵称不能超过20个字符")];
                    }else {
                        if (![nickNameStr isEqualToString:[TIoTCoreUserManage shared].nickName]) {
                            [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
                            
                            [[TIoTCoreRequestObject shared] post:AppUpdateUser Param:@{@"NickName":nickNameStr,@"Avatar":[TIoTCoreUserManage shared].avatar} success:^(id responseObject) {
                                STRONG
                                [MBProgressHUD showSuccess:LOCSTR(@"修改成功")];
                                [[TIoTCoreUserManage shared] saveUserInfo:@{@"UserID":[TIoTCoreUserManage shared].userId,@"Avatar":[TIoTCoreUserManage shared].avatar,@"NickName":nickNameStr,@"PhoneNumber":[TIoTCoreUserManage shared].phoneNumber}];
                                self.nickName.text = [TIoTCoreUserManage shared].nickName;
                                [self reloadView];
                            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                                [MBProgressHUD showError:reason];
                            }];
                        }else{
                            [MBProgressHUD showMessage:LOCSTR(@"与原昵称相同") icon:@""];
                        }
                    }
                }

            }]];

            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = LOCSTR(@"请输入昵称");
                textField.text = [TIoTCoreUserManage shared].nickName;
            }];

            [self presentViewController:alertController animated:true completion:nil];
}

@end
