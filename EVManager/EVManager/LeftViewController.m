//
//  LeftViewController.m
//  EVManager
//
//  Created by dengyanzhou on 15/9/14.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import "LeftViewController.h"
#import "MenuInfoModel.h"
#import "UIColorHex.h"
#import "UIViewController+MMDrawerController.h"
@implementation MenuButton
@end


@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UIButton *currentBtn;
@property(nonatomic,strong)UITableView *tableView;
@end

@implementation LeftViewController

-(id)init{
    self = [super init];
    if(self){
        [self setRestorationIdentifier:@"MMExampleLeftSideDrawerController"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"菜单";
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];

    // Do any additional setup after loading the view.
}

- (UITableView *)tableView
{
    if (!_tableView) {
        self.tableView = ({
            
            UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , 100)];
            imageView.image = [UIImage imageNamed:@"heihei.jpg"];
            tableView.tableHeaderView = imageView;
            tableView.tableFooterView = [UIView new];
            tableView.rowHeight = 60;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView;
        });
    }
    return _tableView;
}
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.leftMenus.menus.count + 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        MenuButton *btn  =[MenuButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0,cell.frame.size.width,60);
        btn.backgroundColor = [UIColor colorWithRed:1.000 green:0.980 blue:0.993 alpha:1.000];
        btn.tag = indexPath.row + 100;
        btn.titleEdgeInsets =  UIEdgeInsetsMake(0, -150, 0, 0);
        [cell.contentView addSubview:btn];
    }

    MenuButton *button = (MenuButton*)[cell viewWithTag:indexPath.row + 100];
    if (indexPath.row < self.leftMenus.menus.count) {
        button.backgroundColor = [UIColorHex colorWithHexString:self.leftMenus.navibgColor];
        NSString *name = ((Menus*)self.leftMenus.menus[indexPath.row]).name;
        NSString *norColor = ((Menus*)self.leftMenus.menus[indexPath.row]).fontColorDefault;
        NSString *focusColor = ((Menus*)self.leftMenus.menus[indexPath.row]).fontColorFocus;
        [button setTitle: name  forState:UIControlStateNormal];
        [button setTitleColor: [UIColorHex colorWithHexString:norColor]  forState:UIControlStateNormal];
        [button setTitleColor: [UIColorHex colorWithHexString:focusColor]
                     forState:UIControlStateSelected];
        button.tagrgetUrl = ((Menus*)self.leftMenus.menus[indexPath.row]).targetUrl;
    } else if (indexPath.row == self.leftMenus.menus.count){
        [button setTitle:@"清空缓存" forState:UIControlStateNormal];
        button.tagrgetUrl = @"清空缓存";
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.906 green:0.349 blue:0.067 alpha:1.000] forState:UIControlStateSelected];
        
    }else if (indexPath.row == self.leftMenus.menus.count + 1){
        [button setTitle:@"退出登录" forState:UIControlStateNormal];
        button.tagrgetUrl = @"退出登录";
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.906 green:0.349 blue:0.067 alpha:1.000] forState:UIControlStateSelected];

    }else{
    }
    [button addTarget:self action:@selector(gotoUrl:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
- (void)gotoUrl:(MenuButton*)button
{    self.currentBtn.selected = NO;
     self.currentBtn = button;
     button.selected = YES;

    if ([self.delegate respondsToSelector:@selector(leftMenuClick:)]) {
        [ self.delegate performSelector:@selector(leftMenuClick:) withObject:button];
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
