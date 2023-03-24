//
//  TextToSpeechVC.m
//  yingbin
//
//  Created by slxk on 2021/5/20.
//  Copyright © 2021 wq. All rights reserved.
//

#import "TextToSpeechVC.h"
#import "BDSSpeechSynthesizer.h"
#import <AVFoundation/AVFoundation.h>
#include <CommonCrypto/CommonDigest.h>
#import "locallyMusicModel.h"
// 请在官网新建app，配置bundleId，并在此填写相关参数
//NSString* API_KEY = @"Lg9pS1fXYYvsPeOopGBMQ4x6";
//NSString* SECRET_KEY = @"1ytRMvtklzaBSN9uYxghm8W7o9ryoLXO";
NSString* API_KEY = @"VB42D8FlY24u5gYuBgqK4hvY";
NSString* SECRET_KEY = @"dGDReLU2ttNCttPbvtmRYBpAvCB5KG7H";
FILE *_fp;

@interface TextToSpeechVC ()<UITextViewDelegate,BDSSpeechSynthesizerDelegate>

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong)UIButton *girlBtn;
@property (nonatomic, strong)UIButton *manBtn;
@property (nonatomic, strong)UIButton *manCBtn;
@property (nonatomic, strong)UIButton *boyBtn;

@property (nonatomic, strong) UISlider *volumeSlider;//音量
@property (nonatomic, strong) UISlider *rateSlider;//语速
@property (nonatomic, strong) UISlider *toneSlider;//音调

@property (nonatomic, strong)UIButton *auditionBtn;//试听
@property (nonatomic, strong)UIButton *addBtn;//添加


@property (nonatomic,assign)float rate;   //语速

@property (nonatomic,assign)float volume; //音量

@property (nonatomic,assign)float pitchMultiplier;  //音调
@property (nonatomic,strong)NSMutableArray* synthesisTexts;


@property (nonatomic, assign)NSInteger endID;
@property (nonatomic, strong)NSString *songName;//歌曲名称
@property (nonatomic, strong)NSString *moveToPath;//重命名成功后的地址
@property (nonatomic, assign)BOOL isPlaySong;//是否点击试听
@property (nonatomic, strong)NSString *mp3Name;//mp3固定文件名
@property (nonatomic, strong)DeviceViewModel *model;

//上一次数据
@property (nonatomic, strong)NSString *STextView;
@property (nonatomic,assign)float SRate;
@property (nonatomic,assign)float SVolume;
@property (nonatomic,assign)float SPitchMultiplier;
@property (nonatomic, assign)NSInteger sInt;


@end

@implementation TextToSpeechVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"文字转语音");
//    [self.view addSubview:self.scrollView];
    self.model = [UserManageCenter sharedUserManageCenter].deviceModel;

    self.rate = 5;
    self.volume = 5;
    self.pitchMultiplier = 5;
    
    [self createSubviews];
    [self configureSDK];
    
    
    

}

-(void)createSubviews{
    
    WEAK
//内容
    UIView *bgOneView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(KScreenW-30, 160));
    })
    .view;
    bgOneView.layer.cornerRadius = 9;
    
    UILabel *titleLabel = bgOneView
    .addLabel(0)
    .text(LOCSTR(@"语音内容"))
    .font(KFont(14))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    })
    .view;
    
    self.textView = bgOneView
    .addTextView(0)
    .font(KFont(14))
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(titleLabel.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(KScreenW-30-30, 100));
    })
    .view;
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor = KColor999999.CGColor;
    
//声音选择
    UIView *bgThreeView = self.view
    .addView(1)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(bgOneView.mas_bottom).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(KScreenW-30, 120));
    })
    .view;
    bgThreeView.layer.cornerRadius = 9;
    
    UILabel *titleThreeLabel = bgThreeView
    .addLabel(0)
    .text(LOCSTR(@"声音选择"))
    .font(KFont(14))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    })
    .view;
    
    self.girlBtn = bgThreeView
    .addButton(12)
    .image(KImage(@"icon_wxz"))
    .imageSelected(KImage(@"icon_xz"))
    .title(LOCSTR(@"标准女声"))
    .titleFont(KPingFangFont(14))
    .titleColor(KColor666666)
    .selected(YES)
    .contentHorizontalAlignment(UIControlContentHorizontalAlignmentLeft)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        x.selected = !x.selected;
        if (x.selected) {
            self.manBtn.selected = NO;
            self.manCBtn.selected = NO;
            self.boyBtn.selected = NO;
        }else{
            if (self.manBtn.selected== NO && self.manCBtn.selected == NO && self.boyBtn.selected == NO) {
                x.selected = !x.selected;
            }
        }
    })
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(titleThreeLabel.mas_bottom);
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake((KScreenW-30-30)/2, 40));
    })
    .view;
    [self.girlBtn layoutButtonWithImageStyle:ZJButtonImageStyleLeft imageTitleToSpace:10];
    
    self.manBtn = bgThreeView
    .addButton(12)
    .image(KImage(@"icon_wxz"))
    .imageSelected(KImage(@"icon_xz"))
    .title(LOCSTR(@"标准男声"))
    .titleFont(KPingFangFont(14))
    .titleColor(KColor666666)
    .selected(NO)
    .contentHorizontalAlignment(UIControlContentHorizontalAlignmentLeft)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        x.selected = !x.selected;
        if (x.selected) {
            self.girlBtn.selected = NO;
            self.manCBtn.selected = NO;
            self.boyBtn.selected = NO;
        }else{
            if (self.girlBtn.selected== NO && self.manCBtn.selected == NO && self.boyBtn.selected == NO) {
                x.selected = !x.selected;
            }
        }
    })
    .masonry(^(MASConstraintMaker *make){
        make.centerY.mas_equalTo(self.girlBtn.mas_centerY);
        make.left.mas_equalTo(self.girlBtn.mas_right);
        make.size.mas_equalTo(CGSizeMake((KScreenW-30-30)/2, 40));
    })
    .view;
    [self.manBtn layoutButtonWithImageStyle:ZJButtonImageStyleLeft imageTitleToSpace:10];
    
    self.manCBtn = bgThreeView
    .addButton(12)
    .image(KImage(@"icon_wxz"))
    .imageSelected(KImage(@"icon_xz"))
    .title(LOCSTR(@"磁性男声"))
    .titleFont(KPingFangFont(14))
    .titleColor(KColor666666)
    .selected(NO)
    .contentHorizontalAlignment(UIControlContentHorizontalAlignmentLeft)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        x.selected = !x.selected;
        if (x.selected) {
            self.girlBtn.selected = NO;
            self.manBtn.selected = NO;
            self.boyBtn.selected = NO;
        }else{
            if (self.girlBtn.selected== NO && self.manBtn.selected == NO && self.boyBtn.selected == NO) {
                x.selected = !x.selected;
            }
        }
    })
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.girlBtn.mas_bottom);
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake((KScreenW-30-30)/2, 40));
    })
    .view;
    [self.manCBtn layoutButtonWithImageStyle:ZJButtonImageStyleLeft imageTitleToSpace:10];
    
    self.boyBtn = bgThreeView
    .addButton(12)
    .image(KImage(@"icon_wxz"))
    .imageSelected(KImage(@"icon_xz"))
    .title(LOCSTR(@"标准童声"))
    .titleFont(KPingFangFont(14))
    .titleColor(KColor666666)
    .selected(NO)
    .contentHorizontalAlignment(UIControlContentHorizontalAlignmentLeft)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        x.selected = !x.selected;
        if (x.selected) {
            self.girlBtn.selected = NO;
            self.manCBtn.selected = NO;
            self.manBtn.selected = NO;
        }else{
            if (self.girlBtn.selected== NO && self.manBtn.selected == NO && self.manCBtn.selected == NO) {
                x.selected = !x.selected;
            }
        }
    })
    .masonry(^(MASConstraintMaker *make){
        make.centerY.mas_equalTo(self.manCBtn.mas_centerY);
        make.left.mas_equalTo(self.manCBtn.mas_right);
        make.size.mas_equalTo(CGSizeMake((KScreenW-30-30)/2, 40));
    })
    .view;
    [self.boyBtn layoutButtonWithImageStyle:ZJButtonImageStyleLeft imageTitleToSpace:10];
    
    
    
//调节
    UIView *bgTwoView = self.view
    .addView(1)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(bgThreeView.mas_bottom).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(KScreenW-30, 150));
    })
    .view;
    bgTwoView.layer.cornerRadius = 9;

    
    UILabel *volumeLabel = bgTwoView
    .addLabel(1)
    .text(LOCSTR(@"音量"))
    .font(KFont(14))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(70, 50));
    })
    .view;
    
    self.volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(70, 0, KScreenW-60-70, 50)];
    self.volumeSlider.minimumValue = 0.0;
    self.volumeSlider.maximumValue = 9.0;
    self.volumeSlider.thumbTintColor = KThemeColor;
    self.volumeSlider.tintColor = KThemeColor;
    self.volumeSlider.value = 5.0;
    [self.volumeSlider setMinimumTrackTintColor:KThemeColor];
    [self.volumeSlider setMaximumTrackTintColor:[UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0]];
    [bgTwoView addSubview:self.volumeSlider];
    [self.volumeSlider addTarget:self action:@selector(volumeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *rateLabel = bgTwoView
    .addLabel(1)
    .text(LOCSTR(@"语速"))
    .font(KFont(14))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(volumeLabel.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(70, 50));
    })
    .view;
    
    self.rateSlider = [[UISlider alloc]initWithFrame:CGRectMake(70, 50, KScreenW-60-70, 50)];
    self.rateSlider.minimumValue = 0.0;
    self.rateSlider.maximumValue = 9.0;
    self.rateSlider.thumbTintColor = KThemeColor;
    self.rateSlider.tintColor = KThemeColor;
    self.rateSlider.value = 5.0;
    [self.rateSlider setMinimumTrackTintColor:KThemeColor];
    [self.rateSlider setMaximumTrackTintColor:[UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0]];
    [bgTwoView addSubview:self.rateSlider];
    [self.rateSlider addTarget:self action:@selector(rateSliderValueChanged:) forControlEvents:UIControlEventValueChanged];

    UILabel *toneLabel = bgTwoView
    .addLabel(1)
    .text(LOCSTR(@"音调"))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(rateLabel.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(70, 50));
    })
    .view;
    toneLabel.font = KFont(14);
    
    self.toneSlider = [[UISlider alloc]initWithFrame:CGRectMake(70, 100, KScreenW-60-70, 50)];
    self.toneSlider.minimumValue = 0.0;
    self.toneSlider.maximumValue = 9.0;
    self.toneSlider.thumbTintColor = KThemeColor;
    self.toneSlider.tintColor = KThemeColor;
    self.toneSlider.value = 5.0;
    [self.toneSlider setMinimumTrackTintColor:KThemeColor];
    [self.toneSlider setMaximumTrackTintColor:[UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0]];
    [bgTwoView addSubview:self.toneSlider];
    [self.toneSlider addTarget:self action:@selector(toneSliderValueChanged:) forControlEvents:UIControlEventValueChanged];

    
    
//button
    
    
    self.auditionBtn = self.view
    .addButton(0)
    .title(LOCSTR(@"试听"))
    .titleFont(KPingFangFont(14))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .cornerRadius(5)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
        self.isPlaySong = YES;
        [self playSong];
        
    })
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(bgTwoView.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(KScreenW-30-30, 40));
    })
    .view;
    
    self.addBtn = self.view
    .addButton(0)
    .title(LOCSTR(@"保存到自定义曲目"))
    .titleFont(KPingFangFont(14))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .cornerRadius(5)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
        
        if ([MethodTool isContainsEmoji:self.textView.text]) {
            return [MBProgressHUD showMessage:LOCSTR(@"不支持Emoji表情") icon:@""];
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:LOCSTR(@"设置名称") preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"取消") style:UIAlertActionStyleDefault handler:nil]];
                [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    STRONG
                    UITextField *TextField = alertController.textFields.firstObject;
                    
                    NSString *songName = TextField.text;
                    if ([NSString isNullOrNilWithObject:songName] || [NSString isFullSpaceEmpty:songName]) {
                        [MBProgressHUD showMessage:LOCSTR(@"请输入曲目名称") icon:@""];
                    }else {

                        if (songName.length >20) {
                            [MBProgressHUD showError:LOCSTR(@"名称不能超过20个字符")];
                        }else {
                            NSMutableArray *array = [NSMutableArray new];
                            for (locallyMusicModel *model in [UserManageCenter sharedUserManageCenter].devicePlayList) {
                                [array addObject:model.SN];
                            }
                            
                            if ([array containsObject:songName]) {
                                [MBProgressHUD showError:LOCSTR(@"名称已存在")];
                            }else{
                                self.isPlaySong = NO;
                                self.songName = songName;
                                
                                NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                                 NSString *realPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",self.mp3Name]];
                                 NSFileManager *fileManager = [NSFileManager defaultManager];
                                
                                //判断录音文件存在不
                                if ([fileManager fileExistsAtPath:realPath]){
                                    NSLog(@"---文件存在--");
                                    [self p_setupFileRename:[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] , self.mp3Name] FileName:self.songName];
                                }else{
                                    NSLog(@"---文件不存在--");
                                    [self playSong];
                                }
                            }
                        }
                    }

                }]];

                [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.placeholder = LOCSTR(@"请输入曲目名称");
                }];

                [self presentViewController:alertController animated:true completion:nil];
    })
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.auditionBtn.mas_bottom).mas_offset(10);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(KScreenW-30-30, 40));
    })
    .view;
}

//音量值
-(void)volumeSliderValueChanged:(UISlider *)slider
{
    self.volume = slider.value;
}

//语速值
-(void)rateSliderValueChanged:(UISlider *)slider
{
    self.rate = slider.value;
}

//音调值
-(void)toneSliderValueChanged:(UISlider *)slider
{
    self.pitchMultiplier = slider.value;
}

//代理方法
- (void)textViewDidChange:(UITextView *)textView{
    if(textView.text.length!=0){
//        self.placeHolderLabel.hidden=YES;
    }
}
-(NSMutableArray *)synthesisTexts{
    if (!_synthesisTexts) {
        _synthesisTexts = [NSMutableArray new];
    }
    return _synthesisTexts;
}
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-k_Height_NavBar)];
        _scrollView.contentSize = CGSizeMake(KScreenW, self.textView.size.height+100);
        _scrollView.bounces = YES;
        _scrollView.pagingEnabled = YES;
        
    }
    return _scrollView;
}
-(void)configureSDK{
    NSLog(@"TTS version info: %@", [BDSSpeechSynthesizer version]);
    [BDSSpeechSynthesizer setLogLevel:BDS_PUBLIC_LOG_VERBOSE];
    [[BDSSpeechSynthesizer sharedInstance] setSynthesizerDelegate:self];
    [[BDSSpeechSynthesizer sharedInstance] setApiKey:API_KEY withSecretKey:SECRET_KEY];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(18) forKey:BDS_SYNTHESIZER_PARAM_AUDIO_ENCODING];//mp3 16k比特率
}
//试听
-(void)playSong{
    
    
    
    if(self.textView.text.length <= 0){
        return [MBProgressHUD showMessage:LOCSTR(@"请输入需要播报的文字") icon:@""];
    }
    if ([MethodTool isContainsEmoji:self.textView.text]) {
        return [MBProgressHUD showMessage:LOCSTR(@"不支持Emoji表情") icon:@""];
    }

    //声音选择
    if (self.girlBtn.selected) {
        [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_FEMALE) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
        self.sInt = 1;

    } else if(self.manBtn.selected){
        [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_MALE) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
        self.sInt = 2;
    }else if(self.manCBtn.selected){
        [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_MALE_3) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
        self.sInt = 3;
    }else{
        [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_DYY) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
        self.sInt = 4;
    }
    //速度
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(self.rate) forKey:BDS_SYNTHESIZER_PARAM_SPEED];
    //音调
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(self.pitchMultiplier) forKey:BDS_SYNTHESIZER_PARAM_PITCH];
    //音量
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(self.volume) forKey:BDS_SYNTHESIZER_PARAM_VOLUME];
    
//    self.STextView = self.textView.text;
//    self.SRate = self.rate;
//    self.SPitchMultiplier = self.pitchMultiplier;
//    self.SVolume = self.volume;

    
    
//-----------------------
    [SVProgressHUD show];

    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] , self.mp3Name] error:nil];

    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    self.mp3Name = [NSString stringWithFormat:@"zd%@.mp3",[MethodTool getNowTimeTimestamp]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDirPath , self.mp3Name];

    _fp = fopen(filePath.UTF8String, "wb+");
    
    NSAttributedString* string = [[NSAttributedString alloc] initWithString:self.textView.text];

    NSInteger sentenceID = 0;
    NSError* err = nil;


    if (string.length <= 60) {
        sentenceID = [[BDSSpeechSynthesizer sharedInstance] synthesizeSentence:[string string]  withError:&err];
        self.endID = sentenceID;
        NSLog(@"-------44------%ld------%@",(long)sentenceID,[string string]);

    }else{
        //包含句号（按照句号分割成数组 开始传入合并）
//        if ([[string string] containsString:@"，"]) {
//            NSArray  *array = [[[string string] stringByReplacingOccurrencesOfString:@"\n" withString:@""] componentsSeparatedByString:@"，"];
//            for (int i = 0; i < array.count; i++) {
//                sentenceID = [[BDSSpeechSynthesizer sharedInstance] synthesizeSentence:array[i] withError:&err];
//                NSLog(@"-----11--句号---%d---%ld---------%@",i,(long)sentenceID,array[i]);
//                if (i == array.count-1) {
//                    self.endID = sentenceID;
//                    NSLog(@"---22----句号---%d---%ld---------%@",i,(long)sentenceID,array[i]);
//                }
//            }
//
//        }else{
            //不包含句号按照60字符分割传入
            NSInteger end = string.length % 60;
            if (end > 0) {
                for (int i = 0; i < string.length / 60 +1; i++) {

                    if (i == string.length / 60) {
                        NSString * str = [[string string] substringWithRange:NSMakeRange(i*60, end)];
                        sentenceID = [[BDSSpeechSynthesizer sharedInstance] synthesizeSentence:str withError:&err];
                        self.endID = sentenceID;
                        NSLog(@"-------222---%d---%ld---------%@",i,(long)sentenceID,str);
                    }else{
                        NSString * str = [[string string] substringWithRange:NSMakeRange(i*60, 60)];
                        sentenceID = [[BDSSpeechSynthesizer sharedInstance] synthesizeSentence:str withError:&err];
                        NSLog(@"-------111---%d---%ld--------%@",i,(long)sentenceID,str);

                    }
                }
            }else{
                for (int i = 0; i < string.length / 60 ; i++) {
                    NSString *str = [[string string] substringWithRange:NSMakeRange(i*60, 60)];
                    sentenceID = [[BDSSpeechSynthesizer sharedInstance] synthesizeSentence:str withError:&err];
                    if (i == string.length / 60 - 1) {
                        self.endID = sentenceID;
                    }
                    NSLog(@"-------33---%d---%ld------%@",i,(long)sentenceID,str);

                }
            }
//        }
        
        
    }

    
    if(err == nil){
        NSMutableDictionary *addedString = [[NSMutableDictionary alloc] initWithObjects:@[string, [NSNumber numberWithInteger:sentenceID], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0]] forKeys:@[@"TEXT", @"ID", @"SPEAK_LEN", @"SYNTH_LEN"]];
        [self.synthesisTexts addObject:addedString];

    }
    else{
        [self displayError:err withTitle:@"Add sentence Error"];
    }

}
//返回的-----------语音数据-------------
- (void)synthesizerNewDataArrived:(NSData *)newData
                       DataFormat:(BDSAudioFormat)fmt
                   characterCount:(int)newLength
                   sentenceNumber:(NSInteger)SynthesizeSentence{

    NSLog(@"-----------语音数据------%u-----%d-----%ld--",fmt,newLength,(long)SynthesizeSentence);
    if (_fp) {
        size_t size = fwrite(newData.bytes, 1, newData.length, _fp);
        NSLog(@"handleVideoData---fwrite:%lu", size);
    }
    
    //包含句号

//    if ([self.textView.text containsString:@"，"]) {
//        if ((self.endID == SynthesizeSentence)) {
//            [self endMp3];
//            NSLog(@"-------------句号----");
//        }
//    }else{
        NSInteger end = self.textView.text.length % 60;
        if (end > 0) {
            if ((self.endID == SynthesizeSentence) && end == newLength) {
                [self endMp3];
                NSLog(@"-------------endpm3");
            }
        }else{
            if ((self.endID == SynthesizeSentence) && newLength == 60) {
                [self endMp3];
                NSLog(@"-------------endpm3----60");
            }
        }
//    }
    
    
    
    
    NSMutableDictionary* sentenceDict = nil;
    for(NSMutableDictionary *dict in self.synthesisTexts){
        if([[dict objectForKey:@"ID"] integerValue] == SynthesizeSentence){
            sentenceDict = dict;
            break;
        }
    }
    if(sentenceDict == nil){
        NSLog(@"Sentence ID mismatch??? received ID: %ld\nKnown sentences:", (long)SynthesizeSentence);
        for(NSDictionary* dict in self.synthesisTexts){
//            NSLog(@"ID: %ld Text:\"%@\"", [[dict objectForKey:@"ID"] integerValue], [((NSAttributedString*)[dict objectForKey:@"TEXT"]) string]);
        }
        return;
    }
    [sentenceDict setObject:[NSNumber numberWithInteger:newLength] forKey:@"SYNTH_LEN"];
}
//结束合成 开始播放音频
-(void)endMp3{
    if (_fp) {
            fclose(_fp);
            _fp = NULL;
        }
    if (self.isPlaySong) {
        [SVProgressHUD dismiss];
        //从budle路径下读取音频文件
        NSString *string = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] , self.mp3Name];
        //把音频文件转换成url格式
        NSURL *url = [NSURL fileURLWithPath:string];
        //初始化音频类 并且添加播放文件
        self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.avAudioPlayer.delegate = self;
        //开始进行播放
        [self.avAudioPlayer play];
        NSLog(@"-----结束合成---url:%@--Did finish synth, url",url);

    }else{
        [self p_setupFileRename:[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] , self.mp3Name] FileName:self.songName];

    }
    
    
    
}
// 音频播放完成时
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
     
//    [BDSSpeechSynthesizer releaseInstance];//释放合成器唯一实例
//    [self configureSDK];//释放后需要重新注册新的 这样保证每次id都是从0开始
    
}
//----------------------开始合成-----------------
#pragma mark - implement BDSSpeechSynthesizerDelegate
- (void)synthesizerStartWorkingSentence:(NSInteger)SynthesizeSentence{
    
//    NSLog(@"-----开始合成-----Did start synth %d", SynthesizeSentence);

}


//----------------------结束合成-----------------
- (void)synthesizerFinishWorkingSentence:(NSInteger)SynthesizeSentence{

}
//-----------------------合成器发生错误-------------
- (void)synthesizerErrorOccurred:(NSError *)error
                        speaking:(NSInteger)SpeakSentence
                    synthesizing:(NSInteger)SynthesizeSentence{
//    NSLog(@"---合成器发生错误----Did error %d, %ld", SpeakSentence, SynthesizeSentence);
    [SVProgressHUD dismiss];

    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] , self.mp3Name] error:nil];

    [self.synthesisTexts removeAllObjects];
    [[BDSSpeechSynthesizer sharedInstance] cancel];
    [self displayError:error withTitle:@"Synthesis failed"];
    [BDSSpeechSynthesizer releaseInstance];//释放合成器唯一实例
    [self configureSDK];//释放后需要重新注册新的 这样保证每次id都是从0开始
}

-(void)displayError:(NSError*)error withTitle:(NSString*)title{
//    NSString* errMessage = error.localizedDescription;
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:errMessage preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction* dismiss = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction * action) {}];
//    [alert addAction:dismiss];
//    [self presentViewController:alert animated:YES completion:nil];
    [MBProgressHUD showMessage:LOCSTR(@"合成失败了，请重试") icon:@""];
}

/**
 获取Url
 */
- (void)p_setupFileRename:(NSString *)filePath FileName:(NSString *)name {
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
        }];

}
/*
{ URL: https://gz-g-resource-1256872341.cos.ap-guangzhou.myqcloud.com/res%2F100009964656_56UED5AJ29_USER_249555369632731136_RES_zd1622551690_1.0.0?sign=q-sign-algorithm%3Dsha1%26q-ak%3DAKIDMUM9hdmn35rHZe72Y6UfliNo1PYQFZln%26q-sign-time%3D1622551690%3B1622555290%26q-key-time%3D1622551690%3B1622555290%26q-header-list%3D%26q-url-param-list%3D%26q-signature%3Ddc5781baa0400d08174074b90fc5df0341b8ba03
}
    { Status Code: 200, Headers {
    Connection =     (
        "keep-alive"
    );
    "Content-Length" =     (
        0
    );
    Date =     (
        "Tue, 01 Jun 2021 12:48:11 GMT"
    );
    Etag =     (
        "\"d41d8cd98f00b204e9800998ecf8427e\""
    );
    Server =     (
        "tencent-cos"
    );
    "x-cos-hash-crc64ecma" =     (
        0
    );
    "x-cos-request-id" =     (
        NjBiNjJjOGJfZDIyZjJjMGJfM2Q1Yl8zMDZhMGZi
    );
} }
 */
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
    NSURL *file = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] , self.mp3Name]];
    
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
    WEAK
    [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
        STRONG
        [UserManageCenter sharedUserManageCenter].devicePlayList = playList;
        [MBProgressHUD showMessage:LOCSTR(@"保存成功") icon:@""];
        [self goback];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];

    }];
    [SVProgressHUD dismiss];
}


-(void)goback{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] , self.mp3Name] error:nil];
    [BDSSpeechSynthesizer releaseInstance];
}
@end
