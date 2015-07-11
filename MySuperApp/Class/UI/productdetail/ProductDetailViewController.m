//
//  ProductDetailViewController.m
//  MySuperApp
//
//  Created by lee on 14-4-2.
//  Copyright (c) 2014年 aimer. All rights reserved.
//isFromCar

#import "ProductDetailViewController.h"
#import "UrlImageButton.h"
#import "YKStrikePriceLabel.h"
#import "YKProductDetailCell.h"
#import "ProductDetailInfoViewController.h"
#import "ProductShareViewController.h"
#import "ProductShareView.h"
#import "ProductBannerViewController.h"
#import "ShowcomMentViewController.h"
#import "YKPreferentialSuit.h"
#import "MyAimerViewController.h"
#import "YKCanReuse_webViewController.h"

#import "ShareUnit.h"
#import "BfdAgent.h"

//pick显示出来时候的高度
#define PickShowHigh 265.+50.

#define CELL_WITH_0_LAB_X_0 20
#define CELL_WITH_0_LAB_Y_0 0
#define CELL_WITH_0_LAB_H 24.
#define CELL_WITH_0_LAB_W_1 180.
#define COLORBUTTON 50

#define CELL_WITH_0_LAB_FRAME_0 CGRectMake(CELL_WITH_0_LAB_X_0, CELL_WITH_0_LAB_Y_0-6, ScreenWidth-40, 50)
#define CELL_WITH_0_LAB_FRAME_1 CGRectMake(CELL_WITH_0_LAB_X_0, CELL_WITH_0_LAB_Y_0+CELL_WITH_0_LAB_H+37, CELL_WITH_0_LAB_W_1, CELL_WITH_0_LAB_H)
// 网站价（名字）
#define CELL_WITH_0_LAB_FRAME_2 CGRectMake((ScreenWidth / 2) + 20, CELL_WITH_0_LAB_Y_0+CELL_WITH_0_LAB_H+37, CELL_WITH_0_LAB_W_1, CELL_WITH_0_LAB_H)
// 市场价
#define CELL_WITH_0_LAB_FRAME_4 CGRectMake(CELL_WITH_0_LAB_X_0, (CELL_WITH_0_LAB_Y_0 + 3 * CELL_WITH_0_LAB_H)+10, CELL_WITH_0_LAB_W_1, CELL_WITH_0_LAB_H)
// 节省了
#define CELL_WITH_0_LAB_FRAME_6 CGRectMake((ScreenWidth / 2) + 20, (CELL_WITH_0_LAB_Y_0 + 3 * CELL_WITH_0_LAB_H)+10, CELL_WITH_0_LAB_W_1, CELL_WITH_0_LAB_H)

#define CELL_WITH_0_LAB_FRAME_PRICE CGRectMake((ScreenWidth / 2) + 20, CELL_WITH_0_LAB_Y_0+30, CELL_WITH_0_LAB_W_1, CELL_WITH_0_LAB_H)

#define CELL_WITH_0_LAB_FRAME_PRICE_MARKET CGRectMake(CELL_WITH_0_LAB_X_0, CELL_WITH_0_LAB_Y_0+30, CELL_WITH_0_LAB_W_1, CELL_WITH_0_LAB_H)

#define CELL_WITH_0_LAB_FRAME_PRICE_MARKET_2 CGRectMake(CELL_WITH_0_LAB_X_0+40, CELL_WITH_0_LAB_Y_0+30, 60, CELL_WITH_0_LAB_H)

#define CELL_WITH_0_LAB_FRAME_PRICE_Aimer CGRectMake(CELL_WITH_0_LAB_X_0, CELL_WITH_0_LAB_Y_0+30, 200, CELL_WITH_0_LAB_H)

//尺码，颜色，价格，标签
#define CELL_WITH_1_LAB_FRAME_0 CGRectMake(20, 0.+3.5, 34., 42.)
#define CELL_WITH_1_LAB_FRAME_1 CGRectMake((ScreenWidth / 2) + 20, 0.+3.5, 34., 42.)
#define CELL_WITH_1_SIZE_LAB_FRAME_1 CGRectMake(10.+210, 0.+3.5, 34., 42.)



@implementation UIViewForRecursively
@synthesize scroll;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        return scroll;
    }
    return nil;
}
@end

@interface ProductDetailViewController ()<mobideaRecProtocol>
{
    MainpageServ *mainSev;
    
    BOOL isgoodHasAddFav;//单品是否添加过收藏
    
    UrlImageView* shareImgV;
    
}
@property (nonatomic, retain) UIScrollView* scrollViewForHeader;
@property (nonatomic, retain) UITableView* detailTab;//大表
@property (nonatomic, retain) UIView* vToolbar;
@end



@implementation ProductDetailViewController
@synthesize isFromMyAimer;
@synthesize isFromCar;
@synthesize isHiddenBar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"商品详情";
    
    isgoodHasAddFav = NO;
    
    [self createBackBtnWithType:0];
    mainSev = [[MainpageServ alloc] init];
    mainSev.delegate = self;
    //创建右边按钮
    [self createRightBtn];
    [self.navbtnRight setTitle:@"" forState:UIControlStateNormal];
    [self.navbtnRight setTitle:@"" forState:UIControlStateHighlighted];
    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@"nav_icon_share.png"] forState:UIControlStateNormal];
    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@"nav_icon_share_press.png"] forState:UIControlStateHighlighted];
    [self.navbtnRight setFrame:CGRectMake(242, 7, 30, 30)];
    
    isAddtoCar = NO;
    
    
    didSelectColor = -1;
    currentColor = 0;
    currentSize = 0;
    currentNumber = 0;
    buttonsForSize = [[NSMutableArray alloc] init];
    
    //lee894设置首页的高度~~
    //适配屏幕及系统版本
    [self.view addSubview:self.detailTab];
    [self.view addSubview:self.vToolbar];
    [self.view addConstraints:[self viewConstraints]];
    //创建表头	表尾
    [self createTableHeaderView];
    
    [self createtoolbarandpicker];
    
    [self loadData1];

    
    _product_id=[[NSString alloc]init];
    
    recordNUM=1;
    
    NSString *str = @"";
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"usersession"]) {
        str = [[NSUserDefaults standardUserDefaults]objectForKey:@"usersession"];
    }
    [BfdAgent visit:self itemId:self.thisProductId options:@{@"uid":str}];
}

-(NSArray*)viewConstraints
{
    NSDictionary *views = @{@"detailTab" : self.detailTab, @"vToolbar" : self.vToolbar};
    NSDictionary *metrics = @{@"barHeight" : [NSNumber numberWithFloat:lee1fitAllScreen(50)]};
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailTab][vToolbar(barHeight)]|" options:0 metrics:metrics views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[vToolbar]|" options:0 metrics:metrics views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[detailTab]|" options:0 metrics:metrics views:views]];
    return constraints;
}

-(UITableView *)detailTab
{
    if (_detailTab) {
        return _detailTab;
    }
    _detailTab=[[UITableView alloc] init];
//    _detailTab.delegate=self;
//    _detailTab.dataSource=self;
    _detailTab.backgroundColor=[UIColor whiteColor];
    _detailTab.separatorStyle=UITableViewCellSeparatorStyleNone;
    [_detailTab setTranslatesAutoresizingMaskIntoConstraints:NO];
    _detailTab.hidden = YES;
    return _detailTab;
}

-(UIView *)vToolbar
{
    if (_vToolbar) {
        return _vToolbar;
    }
    _vToolbar = [[UIView alloc] init];
    [_vToolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
    return _vToolbar;
}

-(void)mobidea_Recs:(NSError *)error feedback:(id)feedback{
    NSLog(@"----%@---%ld----%@",[error domain],(long)[error code],feedback);
}


-(void)createtoolbarandpicker{

    //创建数量PickeView
    numberProduct = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < 10 ; i++) {
        [numberProduct addObject:[NSString stringWithFormat:@"%d",i]];
    }
    pickerForSelectNumber=[[UIPickerView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 216)];
    [pickerForSelectNumber setDelegate:self];
    [pickerForSelectNumber setDataSource:self];
    pickerForSelectNumber.showsSelectionIndicator=YES;
    //    [self.view addSubview:pickerForSelectNumber];
    [[MyAppDelegate window] addSubview:pickerForSelectNumber];
    
    
    //创建toolbar
    toolBarForNumber=[[UIToolbar alloc] initWithFrame:CGRectMake(0, ScreenHeight+20, ScreenWidth, 44)];
    toolBarForNumber.barStyle=UIBarStyleBlackTranslucent;
    //    [self.view addSubview:toolBarForNumber];
    [[MyAppDelegate window] addSubview:toolBarForNumber];
    
    //toolbar上地按钮
    UIBarButtonItem *buttonForCancel_Number=[[UIBarButtonItem alloc] initWithTitle:@"  取消" style:UIBarButtonItemStyleBordered target:self action:@selector(BarButtonClick:)];
    if (isIOS7up) {
        buttonForCancel_Number.tintColor = [UIColor whiteColor];
    }
    buttonForCancel_Number.tag=101;
    UIBarButtonItem *buttonForFix_Number=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:@selector(BarButtonClick:)];
    buttonForFix_Number.width=lee1fitAllScreen(210);
    UIBarButtonItem *buttonForDone_Number=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(BarButtonClick:)];
    if (isIOS7up) {
        buttonForDone_Number.tintColor = [UIColor whiteColor];
    }
    buttonForDone_Number.tag=102+10;
    [toolBarForNumber setItems:[NSArray arrayWithObjects:buttonForCancel_Number,buttonForFix_Number,buttonForDone_Number,nil]];
    
    //创建picker
    //    颜色的pickeView
    pickerForSelectColor=[[UIPickerView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 216)];
    [pickerForSelectColor setDelegate:self];
    [pickerForSelectColor setDataSource:self];
    pickerForSelectColor.showsSelectionIndicator=YES;
    //    [self.view addSubview:pickerForSelectColor];
    [[MyAppDelegate window] addSubview:pickerForSelectColor];
    //    尺寸的Pickview
    pickerForSelectSize=[[UIPickerView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 216)];
    [pickerForSelectSize setDelegate:self];
    [pickerForSelectSize setDataSource:self];
    pickerForSelectSize.showsSelectionIndicator=YES;
    //    [self.view addSubview:pickerForSelectSize];
    [[MyAppDelegate window] addSubview:pickerForSelectSize];
    
    //创建toolbar
    toolBarForPicker=[[UIToolbar alloc] initWithFrame:CGRectMake(0, ScreenHeight+20, ScreenWidth, 44)];
    toolBarForPicker.hidden = YES;
    toolBarForPicker.barStyle=UIBarStyleBlackTranslucent;
    //    [self.view addSubview:toolBarForPicker];
    [[MyAppDelegate window] addSubview:toolBarForPicker];
    toolBarForSizePicker=[[UIToolbar alloc] initWithFrame:CGRectMake(0, ScreenHeight+20, ScreenWidth, 44)];
    toolBarForSizePicker.barStyle=UIBarStyleBlackTranslucent;
    //    [self.view addSubview:toolBarForSizePicker];
    [[MyAppDelegate window] addSubview:toolBarForSizePicker];
    
    //toolbar上地按钮
    UIBarButtonItem *buttonForCancel=[[UIBarButtonItem alloc] initWithTitle:@"  取消" style:UIBarButtonItemStyleBordered target:self action:@selector(BarButtonClick:)];
    if (isIOS7up) {
        buttonForCancel.tintColor = [UIColor whiteColor];
    }
    buttonForCancel.tag=101;
    UIBarButtonItem *buttonForFix=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:@selector(BarButtonClick:)];
    buttonForFix.width=lee1fitAllScreen(210);
    UIBarButtonItem *buttonForDone=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(BarButtonClick:)];
    if (isIOS7up) {
        buttonForDone.tintColor = [UIColor whiteColor];
    }
    buttonForDone.tag=102;
    [toolBarForPicker setItems:[NSArray arrayWithObjects:buttonForCancel,buttonForFix,buttonForDone,nil]];
    
    
    UIBarButtonItem *buttonForCancel_size=[[UIBarButtonItem alloc] initWithTitle:@"  取消" style:UIBarButtonItemStyleBordered target:self action:@selector(BarButtonClick:)];
    if (isIOS7up) {
        buttonForCancel_size.tintColor = [UIColor whiteColor];
    }
    buttonForCancel_size.tag=101+100;
    UIBarButtonItem *buttonForFix_size=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:@selector(BarButtonClick:)];
    buttonForFix_size.width=lee1fitAllScreen(210);
    UIBarButtonItem *buttonForDone_size=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(BarButtonClick:)];
    if (isIOS7up) {
        buttonForDone_size.tintColor = [UIColor whiteColor];
    }
    buttonForDone_size.tag=102+100;
    [toolBarForSizePicker setItems:[NSArray arrayWithObjects:buttonForCancel_size,buttonForFix_size,buttonForDone_size,nil]];
    
    pickerForSelectColor.backgroundColor = [UIColor whiteColor];
    pickerForSelectNumber.backgroundColor = [UIColor whiteColor];
    pickerForSelectSize.backgroundColor = [UIColor whiteColor];

}



/**
 *	页面出现时根据条件请求
 *  @return (void)
 */
- (void)viewWillAppear:(BOOL) animated
{
    [self NewHiddenTableBarwithAnimated:YES];

    
    
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"1002", @"PageID",nil];
    [TalkingData trackEvent:@"4" label:@"APP启动" parameters:dic1];
    
    isAddFav=NO;
    self.navigationItem.rightBarButtonItem.enabled=YES;
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"action"];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"enterDetial"];
    
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"disable", nil];
	[[NSNotificationCenter defaultCenter]postNotificationName:@"enable" object:nil userInfo:dic];
    [self hiddenBar];
    [super viewWillAppear:animated];
}

/**
 *	创建表头视图，即在UIView上放UIImageView、UIViewForRecursively、UIScrollView、UIPageControl
 *  @return (void)
 */
-(void)createTableHeaderView{ //done
//    headerView=[[UIViewForRecursively alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 192)];
    
    _scrollViewForHeader = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth)];
    _scrollViewForHeader.showsHorizontalScrollIndicator = NO;
    _scrollViewForHeader.showsVerticalScrollIndicator = NO;
    _scrollViewForHeader.scrollsToTop = NO;
    _scrollViewForHeader.delegate = self;
    _scrollViewForHeader.bounces=YES;
    _scrollViewForHeader.clipsToBounds=NO;
    _scrollViewForHeader.pagingEnabled=YES;
//    _scrollViewForHeader.contentOffset=CGPointMake(160, 0);
    _scrollViewForHeader.backgroundColor=[UIColor clearColor];
    
    
//    _scrollViewForHeader=scrollViewForHeader;//指定一下 不增加引用计数
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth)];
//    [view addSubview:headerView];
    [view addSubview:_scrollViewForHeader];
    view.backgroundColor=[UIColor clearColor];
    
    pgControlForScroll=[[MyPageControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, view.frame.size.height - 10 - 3, 6, 10)];
    pgControlForScroll.backgroundColor=[UIColor clearColor];
    pgControlForScroll.currentPage=0;
    [pgControlForScroll setImagePageStateNormal:[UIImage imageNamed:@"pic29.png"]];
    [pgControlForScroll setImagePageStateHighlighted:[UIImage imageNamed:@"banner_dot_red.png"]];
    [pgControlForScroll addTarget:self action:@selector(pgChange) forControlEvents:UIControlEventValueChanged];
    [view addSubview:pgControlForScroll];

//    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 74.5, 220)];
//    leftImageView.backgroundColor = [UIColor clearColor];
//    
//    leftImageView.image = [UIImage imageNamed:@"page_bg_1136.png"];
//    [view addSubview:leftImageView];
//    leftImageView.userInteractionEnabled = YES;
//    
//    UIButton *leftBut = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBut setFrame:CGRectMake(74.5-22, 216/2-16, 22, 32)];
//    leftBut.tag = 133;
//    [leftBut addTarget:self action:@selector(scrollBanner:) forControlEvents:UIControlEventTouchUpInside];
//    [leftBut setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
//    [leftBut setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateHighlighted];
//    
//    [leftImageView addSubview:leftBut];
    
    
//    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth-74.5, 0, 74.5, 220)];
//    rightImageView.backgroundColor = [UIColor clearColor];
//    rightImageView.image = [UIImage imageNamed:@"page_bg_1136.png"];
//    [view addSubview:rightImageView];
//    rightImageView.userInteractionEnabled = YES;
//    
//    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBut setFrame:CGRectMake(0, 216/2-16, 11*2, 16*2)];
//    rightBut.tag = 134;
//    [rightBut addTarget:self action:@selector(scrollBanner:) forControlEvents:UIControlEventTouchUpInside];
//    [rightBut setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
//    [rightBut setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateHighlighted];
//    [rightImageView addSubview:rightBut];
    

    _detailTab.tableHeaderView=view;
    [self loadScrollSubViews];
}

- (void)scrollBanner:(UIButton *)sender{
    
    switch (sender.tag) {
        case 133:
        {
            if (_currentPage != 0) {
                CGPoint nextOffset = CGPointMake(_scrollViewForHeader.frame.size.width*(_currentPage-1), 0);
                [_scrollViewForHeader setContentOffset:nextOffset animated:YES];
                _currentPage--;
            }
            
        }
            break;
        case 134:
        {
            if (_currentPage != scrollNum-1) {
                CGPoint nextOffset = CGPointMake(_scrollViewForHeader.frame.size.width*(_currentPage+1), 0);
                [_scrollViewForHeader setContentOffset:nextOffset animated:YES];
                _currentPage++;
            }
            
        }
            
            break;
            
        default:
            break;
    }
    
}

- (IBAction)leftArrowBtnTapped:(UIButton *)btn
{
    if (_currentPage != 0) {
        CGPoint nextOffset = CGPointMake(_scrollViewForHeader.frame.size.width*(_currentPage-1), 0);
        [_scrollViewForHeader setContentOffset:nextOffset animated:YES];
        _currentPage--;
    }
    
}

- (IBAction)rightArrowBtnTapped:(UIButton *)btn
{
    if (_currentPage != scrollNum-1) {
        CGPoint nextOffset = CGPointMake(_scrollViewForHeader.frame.size.width*(_currentPage+1), 0);
        [_scrollViewForHeader setContentOffset:nextOffset animated:YES];
        _currentPage++;
    }
    
}

#pragma mark - 加载数据
/**
 *	给表头scrollview中的UrlImageButton赋上url，刷新表时使用
 *  @return (void)
 */
-(void)loadScrollSubViews{
    //先删除子视图
    // NSLog(@"=========================================================================");
    for (UIView *view in [_scrollViewForHeader subviews]) {
        [view removeFromSuperview];
    }

    scrollNum=[productModel.bannerlist count];//有几个图片
    
    //这里只有一个pic和一个pic2 怎么弄到scrollview里啊
    [_scrollViewForHeader setContentSize:CGSizeMake(SCREEN_WIDTH*(scrollNum), ScreenWidth)];
    //遍历list 获得小banner对象
    for (int i=0; i<scrollNum; i++) {
        
//        UIView *view_scroll=[[UIView alloc]initWithFrame:CGRectMake(i*170, 8, 170, 212)];
        //view_scroll.backgroundColor=[UIColor blackColor];
//        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 170, 212)];
//        imageView.image=[UIImage imageNamed:@"same_pic_bg.png"];
        UrlImageView *imgView = [[UrlImageView alloc] init];
        [imgView setUserInteractionEnabled:YES];
        [_scrollViewForHeader setClipsToBounds:YES];
        [_scrollViewForHeader addSubview:imgView];
        
        __block UrlImageView* blkImgView = imgView;
        [imgView setImageWithURL:[NSURL URLWithString:[[productModel.bannerlist objectAtIndex:i] BannerPic]] placeholderImage:nil afterDownload:^(UIImage *image) {
            [blkImgView  setFrame:CGRectMake(i * SCREEN_WIDTH, (ScreenWidth - lee1fitAllScreen((image.size.height * ScreenWidth / image.size.width))) / 2, SCREEN_WIDTH, lee1fitAllScreen((image.size.height * ScreenWidth / image.size.width)))];
            
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(0, 0, blkImgView.frame.size.width, blkImgView.frame.size.height)];
            btn.tag = 100+i;
            [btn addTarget:self action:@selector(showBigBanner:) forControlEvents:UIControlEventTouchUpInside];
            [blkImgView addSubview:btn];
        }];
//        [imgView setImageFromUrl:YES withUrl:[[productModel.bannerlist objectAtIndex:i] BannerPic]];
//        if (isRetina) {
//            imgView=[[UrlImageButton alloc] initWithFrame:CGRectMake(10, 10, 149, 190)];
//            [imgView setImageFromUrl:YES withUrl:[self ImageSize:[[productModel.bannerlist objectAtIndex:i] BannerPic] Size:@"340x424"]];
//            
//        }else{
//            imgView=[[UrlImageButton alloc] initWithFrame:CGRectMake(11, 13, 147, 188)];
//            [imgView setImageFromUrl:YES withUrl:[self ImageSize:[[productModel.bannerlist objectAtIndex:i]BannerPic] Size:ChangeImageURL]];
//        }
        
        if (i==0) {
            shareImgV = [[UrlImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
            
            [shareImgV setImageFromUrl:YES withUrl:[[productModel.bannerlist objectAtIndex:i]BannerPic]];
        }
        
//        imageView.tag = 100+i;
//        imgView.adjustsImageWhenHighlighted=NO;
//        [imgView addTarget:self action:@selector(showBigBanner:) forControlEvents:UIControlEventTouchUpInside];
//        [view_scroll addSubview:imageView];
//        [view_scroll addSubview:imgView];
//        imgView.tag=200+i;
    }
}
#pragma mark  商品大图

- (void)showBigBanner:(UrlImageButton *)sender{
    
    ProductBannerViewController *BannerVC = [[ProductBannerViewController alloc] init];
    BannerVC.indexPage = sender.tag-200;
    BannerVC.arrayForImg = productModel.bannerlist;
    [self.navigationController pushViewController:BannerVC animated:YES];
}


-(void)injectColor{
    //颜色数组
    
    colorsForProduct=[[NSMutableArray alloc] init];
    //ProductdetailSuperDetail中有几个元素就说明有几个颜色 有几个颜色就是有几个YKProductdetail
    for (int i=0; i<[[productModel.detailSuper ProductdetailSuperDetail] count]; i++) {
        //从productdetail中取出颜色
        YKProductdetail *eachDetail=[[productModel.detailSuper ProductdetailSuperDetail] objectAtIndex:i];
        [colorsForProduct addObject:[[eachDetail Productdetail_PropertyShow] PropertyColor]];
    }
    [pickerForSelectColor reloadAllComponents];
}


- (void)loadData1{
    [mainSev getProductDetail:self.thisProductId];
    
    [SBPublicAlert showMBProgressHUD:@"加载中···" andWhereView:self.view states:NO];
}

#pragma mark -- 分享

//分享按钮 响应事件
-(void)rightButAction{
    
    //lee999埋点
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"分享", @"Share_Type", self.thisProductId, @"Goods_ID",productModel.prodcutName, @"Goods_Name",nil];
    [TalkingData trackEvent:@"1005" label:@"商品分享" parameters:dic];
    
    
    NSString *str_share = [NSString stringWithFormat:@"我在@爱慕官方商城 iPhone客户端发现了一款不错的产品:%@，%@元，\n%@, 下载客户端:\nhttp://m.aimer.com.cn/method/xiazai",productModel.prodcutName,productModel.price_aimer,productModel.product_share_url== nil?@"":productModel.product_share_url];
    
    [ShareUnit ShareSDKwithTitle:@"爱慕"
                         content:str_share
                  defaultContent:str_share
                             img:shareImgV.image
                             url:productModel.product_share_url
                     description:str_share
                        imageUrl:@""];
}


#pragma mark -- net request delegate
-(void)serviceStarted:(ServiceType)aHandle{
}

-(void)serviceFailed:(ServiceType)aHandle{
    [SBPublicAlert hideMBprogressHUD:self.view];
}

-(void)serviceFinished:(ServiceType)aHandle withmodel:(id)amodel{
    
    [SBPublicAlert hideMBprogressHUD:self.view];
    LBaseModel *model = (LBaseModel *)amodel;
    
    switch (model.requestTag) {
        case Http_Product_Tag:
        {
            if (!model.errorMessage) {
                
                productModel = (ProductProductDetailModel *)model;
                _detailTab.hidden = NO;
                
                NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:productModel.productId, @"GoodsID",productModel.prodcutName, @"GoodsName",nil];
                [TalkingData trackEvent:@"1002" label:@"商品详情" parameters:dic2];
                
                
                //lee999 150711 修改商品已下架的提示
                if (!productModel.is_valid) {
                    [ESToast showDelayToastWithText:@"该商品已失效"];
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
                //end
                
                if ([[productModel.detailSuper ProductdetailSuperDetail] count]==0) {
                    
                    if ([productModel.colorlist count]==0) {
                        self.leftNUM=0;
                    }else{
                        _str_append=[[NSMutableString alloc]init];
                        [self.str_append appendFormat:@"%@",[[productModel.colorlist objectAtIndex:currentColor]ID]];
                        [self.str_append appendFormat:@"|"];
                        //                    [self.str_append appendFormat:@"%@",[[productModel.array_size objectAtIndex:currentSize]objectForKey:@"id"]];
                        for (int j = 0; j<productModel.array_size.count; j++) {
                            if ([[[[productModel.array_size objectAtIndex:j] allKeys] lastObject] isEqualToString:[[productModel.colorlist objectAtIndex:currentColor]ID]]) {
                                
                                NSArray *arr = [[productModel.array_size objectAtIndex:j]objectForKey:[[productModel.colorlist objectAtIndex:currentColor]ID]];
                                
                                [self.str_append appendFormat:@"%@",[[arr objectAtIndex:j] objectForKey:@"id"]];
                                
                            }
                        }
                        
                        [self.str_append appendFormat:@"|"];
                        for (int i=0; i<[productModel.array_color_size count]; i++) {
                            if ([[productModel.array_color_size objectAtIndex:i]isEqualToString:self.str_append]) {
                                self.product_id=[[productModel.productlist objectAtIndex:i] ID];
                                self.leftNUM=[[[productModel.productlist objectAtIndex:i] Count] intValue];
                            }
                        }
                    }
                    if ([productModel.suitid isKindOfClass:[NSNull class]]) {
                        hasSuit = NO;
                    }
                    else {
                        if (![productModel.suitid isEqualToString:@""] && productModel.suitid) {
                            hasSuit = YES;
                        }
                        else {
                            hasSuit = NO;
                        }
                    }

                    //                    NSLog(@"_++++++++++++++++++++++++++++++++++++++++++++++%d",leftNUM);
                    _buttonView_height= 11+130*([productModel.recommendlist count]/3+([productModel.recommendlist count]%3==0?0:1)) + 10;
                    _buttonView_height = lee1fitAllScreen(_buttonView_height);
                    self.selectedSize=nil;
                    [self loadScrollSubViews];
                    [pickerForSelectSize reloadAllComponents];
                    
//                    [_detailTab reloadData];
                    if (self.selectedSize==nil&&[productModel.array_size count]!=0) {
                        
                        for (int j = 0; j<productModel.array_size.count; j++) {
                            if ([[[[productModel.array_size objectAtIndex:j] allKeys] lastObject] isEqualToString:[[productModel.colorlist objectAtIndex:currentColor]ID]]) {
                                
                                self.arrTemSize = [[productModel.array_size objectAtIndex:j]objectForKey:[[productModel.colorlist objectAtIndex:currentColor]ID]];
                                
                                self.selectedSize=[[self.arrTemSize objectAtIndex:0] objectForKey:@"spec_alias"];
                                
                                break;
                            }
                        }
                    }
                }
                
                //在刷新表之前 给颜色button赋值
                for (int i=0; i<[[productModel.detailSuper ProductdetailSuperDetail] count]; i++) {
                    //从productdetail中取出颜色
                    YKProductdetail *eachDetail=[[productModel.detailSuper ProductdetailSuperDetail] objectAtIndex:i];
                    if ([self.thisProductId isEqualToString:[[eachDetail Productdetail_PropertyShow] PropertyID]]) {
                        currentProduct=i;
                        currentColor=i;
                    }
                    
                }
                
                //找出当前currentProduct的
                pgControlForScroll.numberOfPages=[productModel.bannerlist count];
                [pgControlForScroll updateDots];
                CGRect rc = pgControlForScroll.frame;
                rc.size.width = pgControlForScroll.subviews.count * (6 + 4) + 6;
                rc.origin.x = (SCREEN_WIDTH - rc.size.width) / 2;
                [pgControlForScroll setFrame:rc];
                //在刷新表之前 给表头的每个图片赋值
                [self loadScrollSubViews];
                //给picker数据源赋值
                [self injectColor];
                //            [self structMultiDesc];
                [_detailTab setDelegate:self];
                [_detailTab setDataSource:self];
                [_detailTab reloadData];
                
                if (_vToolbar) {
                    [_vToolbar setBackgroundColor:[UIColor blackColor]];

                    //200购物车 202收藏 203去购物车 201客服
                    UIButton* btnAddToCart = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btnAddToCart setFrame:CGRectMake(ScreenWidth - lee1fitAllScreen(117), 0, lee1fitAllScreen(117), _vToolbar.frame.size.height)];
                    [btnAddToCart addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                    [btnAddToCart setTag:200];
                    [btnAddToCart.titleLabel setFont:[UIFont systemFontOfSize:17]];
                    [btnAddToCart setTitle:@"加入购物车" forState:UIControlStateNormal];
                    [btnAddToCart setBackgroundColor:[UIColor colorWithHexString:@"#c8002c"]];
                    [_vToolbar addSubview:btnAddToCart];
                    
                    CGFloat fUnit = (ScreenWidth - btnAddToCart.frame.size.width) / 3;
                    
                    for (NSInteger i = 0; i < 3; ++i) {
                        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        [btn setFrame:CGRectMake(i * (fUnit), 0, fUnit, lee1fitAllScreen(50))];
                        [btn setTag:201 + i];
                        [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                        [btn setContentMode:UIViewContentModeCenter];
                        [_vToolbar addSubview:btn];
                        [btn.titleLabel setFont:[UIFont systemFontOfSize:9]];
                        [btn setImageEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, 0)];
                        
                        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, fUnit, 9)];
                        [lbl setFont:[UIFont systemFontOfSize:9]];
                        [lbl setTextColor:[UIColor whiteColor]];
                        [lbl setTextAlignment:NSTextAlignmentCenter];
                        [lbl setTag:1782329];
                        [btn addSubview:lbl];
                        switch (i) {
                            case 0:
                            {
                                [btn setImage:[UIImage imageNamed:@"tb_ico_kf_w"] forState:UIControlStateNormal];
                                [lbl setText:@"联系客服"];
                            }
                                break;
                            case 1:
                            {
                                [btn setImage:[UIImage imageNamed:@"tb_ico_like_select"] forState:UIControlStateSelected];
                                [btn setImage:[UIImage imageNamed:@"tb_ico_like_w"] forState:UIControlStateNormal];
                                if (productModel.isSollection || isgoodHasAddFav) {
                                    [lbl setText:@"已收藏"];
                                    [btn setSelected:YES];
                                }else
                                {
                                    [lbl setText:@"加入收藏"];
                                }
                            }
                                break;
                            case 2:
                            {
                                [btn setImage:[UIImage imageNamed:@"tb_ico_gwc_w"] forState:UIControlStateNormal];
                                [lbl setText:@"购物车"];
                            }
                                break;
                            default:
                                break;
                        }
                    }
                }
                
                [SBPublicAlert hideMBprogressHUD:self.view];
                
            }else {
                [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:0.6];
                [self.navigationController popViewControllerAnimated:YES];
            }
    
        }
            break;
        case Http_FavoriteAdd_Tag : {
            if (!model.errorMessage) {
                [SBPublicAlert showMBProgressHUD:@"收藏成功" andWhereView:self.view hiddenTime:0.6];
//                addButfav.selected = YES;
                isgoodHasAddFav = YES;
                if(_vToolbar)
                {
                    UIButton* btn = (UIButton*)[_vToolbar viewWithTag:202];
                    [btn setSelected:YES];
                    if (btn) {
                        UILabel* lbl = (UILabel*)[btn viewWithTag:1782329];
                        [lbl setText:@"已收藏"];
                    }
                }
            }else {
                [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:0.6];
                
            }
        }
            break;
        case Http_Car_add_Tag: {
            if (!model.errorMessage) {
                
                
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"DelCarSuit" object:nil];
                
                [SBPublicAlert hideMBprogressHUD:self.view];
                
                [UIApplication sharedApplication].applicationIconBadgeNumber=[[[NSUserDefaults standardUserDefaults]objectForKey:@"totalNUM"]intValue];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TotleNumber" object:nil];
                
                UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"提醒" message: @"成功加入购物车" delegate:self cancelButtonTitle: @"去购物车" otherButtonTitles: @"继续购物",nil];
                someError.tag = 110011;
                [someError show];
            }else{
                [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:0.6];
            }
        }
            break;
        case 10086 : {
            [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:0.6];
        }
            
            break;
        default:
            [SBPublicAlert hideMBprogressHUD:self.view];
            
            break;
    }
}

/**
 *	picker上的toolbar上左右两个按钮响应事件
 *	@param  (id)sender 左右两个UIBarButtonItem
 *  @return (void)
 */

- (void)hiddle {
    toolBarForNumber.hidden = YES;
    toolBarForSizePicker.hidden = YES;
    toolBarForPicker.hidden = YES;
}

-(void)hiddenBar{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    pickerForSelectNumber.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 216);
    toolBarForNumber.frame = CGRectMake(0, ScreenHeight+20, ScreenWidth, 44);
    
    pickerForSelectColor.frame=CGRectMake(0, ScreenHeight, ScreenWidth, 216);
    toolBarForPicker.frame=CGRectMake(0, ScreenHeight+20, ScreenWidth, 44)
    ;
    [UIView commitAnimations];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    pickerForSelectSize.frame=CGRectMake(0, ScreenHeight, ScreenWidth, 216);
    toolBarForSizePicker.frame=CGRectMake(0, ScreenHeight+20, ScreenWidth, 44)
    ;
    [UIView setAnimationDidStopSelector:@selector(hiddle)];
    [UIView commitAnimations];
}

-(void)BarButtonClick:(UIBarButtonItem *)barButton{
    
    
    [self hiddenBar];
    
    
    if(barButton.tag==102)
    {
        if (didSelectColor!=currentColor) {// 如果颜色不同 说明换商品了
            didSelectColor=currentColor;
            currentProduct=currentColor;
            
            currentSize = [self indexOfSize:self.selectedSize];
            [self structMultiDesc];
            [_detailTab reloadData];
        }
    }
    else if(barButton.tag==102+100)
    {
        NSLog(@"size完成arrTemSize:%@", self.arrTemSize);
        NSLog(@"size完成currentSize:%ld", (long)currentSize);
        if ([productModel.array_size count]!=0)
        {
//            self.selectedSize=[[self.arrTemSize objectAtIndex:currentSize]objectForKey:@"spec_alias"];
            //lee999 修改选择尺码崩溃
            if ([self.arrTemSize count] > currentSize) {
                self.selectedSize=[[self.arrTemSize objectAtIndex:currentSize]objectForKey:@"spec_alias"];
            }else{
                self.selectedSize = @"";
                currentSize = 0;
            }
        }
        if ([productModel.colorlist count]==0) {
            self.leftNUM=0;
        }
        else{
            _str_append=[[NSMutableString alloc]init];
            [self.str_append appendFormat:@"%@",[[productModel.colorlist objectAtIndex:currentColor]ID]];
            [self.str_append appendFormat:@"|"];
            for (int j = 0; j<productModel.array_size.count; j++) {
                if ([[[[productModel.array_size objectAtIndex:j] allKeys] lastObject] isEqualToString:[[productModel.colorlist objectAtIndex:currentColor]ID]]) {
                    
                    NSArray *arr = [[productModel.array_size objectAtIndex:j]objectForKey:[[productModel.colorlist objectAtIndex:currentColor]ID]];
  
                    //lee999 修改选择尺码崩溃
                    if ([arr count] > currentSize) {
                        [self.str_append appendFormat:@"%@",[[arr objectAtIndex:currentSize] objectForKey:@"id"]];
                    }else{
                        currentSize = 0;
                    }
                    
                }
            }
            [self.str_append appendFormat:@"|"];
            for (int i=0; i<[productModel.array_color_size count]; i++) {
                if ([[productModel.array_color_size objectAtIndex:i]isEqualToString:self.str_append]) {
                    self.product_id=[[productModel.productlist objectAtIndex:i] ID];
                    self.leftNUM=[[[productModel.productlist objectAtIndex:i] Count] intValue];
                }
            }
        }
        [self setSizeButtonText];
        [_detailTab reloadData];
    }else if(barButton.tag==102+10){
        if (didSelectNumber != currentNumber) {
            
            buttonForNum.text = [[NSNumber numberWithInteger:currentNumber] description];
            recordNUM=[buttonForNum.text intValue];
            [_detailTab reloadData];
        }
    }
}



- (int)indexOfSize:(NSString *)size
{
    int index = 0;
    for (int i=0; i<self.arrTemSize.count; i++) {
        if ([[[self.arrTemSize objectAtIndex:i]objectForKey:@"spec_alias"] isEqualToString:self.selectedSize]) {
            index = i;
        }
    }
    return index;
}


-(void)setSizeButtonText{
    label_size.text=self.selectedSize;
}

/**
 *	根据商品详情构造字符串
 *  @return (void)
 */
-(void)structMultiDesc{
    self.multiDescStr=[NSMutableString string];
    YKProductdetail *proDetail = [[productModel.detailSuper ProductdetailSuperDetail] objectAtIndex:currentProduct];
    
    [self.multiDescStr appendFormat:@"%@\n",[[[[proDetail Productdetail_MultiShow] MultiDesc] componentsSeparatedByString:@","] objectAtIndex:0]];
    [self.multiDescStr appendFormat:@"市场价格：%@\n",[[[proDetail Productdetail_SimpleDesc] SimplePrice3] NVValue]];
    [self.multiDescStr appendString:@"品名：\n"];
    [self.multiDescStr appendString:@"产地：\n"];
    [self.multiDescStr appendFormat:@"颜色：%@\n",[[proDetail Productdetail_PropertyShow] PropertyColor]];
    [self.multiDescStr appendString:@"上市时间：\n"];
}


#pragma mark - 主要action的事件处理   立即购买、加入购物车、收藏、分享、用户评价、用户问答
/**
 *	商品详情界面中一些重要的点击事件处理中心：立即购买、加入购物车、收藏、分享、用户评价、用户问答
 *	@param  (UIButton *)action 点击按钮
 *  @return (void)
 */
-(void)buttonAction:(UIButton *)action{
    
    if ([buttonForNum.text intValue]>9) {
        [SBPublicAlert showAlertTitle:@"爱慕提示" Message:@"单品购买不得超过9件，谢谢"];
        return;
    }
    //200购物车 202收藏 203去购物车 201客服
    switch (action.tag) {
            
        case 200: /* 加入购物车 */ {
            
            isAddtoCar = YES;
            
            
            //向服务器发送添加购物车请求
            //YKShopCarService
            //首先需要知道当前产品的productID
            //从list中找到索引为currentproduct的产品
            
            //lee999 优化 加入购物车需先登录
            if (![SingletonState sharedStateInstance].userHasLogin) {
                
                [self changeToMyaimer];

                
//                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"爱慕提示" message:@"您尚未登录，请先登录。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
//                alert.tag=111;
//                [alert show];
                return;
            }
            
            
            _str_append=[[NSMutableString alloc]init];
            [self.str_append appendFormat:@"%@",[[productModel.colorlist objectAtIndex:currentColor]ID]];
            [self.str_append appendFormat:@"|"];
            
            for (int j = 0; j<productModel.array_size.count; j++) {
                if ([[[[productModel.array_size objectAtIndex:j] allKeys] lastObject] isEqualToString:[[productModel.colorlist objectAtIndex:currentColor]ID]]) {
                    
                    NSArray *arr = [[productModel.array_size objectAtIndex:j]objectForKey:[[productModel.colorlist objectAtIndex:currentColor]ID]];
                    
                    NSString *str = nil;
                    for (int k = 0; k< arr.count; k++) {
                        
                        if ([[[arr objectAtIndex:k] objectForKey:@"spec_value"] isEqualToString:self.selectedSize]) {
                            str = [[arr objectAtIndex:k] objectForKey:@"id"];
                        }
                    }
                    //lee999 修改选择尺码的崩溃
                    if ([arr count] > currentSize) {
                        [self.str_append appendFormat:@"%@",(str?str:[[arr objectAtIndex:currentSize] objectForKey:@"id"])];
                    }else{
                        currentSize = 0;
                        return;
                    }
                }
            }
            NSLog(@"颜色:%@ 尺码:%@", [[productModel.colorlist objectAtIndex:currentColor]ID], self.str_append);
            [self.str_append appendFormat:@"|"];
            for (int i=0; i<[productModel.array_color_size count]; i++) {
                if ([[productModel.array_color_size objectAtIndex:i]isEqualToString:self.str_append]) {
                    self.product_id=[[productModel.productlist objectAtIndex:i] ID];
                    self.leftNUM=[[[productModel.productlist objectAtIndex:i] Count] intValue];
                }
            }
            if ([[self getLastViewController] isEqualToString:@"YKCartController"]) {
                [SBPublicAlert showAlertTitle:@"爱慕提示" Message:@"该商品已经在购物车中"];
            }else{
                if ([buttonForNum.text intValue]>99) {
                    [SBPublicAlert showAlertTitle:@"爱慕提示" Message:@"单件商品的数量不能超过100，谢谢"];
                }else{
                    if (self.selectedSize==nil) {
                        [SBPublicAlert showAlertTitle:@"爱慕提示" Message:@"请选择尺码"];
                        
                        return;
                    }
                    if ([buttonForNum.text intValue]<=self.leftNUM) {
                        [self performSelector:@selector(loadAddCar) withObject:nil afterDelay:0.1];
                    }else{
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"库存不足" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        alert.tag=12015;
                        [alert show];
                    }
                } // end else
            }
        }
            break;
        case 200 + 1://联系客服
        {
            //lee999 增加联系客服
            YKCanReuse_webViewController *webView = [[YKCanReuse_webViewController alloc] init];
            webView.strURL = [NSString stringWithFormat:@"%@?gid=%@",kefuUrl,self.product_id];
            webView.strTitle = @"联系客服";
            [self.navigationController pushViewController:webView animated:YES];
            
            
        }
            break;
        case 200 + 2: /* 收藏 */ {
            isAddFav=YES;
            
            
            if (productModel.isSollection) {
                [MYCommentAlertView showMessage:@"您已经收藏过该商品，喜欢就买了吧" target:nil];
                return;
            }
            if (isgoodHasAddFav) {
                [MYCommentAlertView showMessage:@"您已经收藏过该商品，喜欢就买了吧" target:nil];
                return;
            }
            if (action.selected) {
                [MYCommentAlertView showMessage:@"您已经收藏过该商品，喜欢就买了吧" target:nil];
                return;
            }
            
            if ([SingletonState sharedStateInstance].userHasLogin) {
                
                NSDictionary *dic1  = [NSDictionary dictionaryWithObjectsAndKeys:self.thisProductId, @"GoodsID",productModel.prodcutName, @"GoodsName",nil];
                [TalkingData trackEvent:@"1006" label:@"加入收藏夹" parameters:dic1];
                
                [mainSev getFavoriteadd:self.thisProductId andType:@"goods" anduk:@""];
                [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];
                
            }else{
                
                [self changeToMyaimer];

                
//                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"爱慕提示" message:@"您尚未登录，请先登录。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
//                alert.tag=111;
//                [alert show];
            }
        }
            break;
        case 200 + 3:
        {
            
            //lee999 修改购车的跳转，导致界面下方少一块
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self performSelector:@selector(JumpToCarpage) withObject:nil afterDelay:0.2];

//            [self changetableBarto:3];
        }
            break;
        default:
            break;
    }
}

-(void)loadAddCar{
    
    NSString *sku=[NSString stringWithFormat:@"%@:%@:product",self.product_id,buttonForNum.text];
    if ([UIApplication sharedApplication].applicationIconBadgeNumber<10000) {
        [mainSev getCar_add:sku];
        [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];
        
        NSDictionary *dic1  = [NSDictionary dictionaryWithObjectsAndKeys:self.thisProductId, @"GoodsID",productModel.prodcutName, @"GoodsName",@"product", @"SelectType",sku, @"SKU",[NSNumber numberWithShort:[buttonForNum.text intValue]],@"Number",nil];
        [TalkingData trackEvent:@"1007" label:@"加入购物车" parameters:dic1];
        
    }else{
        [SBPublicAlert showAlertTitle:@"爱慕提示" Message:@"已经超过10000件商品"];
    }
}

#pragma mark delegate&dataSource @end

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==111) {
        
        //登录
        
        if (buttonIndex == 1) {
            //切换到我的爱慕进行登录 来源于竖屏的商场~~
            [SingletonState sharedStateInstance].myaimerIsFrom = 2;
            //lee999新增这个字段
            [SingletonState sharedStateInstance].isProductDetailGotoLogin = YES;
            [self changeToMyaimer];
        
        }
    }else if (alertView.tag==222) {//无数据就出栈
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(alertView.tag!=222&&alertView.tag!=111&&alertView.tag!=12015){
        //去购物车
        if (buttonIndex == 0) {
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self performSelector:@selector(JumpToCarpage) withObject:nil afterDelay:0.2];
        }
    }
}


#pragma mark--  登录成功之后的回调函数
-(void)loginOKCallBack:(NSString *)prama{
    if (isAddtoCar) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 200;
        [self buttonAction:btn];
        isAddtoCar = NO;
    }
}


-(void)JumpToCarpage{
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *bsc = [app.mytabBarController.viewControllers objectAtIndex:3];
    [bsc popToRootViewControllerAnimated:NO];
    
    [self changetableBarto:3];
}


#pragma mark picker delegate&dataSource
//====================================================
// 函数名称: picker delegate&dataSource
// 函数功能: picker的协议方法
//====================================================
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView==pickerForSelectColor) {
        return [productModel.colorlist count];
    }else if (pickerView == pickerForSelectSize) {
        return  [self.arrTemSize count];
        return 0;
    }else {
        return numberProduct.count;
    }
    
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 220, 44) ];
    NSString *pickerText=@"";
    UrlImageView *image=[[UrlImageView alloc]init];
    if (pickerView==pickerForSelectColor) {
        
        pickerText= [[productModel.colorlist objectAtIndex:row] Spec_alias];
        [image setImageWithURL:[NSURL URLWithString:[[productModel.colorlist objectAtIndex:row] ImageUrl]]];
        titleLabel.textAlignment = UITextAlignmentLeft;
        
    }else if (pickerView==pickerForSelectSize){
        
        titleLabel.textAlignment = UITextAlignmentCenter;
    
        pickerText= [[self.arrTemSize objectAtIndex:row] objectForKey:@"spec_alias"];
 
    }else if (pickerView == pickerForSelectNumber){
        pickerText = [numberProduct objectAtIndex:row];
        titleLabel.textAlignment = UITextAlignmentCenter;
    }
    titleLabel.text = pickerText;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [ UIFont boldSystemFontOfSize:18];;
    titleLabel.opaque = NO;
    
    image.frame=CGRectMake(180, 4, 50, 36);
    UIView *view_image=[[UIView alloc]init];
    view_image.frame=CGRectMake(0, 0, ScreenWidth, 44);
    [view_image addSubview:image];
    [view_image addSubview:titleLabel];
    return view_image;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (pickerView==pickerForSelectColor) {
        currentColor=row;
    }else if (pickerView == pickerForSelectSize) {
        currentSize=row;
    }else {
        currentNumber = row+1;
    }
    
}
//delegate & dataSource @end
#pragma mark textField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    toolBarForNumber.hidden = NO;
    toolBarForSizePicker.hidden = YES;
    toolBarForPicker.hidden = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    pickerForSelectNumber.frame = CGRectMake(0,  ScreenHeight-PickShowHigh, ScreenWidth, 216);
    toolBarForNumber.frame = CGRectMake(0, ScreenHeight-PickShowHigh-44, ScreenWidth, 44);
    
    pickerForSelectColor.frame=CGRectMake(0, ScreenHeight, ScreenWidth, 216);
    toolBarForPicker.frame=CGRectMake(0, ScreenHeight+20, ScreenWidth, 44);
    
    pickerForSelectSize.frame=CGRectMake(0, ScreenHeight, ScreenWidth, 216);
    toolBarForPicker.frame=CGRectMake(0, ScreenHeight+20, ScreenWidth, 44);
    
    toolBarForSizePicker.frame=CGRectMake(0, ScreenHeight+20, ScreenWidth, 44);
    
    
    [UIView commitAnimations];
    
    [_detailTab scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return  NO;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField.text isEqualToString:@"0"]) {
        textField.text=@"1";
    }else{
        recordNUM=[textField.text intValue];
        textField.text=[NSString stringWithFormat:@"%d",recordNUM];
    }
}
//拖动的时候隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [buttonForNum resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	if (range.location > 0) {
		return NO;
	}
	return YES;
}

#pragma mark -
#pragma mark scroll与pagecontrol联动
/**
 *	UIPageControl上绑定的valueChange事件
 *  @return (void)
 */

-(void)pgChange{
    NSInteger page=pgControlForScroll.currentPage;
    [_scrollViewForHeader setContentOffset:CGPointMake(SCREEN_WIDTH*page, 0) animated:YES];
}

/**
 *	根据scrollview位移更改UIPageControl值
 *  @return (void)
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offSet=_scrollViewForHeader.contentOffset.x;
    pgControlForScroll.currentPage=offSet/SCREEN_WIDTH;
    _currentPage = pgControlForScroll.currentPage;
    [pgControlForScroll updateDots];
}

/**
 *	颜色picker的显示
 *	@param  (UIButton *)button 颜色按钮
 *  @return (void)
 */
-(void)showPicker:(UIButton *)button
{
    if ([buttonForNum isFirstResponder]) {
        [buttonForNum resignFirstResponder];
    }
    [pickerForSelectNumber removeFromSuperview];
    [toolBarForNumber removeFromSuperview];
    [pickerForSelectColor removeFromSuperview];
    [toolBarForPicker removeFromSuperview];
    [pickerForSelectSize removeFromSuperview];
    [toolBarForSizePicker removeFromSuperview];
    
    [self createtoolbarandpicker];
    
    if (button==self.buttonForSelect) {
        toolBarForNumber.hidden = YES;
        toolBarForSizePicker.hidden = YES;
        toolBarForPicker.hidden = NO;
        
        [pickerForSelectColor reloadAllComponents];//picker的数据源是会变的 reload后更换一套新的数据源
        [pickerForSelectColor selectRow:currentColor inComponent:0 animated:NO];
        
        [_detailTab scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        pickerForSelectSize.frame=CGRectMake(0, ScreenHeight, ScreenWidth, 216);
        toolBarForSizePicker.frame=CGRectMake(0,ScreenHeight+20, ScreenWidth, 44);
        pickerForSelectColor.frame=CGRectMake(0, ScreenHeight-PickShowHigh, ScreenWidth, 216);
        toolBarForPicker.frame=CGRectMake(0, ScreenHeight-PickShowHigh-44, ScreenWidth, 44);
        
        [UIView commitAnimations];
    }else{
        toolBarForNumber.hidden = YES;
        toolBarForSizePicker.hidden = NO;
        toolBarForPicker.hidden = YES;
        
        [pickerForSelectSize reloadAllComponents];//picker的数据源是会变的 reload后更换一套新的数据源
        
        
        for (int i = 0; i<self.arrTemSize.count; i++) {
            if ([[[self.arrTemSize objectAtIndex:i]objectForKey:@"spec_alias"] isEqualToString:self.selectedSize]) {
                [pickerForSelectSize selectRow:i inComponent:0 animated:NO];
                break;
            }else {
                [pickerForSelectSize selectRow:0 inComponent:0 animated:NO];
                
            }
        }
        
        
        [_detailTab scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        pickerForSelectSize.frame=CGRectMake(0, ScreenHeight-PickShowHigh, ScreenWidth, 216);
        toolBarForSizePicker.frame=CGRectMake(0,ScreenHeight-PickShowHigh-44, ScreenWidth, 44);
        
        pickerForSelectColor.frame=CGRectMake(0, ScreenHeight, ScreenWidth, 216);
        toolBarForPicker.frame=CGRectMake(0, ScreenHeight+20, ScreenWidth, 44);
        [UIView commitAnimations];
    }
}


#pragma mark -
#pragma mark tableView delegate & dataSource
//====================================================
// 函数名称: tableView delegate&dataSource
// 函数功能: tableView的协议方法
//====================================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (hasSuit) {
        return 6;
    }
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    static NSString *myOrderCell = @"MyOrderCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myOrderCell];
//    //详情表
//    if (cell==nil) {
        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    }
//    for (UIView *v in [cell.contentView subviews]) {
//        [v removeFromSuperview];
//    }
    cell.contentView.backgroundColor=[UIColor clearColor];
    detailList=[productModel.detailSuper ProductdetailSuperDetail];
    NSInteger row = [indexPath row];
    if (row > 2 && !hasSuit) {
        row += 1;
    }
    switch (row) {
        case 0:{
            int forNum=5;
            for (int i = 0; i < forNum; ++i) {
                UILabel *cellWith0Lab = [[UILabel alloc] init];
                // 初始化cell0的各label
                switch (i) {
                        // 标题
                    case 0:
                    {
                        [cellWith0Lab setFrame:CELL_WITH_0_LAB_FRAME_0];
                        [cellWith0Lab setBackgroundColor:[UIColor clearColor]];
                        cellWith0Lab.font=[UIFont systemFontOfSize:13];
                        cellWith0Lab.textColor=[UIColor colorWithHexString:@"#4c4c4c"];
                        cellWith0Lab.lineBreakMode=UILineBreakModeWordWrap;
                        cellWith0Lab.numberOfLines=0;
                        [cellWith0Lab setText:productModel.prodcutName];
                        
                    }
                        break;
                    case 1://商品编号
                    {
                        if ([productModel.arr_desc count] < 3) {
                            [cellWith0Lab setFrame:CGRectMake(20,10+24+37, 180, 24)];
                        } else {
                            [cellWith0Lab setFrame:CELL_WITH_0_LAB_FRAME_1];
                        }
                        if ([productModel.arr_desc count]>0) {
                            [cellWith0Lab setText:[NSString stringWithFormat:@"%@",[productModel.arr_desc objectAtIndex:0]== nil?@"":[productModel.arr_desc objectAtIndex:0]]];
                        }
                        cellWith0Lab.font=[UIFont systemFontOfSize:12];
                        cellWith0Lab.textColor=[UIColor colorWithHexString:@"#666666"];
                        
                        //lee999 150708 添加分割线
                        UIView *splineV = [[UIView alloc] initWithFrame:CGRectMake(0, cellWith0Lab.frame.origin.y -4, ScreenWidth, 0.5)];
                        [splineV setBackgroundColor:[UIColor colorWithHexString:splineBGC]];
                        [cell addSubview:splineV];
                        //end
                    }
                        break;
                    case 2://品牌
                    {
                        if ([productModel.arr_desc count] < 3) {
                            [cellWith0Lab setFrame:CGRectMake((ScreenWidth / 2) + 20, 10+24+37, 180, 24)];
                        } else {
                            [cellWith0Lab setFrame:CELL_WITH_0_LAB_FRAME_2];
                        }
                        if ([productModel.arr_desc count]>1) {
                            [cellWith0Lab setText:[NSString stringWithFormat:@"%@",[productModel.arr_desc objectAtIndex:1] == nil?@"":[productModel.arr_desc objectAtIndex:1]]];
                        }
                        cellWith0Lab.font=[UIFont systemFontOfSize:12];
                        cellWith0Lab.textColor=[UIColor colorWithHexString:@"#666666"];
                    }
                        break;
                    case 3://
                        [cellWith0Lab setFrame:CELL_WITH_0_LAB_FRAME_4];
                        if ([productModel.arr_desc count]>2) {
                            [cellWith0Lab setText:[NSString stringWithFormat:@"%@",[productModel.arr_desc objectAtIndex:2]== nil?@"":[productModel.arr_desc objectAtIndex:2]]];
                        }
                        cellWith0Lab.font=[UIFont systemFontOfSize:12];
                        cellWith0Lab.textColor=[UIColor colorWithHexString:@"#666666"];
                        break;
                    case 4://
                        [cellWith0Lab setFrame:CELL_WITH_0_LAB_FRAME_6];
                        if ([productModel.arr_desc count]>3) {
                            [cellWith0Lab setText:[NSString stringWithFormat:@"%@",[productModel.arr_desc objectAtIndex:3]== nil?@"":[productModel.arr_desc objectAtIndex:3]]];
                        }
                        cellWith0Lab.font=[UIFont systemFontOfSize:12];
                        cellWith0Lab.textColor=[UIColor colorWithHexString:@"#666666"];
                        break;
                        
                    default:
                        break;
                } // end switch  初始化cell0的各label
                [cellWith0Lab setBackgroundColor:[UIColor clearColor]];
                [cell.contentView addSubview:cellWith0Lab];
            } // end for
            
            UIImageView *imageview=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"magazine_share_devider.png"]];
            imageview.frame=CGRectMake(10, (CELL_WITH_0_LAB_Y_0 + 1*CELL_WITH_0_LAB_H)+30, 300, 2);
            [cell.contentView addSubview:imageview];
            
            
            UIImageView *imageview_split=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"devider_line-1.png"]];
            imageview_split.frame=CGRectMake(0,2, ScreenWidth, 2);
            [cell.contentView addSubview:imageview_split];

            //售价
            UILabel *aimer_price=[[UILabel alloc]init];
            [aimer_price setFrame:CELL_WITH_0_LAB_FRAME_PRICE];
            [aimer_price setText:[NSString stringWithFormat:@"%@  : ￥%@",productModel.price_aimer_label,productModel.price_aimer]];//, [[simple SimplePrice1] NVValue]]];
            aimer_price.font=[UIFont systemFontOfSize:13];
            aimer_price.textColor=[UIColor colorWithHexString:@"#c21513"];
            aimer_price.backgroundColor=[UIColor clearColor];
            [cell.contentView addSubview:aimer_price];
            
            //原价
            UILabel *aimer_price_label=[[UILabel alloc]init];
            [aimer_price_label setFrame:CELL_WITH_0_LAB_FRAME_PRICE_MARKET];
            [aimer_price_label setText:[NSString stringWithFormat:@"%@  :",productModel.price_market_label]];//, [[simple SimplePrice1] NVValue]]];
            aimer_price_label.font=[UIFont systemFontOfSize:13];
            aimer_price_label.textColor=[UIColor colorWithHexString:@"#666666"];
            aimer_price_label.backgroundColor=[UIColor clearColor];
            [cell.contentView addSubview:aimer_price_label];
            
            
            YKStrikePriceLabel *strikelabel=[[YKStrikePriceLabel alloc]init];
            strikelabel.frame=CELL_WITH_0_LAB_FRAME_PRICE_MARKET_2;
            [strikelabel setFont:[UIFont systemFontOfSize:13]];
            strikelabel.text=[NSString stringWithFormat:@"%@",productModel.price_market];
            strikelabel.textColor=[UIColor colorWithHexString:@"#818181"];
            strikelabel.backgroundColor=[UIColor clearColor];
            strikelabel.textAlignment=UITextAlignmentCenter;
            [cell.contentView addSubview:strikelabel];
            
            if ([productModel.price_market isEqualToString: productModel.price_aimer]) {
                aimer_price_label.hidden=YES;
                strikelabel.hidden=YES;
                aimer_price.frame=CELL_WITH_0_LAB_FRAME_PRICE_Aimer;
            }
        }
            break;
        case 1:{
            
            //下拉列表选择颜色按钮
            self.buttonForSelect=[UrlImageButton buttonWithType:UIButtonTypeCustom];
            [self.buttonForSelect setFrame:CGRectMake(62, 10, 79, 31)];
//            [self.buttonForSelect setImage:[UIImage imageNamed:@"choice_btn_arrow.png"] forState:UIControlStateNormal];
//            [self.buttonForSelect setImage:[UIImage imageNamed:@"choice_btn_arrow.png"]forState:UIControlStateHighlighted];
//            [self.buttonForSelect setImageEdgeInsets:UIEdgeInsetsMake(12, 65, 12, 4)];
            [self.buttonForSelect setBackgroundImage:[UIImage imageNamed:@"lp_option"] forState:UIControlStateNormal];
            [self.buttonForSelect setBackgroundImage:[UIImage imageNamed:@"lp_option_hover"] forState:UIControlStateHighlighted];
            [self.buttonForSelect addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
            self.buttonForSelect.tag=COLORBUTTON;
            [cell.contentView addSubview:self.buttonForSelect];
            
            
            //lee999 150708 添加分割线
            UIView *splineV = [[UIView alloc] initWithFrame:CGRectMake(0, self.buttonForSelect.frame.origin.y -8, ScreenWidth, 0.5)];
            [splineV setBackgroundColor:[UIColor colorWithHexString:splineBGC]];
            [cell addSubview:splineV];
            //end
            
            //===
            //by:kaisuki 添加标签到颜色按钮上去
            UILabel *label_color=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 52, 28)];
            if ([productModel.colorlist count]!=0) {
                label_color.text=[[productModel.colorlist objectAtIndex:currentColor] Spec_alias];
            }
            label_color.textColor=[UIColor colorWithHexString:@"#666666"];
            label_color.textAlignment=UITextAlignmentCenter;
            label_color.backgroundColor=[UIColor clearColor];
            label_color.font=[UIFont systemFontOfSize:12];
            [self.buttonForSelect addSubview:label_color];
            
            self.buttonForSize=[UrlImageButton buttonWithType:UIButtonTypeCustom];
            [self.buttonForSize setFrame:CGRectMake(lee1fitAllScreen(212), 10, 79, 31)];
//            [self.buttonForSize setImage:[UIImage imageNamed:@"choice_btn_arrow.png"] forState:UIControlStateNormal];
//            [self.buttonForSize setImage:[UIImage imageNamed:@"choice_btn_arrow.png"] forState:UIControlStateHighlighted];
//            [self.buttonForSize setImageEdgeInsets:UIEdgeInsetsMake(12, 65, 12, 4)];
            [self.buttonForSize setBackgroundImage:[UIImage imageNamed:@"lp_option"] forState:UIControlStateNormal];
            [self.buttonForSize setBackgroundImage:[UIImage imageNamed:@"lp_option_hover"] forState:UIControlStateHighlighted];
            [self.buttonForSize addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
            self.buttonForSize.tag=COLORBUTTON;
            [cell.contentView addSubview:self.buttonForSize];
            
            //===
            //by:kaisuki 添加标签到颜色按钮上去
            label_size=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 52, 28)];
            if ([productModel.array_size count]!=0) {
                
                for (int j = 0; j<productModel.array_size.count; j++) {
                    if ([[[[productModel.array_size objectAtIndex:j] allKeys] lastObject] isEqualToString:[[productModel.colorlist objectAtIndex:currentColor]ID]]) {
                        self.arrTemSize = [[productModel.array_size objectAtIndex:j]objectForKey:[[productModel.colorlist objectAtIndex:currentColor]ID]];
                        
                        for (int g = 0; g<  self.arrTemSize.count; g++) {
                            if ([self.selectedSize isEqualToString:[[self.arrTemSize objectAtIndex:g]objectForKey:@"spec_alias"]]) {
                                label_size.text = self.selectedSize;
                                break;
                            }else {
                                //lee999 增加判断
                                if ([self.arrTemSize count] > currentSize) {
                                    label_size.text =[[self.arrTemSize objectAtIndex:currentSize] objectForKey:@"spec_alias"];
                                }else{
                                    currentSize = 0;
                                    label_size.text =[[self.arrTemSize objectAtIndex:currentSize] objectForKey:@"spec_alias"];

                                }
                                //end
                                
                            }
                        }
                    }
                }
            }
            label_size.textColor=[UIColor colorWithHexString:@"#666666"];
            label_size.textAlignment=UITextAlignmentCenter;
            label_size.backgroundColor=[UIColor clearColor];
            label_size.font=[UIFont systemFontOfSize:12];
            [self.buttonForSize addSubview:label_size];
            
            //从购物车和秒杀进 不创建数量
            int forNum = 3;
            for (int i = 0; i < forNum; ++i) {
                UILabel *cellWith1Lab = [[UILabel alloc] init];
                switch (i) {
                    case 0:
                    {
                        [cellWith1Lab setFrame:CELL_WITH_1_LAB_FRAME_0];
                        [cellWith1Lab setText:@"颜色:"];
                    }
                        break;
                    case 1:
                    {
                        [cellWith1Lab setFrame:CELL_WITH_1_LAB_FRAME_1];
                        [cellWith1Lab setText:@"尺码:"];
                    }
                        break;
                    case 2:
                    {
                        [cellWith1Lab setFrame:CGRectMake(20, 55, 72, 28)];
                        [cellWith1Lab setText:@"数量:"];
                    }
                        break;
                    case 3:
                    {
                        
                        
                        [cellWith1Lab setFrame:CGRectMake(172, 55, 72, 28)];
                        [cellWith1Lab setText:@"尺码对照"];
                    }
                        break;
                    default:
                        break;
                } // end for
                [cellWith1Lab setBackgroundColor:[UIColor clearColor]];
                [cellWith1Lab setFont:[UIFont systemFontOfSize:13]];
                [cellWith1Lab setTextColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
                [cell.contentView addSubview:cellWith1Lab];
            } // end for
            
            buttonForNum=[[UITextField alloc] initWithFrame:CGRectMake(60, 50, 79, 30)];
            buttonForNum.borderStyle=UITextBorderStyleNone;
            buttonForNum.background=[UIImage imageNamed:@"choice_btn_02.png"];
            buttonForNum.tag=51;
            buttonForNum.textAlignment=UITextAlignmentCenter;
            buttonForNum.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            buttonForNum.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
//            buttonForNum.textColor=[UIColor blackColor];
            //lee999 0708 修改文字颜色为灰色  数量上的文字
            buttonForNum.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];

            buttonForNum.keyboardType=UIKeyboardTypeNumberPad;
            buttonForNum.backgroundColor=[UIColor clearColor];
            buttonForNum.returnKeyType=UIReturnKeyDone;
            buttonForNum.delegate=self;
            buttonForNum.text=([self.num isEqualToString:@""]||self.num==nil)?[[NSString alloc]initWithFormat:@"%d",recordNUM]:self.num;
            [cell.contentView addSubview:buttonForNum];
            
            UIButton *button_Size=[UIButton buttonWithType:UIButtonTypeCustom];
            button_Size.frame=CGRectMake(lee1fitAllScreen(212), 54, 75, 28);
            [button_Size setBackgroundImage:[UIImage imageNamed:@"lp_size_normal"] forState:UIControlStateNormal];
            [button_Size setBackgroundImage:[UIImage imageNamed:@"lp_size_hover"] forState:UIControlStateHighlighted];
            [button_Size setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
            [button_Size setTitle:@"尺码表" forState:UIControlStateNormal];
            [button_Size setTitle:@"尺码表" forState:UIControlStateHighlighted];
            button_Size.titleLabel.font=[UIFont systemFontOfSize:11];
            [button_Size setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];;
            [button_Size setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateHighlighted];
            [button_Size addTarget:self action:@selector(sizeButActionChick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button_Size];
            
            UIImageView *imageview_split=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"h_split_.png"]];
            imageview_split.frame=CGRectMake(20, 89, ScreenWidth-40, 2);
            [cell.contentView addSubview:imageview_split];
        }
            break;
        case 2:{
//            //动态创建 按钮数组 不改变原有button的tag分配
//            NSArray *buttonName=[NSArray arrayWithObjects:@"加入购物车",@"加入收藏",nil];
//            NSArray *buttonNameNoProduct=[NSArray arrayWithObjects:@"已售完",@"加入收藏", nil];
//            int h=0;
//            for (int i=0; i<2; i++) {
//                UIButton *buttonForAction=[UIButton buttonWithType:UIButtonTypeCustom];
//                buttonForAction.frame=CGRectMake(15+150*h+18*h, 9, 120, 40);
//                switch (i) {
//                    case 0:
//                        [buttonForAction setBackgroundImage:[UIImage imageNamed:@"login_btn.png"] forState:UIControlStateNormal];
//                        [buttonForAction setBackgroundImage:[UIImage imageNamed:@"login_btn_press.png"] forState:UIControlStateHighlighted];
//                        [buttonForAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                        [buttonForAction setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//                        break;
//                    case 1:
//                    {
//                        [buttonForAction setImage:[UIImage imageNamed:@"icon_like_gray.png"] forState:UIControlStateNormal];
//                        [buttonForAction setImage:[UIImage imageNamed:@"icon_like_red.png"] forState:UIControlStateHighlighted];
//                        [buttonForAction setImage:[UIImage imageNamed:@"icon_like_red.png"] forState:UIControlStateSelected];
//                        
//                        //lee999增加收藏过的商品，显示红色
//                        //lee999 增加  || isgoodHasAddFav    修改bug  单品页，点击收藏，收藏标识变成红色，选择颜色或者尺码，收藏标识变成灰色的了。。点击收藏按钮提示已经收藏过。选择颜色尺码后收藏按钮的颜色不应变灰色
//                        if (productModel.isSollection || isgoodHasAddFav) {
//                            [buttonForAction setImage:[UIImage imageNamed:@"icon_like_red.png"] forState:UIControlStateNormal];
//                        }
//                        //end
//                        
//                        [buttonForAction setImageEdgeInsets:UIEdgeInsetsMake(10, 90, 10, 10)];
//                        [buttonForAction setTitleEdgeInsets:UIEdgeInsetsMake(10, -45, 10, 0)];
//                        [buttonForAction setBackgroundImage:[UIImage imageNamed:@"add_like_btn.png"] forState:UIControlStateNormal];
//                        [buttonForAction setBackgroundImage:[UIImage imageNamed:@"add_like_btn_press.png"] forState:UIControlStateHighlighted];
//                        [buttonForAction setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                        [buttonForAction setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
//                        
//                        addButfav = buttonForAction;
//                    }
//                        break;
//                    default:
//                        break;
//                }
//                if (self.leftNUM<1) {
//                    if (i==0) {
//                        [buttonForAction setEnabled:NO];
//                    }
//                    
//                    [buttonForAction setTitle:[buttonNameNoProduct objectAtIndex:i] forState:UIControlStateNormal];
//                }else{
//                    [buttonForAction setTitle:[buttonName objectAtIndex:i] forState:UIControlStateNormal];
//                    [buttonForAction setEnabled:YES];
//                }
//
//                //加入收藏夹
//                [buttonForAction addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
//                buttonForAction.tag=200+i;
//                [cell.contentView addSubview:buttonForAction];
//                h++;
//
                // 商品详情按钮
                YKProductDetailCell *productView = [[[NSBundle mainBundle] loadNibNamed:@"YKProductDetailCell" owner:self options:nil]lastObject];
                productView.noticeLabel.text = productModel.notice ;
                productView.frame = CGRectMake(0, 0, ScreenWidth, 180);
                //商品详情~~~~~~
                [productView.ButProductdetail addTarget:self action:@selector(Productdetail_ActiveShow:) forControlEvents:UIControlEventTouchUpInside];
                //商品评价~~~~~~
                [productView.ButProductPingjian addTarget:self action:@selector(Productdetail_PingjianShow:) forControlEvents:UIControlEventTouchUpInside];
                productView.LabelPingJiancount.text = [NSString stringWithFormat:@"%@人评论", productModel.commentcount==nil?@"":productModel.commentcount];
        
                [cell.contentView addSubview:productView];
//
//            }
        }
            break;
        case 3:
        {
            UIButton * button_Size = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([productModel.suitid isKindOfClass:[NSString class]]) {
                button_Size.frame = CGRectMake(48, 4, 226, 44);
                button_Size.titleLabel.font = [UIFont systemFontOfSize:16];
                [button_Size setTitle:@"优 惠 套 装" forState:UIControlStateNormal];
                [button_Size setImage:[UIImage imageNamed:@"sale_icon.png"] forState:UIControlStateNormal];
                [button_Size setImage:[UIImage imageNamed:@"sale_icon.png"] forState:UIControlStateHighlighted];
                [button_Size setImageEdgeInsets:UIEdgeInsetsMake(8, 60, 12, 142)];
                [button_Size setBackgroundImage:[UIImage imageNamed:@"login_btn.png"] forState:UIControlStateNormal];
                [button_Size setBackgroundImage:[UIImage imageNamed:@"login_btn_press.png"] forState:UIControlStateHighlighted];
                [button_Size setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button_Size addTarget:self action:@selector(preferendialsuit:) forControlEvents:UIControlEventTouchUpInside];
                
            }else{
                button_Size.frame=CGRectMake(105, 0, 120, 0);
            }
            [cell.contentView addSubview:button_Size];
        }
            break;
        case 4:
        {//详情描述、问答、评价
//            UIImageView * imageView_recommend = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"same_recommand_bg.png"]];
//            imageView_recommend.frame = CGRectMake(0, 0+10, ScreenWidth, 28);
//            [cell.contentView addSubview:imageView_recommend];

            UILabel *label_recommend = [[UILabel alloc]initWithFrame:CGRectMake(0, 0+10, ScreenWidth, 28)];
            label_recommend.textAlignment = UITextAlignmentCenter;
            label_recommend.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
            label_recommend.text = @"同系列产品推荐";
            label_recommend.font = [UIFont systemFontOfSize:LabSmallSize];
            label_recommend.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:label_recommend];
         }
            break;
        case 5: {
            int height= 1;
            for (int i=0; i<[productModel.recommendlist count]/3+1; i++) {
                for (int j=0; j<3&&i*3+j<[productModel.recommendlist count]; j++) {
                    UIView *view_button=[[UIView alloc]initWithFrame:CGRectMake(j*lee1fitAllScreen(104), height+i* lee1fitAllScreen(114), lee1fitAllScreen(112), lee1fitAllScreen(124))];
                    
                    UIButton *control = [[UIButton alloc] initWithFrame:CGRectMake(10, 9, lee1fitAllScreen(91), lee1fitAllScreen(111))];
                    control.tag =i*3+j ;
                    [[NSUserDefaults standardUserDefaults]setObject:[[productModel.recommendlist objectAtIndex:i*3+j]RecommendID] forKey:[[NSNumber numberWithInteger:control.tag] description]];
                    
                    UrlImageView *imageView=[[UrlImageView alloc]init];
                    imageView.frame=CGRectMake(0, 0, lee1fitAllScreen(91), lee1fitAllScreen(111));
                    [imageView setImageWithURL:[NSURL URLWithString:[self ImageSize:[[productModel.recommendlist objectAtIndex:i*3+j]RecommendPic] Size:ChangeImageURL]] placeholderImage:nil];
                    [control addSubview:imageView];
                    
                    control.adjustsImageWhenHighlighted = NO;
                    control.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:14];
                    [control setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, lee1fitAllScreen(3), lee1fitAllScreen(5))];
                    [control setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [view_button addSubview:control];
                 
                    [control addTarget:self action:@selector(PressRecommend:) forControlEvents:UIControlEventTouchDown];
                    [cell.contentView addSubview:view_button];
                }
            }
        }
            break;
        default:
            break;
    } // end switch
    
    cell.clipsToBounds=YES;
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


-(NSString *)getLastViewController{
    NSArray *viewControllers=[self.navigationController viewControllers];
    NSString *vcClass = nil;
    if (viewControllers.count >=2 ) {
        vcClass=NSStringFromClass([[viewControllers objectAtIndex:[viewControllers count]-2] class]);
    }
    return vcClass;
}

#pragma mark ===商品详情

- (void)Productdetail_ActiveShow:(UIButton *)sender {
    ProductDetailInfoViewController *productDescriptionVC = [[ProductDetailInfoViewController alloc] init];
    productDescriptionVC.url = productModel.str_Pro_desc;
    productDescriptionVC.isHiddenBar = self.isHiddenBar;
    [self.navigationController pushViewController:productDescriptionVC animated:YES];
}

#pragma mark === 商品评价
- (void)Productdetail_PingjianShow:(UIButton *)sender {

    ShowcomMentViewController *aceessVC = [[ShowcomMentViewController alloc] init];
    aceessVC.goodId = self.thisProductId;
    aceessVC.pingjian = productModel.commentcount;
    aceessVC.isFromMyAimer = self.isFromMyAimer;
    aceessVC.isHiddenBar = self.isHiddenBar;
    [self.navigationController pushViewController:aceessVC animated:YES];

}


#pragma mark 尺寸对照按钮事件的
- (void)sizeButActionChick:(UIButton *)sender {
        
    if (productModel.size_url.length<1) {
        [SBPublicAlert showMBProgressHUD:@"此分类暂无尺码表" andWhereView:self.view hiddenTime:0.6];
    }else {
        
        YKCanReuse_webViewController *webView = [[YKCanReuse_webViewController alloc] init];
        webView.strURL = productModel.size_url;
        webView.strTitle = @"尺码对照";
        webView.isHiddenBar = self.isHiddenBar;
        [self.navigationController pushViewController:webView animated:YES];
    }
}


- (void)preferendialsuit:(id) sender
{
    YKPreferentialSuit *controller = [[YKPreferentialSuit alloc] init];
    controller.strStuit = productModel.suitid;
    controller.isFromMyAimer =  self.isFromMyAimer;
    controller.isHiddenBar = self.isHiddenBar;
    [self.navigationController pushViewController:controller animated:YES];
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([indexPath row]==0) {
//    }
//}
#pragma mark-- 同产品推荐
-(void)PressRecommend:(id)sender{
    
    UrlImageButton *button=(UrlImageButton*)sender;
    ProductDetailViewController *detial = [[ProductDetailViewController alloc]init];
    detial.thisProductId=[[NSUserDefaults standardUserDefaults] objectForKey:[[NSNumber numberWithInteger:button.tag] description]];
    detial.isFromMyAimer = self.isFromMyAimer;
    detial.isHiddenBar = self.isHiddenBar;
    detial.isPush = YES;
    [self.navigationController pushViewController:detial animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int rs = 0;
    if (hasSuit) { //判断是不是有套装
        switch ([indexPath row]) {
            case 0:
                if ([productModel.arr_desc count]<3) {
                    return 110;
                }else{
                    return 110;
                }
                break;
            case 1:
                if (self.leftNUM==0) {
                    rs=0;
                }else{
                    rs=92;
                }
                return rs;
                break;
            case 2:
                return 180; // lee999 修改添加购物车，收藏，商品详情，评价，公告的位置
//                return 152+48  + 40; //商品详情和评价 后又加上公告字段
                
                break;
            case 3:
                return 52;
                break;
            case 4:
                if ([productModel.recommendlist count]==0) {
                    return 0;
                }else{
                    return 15;
                }
            case 5:
                if ([productModel.recommendlist count]==0) {
                    //同系列产品推荐
                    return 10;
                }else{
                    return self.buttonView_height;
                }
                break;
            default: break;
        }
    }
    else {
        switch ([indexPath row]) {
            case 0:
                if ([productModel.arr_desc count]<3) {
                    return 110;
                }else{
                    return 110;
                }
                break;
            case 1:
                if (self.leftNUM==0) {
                    rs=0;
                }else{
                    rs=92;
                }
                return rs;
                break;
            case 2:
                return 180; // lee999 修改添加购物车，收藏，商品详情，评价，公告的位置
//                return 152+48  + 40; //商品详情和评价 后又加上公告字段  //
//                break;
            case 3:
                if ([productModel.recommendlist count]==0) {
                    return 0;
                }else{
                    return 44;
                }
            case 4:
                if ([productModel.recommendlist count]==0) {
                    return 20;
                }else{
                    return self.buttonView_height;
                }
                break;
            default: break;
        }
    }
    
    return 0;
}

#pragma mark - dealloc

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self hiddenBar];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"1002", @"PageID",nil];
    [TalkingData trackEvent:@"5" label:@"商品详情" parameters:dic];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"avoidReload" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelConnection" object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
