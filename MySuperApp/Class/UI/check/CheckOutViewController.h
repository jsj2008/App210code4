//
//  CheckOutViewController.h
//  MySuperApp
//
//  Created by bonan on 14-4-6.
//  Copyright (c) 2014年 zan. All rights reserved.
//

#import "LBaseViewController.h"
#import "COCheckOutModel.h"

@interface CheckOutViewController : LBaseViewController <ServiceDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    CGFloat height_s;
    CGFloat height_d;

    MainpageServ *mainSev;
    
   IBOutlet UITableView* chectOutTable;
    
    NSInteger suitCount;  //套装拥有数量
    NSInteger packageCount; //礼包数量

    
    COCheckOutModel *mycheckOutModel;

    
    NSMutableArray* otherCells;
    NSMutableArray* tableCells;
    NSMutableArray* suitlistcell;//套装
    NSMutableArray* packagelistcell;//礼包

    
    NSString* postText; //订单留言
}

@property (nonatomic, assign) BOOL isAmier;

@property(nonatomic, retain) NSString* straddressID; //地址ID

@property(nonatomic, retain) NSString* usev6useCardId; //使用的电子券
@property(nonatomic, retain) NSString* useCouponcardId; //优惠劵ID
@property(nonatomic, retain) NSString* usefreepostcardId;//使用的包邮卡ID

@property(nonatomic, retain)NSString* postText; //订单留言

//在支付方式的界面需要用到的
@property(nonatomic, assign) NSInteger selectIndex;
@property(nonatomic, retain) NSString * m_strPayMethod; //支付方式

@property (nonatomic, retain) AddressAddresslist* addressItem_ben;

@property (nonatomic, retain) NSString *province;

///TD 统计所用参数
@property (nonatomic, retain) NSMutableDictionary *dicTD;



@end
