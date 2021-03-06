//
//  CarpageViewController.m
//  aimerOnline
//
//  Created by lee on 14-3-3.
//  Copyright (c) 2014年 aimer. All rights reserved.
//
//

#import "BfdAgent.h"
#import "CommModel.h"
#import "CarpageViewController.h"
#import "ProductDetailViewController.h"
#import "UIImage+ImageSize.h"
#import "YKChoseGiftViewController.h"
#import "CheckOutViewController.h"
#import "MyButton.h"
#import "NSString+WPAttributedMarkup.h"


@interface CarpageViewController () <mobideaRecProtocol>
{
    
    BOOL isEditing; //是否编辑状态
    UIView* vToolbar;
    UIButton* btnCheckOut;
}
@property (nonatomic, retain) NSMutableArray* selectedList;
@property (nonatomic, retain) UIButton* btnCheckBox;
@end

@implementation CarpageViewController

- (id)init{
    self = [super init];
    if (self)
        self.title = @"购物车";
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isDisable  = YES;
    
    isEditing = NO;
    
    //创建编辑购物车按钮
    [self createEditbtn];
    
    
    textproductNumArray = [[NSMutableArray alloc] init] ;
	_tableCells = [[NSMutableArray alloc] init] ;
	_favCells = [[NSMutableArray alloc] init] ;
    _suitlistcell = [[NSMutableArray alloc] initWithCapacity:1];
    _packagelistcell = [[NSMutableArray alloc] initWithCapacity:1];
    _selectedList = [[NSMutableArray alloc] initWithCapacity:1];
    mainSer = [[MainpageServ alloc] init];
    mainSer.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.title = @"购物车";

    [self NewSHowTableBarwithAnimated:YES];
    
    //lee999如果是编辑状态，则恢复未原来的状态
    if (isEditing) {
        [self editCarNumber];
    }
    
    [self loadData];
    
    [DplusMobClick track:@"购物车"];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self ShowFooterwithAnimated:NO];
    
    self.isPush = NO;
}

//lee999 如果处于编辑状态的话，恢复原来的状态
-(void)viewWillDisappear:(BOOL)animated{
    //如果是编辑状态，则恢复未原来的状态
    
    if (isEditing) {
        isEditing = NO;
        isEditing = NO;
        [self finishEditCar];
    }
}
//end

-(void)loadData{
    
    [mainSer getCar];
    [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];
    if (isCheck) {
        isCheck = NO;
        if ([SingletonState sharedStateInstance].userHasLogin) {
            [self gotoChectViewC:nil];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //lee新增 是否选择放弃赠品
    if (alertView.tag ==  10087) {
        if (buttonIndex == 1) {
            CheckOutViewController* chectOut = [[CheckOutViewController alloc] init];
            [self.navigationController pushViewController:chectOut animated:YES];
        }
        return;
    }
    //end
    
    if (alertView.tag == 10000000 && buttonIndex == 1) {
        //切换到我的爱慕进行登录 来源于竖屏的商场~~
        [self changeToMyaimer];
    }
}

#pragma mark-- 去结算中心 & 删除按钮
-(void)gotoChectViewC:(UIButton*)sender
{
    if (sender && sender.selected) {
        //删除
        NSMutableArray* marrUks = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray* marrUksname = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray* marrUksnum = [[NSMutableArray alloc] initWithCapacity:1];

        for (YKItem* item in _carModel.carProductlist) {
            if (item.selected) {
                [marrUks addObject:item.uk];
                [marrUksname addObject:item.name];
                [marrUksnum addObject:item.number];
            }
        }
        for (YKSuitListItem* item in _carModel.suitlist) {
            if (item.selected) {
                [marrUks addObject:item.uk];
                [marrUksname addObject:item.name];
                [marrUksnum addObject:@"1"];

            }
        }
        for (YKSuitListItem* item in _carModel.packagelist) {
            if (item.selected) {
                [marrUks addObject:item.uk];
                [marrUksname addObject:item.name];
                [marrUksnum addObject:@"1"];
            }
        }
        
        [DplusMobClick track:@"移出购物车" property:@{@"商品Sku":[marrUks componentsJoinedByString:@"|"],
                                                 @"商品名称":[marrUksname componentsJoinedByString:@"|"],
                                                 @"商品数量":[marrUksnum componentsJoinedByString:@"|"]}];
        
        [mainSer getDelcar:[marrUks componentsJoinedByString:@"|"]];
        [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];

        return;
    }
    if (self.carModel.showwarn) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"爱慕提示" message:(NSString *)self.carModel.warn delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil,nil];
        alert.tag = 1000988;
		[alert show];
        return;
    }
	if ([SingletonState sharedStateInstance].userHasLogin) {
        
        //lee999 新增判断
        if ([self.carModel.gifts count] != 0) {
            UIAlertView *alertv = [[UIAlertView alloc] initWithTitle:@"爱慕提示" message:@"您还没有将赠品添加到购物车哦，请在下方赠品区选择，否则视为自动放弃！" delegate:self cancelButtonTitle:@"返回添加" otherButtonTitles:@"去结算", nil];
            alertv.tag = 10087;
            [alertv show];
            return;
        }
        
        //lee999 150708 新增判断 如果没选中商品的话，不能进入结算中心
        if ([_carModel.itemNumber integerValue] == 0) {
            [SBPublicAlert showMBProgressHUD:@"请您勾选购物车中的商品" andWhereView:self.view hiddenTime:AlertShowTime];
            return;
        }
        //end
        
        
        CheckOutViewController* chectOut = [[CheckOutViewController alloc] init];
        [self.navigationController pushViewController:chectOut animated:YES];
	} else {
        
        [self changeToMyaimer];
	}
}


#pragma mark--- 创建没有商品的view 和 表格
-(void)createNoGoodView{
    
    _nullView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, NowViewsHight)];
	_nullView.backgroundColor = [UIColor clearColor];
    
    UIImageView* ivEmpty = [[UIImageView alloc] init];
    [ivEmpty setFrame:CGRectMake((ScreenWidth - lee1fitAllScreen(105)) / 2, 80, lee1fitAllScreen(105), lee1fitAllScreen(110))];
    [ivEmpty setImage:[UIImage imageNamed:@"shop_none"]];
    [_nullView addSubview:ivEmpty];
    
    
	UILabel* name = [[UILabel alloc] init];
    NSMutableAttributedString* maStr = [[NSMutableAttributedString alloc] initWithString:@"您的购物车还是空的哦！\n快去选购自己喜欢的宝贝吧~"];
    NSMutableParagraphStyle* mps = [[NSMutableParagraphStyle alloc] init];
    [mps setLineBreakMode:NSLineBreakByCharWrapping];
    [mps setLineSpacing:12];
    [mps setAlignment:NSTextAlignmentCenter];
    
    [maStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#b8b8b8"] range:NSMakeRange(0, maStr.length)];
    [maStr addAttribute:NSParagraphStyleAttributeName value:mps range:NSMakeRange(0, maStr.length)];
    [maStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:lee1fitAllScreen(14)] range:NSMakeRange(0, maStr.length)];
	[name setAttributedText:maStr];
    
    name.numberOfLines = 2;
	name.backgroundColor = [UIColor clearColor];
    CGRect rcName = [name.attributedText boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];
    [name setFrame:CGRectMake(0, ivEmpty.frame.size.height + ivEmpty.frame.origin.y + 32, ScreenWidth, rcName.size.height)];
	[_nullView addSubview:name];
    
    UIButton* gotobutton = [UIButton buttonWithType:UIButtonTypeCustom];
	gotobutton.frame = CGRectMake((ScreenWidth - lee1fitAllScreen(170)) / 2, lee1fitAllScreen(294), lee1fitAllScreen(170), lee1fitAllScreen(36));
	gotobutton.titleLabel.font = [UIFont systemFontOfSize:lee1fitAllScreen(17)];
	[gotobutton setTitle:@"去逛逛" forState:UIControlStateNormal];
	[gotobutton addTarget:self action:@selector(gotoShopping) forControlEvents:UIControlEventTouchUpInside];
    [gotobutton setBackgroundColor:[UIColor colorWithHexString:@"#c8002c"]];
    [gotobutton.layer setCornerRadius:gotobutton.frame.size.height / 2];
    [gotobutton.layer setMasksToBounds:YES];
	[_nullView addSubview:gotobutton];
}


-(void)checkTable{
    
    //lee999recode
    //lee999如果是编辑状态，则恢复未原来的状态
    if ([self.carModel.carProductlist count]<1) {
        //if (isEditing) {
        if (isEditing) {
            [self setNavRightEdit];
        }
    }
    
	if ([self.carModel.carProductlist count]>0 || [self.carModel.suitlist count] > 0  || [self.carModel.packagelist count] > 0) {
        //购物车中有商品
        if (self.nullView) {
            [self.nullView removeFromSuperview];
        }
		[self.view addSubview:shoppingCarTab];
        if (vToolbar) {
            [self.view bringSubviewToFront:vToolbar];
        }
        self.navbtnRight.hidden = NO;
	}else {
        //购物车为空
        if (shoppingCarTab) {
            [shoppingCarTab removeFromSuperview];
        }
        if (vToolbar) {
            [vToolbar removeFromSuperview];
            vToolbar = nil;
        }
        if (!self.nullView) {
            [self createNoGoodView];
        }
		[self.view addSubview:self.nullView];
        //如果购物车里没有数据就加载nillview 并隐藏navBar上的两个按钮
        self.navbtnRight.hidden = YES;
        isEditing = NO;
	}
}


#pragma mark -- NETrequest delegate
-(void)serviceStarted:(ServiceType)aHandle{
}

-(void)serviceFailed:(ServiceType)aHandle{
    [SBPublicAlert hideMBprogressHUD:self.view];
}

-(void)serviceFinished:(ServiceType)aHandle withmodel:(id)amodel
{
    [SBPublicAlert hideMBprogressHUD:self.view];
    NSUInteger tag = (NSUInteger)aHandle;
    if(tag > 200)
    {
        switch (tag) {
            case Http_PartChangeItem20_Tag:
            {
                if (amodel) {
                    if ([[[amodel objectForKey:@"response" isDictionary:nil] description] isEqualToString:@"error"]) {
                        [SBPublicAlert showMBProgressHUD:@"选择失败" andWhereView:self.view hiddenTime:0.6];
                    }else {
                        LBaseModel *model = [ModelManager parseModelWithDictionary:amodel tag:Http_Car_Tag];
                        self.carModel = (CarCarModel *)model;
                        BOOL hasContent = NO;
                        
                        
                        if (_carModel.carProductlist.count) {
                            [self creatCells];
                            hasContent = YES;
                        }else{
                            //lee999 150711 如果没有赠品的话，移除
                            productCount = [self.carModel.carProductlist count];
                        }
                        
                        
                        if (_carModel.suitlist.count) {
                            [self createSuitlistcells];
                            hasContent = YES;
                        }else{
                            //lee999 150711 如果没有赠品的话，移除
                            suitCount = [self.carModel.suitlist count];
                        }
                        
                        
                        if (_carModel.packagelist.count) {
                            [self createPackagelistcells];
                            hasContent = YES;
                        }else{
                            //lee999 150711 如果没有赠品的话，移除
                            packageCount = [self.carModel.packagelist count];
                        }
                        
                        
                        if (hasContent) {
                            [self creatToolBar];
                        }
                        [shoppingCarTab reloadData];
                        return;
                    }
                }else
                {
                    return;
                }
            }
                break;
            default:
                break;
        }
    }
    
    LBaseModel *model = (LBaseModel *)amodel;
    
    switch (model.requestTag) {
        case Http_Car_Tag:
        {
            if (model.errorMessage) {
                [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:0.6];
                return;
            }
            
            self.carModel = (CarCarModel *)model;
            
            BOOL hasContent = NO;
            if (_carModel.carProductlist.count) {
                [self creatCells];
                hasContent = YES;
            }else{
                //lee999 150711 如果没有赠品的话，移除
                productCount = [self.carModel.carProductlist count];
            }
            
            
            if (_carModel.suitlist.count) {
                [self createSuitlistcells];
                hasContent = YES;
            }else{
                suitCount = [self.carModel.suitlist count];
            }
            
            
            if (_carModel.packagelist.count) {
                [self createPackagelistcells];
                hasContent = YES;
            }else{
                //lee999 150711 如果没有赠品的话，移除
                packageCount = [self.carModel.packagelist count];
            }
            
            
            
            if (hasContent) {
                [self creatToolBar];
                //lee999 百分点  150708 增加百分点参数
                //在购物车页面需要在recommend中传字段ids(服务器推荐商品id）和iid（传加入购物车的商品id）
                
                NSMutableArray *arrItemids = [[NSMutableArray alloc] initWithCapacity:0];
                for (YKItem *item in _carModel.hotlist) {
                    [arrItemids addObject:item.productid];
                }
                NSString *strids = @"";
                if ([arrItemids count]>0) {
                    strids = [arrItemids componentsJoinedByString:@"|"];
                }
                
                NSMutableArray *arrItemiid = [[NSMutableArray alloc] initWithCapacity:0];
                for (YKItem *item in _carModel.carProductlist) {
                    [arrItemiid addObject:item.goodsid];
                }
                NSString *striid = @"";
                if ([arrItemiid count]>0) {
                    striid = [arrItemiid componentsJoinedByString:@"|"];
                }
                
                //usersessionUserid  150715 usersession 改为  uid  @"usersession"
                NSString *str = @"";
                if ([[NSUserDefaults standardUserDefaults]objectForKey:@"usersessionUserid"]) {
                    str = [[NSUserDefaults standardUserDefaults]objectForKey:@"usersessionUserid"];
                }
                [BfdAgent recommend:self recommendId:@"rec_FDFEE10D_5A29_BE14_3808_3C336BA76303" options:@{@"ids":strids,@"iid":striid,@"uid":str}];
            }
            

            [self checkTable];
            [shoppingCarTab reloadData];
            [SBPublicAlert hideMBprogressHUD:self.view];
            
        }
            break;
        case Http_EditCar_Tag:
        {
            if (model.errorMessage) {
                
                [self creatCells];
                [self createSuitlistcells];
                [self createPackagelistcells];
                [self creatToolBar];
                [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:0.6];
                
            }else {
                self.carModel = (CarCarModel *)model;
                
                [self creatCells];
                [self createSuitlistcells];
                [self createPackagelistcells];
                [self creatToolBar];
                [SBPublicAlert hideMBprogressHUD:self.view];
                [shoppingCarTab reloadData];
            }
        }
            break;
        //lee新增，删除套装
        case Http_Suittocart_deletes_Tag:

        case  Http_Delcar_Tag://从购物车删除:
        {
            if (model.errorMessage) {
                [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:0.6];
                return;
            }
            NSMutableString *str = [NSMutableString string];
            
            for (int i = 0; i < self.carModel.carProductlist.count; i++) {
                YKItem *item = [self.carModel.carProductlist objectAtIndex:i isArray:nil];
                if ([item.type isEqualToString:@"gift"]) {
                    if (i == self.carModel.carProductlist.count -1) {
                        [str appendString:[NSString stringWithFormat:@"%@:gift",item.productid]];
                    }else {
                        [str appendString:[NSString stringWithFormat:@"%@:gift|",item.productid]];
                    }
                }
            }
            if (![str isEqualToString:@""]) {
                [mainSer getDelcar:str];
                [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];
            }
            
            self.carModel = (CarCarModel *)model;
            [self creatCells];
            [self createSuitlistcells];
            [self createPackagelistcells];
            [self creatToolBar];
            [self checkTable];
            [shoppingCarTab reloadData];
            
            [SBPublicAlert hideMBprogressHUD:self.view];
        }
            break;
        case Http_FavoriteAdd_Tag : {
            if (!model.errorMessage) {
                [SBPublicAlert showMBProgressHUD:@"收藏成功" andWhereView:self.view hiddenTime:0.6];
                NSString* strUk = [((CommModel*)model).jsonDic objectForKey:@"uk" isDictionary:nil];
                
                //将下架商品，添加收藏，并且移除购物车
                
                
                
                [DplusMobClick track:@"移出购物车" property:@{@"商品Sku":strUk,
                                                         @"商品名称":@"下架商品"}];
                
                [mainSer getDelcar:[NSString stringWithFormat:@"%@:product", strUk]];
                [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];

                
            }else {
                [SBPublicAlert showMBProgressHUD:@"收藏失败" andWhereView:self.view hiddenTime:0.6];
            }
        }
            break;
        case 10086:
        {
            [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:0.6];
        }
            break;
        default:
            break;
    }
    
    //lee999 150711 设置气泡
    NSString *strbadge = @"0";
    if ([_carModel.bubble_count integerValue] == 0) {
        strbadge = _carModel.bubble_count;
    }else{
        strbadge = _carModel.bubble_count;
    }
    //end
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%.f",[strbadge floatValue]] forKey:@"totalNUM"];
//    [UIApplication sharedApplication].applicationIconBadgeNumber = [[[NSUserDefaults standardUserDefaults]objectForKey:@"totalNUM"]intValue];
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"totalNUM"]intValue] > 0) {
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [[[[app.mytabBarController tabBar] items] objectAtIndex:3 isArray:nil] setBadgeValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"totalNUM"]];
    }else{
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [[[[app.mytabBarController tabBar] items] objectAtIndex:3 isArray:nil] setBadgeValue:@""];
    }
    //end
}

-(void) mobidea_Recs:(NSError*) error feedback:(id)feedback{
    
    NSLog(@"百分点推荐数据：--%@",feedback);
    
    if ([feedback respondsToSelector:@selector(objectAtIndex:)]) {
        NSArray *arr = (NSArray*)feedback;
        if ([arr count] > 0) {
            NSInteger count = 0;
            for (NSDictionary* dic in feedback) {
                if (count > 2) {
                    break;
                }
                YKItem* item = [[YKItem alloc] init];
                item.productid = [dic objectForKey:@"iid"];
                item.imgurl = [dic objectForKey:@"img"];
                item.name = [dic objectForKey:@"name"];
                item.strdiscountprice = [dic objectForKey:@"price"];
                item.price = [dic objectForKey:@"mktp"];
                item.url = [dic objectForKey:@"url"];
                [_carModel.hotlist insertObject:item atIndex:0];
                ++count;
            }
            [self creatFootView];
        }
    }
}

#pragma mark ===逛一逛 事件
-(void)gotoShopping{
    [self changetableBarto:0];
}

-(void)creatToolBar
{
    if (vToolbar) {
        [vToolbar removeFromSuperview];
        vToolbar = nil;
    }
    vToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - lee1fitAllScreen(60), ScreenWidth, lee1fitAllScreen(60))];
    [vToolbar setBackgroundColor:[UIColor colorWithHexString:@"#f8f8f8"]];
    [vToolbar setAlpha:0.9];
    
    
    btnCheckOut = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCheckOut setFrame:CGRectMake(vToolbar.frame.size.width - 10 - lee1fitAllScreen(90), (vToolbar.frame.size.height - lee1fitAllScreen(44)) / 2, lee1fitAllScreen(90), lee1fitAllScreen(44))];
    [btnCheckOut setBackgroundImage:[UIImage imageNamed:@"btn_shop_a_normal"] forState:UIControlStateNormal];
    [btnCheckOut setBackgroundImage:[UIImage imageNamed:@"btn_shop_a_normal"] forState:UIControlStateSelected];
    [btnCheckOut setBackgroundImage:[UIImage imageNamed:@"btn_shop_a_hoverl"] forState:UIControlStateHighlighted];
    
    if (!isEditing) {
        [btnCheckOut setTitle:[NSString stringWithFormat:@"结算(%@)", _carModel.itemNumber] forState:UIControlStateNormal];
    }else{
        [btnCheckOut setTitle:[NSString stringWithFormat:@"删除(%@)", _carModel.itemNumber] forState:UIControlStateNormal];
    }
    [btnCheckOut setTitle:@"" forState:UIControlStateHighlighted];
    [btnCheckOut setTitle:[NSString stringWithFormat:@"删除(%@)", _carModel.itemNumber] forState:UIControlStateSelected];

    [btnCheckOut addTarget:self action:@selector(gotoChectViewC:) forControlEvents:UIControlEventTouchUpInside];
    
    [vToolbar addSubview:btnCheckOut];
    
    if(self.navbtnRight)
    {
        if ([[self.navbtnRight titleForState:UIControlStateNormal] isEqualToString:@"完成"]) {
            
            [btnCheckOut setSelected:YES];
        }
    }
    
    _btnCheckBox = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCheckBox setFrame:CGRectMake(15, (vToolbar.frame.size.height - lee1fitAllScreen(22)) / 2, lee1fitAllScreen(22), lee1fitAllScreen(22))];
    [_btnCheckBox setImage:[UIImage imageNamed:@"choice_unchecked"] forState:UIControlStateNormal];
    [_btnCheckBox setImage:[UIImage imageNamed:@"choice_checked"] forState:UIControlStateSelected];
    [_btnCheckBox addTarget:self action:@selector(checkBoxAction:) forControlEvents:UIControlEventTouchUpInside];
    [vToolbar addSubview:_btnCheckBox];
    
    BOOL selectAll = YES;
    for (YKItem* item in _carModel.carProductlist) {
        if(!item.is_valid)
        {
            continue;
        }
        if(!item.selected)
        {
            selectAll = NO;
            break;
        }
    }
    for (YKSuitListItem* item in _carModel.suitlist) {
        if(!item.is_valid)
        {
            continue;
        }
        if(!item.selected)
        {
            selectAll = NO;
            break;
        }
    }
    for (YKSuitListItem* item in _carModel.packagelist) {
        if(!item.is_valid)
        {
            continue;
        }
        if(!item.selected)
        {
            selectAll = NO;
            break;
        }
    }
    _btnCheckBox.selected = selectAll;
    
    UILabel* lbl = [[UILabel alloc] init];
    [lbl setText:@"全选"];
    [lbl setTextColor:[UIColor colorWithHexString:@"#666666"]];
    [lbl setFont:[UIFont systemFontOfSize:17]];
    CGRect rc = [lbl.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : lbl.font} context:nil];
    [lbl setFrame:CGRectMake(_btnCheckBox.frame.size.width + _btnCheckBox.frame.origin.x + 12, (vToolbar.frame.size.height - rc.size.height) / 2, rc.size.width, rc.size.height)];
    [vToolbar addSubview:lbl];
    
    lbl = [[UILabel alloc] init];
    [lbl setText:[NSString stringWithFormat:@"%.2f元", [_carModel.selectedItemCount floatValue]]];
    [lbl setTextColor:[UIColor colorWithHexString:@"#c8002c"]];
    [lbl setFont:[UIFont systemFontOfSize:17]];
    rc = [lbl.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : lbl.font} context:nil];
    [lbl setFrame:CGRectMake(btnCheckOut.frame.origin.x - 14 - rc.size.width, 13, rc.size.width, rc.size.height)];
    [vToolbar addSubview:lbl];
    if(isEditing)
    {
        [lbl setHidden:YES];
    }
    
    CGRect lastlblFrame = lbl.frame;
    lbl = [[UILabel alloc] init];
    [lbl setText:@"总计:"];
    [lbl setTextColor:[UIColor colorWithHexString:@"#333333"]];
    [lbl setFont:[UIFont systemFontOfSize:12]];
    rc = [lbl.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : lbl.font} context:nil];
    [lbl setFrame:CGRectMake(lastlblFrame.origin.x - rc.size.width, 16, rc.size.width, rc.size.height)];
    [vToolbar addSubview:lbl];
    if(isEditing)
    {
        [lbl setHidden:YES];
    }
    
    lbl = [[UILabel alloc] init];
    [lbl setText:@"不含运费"];
    [lbl setTextColor:[UIColor colorWithHexString:@"#333333"]];
    [lbl setFont:[UIFont systemFontOfSize:12]];
    rc = [lbl.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : lbl.font} context:nil];
    [lbl setFrame:CGRectMake(btnCheckOut.frame.origin.x - 14 - rc.size.width, 38, rc.size.width, rc.size.height)];
    [vToolbar addSubview:lbl];
    if(isEditing)
    {
        [lbl setHidden:YES];
    }
    [self.view addSubview:vToolbar];
    [self.view bringSubviewToFront:vToolbar];
    
    if ([_carModel.selectedItemCount floatValue] == 0) {
        btnCheckOut.enabled = NO;
    }else{
        btnCheckOut.enabled = YES;
    }
    
}

-(void)creatHeadView{
	UIView* headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, lee1fitAllScreen(60))];
	headView.backgroundColor = [UIColor clearColor];
	UILabel* sizeName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 25)];
	sizeName.backgroundColor = [UIColor clearColor];
	sizeName.text = @"商品数量：";
	sizeName.font = [UIFont systemFontOfSize:14];
	sizeName.textColor = [UIColor blackColor];//UIColorFromRGB(0x666666)
	[headView addSubview:sizeName];
	
	UILabel* value = [[UILabel alloc] initWithFrame:CGRectMake(180, 10, 130, 25)];
	value.backgroundColor = [UIColor clearColor];
    
    value.text = self.carModel.itemNumber;
	value.textAlignment = UITextAlignmentRight;
	value.font = [UIFont systemFontOfSize:12];
	value.textColor = [UIColor blackColor];//UIColorFromRGB(0x666666)
	[headView addSubview:value];
	
	UILabel* sizeName1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 180, 30)];
	sizeName1.backgroundColor = [UIColor clearColor];
	sizeName1.text = @"应付总额（不含运费）：";
	sizeName1.font = [UIFont systemFontOfSize:14];
	sizeName1.textColor = [UIColor blackColor];//UIColorFromRGB(0x666666)
	[headView addSubview:sizeName1];
	
	UILabel* value1 = [[UILabel alloc] initWithFrame:CGRectMake(180, 30, 130, 25)];
	value1.backgroundColor = [UIColor clearColor];
    value1.text = [NSString stringWithFormat:@"¥%@",self.carModel.itemPrice];
	value1.textAlignment = UITextAlignmentRight;
	value1.font = [UIFont boldSystemFontOfSize:14];
	value1.textColor = [UIColor colorWithHexString:@"0xB90023"];//UIColorFromRGB(0xB90023);
	[headView addSubview:value1];
	
	shoppingCarTab.tableHeaderView = headView;
}

//进入商品详情
-(void)touchAction:(UITapGestureRecognizer*)sender{
    
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    
    //lee999 150708 新增编辑状态不能进入商品详情
    if (btnCheckOut.selected) {
        return;
    }
    //end
    
	YKItem* item = (YKItem*)[self.carModel.hotlist objectAtIndex:tap.view.tag isArray:nil];
	ProductDetailViewController* detail = [[ProductDetailViewController alloc] init];
	detail.thisProductId = item.productid;
    detail.ThisPorductName=item.name;
    detail.isPush = YES;
    
    NSDictionary *dic1  = [NSDictionary dictionaryWithObjectsAndKeys:item.productid, @"GoodsID",item.name, @"GoodsName",nil];
    [TalkingData trackEvent:@"5008" label:@"购物车推荐" parameters:dic1];
    
	[self.navigationController pushViewController:detail animated:YES];
    
    
    [DplusMobClick track:@"购物车推荐" property:@{@"商品ID":item.productid,@"商品名称":item.name}];
    
    //lee999 新增百分点
    if (tap.view.tag < 3) {

        
        //lee9999 修改 百分点的唯一标示  @“usersession”
        NSString *str = @"";
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"usersessionUserid"]) {
            str = [[NSUserDefaults standardUserDefaults]objectForKey:@"usersessionUserid"];
        }

        [BfdAgent feedback:self recommendId:@"rec_FDFEE10D_5A29_BE14_3808_3C336BA76303" itemId:item.productid options:@{@"uid":str}];
    }
    
}

- (void)creatFootView
{
    CGFloat unitHeight = lee1fitAllScreen(187);
    NSInteger count = _carModel.hotlist.count > 6 ? 6 : _carModel.hotlist.count;
    NSInteger row = count % 3 > 0 ? (count / 3 + 1) : (count / 3);
	UIView* footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 39 + 65 + unitHeight * (row) + lee1fitAllScreen(60))];
	footView.backgroundColor = [UIColor clearColor];
	    
    UILabel * notice = [[UILabel alloc] initWithFrame:CGRectMake(25, 6, ScreenWidth - 40, 65)];
	notice.text = [NSString stringWithFormat:@"温馨提示：%@", self.carModel.notice];
	notice.textColor = [UIColor colorWithHexString:@"#181818"];//UIColorFromRGB(0xB90023);
	notice.backgroundColor = [UIColor clearColor];
	notice.font = [UIFont systemFontOfSize:14];
    notice.numberOfLines = 3;
	[footView addSubview:notice];
		
    UIView *splineV = [[UIView alloc] initWithFrame:CGRectMake(0, 65 + 12, ScreenWidth, 0.5)];
    [splineV setBackgroundColor:[UIColor colorWithHexString:splineBGC]];
    [footView addSubview:splineV];
    
	UILabel* tit = [[UILabel alloc] initWithFrame:CGRectMake(0, 65 + 12 + 12, ScreenWidth, 13)];
	tit.text = @"热销商品推荐";
	tit.textColor = [UIColor colorWithHexString:@"#181818"];
    tit.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    tit.textAlignment = NSTextAlignmentCenter;
	tit.backgroundColor = [UIColor clearColor];
	[footView addSubview:tit];
	
    CGFloat originX = 10;
    CGFloat originY = 39 + 80;
    CGFloat unitWidth = lee1fitAllScreen(90);
    CGFloat spacing = (ScreenWidth - unitWidth * 3 - originX * 2) / 2;
	for (NSInteger i = 0; i < count; ++i) {
		YKItem* item = (YKItem *)[self.carModel.hotlist objectAtIndex:i isArray:nil];
        UIView* vUnit = [[UIView alloc] initWithFrame:CGRectMake(originX + (i % 3) * (spacing + unitWidth), (i / 3) * (unitHeight) + originY, unitWidth, unitHeight)];
        vUnit.tag = i;
        // 单击的 Recognizer
        UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction:)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        [vUnit addGestureRecognizer:singleRecognizer];
        
        UrlImageView* uiv = [[UrlImageView alloc] initWithFrame:CGRectMake(0, 0, unitWidth, lee1fitAllScreen(110))];
        [uiv setImageWithURL:[NSURL URLWithString:item.imgurl] placeholderImage:nil];
        [vUnit addSubview:uiv];
        
        UILabel* lblName = [[UILabel alloc] init];
        [lblName setText:item.name];
        [lblName setTextColor:[UIColor colorWithHexString:@"#333333"]];
        [lblName setFont:[UIFont systemFontOfSize:11]];
        [lblName setLineBreakMode:NSLineBreakByTruncatingTail];
        [lblName setNumberOfLines:2];
        
        NSMutableParagraphStyle* mps = [[NSMutableParagraphStyle alloc] init];
        mps.lineBreakMode = NSLineBreakByCharWrapping;
        mps.lineSpacing = 6;
        CGRect rcName = [lblName.text boundingRectWithSize:CGSizeMake(unitWidth, 40) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : lblName.font, NSParagraphStyleAttributeName : mps} context:nil];
        [lblName setFrame:CGRectMake(0, uiv.frame.origin.y + uiv.frame.size.height + 10, unitWidth, rcName.size.height)];
        [vUnit addSubview:lblName];
        
        UILabel* lblPrice = [[UILabel alloc] init];
        [lblPrice setTextColor:[UIColor colorWithHexString:@"#c8002c"]];
        [lblPrice setText:[NSString stringWithFormat:@"￥%.2f", [item.strdiscountprice floatValue]]];
        [lblPrice setFont:[UIFont systemFontOfSize:12]];
        [lblPrice setFrame:CGRectMake(0, uiv.frame.size.height + uiv.frame.origin.y + 45, unitWidth, 13)];
        [vUnit addSubview:lblPrice];
  
        //lee999 150713 注释掉 原价，省的有冲突
//        if([item.strdiscountprice floatValue] != [item.price floatValue])
//        {
//            UILabel* lblMPrice = [[UILabel alloc] init];
//            [lblMPrice setTextColor:[UIColor colorWithHexString:@"#888888"]];
//            [lblMPrice setFont:[UIFont systemFontOfSize:12]];
//            [lblMPrice setTextAlignment:NSTextAlignmentRight];
//            NSString* str = [NSString stringWithFormat:@"￥%.2f", [item.price floatValue]];
//            NSMutableAttributedString* mattStr = [[NSMutableAttributedString alloc] initWithString:str];
//            [mattStr addAttribute:NSStrikethroughColorAttributeName value:lblMPrice.textColor range:NSMakeRange(0, str.length)];
//            [mattStr addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:1] range:NSMakeRange(0, str.length)];
//            [mattStr addAttribute:NSForegroundColorAttributeName value:lblMPrice.textColor range:NSMakeRange(0, str.length)];
//            [mattStr addAttribute:NSFontAttributeName value:lblMPrice.font range:NSMakeRange(0, str.length)];
//            [lblMPrice setAttributedText:mattStr];
//            [lblMPrice setFrame:CGRectMake(0, uiv.frame.size.height + uiv.frame.origin.y + 45, unitWidth, 13)];
//            [vUnit addSubview:lblMPrice];
//        }
        
        [footView addSubview:vUnit];
        
    }
	
	shoppingCarTab.tableFooterView = footView;
}

- (void)add_LikeChick:(UIButton *)sender {
    
    
    YKItem* item = (YKItem*)[self.carModel.carProductlist objectAtIndex:sender.tag - 300 isArray:nil];
    
    if ([SingletonState sharedStateInstance].userHasLogin) {
        NSDictionary *dic1  = [NSDictionary dictionaryWithObjectsAndKeys:item.productid, @"GoodsID",item.name, @"GoodsName",nil];
        [TalkingData trackEvent:@"1006" label:@"加入收藏夹" parameters:dic1];

        UIButton *btn = (UIButton*)sender;
        [btn setImage:[UIImage imageNamed:@"icon_like_red.png"] forState:UIControlStateNormal];

        
        
        [mainSer getFavoriteadd:item.goodsid andType:@"goods" anduk:item.productid];
        [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];
        
    }else{
        
        [self changeToMyaimer];

    }
}

#pragma mark---  编辑购车按钮的相关功能
//创建购物车编辑按钮
-(void)createEditbtn{
    //创建右边按钮
    [self createRightBtn];
//    [self setNavRightEdit];
    
    
    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@"nav_icon_edit.png"] forState:UIControlStateNormal];
    [self.navbtnRight setTitle:@"" forState:UIControlStateNormal];
    [self.navbtnRight setTitle:@"" forState:UIControlStateHighlighted];
    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@"nav_icon_edit_press.png"] forState:UIControlStateHighlighted];
    [self.navbtnRight setFrame:CGRectMake(ScreenWidth-110, 10, 25, 25)];
    
//    [self.navbtnRight addTarget:self action:@selector(editCarNumber) forControlEvents:UIControlEventTouchUpInside];
    
    
}

//设置为编辑模式
-(void)setNavRightEdit{
    
    
//    [shoppingCarTab setEditing:NO animated:YES];

    
//    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@"nav_icon_edit.png"] forState:UIControlStateNormal];
//    [self.navbtnRight setTitle:@"" forState:UIControlStateNormal];
//    [self.navbtnRight setTitle:@"" forState:UIControlStateHighlighted];
//    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@"nav_icon_edit_press.png"] forState:UIControlStateHighlighted];
//    [self.navbtnRight setFrame:CGRectMake(225, 10, 25, 25)];
//    
//    [self.navbtnRight addTarget:self action:@selector(editCarNumber) forControlEvents:UIControlEventTouchUpInside];
}
//设置为编辑完成
-(void)setNavRightOK{
    
    [shoppingCarTab setEditing:YES animated:YES];

    
//    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@"nav_btn.png"] forState:UIControlStateNormal];
//    [self.navbtnRight setTitle:@"完成" forState:UIControlStateNormal];
//    [self.navbtnRight setTitle:@"完成" forState:UIControlStateHighlighted];
//    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@"nav_btn_press.png"] forState:UIControlStateHighlighted];
//    [self.navbtnRight setFrame:CGRectMake(242, 7, 66, 32)];
//    
//    [self.navbtnRight removeTarget:self action:@selector(editCarNumber) forControlEvents:UIControlEventTouchUpInside];
//    [self.navbtnRight addTarget:self action:@selector(finishEditCar) forControlEvents:UIControlEventTouchUpInside];
}

-(void)rightButAction
{
    if (isEditing) {
        [self finishEditCar];
        isEditing = NO;

    }else
    {
        [self editCarNumber];
        isEditing = YES;
    }
}

#pragma mark---- 编辑按钮的Action  转为编辑状态
-(void)editCarNumber{
    
    [shoppingCarTab reloadData];
//    [shoppingCarTab setEditing:isEditing animated:YES];
    
    if (btnCheckOut) {
        [btnCheckOut setSelected:YES];
    }
  
    //lee999 150715 关于购物车 删除和结算完成的按钮修改 最后一次修改如果不行，就还原这个地方  我也无语了
    [btnCheckOut setTitle:@"" forState:UIControlStateNormal];
//    if (!isEditing) {
//        [btnCheckOut setTitle:[NSString stringWithFormat:@"结算(%@)", _carModel.itemNumber] forState:UIControlStateNormal];
//    }else{
//        [btnCheckOut setTitle:[NSString stringWithFormat:@"删除(%@)", _carModel.itemNumber] forState:UIControlStateNormal];
//    }
//
////    if (isEditing) {
////        [btnCheckOut setTitle:@"" forState:UIControlStateNormal];
////    }else{
////        [btnCheckOut setTitle:@"" forState:UIControlStateNormal];
////    }
    //end

    
    if(vToolbar)
    {
        for (id v in vToolbar.subviews) {
            if([v class] == [UILabel class])
            {
                UILabel* lbl = (UILabel*)v;
                if ([lbl.text isEqualToString:@"全选"]) {
                    continue;
                }
            }
            if ([v class] == [UIButton class]) {
                continue;
            }
            [v setHidden:YES];
        }
    }
    
    [self.navbtnRight setTitle:@"完成" forState:UIControlStateNormal];
    [self.navbtnRight setTitle:@"完成" forState:UIControlStateHighlighted];
    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [self.navbtnRight setFrame:CGRectMake(ScreenWidth- 80, 7, 66, 32)];
    
//    [self.navbtnRight addTarget:self action:@selector(finishEditCar) forControlEvents:UIControlEventTouchUpInside];
    
    //lee999 150503 修改输入框
//    for (UITableViewCell *tbvc in self.tableCells) {
//        id v = [tbvc viewWithTag:100992];
//        if ([v class] == [UITextField class]) {
//            [(UITextField*)v setBackground:[UIImage imageNamed:@"sort_bg_02_press.png"]];
//        }
//    }
    
    for (int i=0; i<[textproductNumArray count]; i++) {
        UITextField* textfield = (UITextField*)[textproductNumArray objectAtIndex:i isArray:nil];
        [textfield setBackground:[UIImage imageNamed:@"sort_bg_02_press.png"]];
        [textfield resignFirstResponder];
    }
    
    //end
    
//    [shoppingCarTab setEditing:!isEditing animated:YES];


    
//    UITextField* numberValue = [[UITextField alloc] initWithFrame:CGRectMake(isEditing?228:245, yOffset+1, 36, 20)];
//    numberValue.textAlignment=UITextAlignmentCenter;
//    numberValue.tag = 100992;
//    
//    if (isEditing) {
//        numberValue.background=[UIImage imageNamed:@"sort_bg_02_press.png"];
//    
    
//    [self setNavRightOK];
    
//    [shoppingCarTab setEditing:YES animated:YES];

    
    //编辑状态
//	if (isEditing) {
//
//        [self setNavRightOK];
////		for (int i=0; i<[textproductNumArray count]; i++) {
//////			UITextField* textfield = (UITextField*)[textproductNumArray objectAtIndex:i];
//////            textfield.textColor=[UIColor colorWithHexString:@"#ffffff"];
//////            textfield.background=[UIImage imageNamed:@"input_.png"];
////		}
//        
//        
//        //lee999 1013把这个地方注释了，为了修改一个bug，不知道能不能成功.....
////		[self creatCells];
////        [self createSuitlistcells];
////		[shoppingCarTab reloadData];
//		
//	}else {
//    //完成状态
//        
//        [self setNavRightEdit];
//        
////		for (int i=0; i<[textproductNumArray count]; i++) {
//////			UITextField* textfield = (UITextField*)[textproductNumArray objectAtIndex:i];
//////            textfield.textColor=[UIColor colorWithHexString:@"#ffffff"];
//////            textfield.background=[UIImage imageNamed:@"input_.png"];
////		}
////		[shoppingCarTab reloadData];
//	}
    
	for (int i=0; i<[textproductNumArray count]; i++) {
		UITextField* textfield = (UITextField*)[textproductNumArray objectAtIndex:i isArray:nil];
		[textfield resignFirstResponder];
	}
    //lee999
//    for (int i=0; i<[textsuitNumArray count]; i++) {
//		UITextField* textfield = (UITextField*)[textsuitNumArray objectAtIndex:i];
//		[textfield resignFirstResponder];
//	}
    //end
    
//	[self creatFootView];
    
//	if (isEditing) {
		[self.addfavButton setBackgroundImage:[UIImage imageNamed:@"big_btn_hover.png"] forState:UIControlStateNormal];
		self.addfavButton.enabled = NO;
//	}else {
//		[self.addfavButton setBackgroundImage:[UIImage imageNamed:@"big_btn.png"] forState:UIControlStateNormal];
//		self.addfavButton.enabled = YES;
//	}
}


#pragma mark---- 完成按钮的Action  转为编辑完状态
-(void)finishEditCar{
    
//    sku :   货品ID:数量:类型(product、gift)|货品ID:数量:类型(product、gift)  如果是赠品：11052064707566:1:gift:549 549为赠品活动的id
    
    if (btnCheckOut) {
        [btnCheckOut setSelected:NO];
    }
    
    [btnCheckOut setTitle:[NSString stringWithFormat:@"结算(%@)", _carModel.itemNumber] forState:UIControlStateNormal];

    
    if(vToolbar)
    {
        for (UIView* v in vToolbar.subviews) {
            [v setHidden:NO];
        }
    }
    
//    [shoppingCarTab setEditing:isEditing animated:YES];

    
    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@"nav_icon_edit.png"] forState:UIControlStateNormal];
    [self.navbtnRight setTitle:@"" forState:UIControlStateNormal];
    [self.navbtnRight setTitle:@"" forState:UIControlStateHighlighted];
    [self.navbtnRight setBackgroundImage:[UIImage imageNamed:@"nav_icon_edit_press.png"] forState:UIControlStateHighlighted];
    [self.navbtnRight setFrame:CGRectMake(ScreenWidth-110, 10, 25, 25)];
    
//    [self.navbtnRight addTarget:self action:@selector(editCarNumber) forControlEvents:UIControlEventTouchUpInside];
    
    
    //    [shoppingCarTab reloadData];
    
    //清除掉框框
    for (int i=0; i<[textproductNumArray count]; i++) {
        UITextField* textfield = (UITextField*)[textproductNumArray objectAtIndex:i isArray:nil];
        [textfield setBackground:[UIImage imageNamed:@""]];
        [textfield resignFirstResponder];
    }
    
    
    if ([textproductNumArray count] > 0) {
        NSMutableString * sku = [NSMutableString string];
        for (int i=0; i<[textproductNumArray count]; i++) {
            
            UITextField* textfield = (UITextField*)[textproductNumArray objectAtIndex:i isArray:nil];
            [textfield resignFirstResponder];
            NSInteger number = [textfield.text intValue];
            
            YKItem *item = (YKItem *)[self.carModel.carProductlist objectAtIndex:i isArray:nil];
            
            if(number == 0)
            {
                [SBPublicAlert showAlertTitle:@"爱慕提示" Message:@"数量不得小于1"];
                textfield.text = [NSString stringWithFormat:@"%@", item.number];
                isEditing = NO;
                return;
            }
            //获取库存 和当前数量进行比对
            if (number > item.count && item.is_valid) {
                [SBPublicAlert showAlertTitle:@"爱慕提示" Message:@"您有商品库存不足！"];
                //isEditing = !isEditing;
                textfield.text = [NSString stringWithFormat:@"%@",item.number];
                isEditing = NO;
                return;
                
                textfield.text = [[NSNumber numberWithInteger:item.count] description];
                [shoppingCarTab setEditing:NO animated:YES];
                isEditing = NO;

                //lee999  这个地方的问题已经修复！
                if ([item.type isEqualToString:@"product"]) {
                    if (i==[textproductNumArray count]-1) {
                        [sku appendString: [NSString stringWithFormat:@"%@:%@:product",item.productid, [[NSNumber numberWithInteger:item.count] description]]];
                    }else {
                        [sku appendString:[NSString stringWithFormat:@"%@:%@:product|",item.productid, [[NSNumber numberWithInteger:item.count] description]]];
                    }
                }
                NSLog(@"sku是：-----%@",sku);
                [mainSer getEditcar:sku]; // *	修改购物车
                [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];
                //end
                
                return;
            }
            
            //重新拼接SKU
            if ([item.type isEqualToString:@"product"]) {
                if (i==[textproductNumArray count]-1) {
                    [sku appendString: [NSString stringWithFormat:@"%@:%@:product",item.productid, [[NSNumber numberWithInteger:number] description]]];
                }else {
                    [sku appendString:[NSString stringWithFormat:@"%@:%@:product|",item.productid, [[NSNumber numberWithInteger:number] description]]];
                }
            }
        }
        NSLog(@"sku是：-----%@",sku);
        //isEditing = !isEditing;
        [mainSer getEditcar:sku]; // *	修改购物车
        [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];
        
    } else {
        
        //isEditing = !isEditing;
        [mainSer getCar];
        [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (range.location > 0) {
        textField.text = string;
		return NO;
	}
	return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
//	if (isEditing) {
    if (isEditing) {
	} else{
        [textField resignFirstResponder];
    }
//	[shoppingCarTab scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark 赠品的详细页
-(void)addfavAction{
    YKChoseGiftViewController* gift = [[YKChoseGiftViewController alloc] init];
    [self.navigationController pushViewController:gift animated:YES];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSInteger index = indexPath.row;
    if (indexPath.section < suitCount) {
        if ([indexPath section] < 0 || [indexPath section] >= [self.carModel.suitlist count]) {
            return ;
        }
        YKSuitListItem *item = [self.carModel.suitlist objectAtIndex:[indexPath section] isArray:nil];
        //删除套装
        //....
        [mainSer getDeletesuittocar:item.suitid];
        [SBPublicAlert showMBProgressHUD:@"正在请求" andWhereView:self.view states:NO];
        
        
        [DplusMobClick track:@"移出购物车" property:@{@"商品Sku":item.suitid,
                                                 @"商品名称":item.name,
                                                 @"商品类型":@"套装"}];
        
    }
    else if (indexPath.section - suitCount < packageCount) {
        if ([indexPath section] < 0) {
            return ;
        }
        YKSuitListItem *item = [self.carModel.packagelist objectAtIndex:[indexPath section] - suitCount  isArray:nil];
        [mainSer getDelcar:item.uk];
        [SBPublicAlert showMBProgressHUD:@"正在请求" andWhereView:self.view states:NO];
        
        
        [DplusMobClick track:@"移出购物车" property:@{@"商品Sku":item.uk,
                                                    @"商品名称":item.name,
                                                    @"商品类型":@"礼包"}];
        
        
        //删除套装
        //....
//        [mainSer getDeletesuittocar:item.suitid];
//        [SBPublicAlert showMBProgressHUD:@"正在请求" andWhereView:self.view states:NO];
        
    }
    else if ([indexPath section] - suitCount - packageCount < productCount && !isaddfav) {
		YKItem* item = (YKItem *)[self.carModel.carProductlist objectAtIndex:indexPath.section - suitCount - packageCount  isArray:nil];
        NSString* sku = @"";
        if ([item.type isEqualToString:@"product"]) {
            sku = [NSString stringWithFormat:@"%@:product",item.productid];
        }else {
            sku = [NSString stringWithFormat:@"%@:gift",item.productid];
        }

        NSDictionary *dic1  = [NSDictionary dictionaryWithObjectsAndKeys:item.name, @"GoodsName",sku, @"SKU",[NSNumber numberWithShort:currentNumber],@"Number",nil];
        [TalkingData trackEvent:@"1007" label:@"从购物车删除" parameters:dic1];
        
        [mainSer getDelcar:sku];
    
        
        
        [DplusMobClick track:@"移出购物车" property:@{@"商品Sku":sku,
                                                 @"商品名称":item.name,
                                                 @"商品类型":@"单品"}];
        
        [SBPublicAlert showMBProgressHUD:@"正在请求" andWhereView:self.view states:NO];
        
    } else {
        //修改: 有赠品商品:删除按钮
        if ([indexPath section] - suitCount - packageCount < productCount && isaddfav) {
            YKItem* item = (YKItem *)[self.carModel.carProductlist objectAtIndex:indexPath.section - suitCount - packageCount  isArray:nil];
            NSString* sku = @"";
            if ([item.type isEqualToString:@"product"]) {
                sku = [NSString stringWithFormat:@"%@:product",item.productid];
            }else {
                sku = [NSString stringWithFormat:@"%@:gift",item.productid];
            }

            NSDictionary *dic1  = [NSDictionary dictionaryWithObjectsAndKeys:item.name, @"GoodsName",sku, @"SKU",[NSNumber numberWithShort:currentNumber],@"Number",nil];
            [TalkingData trackEvent:@"1007" label:@"从购物车删除" parameters:dic1];
            
            [mainSer getDelcar:sku];
            [SBPublicAlert showMBProgressHUD:@"正在请求" andWhereView:self.view states:NO];
            
            
            
            [DplusMobClick track:@"移出购物车" property:@{@"商品Sku":sku,
                                                     @"商品名称":item.name,
                                                     @"商品类型":@"赠品"}];
        }
    }
}


#pragma mark 创建普通的商品列表
-(void)creatCells{
//	[self creatHeadView];
	[self creatFootView];
	[textproductNumArray removeAllObjects];
    //[textsuitNumArray removeAllObjects];
	[self.tableCells removeAllObjects];
    productCount = [self.carModel.carProductlist count];
	[self.favCells removeAllObjects];
	for (int i =0 ; i < [self.carModel.carProductlist count]; i++) {
		static NSString	*CellIdentifier = @"Cell1";
        UITableViewCell *shoppingCarCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                  reuseIdentifier:CellIdentifier];
        shoppingCarCell.selectionStyle = UITableViewCellSelectionStyleNone;

        
		YKItem* item = (YKItem*)[self.carModel.carProductlist objectAtIndex:i  isArray:nil];
        BOOL showStock = NO;
        BOOL isShowStock = NO;
        if (item.stock && ![item.stock isKindOfClass:[NSNull class]] && ![item.stock isEqualToString:@""]) {
            
            showStock = YES;
            
            //lee999 150707 新增已下架商品的判断 如果商品已下架，也显示删除按钮
            if ([item.stock isEqualToString:@"缺货"] || [item.stock isEqualToString:@"商品已下架"]) {
                isShowStock = YES;
            }
        }
        
        UIButton* btnCheckBox = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnCheckBox setFrame:CGRectMake(6, 36, lee1fitAllScreen(22) + 16, lee1fitAllScreen(22) + 16)];
        [btnCheckBox setImageEdgeInsets:UIEdgeInsetsMake(-8, -8, -8, -8)];
        [btnCheckBox setImage:[UIImage imageNamed:@"choice_unchecked.png"] forState:UIControlStateNormal];
        [btnCheckBox setImage:[UIImage imageNamed:@"choice_checked.png"] forState:UIControlStateSelected];
        [btnCheckBox addTarget:self action:@selector(productCheckBoxAction:) forControlEvents:UIControlEventTouchUpInside];
        btnCheckBox.selected = item.selected;
        [shoppingCarCell addSubview:btnCheckBox];
        
        CGFloat xOffset = 28 + lee1fitAllScreen(28);
        
		UrlImageView* shoppingImg = [[UrlImageView alloc] init];
		shoppingImg.frame = CGRectMake(xOffset, 16, lee1fitAllScreen(70), lee1fitAllScreen(90));
        if (isRetina) {
            [shoppingImg setImageWithURL:[NSURL URLWithString:[self ImageSize:item.imgurl Size:ChangeImageURL]] placeholderImage:nil];
        }else{
            [shoppingImg setImageWithURL:[NSURL URLWithString:[self ImageSize:item.imgurl Size:ChangeImageURL]] placeholderImage:nil];
        }
        [shoppingCarCell addSubview:shoppingImg];
        
        
        CGFloat fTextWidth = ScreenWidth - shoppingImg.frame.size.width - xOffset - 12 - 16;
        xOffset = shoppingImg.frame.size.width + shoppingImg.frame.origin.x + 16;
        CGFloat yOffset = 9;
        if (!showStock) {
            yOffset += 5;
        }
		
        CGFloat nameHeight = showStock?40:50;
		if ([item.type isEqualToString:@"gift"]) {
            
            NSDictionary* style1 = @{@"body":[UIFont fontWithName:@"HelveticaNeue" size:14],
                                     @"bold":[UIFont fontWithName:@"HelveticaNeue-Bold" size:14],
                                     @"red": [UIColor redColor]};
            
            UILabel* shoppingName = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, isEditing?160:180, 40)]; //textSize.height
			shoppingName.backgroundColor = [UIColor clearColor];
			shoppingName.lineBreakMode = NSLineBreakByTruncatingTail;
            shoppingName.attributedText = [[NSString stringWithFormat:@"<red>【赠品】</red>%@",item.name] attributedStringWithStyleBook:style1];
            shoppingName.font = [UIFont systemFontOfSize:14];
			[shoppingCarCell addSubview:shoppingName];
            shoppingName.numberOfLines = 2;
		}
        else {
            UILabel* shoppingName = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, fTextWidth, nameHeight)];
			shoppingName.backgroundColor = [UIColor clearColor];
			shoppingName.numberOfLines = 0;
			shoppingName.lineBreakMode = UILineBreakModeWordWrap;
			shoppingName.text = item.name;
			shoppingName.font = [UIFont systemFontOfSize:13];
			shoppingName.textColor = [UIColor blackColor];
			[shoppingCarCell addSubview:shoppingName];
		}
        yOffset += nameHeight+10;
        
        //lee999  显示缺货的文字
        if (showStock) {
            UILabel* desc = [[UILabel alloc] initWithFrame:CGRectMake(shoppingImg.frame.origin.x, shoppingImg.frame.origin.y + shoppingImg.frame.size.height + 10, shoppingImg.frame.size.width + 16 + fTextWidth / 2, 13)];
            desc.backgroundColor = [UIColor clearColor];
            desc.text = item.stock;
            desc.font = [UIFont systemFontOfSize:13];
            desc.textColor = [UIColor colorWithHexString:@"0xc8002c"];//UIColorFromRGB(0xB90023);
            [shoppingCarCell addSubview:desc];
            yOffset += 20;
        }
        UITextField* numberValue = nil;
        if (item.is_valid) {
            
            //UILabel* colorName = [[UILabel alloc] initWithFrame:CGRectMake(110, yOffset, isEditing?75:105, 20)];
            UILabel* colorName = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 62, fTextWidth / 2, 13)];
            colorName.backgroundColor = [UIColor clearColor];
            colorName.lineBreakMode = NSLineBreakByTruncatingTail;
            colorName.text = [NSString stringWithFormat:@"颜色：%@",item.color];
            colorName.font = [UIFont systemFontOfSize:13];
            colorName.textColor = [UIColor colorWithHexString:@"0x666666"];//UIColorFromRGB(0x3b3b3b);
            [shoppingCarCell addSubview:colorName];
            
            UILabel* numberName = [[UILabel alloc] init];
            
            numberName.frame=CGRectMake(xOffset + fTextWidth / 2, colorName.frame.origin.y, 110, 13);
            numberName.backgroundColor = [UIColor clearColor];
            numberName.text = @"数量：";
            numberName.font = [UIFont systemFontOfSize:13];
            numberName.textColor = [UIColor colorWithHexString:@"0x666666"];//UIColorFromRGB(0x3b3b3b);
            [shoppingCarCell addSubview:numberName];
            
            //lee999 商品数量
            numberValue = [[UITextField alloc] initWithFrame:CGRectMake(lee1fitAllScreen(255), numberName.frame.origin.y - 3, 36, 20)];
            numberValue.textAlignment=UITextAlignmentCenter;
            numberValue.tag = 100992;
            
            if (isEditing) {
                numberValue.background=[UIImage imageNamed:@"sort_bg_02_press.png"];
                numberValue.textColor = [UIColor blackColor];
            }else {
                numberValue.background=[UIImage imageNamed:@""];
                numberValue.textColor = [UIColor blackColor];
            }
            numberValue.text = [NSString stringWithFormat:@"%@",item.number];
            numberValue.tag = i;
            numberValue.delegate = self;
            numberValue.keyboardType = UIKeyboardTypeNumberPad;
            numberValue.font = [UIFont systemFontOfSize:14];
            if ([item.type isEqualToString:@"product"]) {
                [textproductNumArray addObject:numberValue];
            }
            [shoppingCarCell addSubview:numberValue];
            yOffset += 18;
            
            UILabel* sizeName = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 87, fTextWidth / 2, 13)];
            sizeName.backgroundColor = [UIColor clearColor];
            sizeName.text = [NSString stringWithFormat:@"尺码：%@",item.size];
            sizeName.font = [UIFont systemFontOfSize:13];
            sizeName.textColor = UIColorFromRGB(0x666666);
            [shoppingCarCell addSubview:sizeName];
            
//            int xOffset = 110;
            UIFont *font = [UIFont systemFontOfSize:13];
//            NSString *str = @"单价: ";
//            CGFloat strWidth = [str sizeWithFont:font].width;
            //UILabel* priceName = [[UILabel alloc] initWithFrame:CGRectMake(isEditing?198:213, yOffset, strWidth, 25)];
            UILabel* priceName = [[UILabel alloc] init];

            priceName.backgroundColor = [UIColor clearColor];
            priceName.text = [NSString stringWithFormat:@"单价: ¥%.2f",[item.price floatValue]];
            CGFloat strWidth = [priceName.text sizeWithFont:font].width;
            priceName.font = font;
            priceName.textColor = UIColorFromRGB(0x666666);
            [priceName setFrame:CGRectMake(numberName.frame.origin.x, sizeName.frame.origin.y, strWidth, 13)];
            [shoppingCarCell addSubview:priceName];
//            xOffset += strWidth;
            
//            str = [NSString stringWithFormat:@"¥%.2f",[item.price floatValue]];
//            strWidth = [str sizeWithFont:font].width;
            //UILabel* priceValue = [[UILabel alloc] initWithFrame:CGRectMake(isEditing?228:245, yOffset, strWidth, 25)];
//            UILabel* priceValue = [[UILabel alloc] initWithFrame:CGRectMake(245, yOffset, strWidth, 25)];
//
//            priceValue.backgroundColor = [UIColor clearColor];
//            priceValue.text = str;
//            priceValue.font = font;
//            priceValue.textColor =  UIColorFromRGB(0x3b3b3b);
//            [shoppingCarCell addSubview:priceValue];
//            xOffset += strWidth + (isEditing?28:28);
//            yOffset += 30;
            
            
            NSString* str = @"总价: ";
            strWidth = [str sizeWithFont:font].width;
            //UILabel* caseName = [[UILabel alloc] initWithFrame:CGRectMake(isEditing?198:213, yOffset, strWidth, 25)];
            UILabel* caseName = [[UILabel alloc] initWithFrame:CGRectMake(numberName.frame.origin.x, 112, strWidth, 13)];

            caseName.backgroundColor = [UIColor clearColor];
            caseName.text = str;
            caseName.font = font;
            caseName.textColor = UIColorFromRGB(0x181818);//UIColorFromRGB(0x666666)
            [shoppingCarCell addSubview:caseName];
            //            xOffset += strWidth;
            
            str = [NSString stringWithFormat:@"¥%.2f",[item.subtotal floatValue]];
            strWidth = [str sizeWithFont:font].width;
            //UILabel* caseValue = [[UILabel alloc] initWithFrame:CGRectMake(isEditing?228:245, yOffset, strWidth, 25)];
            UILabel* caseValue = [[UILabel alloc] initWithFrame:CGRectMake(caseName.frame.origin.x + caseName.frame.size.width, caseName.frame.origin.y, strWidth, 13)];

            caseValue.backgroundColor = [UIColor clearColor];
            caseValue.text = str;
            caseValue.font = font;
            caseValue.textColor = UIColorFromRGB(0xc8002c);
            [shoppingCarCell addSubview:caseValue];
            
//            UIView* vBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, lee1fitAllScreen(146))];
//            [shoppingCarCell setBackgroundView:vBG];
//            
//            UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, lee1fitAllScreen(146) - lee1fitAllScreen(10), ScreenWidth * 2, lee1fitAllScreen(10))];
//            [v setBackgroundColor:[UIColor colorWithHexString:@"#e0e0e0"]];
//            [vBG addSubview:v];
            
        }else {
            [btnCheckBox setHidden:YES];
            
            UIImageView* ivLogo = [[UIImageView alloc] initWithFrame:CGRectMake((shoppingImg.frame.origin.x - 35) / 2, 46, 35, 20)];
            [ivLogo setImage:[UIImage imageNamed:@"sign_bg_invalid_t"]];
            [shoppingCarCell addSubview:ivLogo];
            
            UIButton *buttonForAction=[UIButton buttonWithType:UIButtonTypeCustom];
            buttonForAction.frame = CGRectMake(180, 80, 120, 40);
            [buttonForAction setImage:[UIImage imageNamed:@"icon_like_gray.png"] forState:UIControlStateNormal];
            
            if ([item.isSollection intValue] == 0 ) {
                
                [buttonForAction setTitle:@"加入收藏" forState:UIControlStateNormal];
                [buttonForAction setImage:[UIImage imageNamed:@"icon_like_gray.png"] forState:UIControlStateNormal];
                [buttonForAction addTarget:self action:@selector(add_LikeChick:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [buttonForAction setTitle:@"已收藏" forState:UIControlStateNormal];
                [buttonForAction setImage:[UIImage imageNamed:@"icon_like_red.png"] forState:UIControlStateNormal];
                [buttonForAction removeTarget:self action:@selector(add_LikeChick:) forControlEvents:UIControlEventTouchUpInside];
          }
            
            [buttonForAction setImageEdgeInsets:UIEdgeInsetsMake(10, 90, 10, 10)];
            [buttonForAction setTitleEdgeInsets:UIEdgeInsetsMake(10, -45, 10, 0)];
            [buttonForAction setBackgroundImage:[UIImage imageNamed:@"add_like_btn.png"] forState:UIControlStateNormal];
            [buttonForAction setBackgroundImage:[UIImage imageNamed:@"add_like_btn_press.png"] forState:UIControlStateHighlighted];
            [buttonForAction setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [buttonForAction setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            buttonForAction.tag = i+300;
            [shoppingCarCell addSubview:buttonForAction];
            
        }
		
        xOffset = 28 + lee1fitAllScreen(28);
        
        UIView* vTap = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0, ScreenWidth - xOffset, lee1fitAllScreen(146))];
        [vTap setTag:i];
        [shoppingCarCell addSubview:vTap];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(simpleProductAction:)];
        [vTap setUserInteractionEnabled:YES];
        [vTap addGestureRecognizer:tap];
        
        if (numberValue) {
            [shoppingCarCell bringSubviewToFront:vTap];
        }
        
        [self.tableCells addObject:shoppingCarCell];
	}
    //    添加收藏
//    for (int i = 0; i < [self.carModel.carProductlist count]; i ++) {
//        static NSString	*CellIdentifier1 = @"Cell";
//        UITableViewCell *FavCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                                          reuseIdentifier:CellIdentifier1];
//        FavCell.selectionStyle = UITableViewCellSelectionStyleNone;
//        UIImageView* lineView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"h_split_.png"]];
//        lineView1.frame = CGRectMake(0, 130, ScreenWidth, 2);
//        [FavCell addSubview:lineView1];
//
//        UIImageView* bgview1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rr_side_js.png"]];
//        bgview1.frame = CGRectMake(10, 10, 93, 113);
//        [FavCell addSubview:bgview1];
//
//        UrlImageView* shoppingImg1 = [[UrlImageView alloc] init];
//        shoppingImg1.image = [UIImage imageNamed:@"rr_side_down_bg2.png"];
//        shoppingImg1.frame = CGRectMake(14, 15, 84, 103);
//        shoppingImg1.backgroundColor = [UIColor clearColor];
//        [FavCell addSubview:shoppingImg1];
//
//        UILabel* shoppingName1 = [[UILabel alloc] initWithFrame:CGRectMake(110, 15, 200, 45)];
//        shoppingName1.backgroundColor = [UIColor clearColor];
//        shoppingName1.numberOfLines = 0;
//        shoppingName1.lineBreakMode = UILineBreakModeWordWrap;
//        shoppingName1.text = @"爱美丽精致文胸";
//        shoppingName1.font = [UIFont systemFontOfSize:13];
//        shoppingName1.textColor = [UIColor blackColor];//UIColorFromRGB(0x666666)
//        [FavCell addSubview:shoppingName1];
//        
//        UIButton* addFav = [UIButton buttonWithType:UIButtonTypeCustom];
//        addFav.frame = CGRectMake(180, 80, 130, 35);
//        addFav.titleLabel.font = [UIFont systemFontOfSize:13];
//        [addFav setTitle:@"加入收藏夹" forState:UIControlStateNormal];
//        [addFav setBackgroundImage:[UIImage imageNamed:@"big_btn.png"] forState:UIControlStateNormal];
//        [addFav setBackgroundImage:[UIImage imageNamed:@"big_btn_hover.png"] forState:UIControlStateHighlighted];
//        [FavCell addSubview:addFav];
//        
//        [self.favCells addObject:FavCell];
//    }
}


#pragma mark  创建套装列表
-(void)createSuitlistcells
{
    [self.suitlistcell removeAllObjects];
    suitCount = [self.carModel.suitlist count];
    
    for (int j=0; j<[self.carModel.suitlist count]; j++) {
        YKSuitListItem* item = [self.carModel.suitlist objectAtIndex:j isArray:nil];
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1];
        
        static NSString	*CellSuitlist3 = @"Cell3";
        UITableViewCell *viewSuitlistCell3 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellSuitlist3];
        viewSuitlistCell3.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        UIImageView *buttom = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 60)];
//        
//        [buttom setImage:[[UIImage imageNamed:@"list_bg_03.png"] resizableImageWithCap:UIEdgeInsetsMake(5, 5, 0, 0)]];
//        [viewSuitlistCell3 addSubview:buttom];
        
        UIFont *font = [UIFont systemFontOfSize:13];
        CGFloat xOffset = 28 + lee1fitAllScreen(28);
        CGFloat yOffset = 16;
        CGFloat height = 14;
        
        if (item.is_valid) {
            UIButton* btnCheckBox = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnCheckBox setFrame:CGRectMake(6, 16, lee1fitAllScreen(22) + 16, lee1fitAllScreen(22) + 16)];
            [btnCheckBox setImageEdgeInsets:UIEdgeInsetsMake(-8, -8, -8, -8)];
            [btnCheckBox setImage:[UIImage imageNamed:@"choice_unchecked"] forState:UIControlStateNormal];
            [btnCheckBox setImage:[UIImage imageNamed:@"choice_checked"] forState:UIControlStateSelected];
            [btnCheckBox addTarget:self action:@selector(suitCheckBoxAction:) forControlEvents:UIControlEventTouchUpInside];
            btnCheckBox.selected = item.selected;
            [viewSuitlistCell3 addSubview:btnCheckBox];
        }else
        {
            UIImageView* ivLogo = [[UIImageView alloc] initWithFrame:CGRectMake((50 - 35) / 2, 10, 35, 20)];
            [ivLogo setImage:[UIImage imageNamed:@"sign_bg_invalid_t"]];
            [viewSuitlistCell3 addSubview:ivLogo];
        }
        
        UILabel* pName = [[UILabel alloc] init];
        pName.backgroundColor = [UIColor clearColor];
        pName.lineBreakMode = UILineBreakModeTailTruncation;
        pName.text = item.name;
        pName.font = [UIFont systemFontOfSize:14];
        pName.textColor = [UIColor blackColor];//UIColorFromRGB(0x666666);
        NSMutableParagraphStyle* mps = [[NSMutableParagraphStyle alloc] init];
        [mps setLineBreakMode:pName.lineBreakMode];
        CGRect rcName = [pName.text boundingRectWithSize:CGSizeMake((lee1fitAllScreen(204) - xOffset), MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : pName.font, NSParagraphStyleAttributeName : mps} context:nil];
        [pName setFrame:CGRectMake(xOffset, yOffset - (rcName.size.height > pName.font.pointSize ? rcName.size.height - pName.font.pointSize : 0), (lee1fitAllScreen(204) - xOffset), rcName.size.height)];
        [viewSuitlistCell3 addSubview:pName];
        
        /*
         //lee999 套装的商品数量要求可以编辑~~
         //lee999 商品数量
         UITextField* numberValue = [[UITextField alloc] initWithFrame:CGRectMake(xOffset+40, yOffset+3, 36, height)];
         numberValue.textAlignment=UITextAlignmentCenter;
         if (isEditing) {
         numberValue.background=[UIImage imageNamed:@"sort_bg_02_press.png"];
         numberValue.textColor = [UIColor blackColor];
         }else {
         numberValue.background=[UIImage imageNamed:@""];
         numberValue.textColor = [UIColor blackColor];
         }
         numberValue.text = [NSString stringWithFormat:@"%d",item.number];
         numberValue.tag = j;
         numberValue.delegate = self;
         numberValue.keyboardType = UIKeyboardTypeNumberPad;
         numberValue.font = [UIFont systemFontOfSize:14];
         [textsuitNumArray addObject:numberValue];
         [viewSuitlistCell3 addSubview:numberValue];
         */
        
        NSString *str = @"套装价: ";
        int strWidth = [str sizeWithFont:font].width;
        UILabel* desc = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset + 20, strWidth, height)];
        desc.backgroundColor = [UIColor clearColor];
        desc.text = str;
        desc.font = [UIFont systemFontOfSize:14];
        desc.textColor = UIColorFromRGB(0x181818);/*UIColorFromRGB(0x666666)*/
        [viewSuitlistCell3 addSubview:desc];
        xOffset += strWidth;
        
        desc = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, desc.frame.origin.y, 90, height)];
        desc.backgroundColor = [UIColor clearColor];
        desc.text = [NSString stringWithFormat:@"￥%.2f", item.disountprice];
        desc.font = [UIFont systemFontOfSize:14];
        desc.textColor = UIColorFromRGB(0xc8002c);
        [viewSuitlistCell3 addSubview:desc];
        xOffset = lee1fitAllScreen(204);
        
        desc = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, desc.frame.origin.y, 110, height)];
        desc.backgroundColor = [UIColor clearColor];
        desc.lineBreakMode = UILineBreakModeMiddleTruncation;
        desc.text = [NSString stringWithFormat:@"优惠: ￥%.2f", item.save];
        desc.font = [UIFont systemFontOfSize:14];
        desc.textColor = UIColorFromRGB(0x666666);
        [viewSuitlistCell3 addSubview:desc];
        
        
        NSDictionary* style1 = @{@"body":[UIFont fontWithName:@"HelveticaNeue" size:14],
                                 @"bold":[UIFont fontWithName:@"HelveticaNeue-Bold" size:14],
                                 @"red": [UIColor colorWithHexString:@"666666"]};

        
        desc = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, pName.frame.origin.y, ScreenWidth - xOffset - 12, rcName.size.height)];
        desc.backgroundColor = [UIColor clearColor];
        desc.lineBreakMode = UILineBreakModeMiddleTruncation;
        desc.attributedText = [[NSString stringWithFormat:@"<red>数量：</red>%d",item.number] attributedStringWithStyleBook:style1];
//        desc.text = [NSString stringWithFormat:@"数量: %d", item.number];
        desc.font = [UIFont systemFontOfSize:14];
        [viewSuitlistCell3 addSubview:desc];
        
        [array addObject:viewSuitlistCell3];
        
        xOffset = 28 + lee1fitAllScreen(28);
        for (int k = 0; k<[item.suits count]; k++) {
            static NSString	*CellIdentifier2 = @"Cell2";
            UITableViewCell *Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:CellIdentifier2];
            Cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel* lblSep = [[UILabel alloc] initWithFrame:CGRectMake(28 + lee1fitAllScreen(28), 0, ScreenWidth - 28 - lee1fitAllScreen(28) - 12, 1)];
            [lblSep setBackgroundColor:[UIColor colorWithHexString:@"#d0d0d0"]];
            [Cell addSubview:lblSep];
//            UIImageView *icon = nil;
//            if (k==0) {
//                
//                UIImageView *topImageV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 150)];
//                [topImageV setImage:[[UIImage imageNamed:@"list_bg_01.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 14, 250, 100)]];
//                
//                [Cell addSubview:topImageV];
//                
//                icon  = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 21, 38)];
//                [icon setImage:[UIImage imageNamed:@"icon_suit.png"]];
//                [Cell addSubview:icon];
//                
//            }else {
//                UIImageView *modile = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 150)];
//                [modile setImage:[[UIImage imageNamed:@"list_bg_02.png"]resizableImageWithCap:UIEdgeInsetsMake(5, 5, 0, 0)]];
//                [Cell addSubview:modile];
//            }
            
            YKProductsItem *pItem = [item.suits objectAtIndex:k isArray:nil];
            BOOL showStock = NO;
            if (pItem.stock && ![pItem.stock isKindOfClass:[NSNull class]] && ![pItem.stock isEqualToString:@""]) {
                showStock = YES;
            }
            
//            UIImageView* bgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart_pic_bg.png"]];
//            bgview.frame = CGRectMake(14, 10, 93, 113);
//            [Cell addSubview:bgview];
            
            UrlImageView* shoppingImg = [[UrlImageView alloc] init];
            [shoppingImg setImageWithURL:[NSURL URLWithString:pItem.pic] placeholderImage:nil];
            shoppingImg.frame = CGRectMake(xOffset, 12, lee1fitAllScreen(70), lee1fitAllScreen(90));
            [Cell addSubview:shoppingImg];
            
            CGFloat fTextWidth = ScreenWidth - shoppingImg.frame.size.width - xOffset - 12 - 16;
            
            int yOffset = 6;
            if (!showStock) {
                yOffset += 8;
            }
            
            CGFloat nameHeight = showStock ? 40 : 45;
            UILabel* shoppingName = [[UILabel alloc] initWithFrame:CGRectMake(shoppingImg.frame.origin.x + shoppingImg.frame.size.width + 16, yOffset, fTextWidth/*isEditing ? 160 : 190*/, nameHeight)];
            shoppingName.backgroundColor = [UIColor clearColor];
            shoppingName.numberOfLines = 0;
            shoppingName.lineBreakMode = UILineBreakModeWordWrap;
            shoppingName.text = pItem.name;
            shoppingName.font = [UIFont systemFontOfSize:13];
            shoppingName.textColor = [UIColor colorWithHexString:@"#181818"];
            [Cell addSubview:shoppingName];

            yOffset += nameHeight;
            
            if (showStock) {
                UILabel* desc = [[UILabel alloc] initWithFrame:CGRectMake(shoppingImg.frame.origin.x + shoppingImg.frame.size.width + 16, yOffset, fTextWidth, 12)];
                desc.backgroundColor = [UIColor clearColor];
                desc.text = pItem.stock;
                desc.font = [UIFont systemFontOfSize:12];
                desc.textColor = [UIColor colorWithHexString:@"#c8002c"];
                [Cell addSubview:desc];

                yOffset += 12;
            }
            yOffset = 64;
            UILabel* colorName = [[UILabel alloc] initWithFrame:CGRectMake(shoppingImg.frame.origin.x + shoppingImg.frame.size.width + 16, 64, fTextWidth/*isEditing?160:170*/, 13)];
            colorName.backgroundColor = [UIColor clearColor];
            colorName.lineBreakMode = UILineBreakModeMiddleTruncation;
            colorName.text = [NSString stringWithFormat:@"颜色: %@    尺码: %@", pItem.color, pItem.size];
            colorName.font = [UIFont systemFontOfSize:13];
            colorName.textColor = UIColorFromRGB(0x666666);
            [Cell addSubview:colorName];

            yOffset += 13;
            
            UILabel* priceName = [[UILabel alloc] initWithFrame:CGRectMake(shoppingImg.frame.origin.x + shoppingImg.frame.size.width + 16, 89, fTextWidth, 13)];
            priceName.backgroundColor = [UIColor clearColor];
            priceName.text = [NSString stringWithFormat:@"单价: ￥%.2f", pItem.mkt_price];
            priceName.font = [UIFont systemFontOfSize:13];
            priceName.textColor = UIColorFromRGB(0x666666);
            [Cell addSubview:priceName];

            
//            UILabel* priceValue = [[UILabel alloc] initWithFrame:CGRectMake(150, yOffset-1, 100, 30)];
//            priceValue.backgroundColor = [UIColor clearColor];
//            priceValue.text = [NSString stringWithFormat:@"￥%.2f", pItem.price];
//            priceValue.font = [UIFont systemFontOfSize:14];
//            priceValue.textColor = UIColorFromRGB(0xc8002c);
//            [Cell addSubview:priceValue];

//            [Cell bringSubviewToFront:icon];
            [array addObject:Cell];
            xOffset = 28 + lee1fitAllScreen(28);
            
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(xOffset, 0, ScreenWidth - xOffset, lee1fitAllScreen(116))];
            [btn setTag:k + j * 10000];
            [btn addTarget:self action:@selector(suitProductAction:) forControlEvents:UIControlEventTouchUpInside];
            [Cell addSubview:btn];
        }
        
        [self.suitlistcell addObject:array];
    }
}

#pragma mark 创建礼包列表
-(void)createPackagelistcells
{
    [self.packagelistcell removeAllObjects];
    packageCount = [self.carModel.packagelist count];
    
    for (int j=0; j<[self.carModel.packagelist count]; j++) {
        YKSuitListItem* item = [self.carModel.packagelist objectAtIndex:j isArray:nil];
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1];
        
        
        static NSString	*CellSuitlist3 = @"Cell4";
        UITableViewCell *viewSuitlistCell3 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellSuitlist3];
        viewSuitlistCell3.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        UIImageView *buttom = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 60)];
//        
//        [buttom setImage:[[UIImage imageNamed:@"list_bg_03.png"] resizableImageWithCap:UIEdgeInsetsMake(5, 5, 0, 0)]];
//        [viewSuitlistCell3 addSubview:buttom];
        
        UIFont *font = [UIFont systemFontOfSize:13];
        CGFloat xOffset = 28 + lee1fitAllScreen(28);
        CGFloat yOffset = 16;
//        int height = (70-yOffset-10)/2;
        
        
        if (item.is_valid) {
            UIButton* btnCheckBox = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnCheckBox setFrame:CGRectMake(6, 16, lee1fitAllScreen(22) + 16, lee1fitAllScreen(22) + 16)];
            [btnCheckBox setImageEdgeInsets:UIEdgeInsetsMake(-8, -8, -8, -8)];
            [btnCheckBox setImage:[UIImage imageNamed:@"choice_unchecked"] forState:UIControlStateNormal];
            [btnCheckBox setImage:[UIImage imageNamed:@"choice_checked"] forState:UIControlStateSelected];
            btnCheckBox.selected = item.selected;
            [btnCheckBox addTarget:self action:@selector(packageCheckBoxAction:) forControlEvents:UIControlEventTouchUpInside];
            [viewSuitlistCell3 addSubview:btnCheckBox];
        }else
        {
            UIImageView* ivLogo = [[UIImageView alloc] initWithFrame:CGRectMake((50 - 35) / 2, 10, 35, 20)];
            [ivLogo setImage:[UIImage imageNamed:@"sign_bg_invalid_t"]];
            [viewSuitlistCell3 addSubview:ivLogo];
        }
        
        UILabel* pName = [[UILabel alloc] init];
        pName.backgroundColor = [UIColor clearColor];
        pName.lineBreakMode = UILineBreakModeTailTruncation;
        pName.text = item.name;
        pName.font = [UIFont systemFontOfSize:14];
        pName.textColor = [UIColor blackColor];//UIColorFromRGB(0x666666);
        NSMutableParagraphStyle* mps = [[NSMutableParagraphStyle alloc] init];
        [mps setLineBreakMode:pName.lineBreakMode];
        CGRect rcName = [pName.text boundingRectWithSize:CGSizeMake((lee1fitAllScreen(204) - xOffset), MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : pName.font, NSParagraphStyleAttributeName : mps} context:nil];
        [pName setFrame:CGRectMake(xOffset, yOffset - (rcName.size.height > pName.font.pointSize ? rcName.size.height - pName.font.pointSize : 0), (lee1fitAllScreen(204) - xOffset), rcName.size.height)];
        [viewSuitlistCell3 addSubview:pName];
        
        NSString *str = @"礼包价: ";
        CGFloat strWidth = [str sizeWithFont:font].width;
        UILabel* price = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset + 20, strWidth, rcName.size.height)];
        price.backgroundColor = [UIColor clearColor];
        price.text = str;
        price.font = [UIFont systemFontOfSize:14];
        price.textColor = UIColorFromRGB(0x181818);/*UIColorFromRGB(0x666666)*/
        [viewSuitlistCell3 addSubview:price];
        xOffset += strWidth;
        
        UILabel* desc = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, price.frame.origin.y, 90, rcName.size.height)];
        desc.backgroundColor = [UIColor clearColor];
        desc.text = [NSString stringWithFormat:@"￥%.2f", item.disountprice];
        desc.font = [UIFont systemFontOfSize:14];
        desc.textColor = UIColorFromRGB(0xc8002c);
        [viewSuitlistCell3 addSubview:desc];
        xOffset = lee1fitAllScreen(204);
        
        UILabel* save = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, price.frame.origin.y, 110, rcName.size.height)];
        save.backgroundColor = [UIColor clearColor];
        save.lineBreakMode = UILineBreakModeMiddleTruncation;
        save.text = [NSString stringWithFormat:@"优惠: ￥%.2f", item.save];
        save.font = [UIFont systemFontOfSize:14];
        save.textColor = UIColorFromRGB(0x666666);//UIColorFromRGB(0x666666);
        [viewSuitlistCell3 addSubview:save];
        
        NSDictionary* style1 = @{@"body":[UIFont fontWithName:@"HelveticaNeue" size:14],
                                 @"bold":[UIFont fontWithName:@"HelveticaNeue-Bold" size:14],
                                 @"red": [UIColor colorWithHexString:@"666666"]};

        UILabel* number = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, pName.frame.origin.y, ScreenWidth - xOffset - 12, rcName.size.height)];
        number.backgroundColor = [UIColor clearColor];
        number.lineBreakMode = UILineBreakModeMiddleTruncation;
        number.attributedText = [[NSString stringWithFormat:@"<red>数量：</red>%d", item.number] attributedStringWithStyleBook:style1];

//        number.attributedText = [[NSString stringWithFormat:@"数量：<black>%d</black>",1]attributedStringWithStyleBook:style1];//[NSString stringWithFormat:@"数量: %d", 1];
        number.font = [UIFont systemFontOfSize:14];
//        number.textColor = UIColorFromRGB(0x181818);
        [viewSuitlistCell3 addSubview:number];
        
        [array addObject:viewSuitlistCell3];
        
        xOffset = 28 + lee1fitAllScreen(28);
        for (int k = 0; k<[item.suits count]; k++) {
            static NSString	*CellIdentifier2 = @"Cell5";
            UITableViewCell *Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:CellIdentifier2];
            Cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel* lblSep = [[UILabel alloc] initWithFrame:CGRectMake(28 + lee1fitAllScreen(28), 0, ScreenWidth - 28 - lee1fitAllScreen(28) - 12, 1)];
            [lblSep setBackgroundColor:[UIColor colorWithHexString:@"#d0d0d0"]];
            [Cell addSubview:lblSep];
            
            YKProductsItem *pItem = [item.suits objectAtIndex:k isArray:nil];
            BOOL showStock = NO;
            if (pItem.stock && ![pItem.stock isKindOfClass:[NSNull class]] && ![pItem.stock isEqualToString:@""]) {
                showStock = YES;
            }
            
//            UIImageView* bgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart_pic_bg.png"]];
//            bgview.frame = CGRectMake(14, 10, 93, 113);
//            [Cell addSubview:bgview];
            
            UrlImageView* shoppingImg = [[UrlImageView alloc] init];
            [shoppingImg setImageWithURL:[NSURL URLWithString:pItem.pic] placeholderImage:nil];
            shoppingImg.frame = CGRectMake(xOffset, 12, lee1fitAllScreen(70), lee1fitAllScreen(90));
            [Cell addSubview:shoppingImg];
            
            CGFloat fTextWidth = ScreenWidth - shoppingImg.frame.size.width - xOffset - 12 - 16;
            
            int yOffset = 6;
            if (!showStock) {
                yOffset += 8;
            }
            
            CGFloat nameHeight = showStock ? 40 : 45;
            UILabel* shoppingName = [[UILabel alloc] initWithFrame:CGRectMake(shoppingImg.frame.origin.x + shoppingImg.frame.size.width + 16, yOffset, fTextWidth/*isEditing ? 160 : 190*/, nameHeight)];
            shoppingName.backgroundColor = [UIColor clearColor];
            shoppingName.numberOfLines = 0;
            shoppingName.lineBreakMode = UILineBreakModeWordWrap;
            shoppingName.text = pItem.name;
            shoppingName.font = [UIFont systemFontOfSize:13];
            shoppingName.textColor = [UIColor colorWithHexString:@"#181818"];
            [Cell addSubview:shoppingName];
            
            yOffset += nameHeight;
            
            if (showStock) {
                UILabel* desc = [[UILabel alloc] initWithFrame:CGRectMake(shoppingImg.frame.origin.x + shoppingImg.frame.size.width + 16, yOffset, fTextWidth, 12)];
                desc.backgroundColor = [UIColor clearColor];
                desc.text = pItem.stock;
                desc.font = [UIFont systemFontOfSize:12];
                desc.textColor = [UIColor colorWithHexString:@"#c8002c"];
                [Cell addSubview:desc];
                
                yOffset += 12;
            }
            yOffset = 64;
            UILabel* colorName = [[UILabel alloc] initWithFrame:CGRectMake(shoppingImg.frame.origin.x + shoppingImg.frame.size.width + 16, 64, fTextWidth/*isEditing?160:170*/, 13)];
            colorName.backgroundColor = [UIColor clearColor];
            colorName.lineBreakMode = UILineBreakModeMiddleTruncation;
            colorName.text = [NSString stringWithFormat:@"颜色: %@    尺码: %@", pItem.color, pItem.size];
            colorName.font = [UIFont systemFontOfSize:13];
            colorName.textColor = UIColorFromRGB(0x666666);
            [Cell addSubview:colorName];
            
            yOffset += 13;
            
            UILabel* priceName = [[UILabel alloc] initWithFrame:CGRectMake(shoppingImg.frame.origin.x + shoppingImg.frame.size.width + 16, 89, fTextWidth, 13)];
            priceName.backgroundColor = [UIColor clearColor];
            priceName.text = [NSString stringWithFormat:@"单价: ￥%.2f", pItem.mkt_price];
            priceName.font = [UIFont systemFontOfSize:13];
            priceName.textColor = UIColorFromRGB(0x666666);
            [Cell addSubview:priceName];
            
            
//            UILabel* priceValue = [[UILabel alloc] initWithFrame:CGRectMake(150, yOffset-1, 100, 30)];
//            priceValue.backgroundColor = [UIColor clearColor];
//            priceValue.text = [NSString stringWithFormat:@"￥%.2f", pItem.price];
//            priceValue.font = [UIFont systemFontOfSize:14];
//            priceValue.textColor = UIColorFromRGB(0xB90023);
//            [Cell addSubview:priceValue];
            
//            [Cell bringSubviewToFront:icon];
            [array addObject:Cell];
            
            xOffset = 28 + lee1fitAllScreen(28);
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(xOffset, 0, ScreenWidth - xOffset, lee1fitAllScreen(116))];
            [btn setTag:k + j * 10000];
            [btn addTarget:self action:@selector(packageProductAction:) forControlEvents:UIControlEventTouchUpInside];
            [Cell addSubview:btn];
        }
        [self.packagelistcell addObject:array];
    }
}

#pragma mark--- CheckBoxAction 全选

-(void)checkBoxAction:(UIButton*)sender
{
    if(_btnCheckBox)
    {
        if (_btnCheckBox.selected) {
            
            //全部取消选中
            if (isEditing) {
                //正在编辑
            }else{
                //编辑完成
            }
            
            [mainSer PartChangeItemWithUk:@"" andType:@"no"];
            [SBPublicAlert showMBProgressHUD:@"正在请求" andWhereView:self.view states:NO];
        }else
        {
            //全部选中
            
            NSMutableArray* marrUks = [[NSMutableArray alloc] initWithCapacity:1];
            for (YKItem* item in _carModel.carProductlist) {
                if(!item.is_valid)
                {
                    continue;
                }
                if(item.selected)
                {
                    continue;
                }
                [marrUks addObject:item.uk];
            }
            for (YKSuitListItem* item in _carModel.suitlist) {
                if(!item.is_valid)
                {
                    continue;
                }
                if(item.selected)
                {
                    continue;
                }
                [marrUks addObject:item.uk];
            }
            for (YKSuitListItem* item in _carModel.packagelist) {
                if(!item.is_valid)
                {
                    continue;
                }
                if(item.selected)
                {
                    continue;
                }
                [marrUks addObject:item.uk];
            }

            if (marrUks && marrUks.count) {
                [mainSer PartChangeItemWithUk:[marrUks componentsJoinedByString:@"|"] andType:@"part"];
                [SBPublicAlert showMBProgressHUD:@"正在请求" andWhereView:self.view states:NO];
            }
        }
    }
}

#pragma mark--- 勾选  礼包
-(void)packageCheckBoxAction:(UIButton*)sender
{
    UITableViewCell* cell = nil;
    if(IOS8_OR_LATER)
    {
        cell = (UITableViewCell*)sender.superview;
    }
    else
    {
        cell = (UITableViewCell*)sender.superview.superview;
    }
    if (cell) {
        NSInteger index = [shoppingCarTab indexPathForCell:cell].section;
        YKSuitListItem* item = [_carModel.packagelist objectAtIndex:index - suitCount isArray:nil];
        [mainSer PartChangeItemWithUk:item.uk andType:@"part"];
        [SBPublicAlert showMBProgressHUD:@"正在请求" andWhereView:self.view states:NO];
    }
}

#pragma mark--- 勾选  套装
-(void)suitCheckBoxAction:(UIButton*)sender
{
    UITableViewCell* cell = nil;
    if(IOS8_OR_LATER)
    {
        cell = (UITableViewCell*)sender.superview;
    }
    else
    {
        cell = (UITableViewCell*)sender.superview.superview;
    }
    if (cell) {
        NSInteger index = [shoppingCarTab indexPathForCell:cell].section;
        YKSuitListItem* item = [_carModel.suitlist objectAtIndex:index isArray:nil];
        [mainSer PartChangeItemWithUk:item.uk andType:@"part"];
        [SBPublicAlert showMBProgressHUD:@"正在请求" andWhereView:self.view states:NO];
    }
}


#pragma mark---勾选 单品 购物车
-(void)productCheckBoxAction:(UIButton*)sender
{
    UITableViewCell* cell = nil;
    if(IOS8_OR_LATER)
    {
        cell = (UITableViewCell*)sender.superview;
    }
    else
    {
        cell = (UITableViewCell*)sender.superview.superview;
    }
    if (cell) {
        NSInteger index = [shoppingCarTab indexPathForCell:cell].section-suitCount-packageCount;
        YKSuitListItem* item = [_carModel.carProductlist objectAtIndex:index isArray:nil];
        [mainSer PartChangeItemWithUk:item.uk andType:@"part"];
        [SBPublicAlert showMBProgressHUD:@"正在请求" andWhereView:self.view states:NO];
    }
}

#pragma mark--- 表相关
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    //lee999recode
//	if ([self.carModel.suitlist count]>0 && [self.carModel.gifts count]>0)
//        return 3+suitCount;
    //end
    
	if ([self.carModel.suitlist count] > 0 || [self.carModel.gifts count] > 0 || [self.carModel.packagelist count] > 0){
        NSInteger count = 1;
		if ([self.carModel.gifts count] > 0) {
			isaddfav = YES;
		}else {
			isaddfav = NO;
		}
//        if ([self.carModel.packagelist count] > 0) {
//            count += [self.carModel.packagelist count];
//        }
		return count + suitCount + packageCount + productCount;
	}
	return productCount + suitCount + packageCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //先显示套装的分区，每个套装可能有不同的商品件数
    if (section < suitCount) {
        return [(NSMutableArray*)[self.suitlistcell objectAtIndex:section isArray:nil] count];
    }
    else if (section - suitCount < packageCount) {
        return [(NSMutableArray*)[self.packagelistcell objectAtIndex:section - suitCount isArray:nil] count];
    }
    //返回正常的商品
    else if (section - suitCount - packageCount < productCount) {
        return 1;
    }
    //判断是否显示赠品按钮
    else if (section - suitCount - packageCount - productCount == 0) {
        if (isaddfav) {
            return 2;
        }else {
            return 0;
        }
    }
    //显示最后的总价区域
    else if (section - suitCount - packageCount - productCount == 1) {
        return 2;
    }
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section < suitCount) {
        //lee999  这个地方是套装的cell
        if (indexPath.row == 0) {
            return 66;
        }
        return lee1fitAllScreen(116);
    }
    else if (indexPath.section - suitCount < packageCount) {
        //lee999  这个地方是礼包的cell
        if (indexPath.row == 0) {
            return 66;
        }
        return lee1fitAllScreen(116);
    }
	else if (indexPath.section - suitCount - packageCount < productCount) {
        // 这个是普通商品的cell
        return lee1fitAllScreen(146);// - lee1fitAllScreen(10);
	} else if (indexPath.section - suitCount - packageCount - productCount == 0) {
		if (isaddfav) {
            //lee新增标题标题的cell  防止标题跟着滚动
            if ([indexPath row] == 0) {
                return lee1fitAllScreen(46);
            }
			return lee1fitAllScreen(56);
		}
		return lee1fitAllScreen(155);
	}
    else if (indexPath.section - suitCount - packageCount - productCount == 1) {
        //lee新增标题标题的cell  防止标题跟着滚动
        if ([indexPath row] == 0) {
            return lee1fitAllScreen(35);
        }
		return lee1fitAllScreen(60);
	}
	return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //显示优惠套装
    if (section < suitCount) {
        return lee1fitAllScreen(10);
    }
    else if (section - suitCount < packageCount) {
        return lee1fitAllScreen(10);
    }
    else if (section - suitCount - packageCount < productCount)
    {
        return lee1fitAllScreen(10);
    }
    else
    {
        return 0.1;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section - suitCount - packageCount - productCount < 0) {
        UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.height, lee1fitAllScreen(10))];
        [v setBackgroundColor:[UIColor colorWithHexString:@"#e0e0e0"]];
        return v;
    }
    else
    {
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //显示优惠套装
	if (indexPath.section < suitCount) {
		return [[self.suitlistcell objectAtIndex:indexPath.section isArray:nil] objectAtIndex:indexPath.row isArray:nil];
	}
    else if (indexPath.section - suitCount < packageCount) {
        return [[self.packagelistcell objectAtIndex:indexPath.section - suitCount isArray:nil] objectAtIndex:indexPath.row isArray:nil];
    }
    //显示普通商品
    else if (indexPath.section - suitCount - packageCount < productCount) {
        return [self.tableCells objectAtIndex:indexPath.section - suitCount - packageCount isArray:nil];
	}
    
    //显示  是否选择赠品的界面
    else if (indexPath.section - suitCount - packageCount - productCount == 0) {
		if (isaddfav) {
			static NSString	*CellIdentifier = @"Cell1";
			UITableViewCell *Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:CellIdentifier];
			Cell.selectionStyle = UITableViewCellSelectionStyleNone;
			self.addfavButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([indexPath row] == 0) {
//                UIImageView* segbg = [[UIImageView alloc] init];//WithImage:[UIImage imageNamed:@"banner_dot_bg.png"]];
//                segbg.frame = CGRectMake(0, 3, ScreenWidth, lee1fitAllScreen(30));
                UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, lee1fitAllScreen(12))];
                name.textColor = [UIColor blackColor];
                name.backgroundColor = [UIColor clearColor];
                [name setTextAlignment:NSTextAlignmentCenter];
                name.font = [UIFont systemFontOfSize:12];
                name.text = @"(商品如不加入购物车内将视为放弃领取活动赠品)";
//                [segbg addSubview:name];
//                [segbg setBackgroundColor:[UIColor whiteColor]];
                
                [Cell addSubview:name];
            }else{
                if (isEditing) {
                    [self.addfavButton setBackgroundImage:[UIImage imageNamed:@"btn_mid_b_hover"] forState:UIControlStateNormal];
                    self.addfavButton.enabled = NO;
                }else {
                    [self.addfavButton setBackgroundImage:[UIImage imageNamed:@"btn_mid_b_normal"] forState:UIControlStateNormal];
                    self.addfavButton.enabled = YES;
                }
                UIImageView *addfavIcon = [[UIImageView alloc] initWithFrame:CGRectMake(40, (lee1fitAllScreen(36) - lee1fitAllScreen(25)) / 2, lee1fitAllScreen(20), lee1fitAllScreen(25))];
                [addfavIcon setImage:[UIImage imageNamed:@"gift_icon.png"]];
                [self.addfavButton addSubview:addfavIcon];
                
                [self.addfavButton setBackgroundImage:[UIImage imageNamed:@"btn_mid_b_hover"] forState:UIControlStateHighlighted];
                [self.addfavButton setFrame:CGRectMake((ScreenWidth - lee1fitAllScreen(170)) / 2, 0, lee1fitAllScreen(170), lee1fitAllScreen(36))];
                [self.addfavButton setTitle:@"选择赠品" forState:UIControlStateNormal];
                [self.addfavButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
                [self.addfavButton addTarget:self action:@selector(addfavAction) forControlEvents:UIControlEventTouchUpInside];
                [self.addfavButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
                [self.addfavButton.titleLabel setTextColor:[UIColor whiteColor]];
                [Cell addSubview:self.addfavButton];
                
                UIImageView* lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"devider_02.png"]];
                lineView.frame = CGRectMake(0, 54, ScreenWidth, 2);
                [Cell addSubview:lineView];
            }
            
			return Cell;
		}else {
            if (self.favCells.count > 0) {
           		return [self.favCells objectAtIndex:indexPath.row isArray:nil];
            }
		}
	}
    else if (indexPath.section - suitCount - packageCount - productCount == 1) {
		static NSString	*CellIdentifier = @"Cell1";
		UITableViewCell *Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:CellIdentifier];
		Cell.selectionStyle = UITableViewCellSelectionStyleNone;
		self.addfavButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if ([indexPath row] == 0) {
            UIImageView* segbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner_dot_bg.png"]];
            segbg.frame = CGRectMake(0, 3, ScreenWidth, lee1fitAllScreen(30));
            UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, ScreenWidth, lee1fitAllScreen(20))];
            name.textColor = [UIColor blackColor];
            name.backgroundColor = [UIColor clearColor];
            name.font = [UIFont systemFontOfSize:13];
            name.text = @"（商品如不加入购物车内将视为放弃领取活动赠品）";
            [segbg addSubview:name];
            [segbg setBackgroundColor:[UIColor whiteColor]];
            
            [Cell addSubview:segbg];
        }else{
        
		if (isEditing) {
			[self.addfavButton setBackgroundImage:[UIImage imageNamed:@"button_red_press.png"] forState:UIControlStateNormal];
			self.addfavButton.enabled = NO;
		}else {
			[self.addfavButton setBackgroundImage:[UIImage imageNamed:@"button_red.png"] forState:UIControlStateNormal];
			self.addfavButton.enabled = YES;
		}
        
        UIImageView *addfavIcon = [[UIImageView alloc] initWithFrame:CGRectMake(40, 2, 20, 25)];
        [addfavIcon setImage:[UIImage imageNamed:@"gift_icon.png"]];
        [self.addfavButton addSubview:addfavIcon];

        
		[self.addfavButton setBackgroundImage:[UIImage imageNamed:@"button_red_press.png"] forState:UIControlStateHighlighted];
        [self.addfavButton setFrame:CGRectMake(80, 10, 160, 35)];
		[self.addfavButton setTitle:@"选择赠品" forState:UIControlStateNormal];
        [self.addfavButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        
		[self.addfavButton addTarget:self action:@selector(addfavAction) forControlEvents:UIControlEventTouchUpInside];
		[self.addfavButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13]];
		[self.addfavButton.titleLabel setTextColor:[UIColor whiteColor]];
		[Cell addSubview:self.addfavButton];
            
		UIImageView* lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_devider.png"]];
		lineView.frame = CGRectMake(0, 49, ScreenWidth, lee1fitAllScreen(2));
		[Cell addSubview:lineView];
            
        }
        
		return Cell;
	}
	return nil;
}

//lee999 是否可以编辑，这个地方也需要修改~~~~  选择赠品的提示，原来是区头，改到cell之后，这个界面也不能进行编辑了
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath section] < suitCount) {
        //lee999 套装的最后一行，也能del
        if (indexPath.row == 0) {
            return YES;
        }
        return NO;
    }
    else if ([indexPath section] - suitCount < packageCount) {
        //lee999 套装的最后一行，也能del
        if (indexPath.row == 0) {
            return YES;
        }
        return NO;
    }
    else if ([indexPath section] - suitCount - packageCount < productCount)
    {
        return YES;
    }
    else if ([indexPath section] - suitCount - packageCount - productCount == 0) {
		if (isaddfav) {
			return NO;
		}
        return YES;
    }
    else if (indexPath.section - suitCount - packageCount - productCount == 1){
        return NO;
    }
    else{
        return YES;
    }
}


#pragma mark---- 商品详情 点击进入
-(void)simpleProductAction:(UITapGestureRecognizer*)gesture
{
    CGPoint pTouchInView = [gesture locationInView:gesture.view.superview];
    if (isEditing) {
        UITextField* tf = nil;
        for (id v in gesture.view.superview.subviews) {
            if ([v class] == [UITextField class]) {
                tf = v;
                break;
            }
        }
        if (tf) {
            if (CGRectContainsPoint(tf.frame, pTouchInView)) {
                [tf becomeFirstResponder];
                return;
            }
        }
    }
    
    UIButton* btn = nil;
    for (id v in gesture.view.superview.subviews) {
        if ([v class] == [UIButton class]) {
            btn = v;
            if ([[btn titleForState:UIControlStateNormal] isEqualToString:@"加入收藏"] || [[btn titleForState:UIControlStateNormal] isEqualToString:@"已收藏"]) {
                break;
            }else
            {
                btn = nil;
            }
        }
    }
    if (btn) {
        if (CGRectContainsPoint(btn.frame, pTouchInView)) {
            [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
            return;
        }
    }
    
    YKItem* item = (YKItem*)[self.carModel.carProductlist objectAtIndex:gesture.view.tag isArray:nil];
    
    if ([item.type isEqualToString:@"gift"]) {
        return;
    }
    
    //lee999 150708 新增编辑状态不能进入商品详情
    if (btnCheckOut.selected) {
        return;
    }
    //end
    
    ProductDetailViewController* detail = [[ProductDetailViewController alloc] init];
    detail.thisProductId = item.goodsid;
    detail.isShop = YES;
    
    detail.isPush = YES;
    [self.navigationController pushViewController:detail animated:YES];

}
#pragma mark---- 套装 点击进入
-(void)suitProductAction:(UIButton*)sender
{
//    if ([indexPath section] < 0 || [indexPath section] >= [self.carModel.suitlist count]) {
//        return ;
//    }
    NSInteger row = sender.tag % 10000;
    NSInteger section = (sender.tag - row) / 10000;
    YKSuitListItem *item = [self.carModel.suitlist objectAtIndex:section isArray:nil];
//    if (indexPath.row == 0) {
//        return ;
//    }
    
    //lee999 150708 新增编辑状态不能进入商品详情
    if (btnCheckOut.selected) {
        return;
    }
    //end
    
    YKProductsItem *pItem = [item.suits objectAtIndex:row isArray:nil];
    ProductDetailViewController *controller = [[ProductDetailViewController alloc] init];
    controller.isPush = YES;
    controller.isShop = YES;
    controller.thisProductId = pItem.product_id;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark---- 礼包 点击进入
-(void)packageProductAction:(UIButton*)sender
{
//    if ([indexPath section] < 0 || ([indexPath section] - suitCount) >= [self.carModel.packagelist count]) {
//        return ;
//    }
    NSInteger row = sender.tag % 10000;
    NSInteger section = (sender.tag - row) / 10000;
    YKSuitListItem *item = [self.carModel.packagelist objectAtIndex:section isArray:nil];
//    if (indexPath.row == 0) {
//        return ;
//    }
    
    //lee999 150708 新增编辑状态不能进入商品详情
    if (btnCheckOut.selected) {
        return;
    }
    //end
    
    YKProductsItem *pItem = [item.suits objectAtIndex:row isArray:nil];
    ProductDetailViewController *controller = [[ProductDetailViewController alloc] init];
    controller.isPush = YES;
    controller.isShop = YES;
    controller.thisProductId = pItem.product_id;
    [self.navigationController pushViewController:controller animated:YES];

}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    //套装进入商品详情
//    if (indexPath.section < suitCount) {
//        if ([indexPath section] < 0 || [indexPath section] >= [self.carModel.suitlist count]) {
//            return ;
//        }
//        YKSuitListItem *item = [self.carModel.suitlist objectAtIndex:[indexPath section]];
//        if (indexPath.row == 0) {
//            return ;
//        }
//        YKProductsItem *pItem = [item.suits objectAtIndex:indexPath.row - 1];
//        ProductDetailViewController *controller = [[ProductDetailViewController alloc] init];
//        controller.isPush = YES;
//        controller.isShop = YES;
//        controller.thisProductId = pItem.product_id;
//        [self.navigationController pushViewController:controller animated:YES];
//    }
//    else if (indexPath.section - suitCount < packageCount) {
//        if ([indexPath section] < 0 || ([indexPath section] - suitCount) >= [self.carModel.packagelist count]) {
//            return ;
//        }
//        YKSuitListItem *item = [self.carModel.packagelist objectAtIndex:[indexPath section] - suitCount];
//        if (indexPath.row == 0) {
//            return ;
//        }
//        YKProductsItem *pItem = [item.suits objectAtIndex:indexPath.row - 1];
//        ProductDetailViewController *controller = [[ProductDetailViewController alloc] init];
//        controller.isPush = YES;
//        controller.isShop = YES;
//        controller.thisProductId = pItem.product_id;
//        [self.navigationController pushViewController:controller animated:YES];
//    }
//    //普通商品进入商品详情
//	else if (indexPath.section - suitCount - packageCount == 0) {
//		YKItem* item = (YKItem*)[self.carModel.carProductlist objectAtIndex:indexPath.row];
//        
//        if ([item.type isEqualToString:@"gift"]) {
//            return;
//        }
//		ProductDetailViewController* detail = [[ProductDetailViewController alloc] init];
//		detail.thisProductId = item.goodsid;
//        detail.isShop = YES;
//        
//        detail.isPush = YES;
//		[self.navigationController pushViewController:detail animated:YES];
//	}
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
