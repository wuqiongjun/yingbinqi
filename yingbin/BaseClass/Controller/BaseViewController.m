//
//  BaseViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    [self navigationBar];

}
- (void)navigationBar{
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    
    if (self.navigationController.viewControllers.count > 1) {
        
        
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -10;

        
        self.navigationItem.leftBarButtonItems = @[negativeSeperator,self.backButtonItem];
    }
}
- (UIBarButtonItem *)backButtonItem{
    if (!_backButtonItem) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[MethodTool imageWithOriginal:@"icon_back"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(goback)];
        
        _backButtonItem = item;
    }
    return _backButtonItem;
}
- (UIBarButtonItem *)addButtonItem{
    if (!_addButtonItem) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[MethodTool imageWithOriginal:@"icon_add_Item"]
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self action:@selector(addItemClick:)];
        _addButtonItem = item;
        
    }
    return _addButtonItem;
}
- (void)goback{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)addItemClick:(UIBarButtonItem *)btn{}


- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *title = @"";
    NSDictionary *attributes = @{
                                 NSFontAttributeName:KBFont(16),
                                 NSForegroundColorAttributeName:[UIColor darkGrayColor]
                                 };
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}
- (UIBarButtonItem *)saveButtonItem{
    if (!_saveButtonItem) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(saveItemClick:)];
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:KFont(15),NSFontAttributeName, nil] forState:UIControlStateNormal];
        item.tintColor = KThemeColor;
        _saveButtonItem = item;
    }
    return _saveButtonItem;
}
- (UIBarButtonItem *)ShareDeviceItem{
    if (!_ShareDeviceItem) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"分享"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(shareDeviceItemClick:)];
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:KFont(15),NSFontAttributeName, nil] forState:UIControlStateNormal];
        item.tintColor = KThemeColor;
        _saveButtonItem = item;
    }
    return _saveButtonItem;
}
- (void)saveItemClick:(UIBarButtonItem *)btn{}
- (void)shareDeviceItemClick:(UIBarButtonItem *)btn{}

@end
