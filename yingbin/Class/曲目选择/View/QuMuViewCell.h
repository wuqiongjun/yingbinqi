//
//  QuMuViewCell.h
//  yingbin
//
//  Created by slxk on 2021/6/9.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QuMuViewCell : UITableViewCell

@property (nonatomic, strong)NSMutableDictionary *quMuDic;
@property (nonatomic, assign)NSInteger integer;
@property (nonatomic, strong)UIImageView *image;

KCOPY void (^selectMusicSuccess)( UIButton *btn);

@end

NS_ASSUME_NONNULL_END
