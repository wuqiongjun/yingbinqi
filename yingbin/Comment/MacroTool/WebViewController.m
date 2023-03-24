//
//  WebViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/21.
//  Copyright © 2021 wq. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()<WKNavigationDelegate,WKUIDelegate>

KSTRONG  WKWebView *wkWebView;
KSTRONG  UIProgressView *progressView;

@end

@implementation WebViewController

-(void)viewDidLoad {
   [super viewDidLoad];
   self.navigationItem.title = self.navTitle;
//   [self.navigationController.navigationBar setBarTintColor:UIColor.whiteColor];
//    self.navigationItem.rightBarButtonItem = self.shareBarButtonItem;
   
   //进度条初始化
   self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 2)];
   self.progressView.backgroundColor = [UIColor grayColor];
   self.progressView.progressTintColor = [UIColor greenColor];
   //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
   self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
   [self.view addSubview:self.progressView];
   
   NSString *urlString = self.url;
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
   request.timeoutInterval = 15.0f;
   [self.wkWebView loadRequest:request];

   WEAK
   [[self.wkWebView rac_valuesForKeyPath:@"estimatedProgress" observer:self] subscribeNext:^(NSNumber * x) {
       STRONG
       self.progressView.progress = x.floatValue;
       if (self.progressView.progress == 1) {
           /*
            *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
            *动画时长0.25s，延时0.3s后开始动画
            *动画结束后将progressView隐藏
            */
           [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
               self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
           } completion:^(BOOL finished) {
               self.progressView.hidden = YES;
           }];
       }
   }];
   
}
- (void)js{
       // 将结果返回给js
   WEAK
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//       STRONG
//       NSString *jsStr = [NSString stringWithFormat:@"appsendmsg('%@')",[UserManageCenter shareInstance].selectedDevice.imei];
//       [self.wkWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//           NSLog(@"方法名%@----%@",result, error);
//       }];
   });

}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    NSString *requestString = navigationAction.request.URL.absoluteString;
   //对外链、拨号和跳转appstore做特殊处理
//    UIApplication *app = [UIApplication sharedApplication];
//    NSURL *url = [navigationAction.request URL];
//    if ([url isViewLoaded])
//    {
       decisionHandler(WKNavigationActionPolicyAllow);//崩在这里
       
//    }else{
//
//        decisionHandler(WKNavigationActionPolicyCancel);
//        SVPSHOWERROR(KUSDOMTEXTOpened);
//        [self refreshAction];
//    }
}

- (void)goback{
   
  

   if ([self.wkWebView canGoBack]) {
       [self goBackAction];
   } else {
       
       [self.navigationController popViewControllerAnimated:YES];
   }
}

- (WKWebView *)wkWebView {
   if (!_wkWebView) {
       //进行配置控制器
       NSString *jScript = @"var script = document.createElement('meta');"
       "script.name = 'viewport';"
       "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
       "document.getElementsByTagName('head')[0].appendChild(script);";
       
       WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
       WKUserContentController* userContentController = [WKUserContentController new];
       [userContentController addUserScript:wkUScript];
       
       WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
       //实例化对象
       
       configuration.userContentController = userContentController;
       //    configuration.preferences.javaScriptEnabled = YES;
       WKPreferences *preferences = [WKPreferences new];
       preferences.javaScriptCanOpenWindowsAutomatically = YES;
       preferences.minimumFontSize = 0.0;
       preferences.javaScriptEnabled = YES;
       configuration.preferences = preferences;
       
       _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-STATUSBAR_HEIGHT-NAVBAR_HEIGHT) configuration:configuration];
       _wkWebView.navigationDelegate = self;
       _wkWebView.UIDelegate = self;
//        _wkWebView.scrollView.scrollEnabled = NO;
       [self.view addSubview:_wkWebView];
   }
   return _wkWebView;
}
//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
   NSLog(@"开始加载网页");
   //开始加载网页时展示出progressView
   self.progressView.hidden = NO;
   //开始加载网页的时候将progressView的Height恢复为1.5倍
   self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
   //防止progressView被网页挡住
   [self.view bringSubviewToFront:self.progressView];
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
   NSLog(@"加载完成");
   NSLog(@"%@",webView.URL);
//   if ([webView.URL.absoluteString isEqualToString:@"http://114.215.190.173/service_test/customer.html"]) {
//       NSLog(@"在线客服");
//       if (!self.isFirst) {
//           self.isFirst = YES;
//           [self js];
//       }
//       
//   }
   //加载完成后隐藏progressView
//    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];
//    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
   NSLog(@"加载失败");
   //加载失败同样需要隐藏progressView
 
   self.progressView.hidden = YES;
   [self handleError:error];
}

//- (void)dealloc {
//    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
//    //    [self.wkWebView removeObserver:self forKeyPath:@"title"];
//}

- (void)goBackAction {
   if ([self.wkWebView canGoBack]) {
       [self.wkWebView goBack];
   }
}

- (void)goForwardAction {
   if ([self.wkWebView canGoForward]) {
       [self.wkWebView goForward];
   }
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
   if (error.code==NSURLErrorCancelled) {
       return;
   }
   [self handleError:error];
}


- (void)handleError:(NSError *)error
{
   
   [self.wkWebView stopLoading];
   [SVProgressHUD showErrorWithStatus:error.localizedDescription];
   [self goback];
  
}

- (void)refreshAction {
   [self.wkWebView reload];
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
   
   if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
       
       NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
       
       completionHandler(NSURLSessionAuthChallengeUseCredential,card);
   }
}

- (void)dealloc
{
   //[TLNotificationCenter removeObserver:self];
 
}



@end
