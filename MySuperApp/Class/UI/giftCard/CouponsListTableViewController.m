//
//  CouponsListTableViewController.m
//  爱慕商场呵
//  Created by malan on 14-9-25.
//  Copyright (c) 2014年 zan. All rights re360云盘served.
//

#import "CouponsListTableViewController.h"
#import "BonusCardCell.h"
#import "CFunction.h"
#import "MYMacro.h"
#import "MyButton.h"
#import "BindViewController.h"
#import "BonusCell.h"
#import "ExchangeRecordViewController.h"
#import "CodeBindBindCodeModel.h"
#import "YKCanReuse_webViewController.h"
#import "CouponListInfoParser.h"
#import "CouponDetailViewController.h"
#import "CouponDetail20ViewController.h"
#import "ManageGiftViewController.h"


@interface CouponsListTableViewController (){
    UIButton* selectedBtn;
    UIView* vCouponMenu;
    NSInteger nSelectedIndexInMenu;
    UIImageView* ivSelected;
    
    int selectIndex;
    
    
    UIButton* btnShowCouponMenu; //全部
    UIButton* btnToFreeShippingCard; //包邮卡
    UIButton* btnToGiftCard;   //礼品卡
    
    
}
@property (nonatomic, retain) UIView* vToolbar;
@property (nonatomic, retain) NSString* strType;
@property (nonatomic, retain) CouponListInfo* cli;
@end

@implementation CouponsListTableViewController
@synthesize isAimer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _arrCard = [[NSMutableArray alloc] init];
    _contentArr = [[NSMutableArray alloc] init];
    
    self.title = @"我的优惠";
    
    [self NewHiddenTableBarwithAnimated:YES];
    
    [self createBackBtnWithType:0];
    mainSer  = [[MainpageServ alloc] init];
    mainSer.delegate = self;
    self.strType = @"c";
    
    //V6 卡
    if (self.clType == EV6Card) {
        self.strType = @"v6card";
        self.title = @"我的会员卡";
    }
    
    selectIndex = 1;
    
    
    [self.view addSubview:self.mytableView];
    
    
    if (self.clType != EV6Card) {
        [self.view addSubview:self.vToolbar];
    }
    [self.view addConstraints:[self viewConstraints]];

    
    
    UIImageView* ivBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yhq_laber_bg"]];
    [ivBG setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, lee1fitAllScreen(35))];
    [_vToolbar addSubview:ivBG];
    
    btnShowCouponMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat btnWidth = ([UIScreen mainScreen].bounds.size.width - 4) / 3;
    [btnShowCouponMenu setFrame:CGRectMake(0, 0, btnWidth, lee1fitAllScreen(35))];
    [btnShowCouponMenu addTarget:self action:@selector(showCouponMenu:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowCouponMenu setTitle:@"优惠券" forState:UIControlStateNormal];
    [btnShowCouponMenu setTitle:@"优惠券" forState:UIControlStateSelected];
    [btnShowCouponMenu setTitleColor:[UIColor colorWithHexString:@"#6c6c6c"] forState:UIControlStateNormal];
    [btnShowCouponMenu setTitleColor:[UIColor colorWithHexString:@"#181818"] forState:UIControlStateSelected];
    [btnShowCouponMenu setSelected:YES];
    [btnShowCouponMenu setExclusiveTouch:NO];
    [_vToolbar addSubview:btnShowCouponMenu];
    btnShowCouponMenu.tag = 1;
    
    [btnShowCouponMenu setImage:[UIImage imageNamed:@"yhq_arrow_d.png"] forState:UIControlStateNormal];
    [btnShowCouponMenu setImage:[UIImage imageNamed:@"yhq_arrow_d.png"] forState:UIControlStateSelected];
    [btnShowCouponMenu setImageEdgeInsets:UIEdgeInsetsMake(15, btnWidth-17, 7, 7)];
    
    ivSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, btnShowCouponMenu.frame.size.height - 1, btnShowCouponMenu.frame.size.width, 1)];
    [ivSelected setBackgroundColor:[UIColor colorWithHexString:@"#c8002c"]];
    [btnShowCouponMenu addSubview:ivSelected];
    
    selectedBtn = btnShowCouponMenu;
    nSelectedIndexInMenu = 10001;
    
    btnToFreeShippingCard = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnToFreeShippingCard setFrame:CGRectMake(btnShowCouponMenu.frame.size.width + btnShowCouponMenu.frame.origin.x + 2, 0, btnWidth, lee1fitAllScreen(35))];
    [btnToFreeShippingCard addTarget:self action:@selector(toFreeShippingCard:) forControlEvents:UIControlEventTouchUpInside];
    [btnToFreeShippingCard setTitle:@"包邮卡" forState:UIControlStateNormal];
    [btnToFreeShippingCard setTitle:@"包邮卡" forState:UIControlStateSelected];
    [btnToFreeShippingCard setTitleColor:[UIColor colorWithHexString:@"#6c6c6c"] forState:UIControlStateNormal];
    [btnToFreeShippingCard setTitleColor:[UIColor colorWithHexString:@"#181818"] forState:UIControlStateSelected];
    btnToFreeShippingCard.tag = 2;
    [btnToFreeShippingCard setExclusiveTouch:NO];
    [_vToolbar addSubview:btnToFreeShippingCard];
    
    btnToGiftCard = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnToGiftCard setFrame:CGRectMake(btnToFreeShippingCard.frame.size.width + btnToFreeShippingCard.frame.origin.x + 2, 0, btnWidth, lee1fitAllScreen(35))];
    [btnToGiftCard addTarget:self action:@selector(toGiftCard:) forControlEvents:UIControlEventTouchUpInside];
    [btnToGiftCard setTitle:@"礼品卡" forState:UIControlStateNormal];
    [btnToGiftCard setTitle:@"礼品卡" forState:UIControlStateSelected];
    [btnToGiftCard setTitleColor:[UIColor colorWithHexString:@"#6c6c6c"] forState:UIControlStateNormal];
    [btnToGiftCard setTitleColor:[UIColor colorWithHexString:@"#181818"] forState:UIControlStateSelected];
    btnToGiftCard.tag = 3;
    [btnToGiftCard setExclusiveTouch:NO];
    [_vToolbar addSubview:btnToGiftCard];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initRequest];
}

-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:YES];
}


- (void)initRequest
{
    [self getData];
    [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];
}




- (void)popBackAnimate:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightButAction{
    BindViewController *ctrl = [[BindViewController alloc] initWithNibName:@"BindViewController" bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
}


- (void)Sendcodes
{
    NSRange numRange = NSMakeRange(self.phoneNum.length-12, 11);;
    //发送验证码
    [mainSer getProveMobile:[self.phoneNum substringWithRange:numRange] andType:@"v6card"];
}

-(void)action:(UIButton*)sender
{
    if ([_strType isEqualToString:@"g"]) {
        ManageGiftViewController* mgvc = [[ManageGiftViewController alloc] init];
        [mgvc setCouponInfo:[_cli.coupons objectAtIndex:sender.tag isArray:nil]];
        [self.navigationController pushViewController:mgvc animated:YES];
        
    }else
    {
        [self changetableBarto:0];
    }
}

//单元格上按钮的点击事件
- (void)btnClicked:(UIButton *) btn onCell:(UITableViewCell *)cell
{
    NSInteger index = [[_mytableView indexPathForCell:cell] row];
    switch (btn.tag) {
        case 1:
        {
            YKCanReuse_webViewController *webView = [[YKCanReuse_webViewController alloc] init];
            webView.strURL = @"http://m.aimer.com.cn/method/v6codeinfo";
            webView.strTitle = @"使用规则";
            [self.navigationController pushViewController:webView animated:YES];
        }
            break;
        case 2:
        {
            //POBJECT(@"使用  会员卡");
            [self changetableBarto:0];
        }
            break;
        case 3:
        {
            //POBJECT(@"兑换")
            UIAlertView *arert = [[UIAlertView alloc] initWithTitle:@"爱慕提示" message:@"是否确认兑换？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            arert.tag = 137;
            [arert show];
        }
            break;
        case 4:
        {
            //POBJECT(@"积分说明");
            YKCanReuse_webViewController *webView = [[YKCanReuse_webViewController alloc] init];
            webView.strURL = @"http://m.aimer.com.cn/method/v6codedescribe";
            webView.strTitle = @"积分说明";
            [self.navigationController pushViewController:webView animated:YES];
        }
            break;
        case 5:
        {
            //POBJECT(@"自助兑换记录");
            ExchangeRecordViewController *ctrl = [[ExchangeRecordViewController alloc] init];
            
            V6CardInfo *v6info = [self.arrCard objectAtIndex:0 isArray:nil];
            ctrl.cardId = v6info.card_id;
            [self.navigationController pushViewController:ctrl animated:YES];
        }
            break;
        case 6:
        {
            //POBJECT(@"优惠券详情");
            NSLog(@"----%@",[self.contentArr objectAtIndex:index isArray:nil]);
            
            if (isAimer) {
                //CouponDetailViewController *userCtrl = [[CouponDetailViewController alloc] initWithNibName:@"CouponDetailViewController" bundle:nil];
                //是不是我自己的优惠券，（自己的能显示二维码，不是自己的没有二维码）
                //userCtrl.isMycard = YES;
                //userCtrl.couponDic =[self.contentArr objectAtIndex:index isArray:nil];
                //[self.navigationController pushViewController:userCtrl animated:YES];
            }
        }
            break;
        case 7:
        {
            //POBJECT(@"使用优惠券");   cell上的点击使用---------
            if([self.title isEqualToString:@"积分优惠"])
            {//积分优惠界面，使用按钮不可用
                
                //lee987 增加兑换礼品卡
                NSDictionary *dic = [self.contentArr objectAtIndex:index isArray:nil];
                NSString* cardType = [[dic objectForKey:@"type" isDictionary:nil] description];
                if ([cardType isEqualToString:@"gift"]) {
                    YKCanReuse_webViewController *webView = [[YKCanReuse_webViewController alloc] init];
                    webView.strURL  = [[dic objectForKey:@"url" isDictionary:nil] description];
                    webView.strTitle = [[dic objectForKey:@"title" isDictionary:nil] description];
                    [self.navigationController pushViewController:webView animated:YES];
                    
                }else{
                //lee999切换到我的爱慕，直接显示到首页
                [self changeToShop];
                [self.navigationController popToRootViewControllerAnimated:YES];
                    
                }
            } else {
                NSDictionary *dic = [self.contentArr objectAtIndex:index isArray:nil];
                self.checkOutViewCtrl.useCouponcardId = LegalObject([dic objectForKey:@"code"],[NSString class]);
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if ([self.strType isEqualToString:@"v6card"]) {
        return 1;
    }
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSLog(@"-----%lu",(unsigned long)self.arrCard.count);
    
    if (section == 0) {
        if (self.arrCard.count == 0 && [self.strType isEqualToString:@"v6card"]) {
            return 1;
        }
        return [self.arrCard count];
    }else if (section == 1) {
        return 1;
    }else {
        return [self.contentArr count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 270.f;
    }else if(indexPath.section == 1) {
        if (self.isAimer) {
            return lee1fitAllScreen(44) + 75;
        }else {
            return lee1fitAllScreen(44) + 75;
        }
    }else {
        return lee1fitAllScreen(76) + 10;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"----title:%@------",self.title);
    
    //会员卡
    if (indexPath.section == 0) {
        
        
        if ([self.arrCard count] == 0) {
        //没有会员卡
            
            UITableViewCell *Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:nil];
            Cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [Cell setBackgroundColor:[UIColor clearColor]];
            
            
            float oldy = 50;//lblContent.frame.origin.y + lblContent.frame.size.height;

            UIImage *img = [UIImage imageNamed:@"hyk_none.png"];
            UIImageView *imav = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-img.size.width)/2, oldy, img.size.width, img.size.height)];
            [imav setImage:img];
            [Cell addSubview:imav];
            
            oldy += img.size.height/2 +50;
            
            UILabel* lblContent = [[UILabel alloc] initWithFrame:CGRectMake(10, oldy, ScreenWidth - 20, 30)];
            [lblContent setText:@"您暂时还没有会员卡"];
            [lblContent setTextAlignment:NSTextAlignmentCenter];
            [lblContent setFont:[UIFont systemFontOfSize:LabSmallSize]];
            [lblContent setTextColor:[UIColor colorWithHexString:@"#b8b8b8"]];
            [Cell addSubview:lblContent];
            
            oldy+=50;
            
            MyButton *but = [MyButton buttonWithType:UIButtonTypeCustom];
            [but setFrame:CGRectMake(70,oldy, ScreenWidth-140, 40)];
            [but setTitle:@"如何入会" forState:UIControlStateNormal];
            [but setTitle:@"如何入会" forState:UIControlStateHighlighted];
            [but setBackgroundImage:[UIImage imageNamed:@"btn_mid_b_normal.png"] forState:UIControlStateNormal];
            [but setBackgroundImage:[UIImage imageNamed:@"btn_mid_b_hover.png"] forState:UIControlStateHighlighted];
            [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [but setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            but.titleLabel.font = [UIFont systemFontOfSize:17.0];
            [but addTarget:self action:@selector(howToAddClubAction) forControlEvents:UIControlEventTouchUpInside];
            [Cell addSubview:but];
            return Cell;
            
        }else{
            
            static NSString *CellIdentifier = @"BonusCardCellIdentifier";
            BonusCardCell *cell = (BonusCardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"BonusCardCell" owner:self options:nil] lastObject];
                cell.parent = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            V6CardInfo *dic = [self.arrCard objectAtIndex:indexPath.row isArray:nil];
            cell.labelTitle.text = [NSString stringWithFormat:@"%@",dic.name];
            cell.labelId.text = [NSString stringWithFormat:@"NO. %@",dic.card_id];
            cell.labelBalance.text = dic.balance;
            cell.labelFrozenBalance.text = [NSString stringWithFormat:@"%@",dic.frozenBalance];
            cell.labelIntegral.text = [NSString stringWithFormat:@" 冻结%@   可用 %@",[dic.frozenScore description],[dic.canUseScore description]];
            
            if ([dic.canUseScore integerValue] < 2000) {
                [cell.btnExchange setEnabled:NO];
            }
            
            return cell;
        }
        
        
    } else if(indexPath.section == 1) {
        
        UITableViewCell *Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:nil];
        Cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [Cell setBackgroundColor:[UIColor clearColor]];

        nametextfield = [[UITextField alloc] initWithFrame:CGRectMake(15, 15, lee1fitAllScreen(215), lee1fitAllScreen(44))];
        nametextfield.delegate = self;
        nametextfield.backgroundColor = [UIColor whiteColor];
        nametextfield.placeholder = @"请输入您的优惠券号";
        nametextfield.font = [UIFont systemFontOfSize:17];
        nametextfield.keyboardType = UIKeyboardTypeDefault;
        [Cell.contentView addSubview:nametextfield];
        [nametextfield.layer setBorderColor:[UIColor colorWithHexString:@"#d0d0d0"].CGColor];
        [nametextfield.layer setBorderWidth:0.5];
        [nametextfield.layer setCornerRadius:2];
        [nametextfield.layer setMasksToBounds:YES];
        [nametextfield setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, lee1fitAllScreen(17), nametextfield.frame.size.height)]];
        [nametextfield setLeftViewMode:UITextFieldViewModeAlways];
        
        //lee999 150706 进行判断啊！！！
        if ([_strType isEqualToString:@"c"] || [_strType isEqualToString:@"u"]) {
            //优惠券
            nametextfield.placeholder = @"请输入您的优惠券号";
        }else if ([_strType isEqualToString:@"g"]){
            //礼品卡
            nametextfield.placeholder = @"请输入您的礼品卡号";
        }else if ([_strType isEqualToString:@"f"]){
            //包邮卡
            nametextfield.placeholder = @"请输入您的包邮卡号";
        }
        //end
        
        
        
        MyButton *but = [MyButton buttonWithType:UIButtonTypeCustom];
        [but setFrame:CGRectMake(nametextfield.frame.origin.x + nametextfield.frame.size.width + 10, 15, lee1fitAllScreen(65), lee1fitAllScreen(44))];
        [but setTitle:@"绑定" forState:UIControlStateNormal];
        [but setTitle:@"绑定" forState:UIControlStateHighlighted];
        but.titleLabel.font = [UIFont systemFontOfSize:17.0];
        
        //lee999recode
        if ([self.title isEqualToString:@"使用优惠券"]) {
            [but setTitle:@"使用" forState:UIControlStateNormal];
            [but setTitle:@"使用" forState:UIControlStateHighlighted];
    
            [but addTarget:self action:@selector(UserCouns:) forControlEvents:UIControlEventTouchUpInside];

        }else{
            [but addTarget:self action:@selector(btnBindClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [but setBackgroundImage:[UIImage imageNamed:@"yhq_btn_normal"] forState:UIControlStateNormal];
        [but setImage:[UIImage imageNamed:@"yhq_btn_hover"] forState:UIControlStateHighlighted];
        
        [Cell addSubview:but];
        
        UILabel* lblSep = [[UILabel alloc] initWithFrame:CGRectMake(0, but.frame.size.height + but.frame.origin.y + 15, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [lblSep setBackgroundColor:[UIColor colorWithHexString:@"#d0d0d0"]];
        [Cell addSubview:lblSep];
        
        UILabel* lblContent = [[UILabel alloc] initWithFrame:CGRectMake(10, lblSep.frame.size.height + lblSep.frame.origin.y + 15, ScreenWidth - 20, 15)];
        if(_contentArr.count)
        {
            
            //lee999 150706 进行判断啊！！！
            if ([_strType isEqualToString:@"c"] || [_strType isEqualToString:@"u"]) {
                //优惠券
                [lblContent setText:@"点击优惠券可查看使用规则"];
            }else if ([_strType isEqualToString:@"g"]){
                //礼品卡
                [lblContent setText:@"点击礼品卡可查看使用规则"];
            }else if ([_strType isEqualToString:@"f"]){
                //包邮卡
                [lblContent setText:@"点击包邮卡可查看使用规则"];
            }
            //end
            
        }else
        {
            float oldy = lblContent.frame.origin.y + lblContent.frame.size.height;
            oldy += 20;
            
            UIImage *img = [UIImage imageNamed:@"yhq_icon_none.png"];
            UIImageView *imav = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-img.size.width)/2, oldy, img.size.width, img.size.height)];
            [imav setImage:img];
            [Cell addSubview:imav];
            
            oldy = oldy + img.size.height +30;
            
            [lblContent setFrame:CGRectMake(10, oldy, ScreenWidth-20, 15)];
            [lblContent setTextAlignment:NSTextAlignmentCenter];
            
            //lee999 150706 进行判断啊！！！
            if ([_strType isEqualToString:@"c"] || [_strType isEqualToString:@"u"]) {
                //优惠券
                [lblContent setText:@"您暂无优惠券"];
                
            }else if ([_strType isEqualToString:@"g"]){
            //礼品卡
                [lblContent setText:@"您暂无礼品卡"];
                
            }else if ([_strType isEqualToString:@"f"]){
            //包邮卡
                [lblContent setText:@"您暂无包邮卡"];
            }
            
        }
        
        [lblContent setFont:[UIFont systemFontOfSize:LabSmallSize]];
        [lblContent setTextColor:[UIColor colorWithHexString:@"#666666"]];
        [Cell addSubview:lblContent];
        
        return Cell;
    }
    //优惠券
    else if(indexPath.section==2) {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UIImageView* ivBg = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - (lee1fitAllScreen(295))) / 2, 0, lee1fitAllScreen(295), lee1fitAllScreen(76))];
        [cell.contentView addSubview:ivBg];
        
        UILabel* lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(0, (lee1fitAllScreen(76) - 18) / 2, lee1fitAllScreen(72), 18)];
        [lblPrice setTextAlignment:NSTextAlignmentCenter];
        [lblPrice setFont:[UIFont boldSystemFontOfSize:15]];
        [lblPrice setTextColor:[UIColor whiteColor]];
        [ivBg addSubview:lblPrice];
        
        UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(lee1fitAllScreen(72) + 10, 22, lee1fitAllScreen(150), 12)];
        [lblTitle setFont:[UIFont boldSystemFontOfSize:12]];
        [lblTitle setLineBreakMode:NSLineBreakByTruncatingTail];
        [lblTitle setTextColor:[UIColor colorWithHexString:@"#666666"]];
        [ivBg addSubview:lblTitle];
        
        UILabel* lblTime = [[UILabel alloc] initWithFrame:CGRectMake(lee1fitAllScreen(72) + 10, lblTitle.frame.size.height + lblTitle.frame.origin.y + 6, lee1fitAllScreen(150), 12)];
        [lblTime setFont:[UIFont systemFontOfSize:12]];
        [lblTime setLineBreakMode:NSLineBreakByTruncatingTail];
        [lblTime setTextColor:[UIColor colorWithHexString:@"#666666"]];
        [ivBg addSubview:lblTime];
        
        UIImageView* ivState = [[UIImageView alloc] initWithFrame:CGRectMake(ivBg.frame.size.width - (lee1fitAllScreen(63)), 5, 0.5, ivBg.frame.size.height - 10)];
        [ivBg addSubview:ivState];
        
        NSString* strStatus = @"";
        NSString* type = @"";
        NSString* strPrice = @"";
        NSString* strTitle = @"";
        NSString* strTime = @"";
        UIImage* iBg = nil;
        id data = [self.contentArr objectAtIndex:indexPath.row isArray:nil];
        UIButton* btnAction = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if ([data class] == [CouponInfo class]) {
            strStatus = ((CouponInfo*)data).stuatus;
            type = ((CouponInfo*)data).type;
            strTitle = ((CouponInfo*)data).title;
            strPrice = [NSString stringWithFormat:@"￥%.0f", [((CouponInfo*)data).price floatValue]];
            
           // strTime = [NSString stringWithFormat:@"有效期至%@", ((CouponInfo*)data).failtime];
            //lee999 150706 要求截取 时分秒
            strTime = [NSString stringWithFormat:@"有效期至%@", [[((CouponInfo*)data).failtime componentsSeparatedByString:@" "] firstObject]];
        }
        
        else if ([data class] == [FreePostCardInfo class])
        {
            strStatus = ((FreePostCardInfo*)data).status;
            strTitle = [NSString stringWithFormat:@"%@共计%@次", ((FreePostCardInfo*)data).name, ((FreePostCardInfo*)data).total_times];
            strPrice = [[NSNumber numberWithInteger:[((FreePostCardInfo*)data).total_times integerValue] - [((FreePostCardInfo*)data).used_times integerValue]] description];
            iBg = [UIImage imageNamed:@"laber_byk"];
            [btnAction setTitleColor:[UIColor colorWithHexString:@"#fd4081"] forState:UIControlStateNormal];
            strTime = [NSString stringWithFormat:@"有效期至%@", [[((FreePostCardInfo*)data).end_time componentsSeparatedByString:@" "] firstObject]];
        }
        if (strStatus) {
            if ([strStatus isEqualToString:@"已过期优惠劵"] || [strStatus isEqualToString:@"已过期优惠劵状态"] || [strStatus isEqualToString:@"无效"])
            {
                iBg = [UIImage imageNamed:@"laber_byk_use"];
                [ivState setImage:[UIImage imageNamed:@"yhq_none_laber"]];
                [ivState setFrame:CGRectMake(ivState.frame.origin.x, 11, lee1fitAllScreen(55), lee1fitAllScreen(55))];
            }
            else if([strStatus isEqualToString:@"已使用"] || [strStatus isEqualToString:@"已用完"])
            {
                iBg = [UIImage imageNamed:@"laber_byk_use"];
                [ivState setImage:[UIImage imageNamed:@"yhq_use_laber"]];
                [ivState setFrame:CGRectMake(ivState.frame.origin.x, 11, lee1fitAllScreen(55), lee1fitAllScreen(55))];
            }
            else
            {
                [ivState setBackgroundColor:[UIColor colorWithHexString:@"c6c6c6"]];
                if ([type isEqualToString:@"o2o"])
                {
                    iBg = [UIImage imageNamed:@"laber_o2o"];
                    [btnAction setTitleColor:[UIColor colorWithHexString:@"#fd890a"] forState:UIControlStateNormal];
                }
                else if([type isEqualToString:@"coupon"])
                {
                    iBg = [UIImage imageNamed:@"laber_yh"];
                    [btnAction setTitleColor:[UIColor colorWithHexString:@"#c8002c"] forState:UIControlStateNormal];
                }
                else if([type isEqualToString:@"gift"])
                {
                    iBg = [UIImage imageNamed:@"laber_lpk"];
                    [btnAction setTitleColor:[UIColor colorWithHexString:@"#ff6767"] forState:UIControlStateNormal];
                }
                [btnAction setTitle:@"使用" forState:UIControlStateNormal];
                [btnAction.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [btnAction setFrame:CGRectMake(ivState.frame.origin.x, 0, lee1fitAllScreen(63), ivBg.frame.size.height)];
                [btnAction setTag:indexPath.row];
                [btnAction addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                [ivBg addSubview:btnAction];
            }
        }
        
        //lee999 150712 新增包邮卡判断数量为0  如果使用次数==总次数 显示为已用完
        if([data class] == [FreePostCardInfo class] &&
           [((FreePostCardInfo*)data).total_times integerValue] == [((FreePostCardInfo*)data).used_times integerValue]){
            iBg = [UIImage imageNamed:@"laber_byk_use"];
            [ivState setImage:[UIImage imageNamed:@"yhq_use_laber"]];
            [ivState setFrame:CGRectMake(ivState.frame.origin.x, 11, lee1fitAllScreen(55), lee1fitAllScreen(55))];
        }
        //end
        
        
        [ivBg setImage:iBg];
        [ivBg setUserInteractionEnabled:YES];
        [lblPrice setText:strPrice];
        [lblTitle setText:strTitle];
        [lblTime setText:strTime];
        CGRect rcTitle = [lblTitle.text boundingRectWithSize:CGSizeMake(lblTitle.frame.size.width, lee1fitAllScreen(62)) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : lblTitle.font} context:nil];
        if (rcTitle.size.height > 15) {
            float originY = (ivBg.frame.size.height - rcTitle.size.height - 6 - 12) / 2;
            [lblTitle setFrame:CGRectMake(lblTitle.frame.origin.x, originY, rcTitle.size.width, rcTitle.size.height)];
            [lblTitle setNumberOfLines:2];
            [lblTime setFrame:CGRectMake(lee1fitAllScreen(72) + 10, lblTitle.frame.size.height + lblTitle.frame.origin.y + 6, lee1fitAllScreen(160), 12)];
        }
        return cell;
    }
    return nil;
}

//lee999 修改绑定
- (void)btnBindClicked:(UIButton *)sender {
    
    [nametextfield resignFirstResponder];
//    if (nametextfield.text.length == 14) {
        self.checkOutViewCtrl.useCouponcardId = nametextfield.text;
        
        [SBPublicAlert showMBProgressHUD:@"正在请求···" andWhereView:self.view states:NO];
        [mainSer addCouponcard:nametextfield.text];
    
//    }else {
//        [SBPublicAlert showMBProgressHUD:@"请输入正确的优惠劵号码" andWhereView:self.view hiddenTime:1.];
//    }
    
}


#pragma mark---- 如何入会
-(void)howToAddClubAction{

    
    YKCanReuse_webViewController *webView = [[YKCanReuse_webViewController alloc] init];
    webView.strURL = @"http://m.aimer.com.cn/method/v6codeinfo";
    webView.strTitle = @"尊享卡会员";
    [self.navigationController pushViewController:webView animated:YES];

}


- (void)UserCouns:(UIButton *)sender {
    
    self.checkOutViewCtrl.useCouponcardId = nametextfield.text;
    [self popBackAnimate:nil];
}


//lee999 新增礼品卡的使用界面
-(void)showGiftUrlAction:(MyButton*)sender{
    
    
    YKCanReuse_webViewController *webView = [[YKCanReuse_webViewController alloc] init];
    webView.strURL  = sender.addstring;
    webView.strTitle = @"礼品卡使用";
    [self.navigationController pushViewController:webView animated:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 2:
        {
            id data = [self.contentArr objectAtIndex:indexPath.row isArray:nil];
            
            NSString * strStatus = @"";
            
            CouponDetail20ViewController* cdvc = [[CouponDetail20ViewController alloc] init];
            if ([data class] == [CouponInfo class]) {
                NSString* type = ((CouponInfo*)data).type;
                strStatus = ((CouponInfo*)data).stuatus;
                if ([type isEqualToString:@"o2o"])
                {
                    cdvc.dType = kO2O;
                }
                else if([type isEqualToString:@"coupon"])
                {
                    cdvc.dType = kCoupon;
                }
                else if([type isEqualToString:@"gift"])
                {
                    cdvc.dType = kGift;
                }
            }
            else if ([data class] == [FreePostCardInfo class])
            {
                strStatus = ((FreePostCardInfo*)data).status;
                cdvc.dType = kFreePost;
            }
            
            //lee999 1、已使用，已过期的优惠券，包邮卡，礼品码不能点击进去到详情页。
            if ([strStatus isEqualToString:@"已过期优惠劵"] ||
                [strStatus isEqualToString:@"已过期优惠劵状态"] ||
                [strStatus isEqualToString:@"无效"] ||
                [strStatus isEqualToString:@"已使用"])
            {
                return;
            }
            
            
            cdvc.data = data;
            [self.navigationController pushViewController:cdvc animated:YES];
        }
            break;
            
        default:
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (section == 0) {
//        if ([self.contentArr count]) {
//            return 30.0f;
//        }
//    }
//    return 0.0f;
//}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if (section == 0) {
//        if (![self.contentArr count]) {
//            return nil;
//        }
//    }
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 21)];
//    label.backgroundColor = [UIColor clearColor];
//    label.font = [UIFont systemFontOfSize:15.0f];
//    label.text = @"优惠券（点击优惠券可查看使用规则）";
//    [view addSubview:label];
//    
//    return view;
//}



#pragma mark 刷新的代理方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [nametextfield resignFirstResponder];
    
    NSInteger returnKey = [_mytableView tableViewDidEndDragging];
    if (returnKey != k_RETURN_DO_NOTHING) {
        NSString * key = [[NSNumber numberWithInteger:returnKey] description];
        [self updateThread:key];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [nametextfield resignFirstResponder];

    NSInteger returnKey = [_mytableView tableViewDidDragging];
    if (returnKey == k_RETURN_LOADMORE) {
        NSString * key = [[NSNumber numberWithInteger:returnKey] description];
        [self updateThread:key];
    }
}

#pragma mark 刷新
-(void)getData
{
    current = 1;
    NSString *PageCurr = [[NSNumber numberWithInteger:current] description];
    [mainSer getCouponcardList20WithPage:PageCurr andPer_page:Per_Page andType:_strType];
}

#pragma mark 加载
- (void)nextPage
{
    current ++;
    NSString *PageCurr = [[NSNumber numberWithInteger:current] description];
    [mainSer getCouponcardList20WithPage:PageCurr andPer_page:Per_Page andType:_strType];
}

- (void)updateTableView
{
    BOOL status = NO;
    if (_cli.current_page < _cli.page_count) {//小于
        status = YES;
    }
    _mytableView.isCloseFooter = !status;
    
    if (status) {//还有数据
        // 一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        [_mytableView reloadData:NO];
    } else {//没有数据
        //  一定要调用本方法，否则下拉/上拖视图的状态不会还原，会一直转菊花
        [_mytableView reloadData:YES];
    }
}
- (void)updateThread:(NSString *)returnKey{
    switch ([returnKey intValue]) {
        case k_RETURN_REFRESH:
            [self getData];
            break;
        case k_RETURN_LOADMORE:
            [self nextPage];
            break;
        default:
            break;
    }
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSLog(@"-----%@",textField.text);
    return YES;
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
    if(![amodel isKindOfClass:[LBaseModel class]])
    {
        switch ((NSUInteger)aHandle) {
            case Http_CouponList20_Tag:
            {
                _cli = [[[CouponListInfoParser alloc] init] parseCouponListInfo:amodel];
                
                //如果V6card
                if ([_cli.v6cards count] == 0) {

                }
                //end
                
                //lee999 150707 新增礼品卡解析
                if ([_strType isEqualToString:@"v6card"]) {
                    if (current == 1) {
                        [self.arrCard removeAllObjects];
                        [self.arrCard addObjectsFromArray:_cli.v6cards];
                    }else {
                        [self.arrCard addObjectsFromArray:_cli.v6cards];
                    }
                    [self updateTableView];
                }
                //end
                
                if ([_strType isEqualToString:@"c"] || [_strType isEqualToString:@"g"] || [_strType isEqualToString:@"u"]) {
                    if (current == 1) {
                        [self.contentArr removeAllObjects];
                        [self.contentArr addObjectsFromArray:_cli.coupons];
                        
                    }else {
                        
                        [self.contentArr addObjectsFromArray:_cli.coupons];
                    }
                    
                    [self updateTableView];
                }
                else if ([_strType isEqualToString:@"f"])
                {
                    if (current == 1) {
                        [self.contentArr removeAllObjects];
                        [self.contentArr addObjectsFromArray:_cli.freepostcards];
                    }else {
                        [self.contentArr addObjectsFromArray:_cli.freepostcards];
                    }
                    
                    [self updateTableView];
                }
            }
                break;
                
            default:
                break;
        }
        return;
    }
    
    
    
    LBaseModel *model = (LBaseModel *)amodel;
    
    switch (model.requestTag) {
        case Http_CoupncardList_Tag:
        {
            if (!model.errorMessage) {
                
                self.couponcardListModel = (CouponcardListCouponcardListModel *)model;
                _labelInfo.text = [NSString stringWithFormat:@"%@%d张会员卡  %ld张优惠券",([self.title  isEqualToString:@"使用优惠券"] ?  @"本单可用" : @"我有"),self.couponcardListModel.cards_count,(long)self.couponcardListModel.couponcard_count];
                
                if (self.couponcardListModel.recordCount == 0) {
                    [SBPublicAlert showMBProgressHUD:@"您还没有会员卡或优惠券可用" andWhereView:self.view hiddenTime:1.];
                    return;
                }
                if (current == 1) {
                    [self.arrCard removeAllObjects];
                    [self.arrCard addObjectsFromArray:(NSMutableArray *)self.couponcardListModel.checkoutCards];
                    [self.contentArr removeAllObjects];
                    [self.contentArr addObjectsFromArray:(NSMutableArray *)self.couponcardListModel.checkoutCouponcard];
                    
                }else {
                    
                    [self.contentArr addObjectsFromArray:(NSMutableArray *)self.couponcardListModel.checkoutCouponcard];
                }
                
                [self updateTableView];
            }else {
                [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:1.];
                [self updateTableView];
            }
        }
            break;
        case Http_Sendcodes_Tag:
        {
            if (!model.errorMessage) {
                
                [SBPublicAlert showMBProgressHUDTextOnly:((CodeBindBindCodeModel *)model).content andWhereView:self.view hiddenTime:3.0];
                
            }else{
                [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:1.];
            }
        }
            break;
        case Http_usev6card_Tag:
        {
            if (!model.errorMessage) {
                //使用成功
                self.checkOutViewCtrl.usev6useCardId = [((Usev6cardusev6cardModel *)model) usev6cardID];
                [self popBackAnimate:nil];//回到结算中心
            }else{
                [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:1.];
            }
        }
            break;
        case Http_exchangecoupon_Tag:
        {
            if (!model.errorMessage) {
                //兑换成功
                [SBPublicAlert showMBProgressHUD:@"兑换成功" andWhereView:self.view hiddenTime:1.];
                [self performSelector:@selector(getData) withObject:nil afterDelay:1.2];
                
            }else{
                [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:1.];
            }
        }
            break;
            //lee999 新增判断
        case Http_addCouponcard_Tag:
        {
            if (!model.errorMessage) {
                nametextfield.text = @"";
                ChengeMyInfo *bangModel = (ChengeMyInfo *)model;
                [self getData];
                [MYCommentAlertView showMessage:bangModel.res target:nil];
            } else {
                [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:0.6];
            }
        }//end
            
        case 10086:
        {
            [SBPublicAlert showMBProgressHUD:model.errorMessage andWhereView:self.view hiddenTime:1.];
            break;
        }
            
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 137) {
        if (buttonIndex==1) {
            [SBPublicAlert showMBProgressHUD:@"正在兑换···" andWhereView:self.view states:NO];
            
            V6CardInfo *v6info = [self.arrCard objectAtIndex:0 isArray:nil];
            [mainSer exchangecoupon:v6info.card_id];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark-- 如果V6card 没有显示入会
//-(void)dontHaveV6card{
//    
//    
//
//    if (self.arrCard.count == 0) {
//        float oldy = lblContent.frame.origin.y + lblContent.frame.size.height;
//        oldy += 20;
//        
//        UIImage *img = [UIImage imageNamed:@"yhq_icon_none.png"];
//        UIImageView *imav = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-img.size.width)/2, oldy, img.size.width, img.size.height)];
//        [imav setImage:img];
//        [cell addSubview:imav];
//        
//        oldy = oldy + img.size.height +30;
//        
//        [lblContent setFrame:CGRectMake(10, oldy, ScreenWidth-20, 15)];
//        [lblContent setTextAlignment:NSTextAlignmentCenter];
//        
//        //lee999 150706 进行判断啊！！！
//        if ([_strType isEqualToString:@"c"] || [_strType isEqualToString:@"u"]) {
//            //优惠券
//            [lblContent setText:@"您暂无优惠券"];
//            
//        }else if ([_strType isEqualToString:@"g"]){
//            //礼品卡
//            [lblContent setText:@"您暂无礼品卡"];
//            
//        }else if ([_strType isEqualToString:@"f"]){
//            //包邮卡
//            [lblContent setText:@"您暂无包邮卡"];
//        }
//        
//    }
//
//}



#pragma mark--  显示我的优惠券

-(void)showCouponMenu:(UIButton*)sender
{
    
    btnShowCouponMenu.selected = YES;
    btnToFreeShippingCard.selected = NO;
    btnToGiftCard.selected = NO;
//    if(sender != selectedBtn)
    if(selectIndex != 1)
    {
        if (ivSelected) {
            [ivSelected removeFromSuperview];
        }
        ivSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, sender.frame.size.height - 1, sender.frame.size.width, 1)];
        [ivSelected setBackgroundColor:[UIColor colorWithHexString:@"#c8002c"]];
        [sender addSubview:ivSelected];
        
        selectIndex = 1;
        
        sender.selected = YES;
        
        _strType = @"c";
        [self getData];
        return;
    }
    if (vCouponMenu) {
        [vCouponMenu removeFromSuperview];
        vCouponMenu = nil;
        return;
    }
    if (ivSelected) {
        [ivSelected removeFromSuperview];
    }
    ivSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, sender.frame.size.height - 1, sender.frame.size.width, 1)];
    [ivSelected setBackgroundColor:[UIColor colorWithHexString:@"#c8002c"]];
    [sender addSubview:ivSelected];
    [selectedBtn setSelected:NO];
    selectedBtn = sender;
    [sender setSelected:YES];
    
    vCouponMenu = [[UIView alloc] initWithFrame:CGRectMake(0, sender.frame.size.height, sender.frame.size.width, sender.frame.size.height * 2)];
    [self.view addSubview:vCouponMenu];
    [self.view bringSubviewToFront:vCouponMenu];
    
    UIButton* btnShowAllCoupon = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnShowAllCoupon setFrame:CGRectMake(0, 0, vCouponMenu.frame.size.width, vCouponMenu.frame.size.height / 2)];
    [btnShowAllCoupon setTag:10001];
    [btnShowAllCoupon addTarget:self action:@selector(showCouponWithType:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowAllCoupon setTitle:@"全部优惠券" forState:UIControlStateNormal];
    [btnShowAllCoupon setTitleColor:[UIColor colorWithHexString:@"#6c6c6c"] forState:UIControlStateNormal];
    [btnShowAllCoupon setExclusiveTouch:NO];
    [btnShowAllCoupon setBackgroundColor:[UIColor colorWithHexString:@"#ffffff"]];
    [vCouponMenu addSubview:btnShowAllCoupon];
    
    UIButton* btnShowUnusedCoupon = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnShowUnusedCoupon setFrame:CGRectMake(0, btnShowAllCoupon.frame.size.height, vCouponMenu.frame.size.width, vCouponMenu.frame.size.height / 2)];
    [btnShowUnusedCoupon setTag:10002];
    [btnShowUnusedCoupon addTarget:self action:@selector(showCouponWithType:) forControlEvents:UIControlEventTouchUpInside];
    [btnShowUnusedCoupon setTitle:@"未使用" forState:UIControlStateNormal];
    [btnShowUnusedCoupon setTitleColor:[UIColor colorWithHexString:@"#6c6c6c"] forState:UIControlStateNormal];
    [btnShowUnusedCoupon setExclusiveTouch:NO];
    [btnShowUnusedCoupon setBackgroundColor:[UIColor colorWithHexString:@"#ffffff"]];
    [vCouponMenu addSubview:btnShowUnusedCoupon];
    
    
    switch (nSelectedIndexInMenu) {
        case 10001:
        {
            [btnShowAllCoupon setBackgroundColor:[UIColor colorWithHexString:@"#f6f6f6"]];
        }
            break;
        case 10002:
        {
            [btnShowUnusedCoupon setBackgroundColor:[UIColor colorWithHexString:@"#f6f6f6"]];
        }
            break;
        default:
            break;
    }
}

-(void)showCouponWithType:(UIButton*)sender
{
    nSelectedIndexInMenu = sender.tag;
    switch (sender.tag) {
        case 10001:
        {
            _strType = @"c";
            [self getData];
        }
            break;
        case 10002:
        {
            _strType = @"u";
            [self getData];
        }
            break;
        default:
        {
            nSelectedIndexInMenu = 10001;
        }
            break;
    }
    if (vCouponMenu) {
        [vCouponMenu removeFromSuperview];
        vCouponMenu = nil;
    }
}

#pragma mark--  显示我的包邮卡

-(void)toFreeShippingCard:(UIButton*)sender
{
 
    btnShowCouponMenu.selected = NO;
    btnToFreeShippingCard.selected = YES;
    btnToGiftCard.selected = NO;
    
    selectIndex = 3;

    
    if (ivSelected) {
        [ivSelected removeFromSuperview];
    }
    ivSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, sender.frame.size.height - 1, sender.frame.size.width, 1)];
    [ivSelected setBackgroundColor:[UIColor colorWithHexString:@"#c8002c"]];
    [sender addSubview:ivSelected];
    [selectedBtn setSelected:NO];
    selectedBtn = sender;
    [sender setSelected:YES];
    if (vCouponMenu) {
        [vCouponMenu removeFromSuperview];
        vCouponMenu = nil;
    }
    _strType = @"f";
    [self getData];
}

#pragma mark--  显示我的会员卡

-(void)toGiftCard:(UIButton*)sender
{
    
    btnShowCouponMenu.selected = NO;
    btnToFreeShippingCard.selected = NO;
    btnToGiftCard.selected = YES;
    
    selectIndex = 2;

    if (ivSelected) {
        [ivSelected removeFromSuperview];
    }
    ivSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, sender.frame.size.height - 1, sender.frame.size.width, 1)];
    [ivSelected setBackgroundColor:[UIColor colorWithHexString:@"#c8002c"]];
    [sender addSubview:ivSelected];
    [selectedBtn setSelected:NO];
    selectedBtn = sender;
    [sender setSelected:YES];
    if (vCouponMenu) {
        [vCouponMenu removeFromSuperview];
        vCouponMenu = nil;
    }
    _strType = @"g";
    [self getData];
}

-(NSArray*)viewConstraints
{
    NSDictionary *views = @{@"mytableView" : self.mytableView, @"vToolbar" : self.vToolbar};
    NSDictionary *metrics = @{@"barHeight" : [NSNumber numberWithFloat:lee1fitAllScreen(35)]};
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    if (self.clType == EAll) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[vToolbar(barHeight)][mytableView]|" options:0 metrics:metrics views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[vToolbar]|" options:0 metrics:metrics views:views]];
    }else
    {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mytableView]|" options:0 metrics:metrics views:views]];
    }
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mytableView]|" options:0 metrics:metrics views:views]];
    return constraints;
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

-(PullToRefreshTableView *)mytableView
{
    if (_mytableView) {
        return _mytableView;
    }
    _mytableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _mytableView.delegate = self;
    _mytableView.dataSource = self;
    _mytableView.backgroundView = nil;
    _mytableView.backgroundColor = [UIColor clearColor];
    _mytableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mytableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    return _mytableView;
}
@end





//        cell.labelTitle.text = LegalObject([dic objectForKey:@"title"],[NSString class]);//@"线上全场通用券";
//        cell.labelDesc.text = LegalObject([dic objectForKey:@"desc"],[NSString class]);
//        NSString *startTime = LegalObject([dic objectForKey:@"start_time"],[NSString class]);
//        if ([startTime isEqualToString:@""] || !startTime) {
//            startTime = @"0000-00-00 00:00:00";
//        }
//
//        NSString *failtime = LegalObject([dic objectForKey:@"failtime"],[NSString class]);
//        if ([failtime isEqualToString:@""] || !failtime) {
//            failtime = @"0000-00-00 00:00:00";
//        }
//        cell.labelTime.text = [NSString stringWithFormat:@"%@ 至\n%@",[startTime substringToIndex:10],[failtime substringToIndex:10]];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSString *dateStr = [formatter stringFromDate:[NSDate date]];
//
//        NSComparisonResult compareResult = [dateStr compare:failtime];
//        NSString *status = LegalObject([dic objectForKey:@"stuatus"],[NSString class]);
//
//
//        //lee999recode
//        if ([self.title isEqualToString:@"使用优惠券"]) {
//         status = @"未使用";
//        cell.labelTime.text = [dic objectForKey:@"time"];
//        compareResult = NSOrderedAscending;
//
//        }
//        //end
//
//        if ([status isEqualToString:@"已过期优惠劵"]||[status isEqualToString:@"已过期优惠劵状态"]) {
//
//            BtnSetImg(cell.btnBonus, @"card_ticket02.png", @"", @"")
//            cell.imageViewIsUsed.image = [UIImage imageNamed:@"ticket_status_out.png"];
//            cell.buttonUsed.hidden = YES;
//
//            //lee999 已经过期的优惠券不可点击
//            cell.btnBonus.enabled = NO;
//            //end
//        } else if ([status isEqualToString:@"未使用"])
//        {
//            if(compareResult == NSOrderedAscending || compareResult == NSOrderedSame) {//没有过期
//                [cell.btnBonus setImage:[UIImage imageNamed:@"card_aimer01.png"] forState:UIControlStateNormal];
//                cell.imageViewIsUsed.image = [UIImage imageNamed:@""];
//                cell.buttonUsed.hidden = NO;
//            } else if (compareResult == NSOrderedDescending){//已过期
//                BtnSetImg(cell.btnBonus, @"card_ticket02.png", @"", @"")
//                cell.imageViewIsUsed.image = [UIImage imageNamed:@"ticket_status_out.png"];
//                cell.buttonUsed.hidden = YES;
//
//                //lee999 已经过期的优惠券不可点击
//                cell.btnBonus.enabled = NO;
//                //end
//            }
//        }
//        else if ([status isEqualToString:@"已使用"]){//已使用
//            BtnSetImg(cell.btnBonus,@"card_aimer01.png",@"",@"");
//            cell.buttonUsed.hidden = YES;
//            cell.imageViewIsUsed.image = [UIImage imageNamed:@"ticket_status_used.png"];
//        }
//        cell.labelPrice.text = LegalObject([dic objectForKey:@"price"],[NSString class]);
//
//
//        //lee增加o2o优惠券的显示
//        NSString *cardtype = @"";
//        cardtype = LegalObject([dic objectForKey:@"type"],[NSString class]);
//        NSLog(@"cardtype---:%@",cardtype);
//        if ([cardtype isEqualToString:@"o2o"]) {
//            [cell.btnBonus setImage:[UIImage imageNamed:@"card_lb03.png"] forState:UIControlStateNormal];
//
//            //lee987 修改020的优惠券展示
//            [cell.buttonUsed setBackgroundImage:[UIImage imageNamed:@"alert-yellow-button.png"] forState:UIControlStateNormal];
//        }