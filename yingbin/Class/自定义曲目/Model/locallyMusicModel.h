//
//  locallyMusicModel.h
//  yingbin
//
//  Created by slxk on 2021/6/3.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface locallyMusicModel : BaseViewModel

/*
 FN(文件名称) ： fileName
 SN(歌曲名称)： songName
 */
@property (nonatomic, strong)NSString *FN;
@property (nonatomic, strong)NSString *SN;

@end

NS_ASSUME_NONNULL_END
