//
//  LNewHomePageViewController.m
//  MyAimerApp
//
//  Created by yanglee on 15/4/8.
//  Copyright (c) 2015年 aimer. All rights reserved.
//

#import "LNewHomePageViewController.h"
#import "NewHomeParser.h"
#import "NewHomeInfo.h"
#import "AppDelegate.h"
#import "SearchpageViewController.h"
#import "HotpageViewController.h"
#import "NewPageViewController.h"
#import "NewMaginzeListViewController.h"
#import "NearByShopViewController.h"
#import "AMMapViewController.h"
#import "UIViewController+MaryPopin.h"
#import "PlayNDropViewController.h"
#import "YKChannelViewController.h"
#import "MyCloset1ViewController.h"
#import "MyButton.h"
#import "APService.h"


@interface LNewHomePageViewController ()
{
    UITableView *myTableV;
    
    NewHomeInfo *_homeinfo;
    
    UIView *magizeView;
    UIView *bannerView;
    SGFocusImageFrame *bannerSGFocus;
    int bannerSGFocusIndex;
    UILabel *firstLab;
    UILabel *secondLab;

    UIView *buyNowView; //限时抢购
    UIView *formeView;  //为我推荐
    
    
    int forMeHeight;   //为我推荐的高度
    NSString *downloadURL; //下载地址

    int sepViewH;
}
@end

@implementation LNewHomePageViewController

- (id)init{
    self = [super init];
    if (self)
        self.title = @"商城";
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"商城";
    
    sepViewH = 10;
    
    forMeHeight = ScreenWidth*1.6875;//540;
    
    [self createNavItem];
    
    mainSev = [[MainpageServ alloc] init];
    mainSev.delegate = self;
    [mainSev getHomePage20data];
    [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];

    //lee999 增加升级提示的判断。
    [mainSev getappVersion];
    
    [self creatTableView];
    
    
//    [LCommentAlertView showMessage:[APService registrationID] target:nil];

//    NSSet *set = [NSSet setWithObjects:@"test",@"test2", nil];
//    [APService setAlias:@"妹妹" callbackSelector:@selector(tagsAliasCallback:tags:alias) object:self];
//    [APService setTags:set alias:@"小纪" callbackSelector:@selector(tags) object:nil];
//    [APService setAlias:@"妹妹" callbackSelector:@selector(succ) object:self];
}

-(void)success{

    [LCommentAlertView showMessage:@"123123" target:nil];
}


-(void)tagsAliasCallback:(int)iResCode
                    tags:(NSSet*)tags
                   alias:(NSString*)alias
{
    [LCommentAlertView showMessage:[NSString stringWithFormat:@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias] target:nil];
    
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    if ([SingletonState sharedStateInstance].isNewHomePageScrollToTop) {
        [SingletonState sharedStateInstance].isNewHomePageScrollToTop = NO;
        [myTableV setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    [self NewSHowTableBarwithAnimated:YES];
}

-(void)createNavItem{

    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth - 40, 30)];
    self.navigationItem.titleView = titleView;
    self.navigationController.navigationBar.translucent = NO;
    
    UIImage *image = [UIImage imageNamed:@"title_logo.png"];
    UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, image.size.width,image.size.height)];
    logoImage.image = image;
    [titleView addSubview:logoImage];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setTitle:@" 请输入宝贝关键词" forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:LabSmallSize];
    [searchBtn setTitleColor:[UIColor colorWithHexString:@"#ff98b2"] forState:UIControlStateNormal];
    [searchBtn setBackgroundImage:[[UIImage imageNamed:@"search_input.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:0] forState:UIControlStateNormal];
    [searchBtn setBackgroundImage:[[UIImage imageNamed:@"search_input.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:0] forState:UIControlStateHighlighted];
    [searchBtn addTarget:self action:@selector(gotoSearchViewC) forControlEvents:UIControlEventTouchUpInside];
    searchBtn.frame = CGRectMake(logoImage.frame.origin.x + logoImage.frame.size.width + 10,
                                 1,
                                 titleView.frame.size.width - logoImage.frame.origin.x - logoImage.frame.size.width - 25
                                 ,titleView.frame.size.height- 2);
    [titleView addSubview:searchBtn];
    
    
    UIImage *imageglass = [UIImage imageNamed:@"icon_search2222.png"];//[UIImage imageNamed:@"icon_search.png"];
    UIImageView *glassImage = [[UIImageView alloc] initWithFrame:CGRectMake(logoImage.frame.origin.x + logoImage.frame.size.width + 18, 6, imageglass.size.width,imageglass.size.height)];
    glassImage.image = imageglass;
    [titleView addSubview:glassImage];

    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *unSelectedImg = [UIImage imageNamed:@"t_ico_location_normal.png"];
    UIImage *selectedImg = [UIImage imageNamed:@"t_ico_location_hover.png"];
    [photoBtn setBackgroundImage:unSelectedImg forState:UIControlStateNormal];
    [photoBtn setBackgroundImage:selectedImg forState:UIControlStateHighlighted];
    [photoBtn addTarget:self action:@selector(gotoNearByShop) forControlEvents:UIControlEventTouchUpInside];
    photoBtn.frame = CGRectMake(10, 3, 20, 20);
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:photoBtn];
    self.navigationItem.rightBarButtonItem = rightBtn;
}


#pragma mark-- service
-(void)serviceStarted:(ServiceType)aHandle{
}

-(void)serviceFailed:(ServiceType)aHandle{
    [SBPublicAlert hideMBprogressHUD:self.view];
    [myTableV headerEndRefreshing];
}

-(void)serviceFinished:(ServiceType)aHandle withmodel:(id)amodel{
    
    [myTableV headerEndRefreshing];
    
    
    LBaseModel *model = (LBaseModel *)amodel;
    if ([amodel isKindOfClass:[LBaseModel class]] &&
        model.requestTag < 200) {
        switch (model.requestTag) {
            case Http_Version_Tag:
            {
               
                VersionVersionModel *versionModel = (VersionVersionModel *)model;
                //版本升级
                VersionVersion *verversion = versionModel.version;
                
                downloadURL = versionModel.comment.url;
                // 必须升级

                if (verversion.need) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"有新版本啦！"
                                                                    message:verversion.message
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"立即升级", nil];
                    alert.delegate = self;
                    [alert setTag:10000];
                    [alert show];
                    
                } else if (verversion.newVer) {
                    // 可以升级，询问是否升级
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"有新版本啦！"
                                                                    message:verversion.message
                                                                   delegate:self
                                                          cancelButtonTitle:@"稍后升级"
                                                          otherButtonTitles:@"立即升级", nil];
                    alert.delegate = self;
                    [alert setTag:10001];
                    [alert show];
                    
                }
                
                
            }
                break;
                
            default:
                break;
        }
        return;
    }
    
    
    _homeinfo = [[NewHomeParser alloc] parseNewHomeInfo:amodel];
    
    [self creatCellView];
    
    [myTableV reloadData];
    
    [SBPublicAlert hideMBprogressHUD:self.view];
    
}




#pragma mark-- 升级提示
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 10000: // 强制升级
            if (buttonIndex==0) { //升级
                
                [self jumpUpdate];//去升级
                
                exit(0);
            }else{
                
            }
            break;
        case 10001: // 可以升级
            if (buttonIndex) {
                [self jumpUpdate];//去升级
            }
            break;
        default:
            break;
    }
}

- (void)jumpUpdate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadURL]];
}


//创建表格
-(void)creatTableView{

    myTableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight- 50 -60)
                                            style:UITableViewStylePlain];
    myTableV.delegate = self;
    myTableV.dataSource = self;
    [self.view addSubview:myTableV];
    [myTableV setBackgroundColor:[UIColor colorWithHexString:@"E6E6E6"]];
    
    //底部view
    UIView *footV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 260)];
    [footV setBackgroundColor:[UIColor colorWithHexString:@"#E6E6E6"]];
    [myTableV setTableFooterView:footV];
    
    
    int totalHight = 0;
    
    //关注
    UILabel *titlelab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, ScreenWidth, 26)];
    [titlelab setNumberOfLines:1];
    [titlelab setTextAlignment:NSTextAlignmentCenter];
    titlelab.text = [NSString stringWithFormat:@"关注"];
    titlelab.font = [UIFont systemFontOfSize:LabMidSize];
    [titlelab setTextColor:[UIColor colorWithHexString:@"#888888"]];
    [footV addSubview:titlelab];
    
    totalHight = 10+36;
    
    
    UIImage *imagewe = [UIImage imageNamed:@"wx_ico.png"];
    UIImageView *imagewechat = [[UIImageView alloc] init];
    [imagewechat setFrame:CGRectMake(68, totalHight, imagewe.size.width, imagewe.size.height)];
    [imagewechat setImage:imagewe];
    [footV addSubview:imagewechat];
    
    
    UIImage *imgweibo = [UIImage imageNamed:@"xl_ico.png"];
    UIImageView *imagewebo = [[UIImageView alloc] init];
    [imagewebo setFrame:CGRectMake(ScreenWidth-68-imgweibo.size.width, totalHight, imgweibo.size.width, imgweibo.size.height)];
    [imagewebo setImage:imgweibo];
    [footV addSubview:imagewebo];
    
    
    UIButton *wechatbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [wechatbtn setFrame:CGRectMake(20, totalHight, 120, 70)];
    [wechatbtn addTarget:self action:@selector(showERcodeViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [wechatbtn setBackgroundColor:[UIColor clearColor]];
    wechatbtn.tag = 100;
    [footV addSubview:wechatbtn];
    
    
    UIButton *weibobtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [weibobtn setFrame:CGRectMake(ScreenWidth-88-imgweibo.size.width, totalHight,120, 70)];
    [weibobtn addTarget:self action:@selector(showERcodeViewAction:) forControlEvents:UIControlEventTouchUpInside];
    weibobtn.tag = 101;
    [weibobtn setBackgroundColor:[UIColor clearColor]];
    [footV addSubview:weibobtn];
    
    
    totalHight += imagewe.size.height +10;
    
    UILabel *wechatlab = [[UILabel alloc] initWithFrame:CGRectMake(0, totalHight, 160, 26)];
    [wechatlab setNumberOfLines:1];
    [wechatlab setTextAlignment:NSTextAlignmentCenter];
    wechatlab.text = [NSString stringWithFormat:@"扫描关注官方微信"];
    wechatlab.font = [UIFont systemFontOfSize:11.];
    [wechatlab setTextColor:[UIColor colorWithHexString:@"#888888"]];
    [footV addSubview:wechatlab];
    
    UILabel *webolab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth-98-imgweibo.size.width, totalHight, 160, 26)];
    [webolab setNumberOfLines:1];
    [webolab setTextAlignment:NSTextAlignmentLeft];
    webolab.text = [NSString stringWithFormat:@"扫描关注新浪微博"];
    webolab.font = [UIFont systemFontOfSize:11.];
    [webolab setTextColor:[UIColor colorWithHexString:@"#888888"]];
    [footV addSubview:webolab];
    
    totalHight += 40;

    
    //4个icon
    UILabel *titlelab2 = [[UILabel alloc] initWithFrame:CGRectMake(0, totalHight, ScreenWidth, 26)];
    [titlelab2 setNumberOfLines:1];
    [titlelab2 setTextAlignment:NSTextAlignmentCenter];
    titlelab2.text = [NSString stringWithFormat:@"服务保障"];
    titlelab2.font = [UIFont systemFontOfSize:LabMidSize];
    [titlelab2 setTextColor:[UIColor colorWithHexString:@"#888888"]];
    [footV addSubview:titlelab2];
    
    totalHight += 40;

    NSArray *arrimage = [NSArray arrayWithObjects:@"zp_icon.png",@"th_icon.png",@"mf_icon.png",@"hdfk_icon.png", nil];
    NSArray *arrlab = [NSArray arrayWithObjects:@"专业正品保证",@"30天无条件退换",@"首次退换免费",@"支持货到付款", nil];

    for (int i = 0; i<4; i++) {
        
        UIImage *image = [UIImage imageNamed:[arrimage objectAtIndex:i]];
//        UIImageView *imagev = [[UIImageView alloc] initWithFrame:CGRectMake(20+i*(image.size.width+50), totalHight, image.size.width,image.size.height)];
        UIImageView *imagev = [[UIImageView alloc] initWithFrame:CGRectMake(37+i*(ScreenWidth/4), totalHight, image.size.width,image.size.height)];

        [imagev setImage:image];
        [footV addSubview:imagev];
        
        
//        UILabel *nameelab = [[UILabel alloc] initWithFrame:CGRectMake(0+i*(image.size.width+50), totalHight + image.size.height, 80, 26)];
        UILabel *nameelab = [[UILabel alloc] initWithFrame:CGRectMake(i*(ScreenWidth/4), totalHight + image.size.height, (ScreenWidth/4), 26)];
        [nameelab setNumberOfLines:1];
        [nameelab setTextAlignment:NSTextAlignmentCenter];
        nameelab.text = [arrlab objectAtIndex:i];
        [nameelab setBackgroundColor:[UIColor clearColor]];
        nameelab.font = [UIFont systemFontOfSize:11.];
        [nameelab setTextColor:[UIColor colorWithHexString:@"#888888"]];
        [footV addSubview:nameelab];
    }
    
    //添加下拉刷新
    [myTableV addHeaderWithCallback:^{
        [mainSev getHomePage20data];
    }];
}


-(void)creatCellView{

    
    //三个杂志入口------------
    int mageH = ScreenWidth*0.468;
    if (!magizeView) {
        magizeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, sepViewH + mageH*3)];
    }
    for (UIView *view in magizeView.subviews) {
        [view removeFromSuperview];
    }
    for (int i = 0; i<3; i++) {
        NewhomeNormalData *data = [_homeinfo.home_navi objectAtIndex:i isArray:nil];
        UrlImageButton *imageView = [[UrlImageButton alloc] initWithFrame:CGRectMake(0,i*(mageH+0.5),ScreenWidth, mageH)];
       // [imageView setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"pic_default_mall_banner.png"]];
        [imageView setImageFromUrl:NO withUrl:data.pic];
        imageView.tag = i;
        [imageView addTarget:self action:@selector(gotoMaginzeViewCwithType:) forControlEvents:UIControlEventTouchUpInside];
        [magizeView addSubview:imageView];
        
        UIView *homeV1 = [[UIView alloc] initWithFrame:CGRectMake(0,i*(mageH),ScreenWidth, 0.5)];
        [homeV1 setBackgroundColor:[UIColor blackColor]];
        [magizeView addSubview:homeV1];
    }
    UIView *homeV1 = [[UIView alloc] initWithFrame:CGRectMake(0,3*(mageH+0.5),ScreenWidth, 0.5)];
    [homeV1 setBackgroundColor:[UIColor colorWithHexString:@"#E6E6E6"]];
    [magizeView addSubview:homeV1];
    
    
    //banner---------------
    if (!bannerView) {
        bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth)];
    }
    for (UIView *view in bannerView.subviews) {
        [view removeFromSuperview];
    }
    NSInteger length = _homeinfo.home_banner.count;
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
    if (length > 1)
    {
        NewhomeNormalData *bannerModel = [_homeinfo.home_banner objectAtIndex:length-1 isArray:nil];
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:bannerModel.title image:bannerModel.pic tag:length-1];
        [itemArray addObject:item];
    }
    for (int i = 0; i < length; i++)
    {
        NewhomeNormalData *bannerModel = [_homeinfo.home_banner objectAtIndex:i isArray:nil];
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:bannerModel.title image:bannerModel.pic tag:i+132];
        [itemArray addObject:item];
        
    }
    //添加第一张图 用于循环
    if (length >1)
    {
        NewhomeNormalData *bannerModel = [_homeinfo.home_banner  objectAtIndex:0 isArray:nil];
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:bannerModel.title image:bannerModel.pic tag:132];
        [itemArray addObject:item];
    }
    
    bannerSGFocus = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,bannerView.frame.size.height) delegate:self imageItems:itemArray isAuto:YES];
    [bannerView addSubview:bannerSGFocus];
    
    //文案
    NewhomeNormalData *bannerModel = [_homeinfo.home_banner objectAtIndex:0 isArray:nil];
    if (!firstLab) {
        firstLab = [[UILabel alloc] initWithFrame:CGRectMake(20,bannerView.frame.size.height + 15, ScreenWidth-40, 20)];
    }
    [firstLab setText:bannerModel.title];
    [firstLab setNumberOfLines:1];
    [firstLab setTextAlignment:NSTextAlignmentCenter];
//    [firstLab setBackgroundColor:[UIColor yellowColor]];
    firstLab.font = [UIFont systemFontOfSize:LabBigSize];
    [firstLab setTextColor:[UIColor colorWithHexString:@"#181818"]];
    
    if (!secondLab) {
        secondLab = [[UILabel alloc] initWithFrame:CGRectMake(10, firstLab.frame.origin.y + firstLab.frame.size.height, ScreenWidth-20, 40)];
    }
    NSString* str =[bannerModel.titledes stringByAppendingString:@"\n "];
    [secondLab setText:str];
    [secondLab setNumberOfLines:2];
//    [secondLab setBackgroundColor:[UIColor greenColor]];
    [secondLab setTextAlignment:NSTextAlignmentCenter];
    secondLab.font = [UIFont systemFontOfSize:LabSmallSize];
    [secondLab setTextColor:[UIColor colorWithHexString:@"#888888"]];

    
    //banner 加两个黑箭头
    
    bannerSGFocusIndex = 0;
    
    UIImage *img = [UIImage imageNamed:@"img_arrow_left.png"];
    UIImageView *leftV = [[UIImageView alloc] initWithFrame:CGRectMake(0, (bannerView.frame.size.height-img.size.height)/2, img.size.width, img.size.height)];
    [leftV setImage:img];
    [bannerView addSubview:leftV];
    
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLeft setFrame:CGRectMake(0, (bannerView.frame.size.height-img.size.height)/2, img.size.width + 20, img.size.height)];
    [btnLeft addTarget:self action:@selector(showPerViewAction) forControlEvents:UIControlEventTouchUpInside];
    btnLeft.tag = 2001;
    [bannerView addSubview:btnLeft];
    
    
    UIImage *img2 = [UIImage imageNamed:@"img_arrow_right.png"];
    UIImageView *rightV = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth-img2.size.width, (bannerView.frame.size.height-img.size.height)/2, img.size.width, img.size.height)];
    [rightV setImage:img2];
    [bannerView addSubview:rightV];
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(ScreenWidth-img2.size.width-20, (bannerView.frame.size.height-img.size.height)/2, img.size.width + 20, img.size.height)];
    [btnRight addTarget:self action:@selector(showNextViewAction) forControlEvents:UIControlEventTouchUpInside];

    btnRight.tag = 2002;
    [bannerView addSubview:btnRight];
    
//    bannerView
    
    
    //限时抢购---------
    if (!buyNowView) {
        buyNowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, sepViewH + ScreenWidth*0.8125)];
    }
    for (UIView *view in buyNowView.subviews) {
        [view removeFromSuperview];
    }
    [buyNowView setBackgroundColor:[UIColor whiteColor]];
    
    UIImage *imageBuy = [UIImage imageNamed:@"time.png"];//
    UIImageView *imageCarV = [[UIImageView alloc] init];
    [imageCarV setFrame:CGRectMake(15, 15, imageBuy.size.width, imageBuy.size.height)];
    [imageCarV setImage:imageBuy];
    [buyNowView addSubview:imageCarV];
    UILabel *buyNowLab = [[UILabel alloc] initWithFrame:CGRectMake(15 + imageBuy.size.width + 5,15, 80, 20)];
    [buyNowLab setText:@"限时抢购"];
    [buyNowLab setNumberOfLines:1];
    [buyNowLab setTextAlignment:NSTextAlignmentCenter];
    buyNowLab.font = [UIFont systemFontOfSize:LabMidSize];
    [buyNowLab setTextColor:[UIColor colorWithHexString:@"#ff8a00"]];
    [buyNowView addSubview:buyNowLab];
    
    UILabel *timeLab = [[UILabel alloc] initWithFrame:CGRectMake(5,15 + buyNowLab.frame.size.height + 10, 100, 20)];
//    [timeLab setText:@"距离本场结束"];
    [timeLab setNumberOfLines:1];
    [timeLab setTextAlignment:NSTextAlignmentCenter];
    timeLab.font = [UIFont systemFontOfSize:LabSmallSize];
    [timeLab setTextColor:[UIColor colorWithHexString:@"#9b9b9b"]];
    [buyNowView addSubview:timeLab];
    
    UrlImageView *buynowV = [[UrlImageView alloc] initWithFrame:CGRectMake(10,50,lee1fitAllScreen(140),lee1fitAllScreen(180))];
    [buynowV setImageFromUrl:NO withUrl:_homeinfo.home_limitsale.pic];
    [buyNowView addSubview:buynowV];
    
    UIButton *buynowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [buynowBtn setFrame:CGRectMake(0, 0, ScreenWidth/2, buyNowView.frame.size.height)];
    [buynowBtn setBackgroundColor:[UIColor clearColor]];
    [buynowBtn addTarget:self action:@selector(gotoBuyNowViewC) forControlEvents:UIControlEventTouchUpInside];
    [buyNowView addSubview:buynowBtn];


    //热卖
    UIImage *imagehot = [UIImage imageNamed:@"hot.png"];
    UIImageView *imagev2 = [[UIImageView alloc] init];
    [imagev2 setFrame:CGRectMake(ScreenWidth/2 +15, 15, imageBuy.size.width, imageBuy.size.height)];
    [imagev2 setImage:imagehot];
    [buyNowView addSubview:imagev2];
    UILabel *hotLab = [[UILabel alloc] initWithFrame:CGRectMake(imagev2.frame.origin.x + imagev2.frame.size.width + 5,15, 50, 20)];
    [hotLab setText:@"热卖"];
    [hotLab setNumberOfLines:1];
    [hotLab setTextAlignment:NSTextAlignmentCenter];
    hotLab.font = [UIFont systemFontOfSize:LabMidSize];
    [hotLab setTextColor:[UIColor colorWithHexString:@"#ff001e"]];
    [buyNowView addSubview:hotLab];
    
    UrlImageView *hotimg = [[UrlImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2+35,38,lee1fitAllScreen(100),lee1fitAllScreen(86))];
    [hotimg setImageFromUrl:NO withUrl:_homeinfo.home_hot.pic];
    [buyNowView addSubview:hotimg];
    
    UIButton *hotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [hotBtn setFrame:CGRectMake(ScreenWidth/2, 0, ScreenWidth/2, buyNowView.frame.size.height/2)];
    [hotBtn setBackgroundColor:[UIColor clearColor]];
    [hotBtn addTarget:self action:@selector(gotoHotViewC) forControlEvents:UIControlEventTouchUpInside];
    [buyNowView addSubview:hotBtn];
    
    
    //搭配
    UILabel *matchLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2+15,buyNowView.frame.size.height/2 +15, 50, 20)];
    [matchLab setText:@"搭配"];
    [matchLab setNumberOfLines:1];
    [matchLab setTextAlignment:NSTextAlignmentCenter];
    matchLab.font = [UIFont systemFontOfSize:LabMidSize];
    [matchLab setTextColor:[UIColor colorWithHexString:@"#00a2ff"]];
    [buyNowView addSubview:matchLab];
    
    UrlImageView *matchV = [[UrlImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2+10,buyNowView.frame.size.height/2 +45,lee1fitAllScreen(60), lee1fitAllScreen(76))];
    [matchV setImageFromUrl:NO withUrl:_homeinfo.home_match.pic];
    [buyNowView addSubview:matchV];
    
    UIButton *matchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [matchBtn setFrame:CGRectMake(ScreenWidth/2, buyNowView.frame.size.height/2, ScreenWidth*1/4, buyNowView.frame.size.height/2)];
    [matchBtn setBackgroundColor:[UIColor clearColor]];
    [matchBtn addTarget:self action:@selector(gotoMatchViewC) forControlEvents:UIControlEventTouchUpInside];
    [buyNowView addSubview:matchBtn];
    
    
    
    
    //新品
    UILabel *newtLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth*3/4+15,buyNowView.frame.size.height/2 +15, 50, 20)];
    [newtLab setText:@"新品"];
    [newtLab setNumberOfLines:1];
    [newtLab setTextAlignment:NSTextAlignmentCenter];
    newtLab.font = [UIFont systemFontOfSize:LabMidSize];
    [newtLab setTextColor:[UIColor colorWithHexString:@"#ff001e"]];
    [buyNowView addSubview:newtLab];
    
    UrlImageView *newbtn = [[UrlImageView alloc] initWithFrame:CGRectMake(ScreenWidth*3/4+10,buyNowView.frame.size.height/2 + 45, lee1fitAllScreen(60), lee1fitAllScreen(76))];
    [newbtn setImageFromUrl:NO withUrl:_homeinfo.home_news.pic];
    [buyNowView addSubview:newbtn];
    
    UIButton *newBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [newBtn setFrame:CGRectMake(ScreenWidth*3/4,
                                buyNowView.frame.size.height/2,
                                ScreenWidth*3/4,
                                buyNowView.frame.size.height/2)];
    [newBtn setBackgroundColor:[UIColor clearColor]];
    [newBtn addTarget:self action:@selector(gotoNewViewC) forControlEvents:UIControlEventTouchUpInside];
    [buyNowView addSubview:newBtn];
    
    
    //sepLine
    UIView *sep1 = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth/2,0,0.5, buyNowView.frame.size.height)];
    [sep1 setBackgroundColor:[UIColor colorWithHexString:@"#d1d1d1"]];
    [buyNowView addSubview:sep1];
    
    UIView *sep2 = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth/2, buyNowView.frame.size.height/2,ScreenWidth/2, 0.5)];
    [sep2 setBackgroundColor:[UIColor colorWithHexString:@"#d1d1d1"]];
    [buyNowView addSubview:sep2];
    
    UIView *sep3 = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth* 3/4,buyNowView.frame.size.height/2,0.5, buyNowView.frame.size.height/2)];
    [sep3 setBackgroundColor:[UIColor colorWithHexString:@"#d1d1d1"]];
    [buyNowView addSubview:sep3];
    
    
    
    //为我推荐----------  V2
    if (!formeView) {
        formeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, sepViewH + forMeHeight +10)]; //原先是forMeHeight = 230
    }
    for (UIView *view in formeView.subviews) {
        [view removeFromSuperview];
    }
    [formeView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *formeLab = [[UILabel alloc] initWithFrame:CGRectMake(10,15, 100, 20)];
    [formeLab setText:@"为我推荐"];
    [formeLab setNumberOfLines:1];
    [formeLab setTextAlignment:NSTextAlignmentCenter];
    formeLab.font = [UIFont systemFontOfSize:LabBigSize];
    [formeLab setTextColor:[UIColor colorWithHexString:@"#000000"]];
    [formeView addSubview:formeLab];
    
    
    UIButton *formemorebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [formemorebtn setFrame:CGRectMake(ScreenWidth-80, 15, 60, 30)];
    [formemorebtn setTitle:@"更多推荐" forState:UIControlStateNormal];
    formemorebtn.titleLabel.font = [UIFont systemFontOfSize:LabSmallSize];
    [formemorebtn setTitleColor:[UIColor colorWithHexString:@"#d1d1d1"] forState:UIControlStateNormal];
    [formemorebtn addTarget:self action:@selector(gotoMoreRecommendViewC) forControlEvents:UIControlEventTouchUpInside];
    [formeView addSubview:formemorebtn];
    
    [formeView addSubview:[self createCellView:_homeinfo.home_more]];
    
}

//为我推荐的商品
-(UIView *)createCellView:(NSArray*)subSortArray{
    
//    int bgvH = 40;
//    int lineNum = 3; //每行的数量
//    
//    int ySP = 14;  //距离顶部的位置
//    int SP = 14;  //间距
//    int pW = 88;  //商品宽度
//    int pH = 180;  //商品高度
//    int imgH = 112; //商品图片的高度
//    //行数
//    int subSortbtnNum = 1;
    
    //----V2
    int bgvH = lee1fitAllScreen(40);
    int lineNum = 2; //每行的数量
    
    int ySP = lee1fitAllScreen(14);  //距离顶部的位置
    int SP = lee1fitAllScreen(13);  //间距
    int pW = lee1fitAllScreen(140);  //商品宽度
    int pH = lee1fitAllScreen(240);  //商品高度
    int imgH = lee1fitAllScreen(173); //商品图片的高度
    
    //行数
    int subSortbtnNum = 2;
    
    
    UIView *bgv = [[UIView alloc] initWithFrame:CGRectMake(0, bgvH, ScreenWidth, subSortbtnNum*pH)];
    [bgv setBackgroundColor:[UIColor clearColor]];
    
    
    UIView *linev = [[UIView alloc] initWithFrame:CGRectMake(SP, pH + 20, ScreenWidth - 2*SP, 0.5)];
    [linev setBackgroundColor:[UIColor colorWithHexString:@"#cacaca"]];
    [bgv addSubview:linev];
    
    
    for (int i = 0; i<subSortbtnNum; i++) {
        
        NSInteger jcount = ([subSortArray count]-lineNum*i)>lineNum?lineNum:([subSortArray count]-lineNum*i);
        
        for (int j = 0; j<jcount; j++) {
            
            
            NewhomeNormalData *item = (NewhomeNormalData*)[subSortArray objectAtIndex:j + i*lineNum isArray:nil];
            
            UIView *sortV = [[UIView alloc] initWithFrame:CGRectMake(SP + j*(pW+SP), ySP + i*(pH + ySP), pW, pH)];
            sortV.tag = j + i*lineNum;
            [bgv addSubview:sortV];
            
            [sortV setBackgroundColor:[UIColor whiteColor]];
            
            UrlImageView *buynowV = [[UrlImageView alloc] initWithFrame:CGRectMake(0, 0, pW, imgH)];
            [buynowV setImageFromUrl:NO withUrl:item.pic];
            buynowV.layer.borderWidth = 0.5;
            buynowV.layer.borderColor = [[UIColor colorWithHexString:@"e2e2e2"] CGColor];
            [sortV addSubview:buynowV];
            
            UILabel *namelab = [[UILabel alloc] initWithFrame:CGRectMake(0, imgH+5, pW, 40)];
            [namelab setNumberOfLines:2];
            [namelab setTextAlignment:NSTextAlignmentLeft];
            namelab.text = [NSString stringWithFormat:@"%@",item.name];
            namelab.font = [UIFont systemFontOfSize:LablitileSmallSize];
            [namelab setTextColor:[UIColor colorWithHexString:@"#444444"]];
            [sortV addSubview:namelab];
            
            
            UIFont *font = [UIFont systemFontOfSize:LabMidSize];
            CGSize pricelabSize = [[NSString stringWithFormat:@"￥%@",item.price.value] sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        
            UILabel *pricelab = [[UILabel alloc] initWithFrame:CGRectMake(0, imgH+45, pricelabSize.width, 26)];
            [pricelab setNumberOfLines:1];
            [pricelab setTextAlignment:NSTextAlignmentLeft];
            pricelab.text = [NSString stringWithFormat:@"￥%@",item.price.value];
            pricelab.font = [UIFont systemFontOfSize:LabMidSize];
            [pricelab setTextColor:[UIColor colorWithHexString:@"#C70000"]];
            [sortV addSubview:pricelab];
            
            
            UILabel *pricelab2 = [[UILabel alloc] initWithFrame:CGRectMake(10+ pricelabSize.width, imgH+45, pW-10, 26)];
            [pricelab2 setNumberOfLines:1];
            [pricelab2 setTextAlignment:NSTextAlignmentLeft];
            pricelab2.text = [NSString stringWithFormat:@"￥%@",item.price1.value];
            pricelab2.font = [UIFont systemFontOfSize:LabMidSize];
            [pricelab2 setTextColor:[UIColor colorWithHexString:@"#888888"]];
            [sortV addSubview:pricelab2];
            
            //价格上的划线
            CGSize pricelab2Size = [[NSString stringWithFormat:@"￥%@",item.price1.value] sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 15)];
            
            UIView *pricelab2V = [[UIView alloc] initWithFrame:CGRectMake(15+ pricelabSize.width, pricelab2.frame.origin.y + 14, pricelab2Size.width, 0.5)];
            [pricelab2V setBackgroundColor:[UIColor colorWithHexString:@"888888"]];
            [sortV addSubview:pricelab2V];
            
            
            MyButton *sortbtn = [MyButton buttonWithType:UIButtonTypeCustom];
            [sortbtn setFrame:CGRectMake(SP + j*(pW+SP), ySP + i*(pH + ySP), pW, pH)];
            [sortbtn addTarget:self action:@selector(gotoProductDetailViewAciton:) forControlEvents:UIControlEventTouchUpInside];
            [sortbtn setBackgroundColor:[UIColor clearColor]];
            sortbtn.addstring = item.goodid;
            sortbtn.addtitle = item.name;
            [bgv addSubview:sortbtn];
        }
    }
    return bgv;
}


#pragma mark--- Action


//---banner回滚上一页
-(void)showPerViewAction{
    
    [bannerSGFocus scrollToIndex:bannerSGFocusIndex-1];
}
//---banner翻到下一页
-(void)showNextViewAction{

    if ([_homeinfo.home_banner count] -1 == bannerSGFocusIndex) {
        [bannerSGFocus scrollToIndex:0];
    }else{
        [bannerSGFocus scrollToIndex:bannerSGFocusIndex+1];
    }
}


-(void)gotoProductDetailViewAciton:(MyButton*)btn{
    
    ProductDetailViewController *jumpVC=[[ProductDetailViewController alloc]init];
    jumpVC.thisProductId=btn.addstring;
    jumpVC.ThisPorductName=btn.addtitle;
    jumpVC.source_id=@"1002";
    jumpVC.isHiddenBar = YES;
    [self.navigationController pushViewController:jumpVC animated:YES];
}


//W为我推荐的  更多推荐
-(void)gotoMoreRecommendViewC{

    
    ProductlistViewController *hot = [[ProductlistViewController alloc] init];
    //lee999 新增   为我推荐的更多推荐   5
    [SingletonState sharedStateInstance].productlistType = 5;
    hot.titleName = @"更多推荐";
    hot.isHiddenFilerbtn = YES;
    //需要追加参数 category == 3267
//    hot.isHot = NO;
//    hot.isOrder = NO;
    [self.navigationController pushViewController:hot animated:YES];

}


//搜索
-(void)gotoSearchViewC{
    
    
#warning ----test lee999
    MyCloset1ViewController *vc1 = [[MyCloset1ViewController alloc] initWithNibName:@"MyCloset1ViewController" bundle:nil];
    [self.navigationController pushViewController:vc1 animated:YES];
    
    return;
    
    
    SearchpageViewController *searchVC = [[SearchpageViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

//附近的店
-(void)gotoNearByShop{
    
    AMMapViewController *nearByVC = [[AMMapViewController alloc] init];
    [self.navigationController pushViewController:nearByVC animated:YES];
    
}

//杂志
-(void)gotoMaginzeViewCwithType:(id)atype{

    UIButton *btn = (UIButton*)atype;
    
    NewhomeNormalData *data = [_homeinfo.home_navi objectAtIndex:btn.tag isArray:nil];

    NSString *str = @"专辑";
    if ([data.atype description].length > 0) {
        str = [data.atype description];
    }
    
    NewMaginzeListViewController *mvc = [[NewMaginzeListViewController alloc] init];
    mvc.isShowSwitchBtn = YES;
    mvc.strtitle = str;
    mvc.params = data.params;
    [self.navigationController pushViewController:mvc animated:YES];
    
}


//限时特卖   跳入专题
-(void)gotoBuyNowViewC{
    

    [self.navigationController pushViewController:[LBaseViewController bannerJumpTo:[[_homeinfo.home_limitsale atype] intValue]
                                                                       withtypeArgu:[_homeinfo.home_limitsale type_argu]
                                                                          withTitle:[_homeinfo.home_limitsale title]
                                                                         andIsRight:NO
                                                   ] animated:YES];
}

//热卖
-(void)gotoHotViewC{

    HotpageViewController *hot = [[HotpageViewController alloc] init];
    hot.isHot = YES;
    [self.navigationController pushViewController:hot animated:YES];
}

//搭配  搭配进入搭配杂志界面
-(void)gotoMatchViewC{
    
    NewMaginzeListViewController *mvc = [[NewMaginzeListViewController alloc] init];
    mvc.isShowSwitchBtn = NO;
    mvc.strtitle = _homeinfo.home_match.atype;
    [self.navigationController pushViewController:mvc animated:YES];
}

//新品
-(void)gotoNewViewC{
    
    ProductlistViewController *hot = [[ProductlistViewController alloc] init];
    [SingletonState sharedStateInstance].productlistType = 0;
    hot.isHot = NO;
    hot.isOrder = NO;
    [self.navigationController pushViewController:hot animated:YES];
}

//显示提示窗
-(void)showERcodeViewAction:(id)sender{

    UIButton*btn = (UIButton*)sender;
    
    PlayNDropViewController *popin = [[PlayNDropViewController alloc] init];
    popin.view.bounds = CGRectMake(20, 0, ScreenWidth -40, lee1fitAllScreen(310));
    popin.view.backgroundColor = [UIColor whiteColor];
    [popin setPopinTransitionStyle:BKTPopinTransitionStyleSnap];
    //[popin setPopinOptions:BKTPopinDisableAutoDismiss];
    BKTBlurParameters *blurParameters = [[BKTBlurParameters alloc] init];
    //blurParameters.alpha = 0.5;
    blurParameters.tintColor = [UIColor colorWithWhite:0 alpha:0.5];
    blurParameters.radius = 0.3;
    [popin setBlurParameters:blurParameters];
    [popin setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
    //popin.presentingController = self;
    
    
    UIImageView *ercodeV = [[UIImageView alloc] initWithFrame:CGRectMake(30, 40, popin.view.bounds.size.width-20, popin.view.bounds.size.height - 50)];
    [popin.view addSubview:ercodeV];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 230, 30)];
    [titleLab setNumberOfLines:2];
    [titleLab setTextAlignment:NSTextAlignmentLeft];
    titleLab.font = [UIFont systemFontOfSize:LabMidSize];
    [titleLab setTextColor:[UIColor colorWithHexString:@"#444444"]];
    [titleLab setBackgroundColor:[UIColor clearColor]];
    [popin.view addSubview:titleLab];
    if (btn.tag == 100) {
        [titleLab setText:@"请扫描微信二维码关注我们"];
        [ercodeV setImage:[UIImage imageNamed:@"aimerWeiXinErCode.png"]];
    }else{
        [titleLab setText:@"请扫描微博二维码关注我们"];
        [ercodeV setImage:[UIImage imageNamed:@"aimerWeiboErCode.png"]];
    }
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *unSelectedImg = [UIImage imageNamed:@"closeBtn.png"];
    UIImage *selectedImg = [UIImage imageNamed:@"closeBtn.png"];
    [photoBtn setBackgroundImage:unSelectedImg forState:UIControlStateNormal];
    [photoBtn setBackgroundImage:selectedImg forState:UIControlStateHighlighted];
    [photoBtn addTarget:self action:@selector(closePresentView) forControlEvents:UIControlEventTouchUpInside];
    photoBtn.frame = CGRectMake(lee1fitAllScreen(270), 10, 20, 20);
    [popin.view addSubview:photoBtn];
    
    
    [self presentPopinController:popin animated:YES completion:^{
        NSLog(@"Popin presented !");
    }];
}

-(void) closePresentView{
    [self dismissCurrentPopinControllerAnimated:YES];
}


#pragma mark---banner 事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(UITapGestureRecognizer*)item{

    NewhomeNormalData *bannerModel = (NewhomeNormalData *)[_homeinfo.home_banner objectAtIndex:[item.view tag]-132];
    
    //lee999埋点
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[bannerModel type_argu], @"TopicID", [bannerModel title], @"ActivityName",nil];
    [TalkingData trackEvent:@"1001" label:@"横屏首页轮播" parameters:dic];
    NSLog(@"banner跳转类型是：-----%d",[[bannerModel atype] intValue]);
    
    [self.navigationController pushViewController:[LBaseViewController bannerJumpTo:[[bannerModel atype] intValue]
                                                                       withtypeArgu:[bannerModel type_argu]
                                                                          withTitle:[bannerModel title]
                                                                         andIsRight:NO
                                                   ] animated:YES];

}

- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame currentItem:(int)index{
    
    bannerSGFocusIndex = index;

    NewhomeNormalData *data = [_homeinfo.home_banner objectAtIndex:index isArray:nil];

    firstLab.text = data.title;
    NSString* str =[data.titledes stringByAppendingString:@"\n "];
    secondLab.text = str;
}


-(void)stopRefalsh{
    [myTableV headerEndRefreshing];
}


#pragma mark-- tableView

// Section的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

// row的个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// Section的 head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 0.1;
    }
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    [view setBackgroundColor:[UIColor colorWithHexString:@"E6E6E6"]];
    return view;
}

// row的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    switch ([indexPath section]) {
        case 0:
            //杂志
            //return 450 + sepViewH;
            return ScreenWidth*1.406 + sepViewH;

            break;
            
        case 1:
            //banner
            //return 405 + sepViewH;
            return ScreenWidth*1.2656 + sepViewH;

            break;
            
        case 2:
            //限时抢购
            //return 260 + sepViewH +10;
            return ScreenWidth*0.8125 + sepViewH +10;
            break;
            
        case 3:
            //为我推荐
            //return 230 + sepViewH;
            return forMeHeight + 20 + sepViewH;

            break;
            
        case 4: //私人衣橱
            return 45 + sepViewH;
            break;
            
        default:
            break;
    }
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * showUserInfoCellIdentifier = @"ShowUserInfoCell";

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    switch ([indexPath section]) {
        case 0:
        {
            //杂志入口
            [cell addSubview:magizeView];
            
        }
            break;
            
        case 1:
        {
            //banner
            [cell setBackgroundColor:[UIColor colorWithHexString:@"F1F1F1"]];
            [cell addSubview:bannerView];
            [cell addSubview:firstLab];
            [cell addSubview:secondLab];
            
            UIView *spV1 = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenWidth*1.2656 -0.5, ScreenWidth, 0.5)];
            [spV1 setBackgroundColor:[UIColor colorWithHexString:@"d1d1d1"]];
            [cell addSubview:spV1];

        }
            break;
            
        case 2:
        {
            //限时抢购
            [cell addSubview:buyNowView];
            /*
            UIView *homeV1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 260)];
            [homeV1 setBackgroundColor:[UIColor greenColor]];
            [cell addSubview:homeV1];
             */
        }
            break;
            
        case 3:
        {
            //为我推荐
            [cell addSubview:formeView];
        }
            break;
            
        case 4: //私人衣橱
        {
            UIView *homeV1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
            [homeV1 setBackgroundColor:[UIColor whiteColor]];
            [cell addSubview:homeV1];
            
            UIImageView *iconImgV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 13, 23, 17)];
            [iconImgV setImage:[UIImage imageNamed:@"list_close.png"]];
            [cell addSubview:iconImgV];
            
            
            UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(48, 12, 100, 25)];
            [titleLab setText:@"私人衣橱"];
            [titleLab setNumberOfLines:2];
            titleLab.font = [UIFont systemFontOfSize:LabMidSize];
            [titleLab setTextColor:[UIColor colorWithHexString:@"#000000"]];
            [cell addSubview:titleLab];

        }
            break;
            
        default:
            break;
    }
    // Configure the cell.
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([indexPath section] == 4) {
        MyCloset1ViewController *vc1 = [[MyCloset1ViewController alloc] initWithNibName:@"MyCloset1ViewController" bundle:nil];
        [self.navigationController pushViewController:vc1 animated:YES];
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end






//分割线
//    UIView *spview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
//    [spview setBackgroundColor:[UIColor colorWithHexString:@"D4D4D4"]];
//    [cell bringSubviewToFront:spview];
//    [cell addSubview:spview];
//
//
//    UIView *spview2 = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-10, ScreenWidth, 0.5)];
//    [spview2 setBackgroundColor:[UIColor colorWithHexString:@"D4D4D4"]];
//    [cell bringSubviewToFront:spview2];
//    [cell addSubview:spview2];


//    if ([indexPath section] == 0) {

//        [cell addSubview:_bannerView];
//        [cell addSubview:subSortView];
//    }


//    if ([indexPath section]!= 0 &&[indexPath row] == 0) {
//        //第0行加分区
//        UIView* sectionheaderV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
//        [sectionheaderV setBackgroundColor:[UIColor whiteColor]];
//
//        if ([self.arrsti count]>0) {
//
//            NSString *imgurl = [[self.arrsti objectAtIndex:[indexPath section]-1 isArray:nil] objectForKey:@"subimg"];
//            UrlImageView *imageView = [[UrlImageView alloc] initWithFrame:CGRectMake(10,10,25,25)];
//            imageView.layer.masksToBounds = YES;
//            [imageView setImageFromUrl:YES withUrl:imgurl];
//            [sectionheaderV addSubview:imageView];
//
//            NSString *subtitle = [[self.arrsti objectAtIndex:[indexPath section]-1 isArray:nil] objectForKey:@"subtitle"];
//            UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, ScreenWidth-45, 35)];
//            [titleLab setText:subtitle];
//            titleLab.font = [UIFont systemFontOfSize:LabLittleBigSize];
//            [titleLab setTextColor:[UIColor colorWithHexString:@"#463417"]];
//            [sectionheaderV addSubview:titleLab];
//        }
//
//        //分割线
//        UIView *spview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
//        [spview setBackgroundColor:[UIColor colorWithHexString:@"E8E6E0"]];
//        [sectionheaderV bringSubviewToFront:spview];
//        [sectionheaderV addSubview:spview];
//
//        UIView *spview2 = [[UIView alloc] initWithFrame:CGRectMake(0, sectionheaderV.frame.size.height-0.5, ScreenWidth,0.5)];
//        [spview2 setBackgroundColor:[UIColor colorWithHexString:@"E8E6E0"]];
//        [sectionheaderV addSubview:spview2];
//
//        [cell addSubview:sectionheaderV];
//    }

//添加店铺
//    if ([indexPath section] == 1 && [indexPath row] != 0) {
//        [cell addSubview:shopscrollView];
//    }

//    if ([indexPath section] == 2) {
//
//        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
//
//        if ([indexPath row] != 0) {
//            //加具体商品列表
//
//            int index = [indexPath row] -1;
//
//            NSString *imageurl = [[itemArray objectAtIndex:index isArray:nil] objectForKey:@"imgUrl"];
//            NSString *namelab = [[itemArray objectAtIndex:index isArray:nil] objectForKey:@"title"];
//            NSString *pricelab1 = [[itemArray objectAtIndex:index isArray:nil] objectForKey:@"price"];
//            NSString *pricelab2 = [[itemArray objectAtIndex:index isArray:nil] objectForKey:@"itemPrice"];
//
//            NSString *realpricelab = [[itemArray objectAtIndex:index isArray:nil] objectForKey:@"resultPrice"];
//            if ([realpricelab description].length >0) {
//                realpricelab = [NSString stringWithFormat:@"%.2f",[realpricelab floatValue]/100];
//            }else{
//                realpricelab = @"";
//            }
//
//
//            NSString * strpricelab = @"";
//            if ([pricelab1 description].length>0) {
//                strpricelab = [NSString stringWithFormat:@"%.2f",[pricelab1 floatValue]/100];
//            }else if([pricelab2 description].length >0)
//            {
//                strpricelab = [NSString stringWithFormat:@"%.2f",[pricelab2 floatValue]/100];
//            }
//
//
//            UrlImageView *imageView = [[UrlImageView alloc] initWithFrame:CGRectMake(10, 10,80, 80)];
//            [imageView setImageFromUrl:YES withUrl:imageurl];
//            [cell addSubview:imageView];
//
//            UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, ScreenWidth-120, 45)];
//            [titleLab setText:namelab];
//            [titleLab setNumberOfLines:2];
//            titleLab.font = [UIFont systemFontOfSize:LabSmallSize];
//            [titleLab setTextColor:[UIColor colorWithHexString:@"#463417"]];
//            [cell addSubview:titleLab];
//
//            UIImageView *imageCarV = [[UIImageView alloc] init];
//            [imageCarV setFrame:CGRectMake(ScreenWidth-20-20, 74, 15, 15)];
//            [imageCarV setImage:[UIImage imageNamed:@"addtocar.png"]];
//            [cell addSubview:imageCarV];
//
//            MyButton *sortbtn = [MyButton buttonWithType:UIButtonTypeCustom];
//            sortbtn.tag = index;
//            [sortbtn setFrame:CGRectMake(ScreenWidth-20-20-20-20, 70, 25, 25)];
//            [sortbtn setImage:[UIImage imageNamed:@"shareicon.png"] forState:UIControlStateNormal];
//            [sortbtn setImage:[UIImage imageNamed:@"shareicon.png"] forState:UIControlStateSelected];
//            [sortbtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
//            sortbtn.addstring = [[itemArray objectAtIndex:index isArray:nil] objectForKey:@"title"];
//            sortbtn.addimageurl = imageurl;
//            [cell addSubview:sortbtn];
//
//            //现在价格
//            UILabel *priceRealLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 45, ScreenWidth-100, 35)];
//            if ([realpricelab description].length >0) {
//                [priceRealLab setText:[NSString stringWithFormat:@"￥%@",realpricelab]];
//            }else{
//                [priceRealLab setText:@""];
//            }
//            priceRealLab.font = [UIFont systemFontOfSize:LabLittleBigSize];
//            [priceRealLab setTextColor:[UIColor colorWithHexString:@"#f83a43"]];
//            [cell addSubview:priceRealLab];
//
//            //原价
//            YKStrikePriceLabel* priceLab = [[YKStrikePriceLabel alloc] initWithColor:[UIColor colorWithHexString:@"#d2c9b6"] andOffset:0];
//
//            priceLab.font = [UIFont systemFontOfSize:LabSmallSize];
//            if ([strpricelab description].length > 0) {
//                [priceLab setText:[NSString stringWithFormat:@"￥%@",strpricelab]];
//            }else{
//                [priceLab setText:@""];
//            }
//            [priceLab setTextColor:[UIColor colorWithHexString:@"#d2c9b6"]];
//            [priceLab setFrame:CGRectMake(100, 65, [Common sizeForString:priceLab.text withFont:priceLab.font].width, 35)];
//            [cell addSubview:priceLab];
//
//            //折扣标签
//            int rightDisX = priceRealLab.frame.origin.x + [Common sizeForString:priceRealLab.text withFont:priceRealLab.font].width + 10;
//
//            UILabel *rightDisCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(rightDisX, 55, 40, 15)];
//            rightDisCountLabel.layer.cornerRadius = 8.0;
//            rightDisCountLabel.layer.masksToBounds = YES;
//            rightDisCountLabel.hidden =  NO;
//            rightDisCountLabel.textAlignment = NSTextAlignmentCenter;
//            if ([realpricelab description].length > 0 && [strpricelab description].length > 0) {
//                rightDisCountLabel.text = [NSString stringWithFormat:@"%.1f折",([realpricelab floatValue])*10/[strpricelab floatValue]];
//                if ([realpricelab floatValue] == [strpricelab floatValue] ||
//                    [priceRealLab.text description].length < 1 ||
//                    [priceLab.text description].length < 1
//                    ) {
//                    rightDisCountLabel.hidden = YES;
//                }else{
//                    rightDisCountLabel.hidden = NO;
//                }
//            }else{
//                rightDisCountLabel.text = @"";
//            }
//            rightDisCountLabel.font = [UIFont systemFontOfSize:LabSmallSize];
//            [rightDisCountLabel setTextColor:[UIColor colorWithHexString:@"#ffffff"]];
//            [rightDisCountLabel setBackgroundColor:[UIColor colorWithHexString:@"#f83a43"]];
//            [cell addSubview:rightDisCountLabel];
//
//            //分割线
//            UIView *spview = [[UIView alloc] initWithFrame:CGRectMake(0, 100-0.5, ScreenWidth, 0.5)];
//            [spview setBackgroundColor:[UIColor colorWithHexString:@"E8E6E0"]];
//
//            [cell addSubview:spview];
//
//        }
//    }

