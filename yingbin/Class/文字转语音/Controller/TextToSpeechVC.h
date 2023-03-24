//
//  TextToSpeechVC.h
//  yingbin
//
//  Created by slxk on 2021/5/20.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextToSpeechVC : BaseViewController<AVSpeechSynthesizerDelegate,AVAudioPlayerDelegate>
//播放器player
@property (nonatomic, strong)AVAudioPlayer *avAudioPlayer;

@end

NS_ASSUME_NONNULL_END
