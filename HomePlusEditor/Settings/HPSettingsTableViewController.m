//
// HPSettingsTableViewController.m
// HomePlus
//
// Settings (UITable)View Controller. Load stuff and call changes here. 
//
// Created Oct 2019
// Author: Kritanta
//


#include "HPSettingsTableViewController.h"
#include <UIKit/UIKit.h>
#include "EditorManager.h"
#include "HPUtilities.h"
#include "HPManager.h"
#include "HPTableCell.h"
#import <sys/utsname.h>
#include "spawn.h"

const int RESET_VALUES = 1;

#pragma mark UIViewController

@implementation HPSettingsTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        self.title = @"HomePlus Settings";
    }
    return self;
}

- (void)opened
{
    [self.tableView reloadData];
    //[[tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].accessoryView ]
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat topPadding = statusBarSize.height;

    //CGFloat bottomPadding = window.safeAreaInsets.bottom;
    
    //self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+topPadding, self.tableView.frame.size.width, self.tableView.frame.size.height-topPadding);

    //self.tableView.bounds = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+topPadding, self.tableView.frame.size.width, self.tableView.frame.size.height-topPadding);
    UIView *bg = [[UIView alloc] init];
    if (!UIAccessibilityIsReduceTransparencyEnabled()) 
    {
        bg.backgroundColor = [UIColor clearColor];

        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //always fill the view
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [bg addSubview:blurEffectView]; //if you have more UIViews, use an insertSubview API to place it where needed
    } 
    else 
    {
        bg.backgroundColor = [UIColor blackColor];
    }

    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,(([[UIScreen mainScreen] bounds].size.width)/750)*300-topPadding-20)];
    self.tableView.tableHeaderView = tableHeaderView;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = bg;


    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    NSDictionary *attributes = @{
                                 NSUnderlineStyleAttributeName: @0,
                                 NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:17]
                                 };
    [self.navigationController.navigationBar setTitleTextAttributes: attributes];


    [self.tableView setTableFooterView:[self customTableFooterView]];
    [self.tableView registerClass:[HPTableCell class] forCellReuseIdentifier:@"Cell"];
}

-(UIView *)customTableFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,10+(([[UIScreen mainScreen] bounds].size.width)/750)*300)];

    UILabel *dInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,0,[[UIScreen mainScreen] bounds].size.width, 10)];
    NSString *DN = [NSString stringWithFormat:[self deviceName]];
    NSString *CF = [NSString stringWithFormat:@"%0.3f", kCFCoreFoundationVersionNumber];
    NSString *FV = [NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
    dInfoLabel.text = [NSString stringWithFormat:@"Device: %@ | Firmware: %@ | CFVersion: %@", DN, FV, CF];
    [dInfoLabel setFont:[UIFont systemFontOfSize:10.0]];
    [footerView addSubview:dInfoLabel];

    UIImage *myImage = [HPUtilities inAppFooter];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
    imageView.frame = CGRectMake(0,10,[[UIScreen mainScreen] bounds].size.width,(([[UIScreen mainScreen] bounds].size.width)/750)*300);
    [footerView addSubview:imageView];
    
    //consts
    CGFloat firstButtonLeftOffset = (([[UIScreen mainScreen] bounds].size.width/375) * 120);
    CGFloat buttonWidth = (([[UIScreen mainScreen] bounds].size.width/375) * 60);

    UIButton *patreonButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [patreonButton addTarget:self 
                action:@selector(handlePatreonButtonPress:)
        forControlEvents:UIControlEventTouchUpInside];
        [patreonButton setTitle:@"" forState:UIControlStateNormal];
        patreonButton.frame = CGRectMake(firstButtonLeftOffset, 36, buttonWidth, 80);
        [footerView addSubview:patreonButton];

    UIButton *discordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [discordButton addTarget:self 
                action:@selector(handleDiscordButtonPress:)
        forControlEvents:UIControlEventTouchUpInside];
        [discordButton setTitle:@"" forState:UIControlStateNormal];
        discordButton.frame = CGRectMake(firstButtonLeftOffset+(buttonWidth), 36, buttonWidth, 80);
        [footerView addSubview:discordButton];

    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [twitterButton addTarget:self 
                action:@selector(handleTwitterButtonPress:)
        forControlEvents:UIControlEventTouchUpInside];
        [twitterButton setTitle:@"" forState:UIControlStateNormal];
        twitterButton.frame = CGRectMake(firstButtonLeftOffset+(buttonWidth*2), 36, buttonWidth, 80);
        [footerView addSubview:twitterButton];

    UIButton *sourceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sourceButton addTarget:self 
                action:@selector(handleSourceButtonPress:)
        forControlEvents:UIControlEventTouchUpInside];
        [sourceButton setTitle:@"" forState:UIControlStateNormal];
        sourceButton.frame = CGRectMake(firstButtonLeftOffset+(buttonWidth*3), 36, buttonWidth, 80);
        [footerView addSubview:sourceButton];

    return footerView;
}


- (NSString*) deviceName
{
    struct utsname systemInfo;

    uname(&systemInfo);

    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];

    static NSDictionary* deviceNamesByCode = nil;

    if (!deviceNamesByCode) {

        deviceNamesByCode = @{@"i386"      : @"Simulator",
                              @"x86_64"    : @"Simulator",
                              @"iPod1,1"   : @"iPod Touch",        // (Original)
                              @"iPod2,1"   : @"iPod Touch",        // (Second Generation)
                              @"iPod3,1"   : @"iPod Touch",        // (Third Generation)
                              @"iPod4,1"   : @"iPod Touch",        // (Fourth Generation)
                              @"iPod7,1"   : @"iPod Touch",        // (6th Generation)       
                              @"iPhone1,1" : @"iPhone",            // (Original)
                              @"iPhone1,2" : @"iPhone",            // (3G)
                              @"iPhone2,1" : @"iPhone",            // (3GS)
                              @"iPad1,1"   : @"iPad",              // (Original)
                              @"iPad2,1"   : @"iPad 2",            //
                              @"iPad3,1"   : @"iPad",              // (3rd Generation)
                              @"iPhone3,1" : @"iPhone 4",          // (GSM)
                              @"iPhone3,3" : @"iPhone 4",          // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" : @"iPhone 4S",         //
                              @"iPhone5,1" : @"iPhone 5",          // (model A1428, AT&T/Canada)
                              @"iPhone5,2" : @"iPhone 5",          // (model A1429, everything else)
                              @"iPad3,4"   : @"iPad",              // (4th Generation)
                              @"iPad2,5"   : @"iPad Mini",         // (Original)
                              @"iPhone5,3" : @"iPhone 5c",         // (model A1456, A1532 | GSM)
                              @"iPhone5,4" : @"iPhone 5c",         // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" : @"iPhone 5s",         // (model A1433, A1533 | GSM)
                              @"iPhone6,2" : @"iPhone 5s",         // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" : @"iPhone 6 Plus",     //
                              @"iPhone7,2" : @"iPhone 6",          //
                              @"iPhone8,1" : @"iPhone 6S",         //
                              @"iPhone8,2" : @"iPhone 6S Plus",    //
                              @"iPhone8,4" : @"iPhone SE",         //
                              @"iPhone9,1" : @"iPhone 7",          //
                              @"iPhone9,3" : @"iPhone 7",          //
                              @"iPhone9,2" : @"iPhone 7 Plus",     //
                              @"iPhone9,4" : @"iPhone 7 Plus",     //
                              @"iPhone10,1": @"iPhone 8",          // CDMA
                              @"iPhone10,4": @"iPhone 8",          // GSM
                              @"iPhone10,2": @"iPhone 8 Plus",     // CDMA
                              @"iPhone10,5": @"iPhone 8 Plus",     // GSM
                              @"iPhone10,3": @"iPhone X",          // CDMA
                              @"iPhone10,6": @"iPhone X",          // GSM
                              @"iPhone11,2": @"iPhone XS",         //
                              @"iPhone11,4": @"iPhone XS Max",     //
                              @"iPhone11,6": @"iPhone XS Max",     // China
                              @"iPhone11,8": @"iPhone XR",         //
                              @"iPhone12,1": @"iPhone 11",         //
                              @"iPhone12,3": @"iPhone 11 Pro",     //
                              @"iPhone12,5": @"iPhone 11 Pro Max", //

                              @"iPad4,1"   : @"iPad Air",          // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   : @"iPad Air",          // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   : @"iPad Mini",         // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   : @"iPad Mini",         // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,7"   : @"iPad Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
                              @"iPad6,7"   : @"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1584) 
                              @"iPad6,8"   : @"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1652) 
                              @"iPad6,3"   : @"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (model A1673)
                              @"iPad6,4"   : @"iPad Pro (9.7\")"   // iPad Pro 9.7 inches - (models A1674 and A1675)
                              };
    }

    NSString* deviceName = [deviceNamesByCode objectForKey:code];

    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:

        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
        else {
            deviceName = @"Unknown";
        }
    }

    return deviceName;
}

- (void)handlePatreonButtonPress:(UIButton*)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.patreon.com/kritantadev"] options:@{} completionHandler:nil];
}

- (void)handleDiscordButtonPress:(UIButton*)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://discord.gg/E9YWU3m"] options:@{} completionHandler:nil];
}

- (void)handleTwitterButtonPress:(UIButton*)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://twitter.com/_kritanta"] options:@{} completionHandler:nil];
}

- (void)handleSourceButtonPress:(UIButton*)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://git.kritanta.me/Kritanta/HomePlus"] options:@{} completionHandler:nil];
}

#pragma mark - 


- (void)donePressed:(id)sender
{
    //[self.delegate globalsViewControllerDidFinish:self];
}

#pragma mark Table Data Helpers

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return(@"Reset Values");
    return (@"");
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch ( section ) 
    {
        case 0: 
        {
            rows = 3;
            break;
        }
        case 1:
        {
            rows = 2;
            break;
        }
        case 2: 
        {
            rows = 4;
            break;
        }
    }
    return rows;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    NSString *sectionName;
    switch (section) 
    {
        case 0:
            sectionName = NSLocalizedString(@"Icons", @"Icons");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Dock", @"Dock");
            break;
        case 2:
            sectionName = NSLocalizedString(@"Settings", @"Settings");
            break;
        default:
            sectionName = @"";
            break;
    }    
    return sectionName;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 15.f;
            cell.backgroundColor = [UIColor clearColor];
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 0, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:0.4].CGColor;

            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}
- (HPTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch( [indexPath section] ) 
    {
        case 0: 
        {
            switch ( [indexPath row] )
            {
                case 0: 
                {
                    HPTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

                    if( cell == nil ) 
                    {
                        cell = [[HPTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SwitchCell"];
                        cell.textLabel.text = @"Hide Icon Labels";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                        cell.accessoryView = switchView;
                        [switchView setOn:[[HPManager sharedManager] currentLoadoutShouldHideIconLabelsForLocation:@"SBIconLocationRoot"] animated:NO];
                        [switchView addTarget:self action:@selector(iconLabelSwitchChanged:) forControlEvents:UIControlEventValueChanged];

                        //[cell.layer setCornerRadius:10];

                        [cell setBackgroundColor: [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:0.4]];//rgb(38, 37, 42)];
                        //Border Color and Width
                        [cell.layer setBorderColor:[UIColor blackColor].CGColor];
                        [cell.layer setBorderWidth:0];

                        //Set Text Col
                        cell.textLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];
                        cell.detailTextLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];

                        cell.clipsToBounds = YES;
                    }
                    return cell;
                }

                case 1: 
                {
                    HPTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

                    if( cell == nil ) 
                    {
                        cell = [[HPTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SwitchCell"];
                        cell.textLabel.text = @"Hide Badges";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                        cell.accessoryView = switchView;
                        [switchView setOn:[[HPManager sharedManager] currentLoadoutShouldHideIconBadgesForLocation:@"SBIconLocationRoot"] animated:NO];
                        [switchView addTarget:self action:@selector(iconBadgeSwitchChanged:) forControlEvents:UIControlEventValueChanged];

                        //[cell.layer setCornerRadius:10];

                        [cell setBackgroundColor: [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:0.4]];//rgb(38, 37, 42)];
                        //Border Color and Width
                        [cell.layer setBorderColor:[UIColor blackColor].CGColor];
                        [cell.layer setBorderWidth:0];

                        //Set Text Col
                        cell.textLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];
                        cell.detailTextLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];

                        cell.clipsToBounds = YES;
                    }
                    return cell;
                }

                case 2: 
                {
                    HPTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

                    if( cell == nil ) 
                    {
                        cell = [[HPTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SwitchCell"];
                        cell.textLabel.text = @"Hide Labels in Folders";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                        cell.accessoryView = switchView;
                        [switchView setOn:[[HPManager sharedManager] currentLoadoutShouldHideIconLabelsForLocation:@"SBIconLocationFolder"] animated:NO];
                        [switchView addTarget:self action:@selector(iconLabelFolderSwitchChanged:) forControlEvents:UIControlEventValueChanged];

                        //[cell.layer setCornerRadius:10];

                        [cell setBackgroundColor: [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:0.4]];//rgb(38, 37, 42)];
                        //Border Color and Width
                        [cell.layer setBorderColor:[UIColor blackColor].CGColor];
                        [cell.layer setBorderWidth:0];

                        //Set Text Col
                        cell.textLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];
                        cell.detailTextLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];

                        cell.clipsToBounds = YES;
                    }
                    return cell;
                }
            }
        }
        case 1: // Dock
        {
            switch ( [indexPath row] )
            {
                case 0: 
                {
                    HPTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

                    if( cell == nil ) 
                    {
                        cell = [[HPTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SwitchCell"];
                        cell.textLabel.text = @"Hide Dock BG";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                        cell.accessoryView = switchView;
                        [switchView setOn:[[HPManager sharedManager] currentLoadoutShouldHideDockBG] animated:NO];
                        [switchView addTarget:self action:@selector(dockbGSwitchChanged:) forControlEvents:UIControlEventValueChanged];

                        //[cell.layer setCornerRadius:10];

                        [cell setBackgroundColor: [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:0.4]];//rgb(38, 37, 42)];
                        //Border Color and Width
                        [cell.layer setBorderColor:[UIColor blackColor].CGColor];
                        [cell.layer setBorderWidth:0];

                        //Set Text Col
                        cell.textLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];
                        cell.detailTextLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];

                        cell.clipsToBounds = YES;
                    }
                    return cell;
                }

                case 1: 
                {
                    HPTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

                    if( cell == nil ) 
                    {
                        cell = [[HPTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SwitchCell"];
                        cell.textLabel.text = @"Force iPX Dock";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                        cell.accessoryView = switchView;
                        [switchView setOn:[[HPManager sharedManager] currentLoadoutModernDock] animated:NO];
                        [switchView addTarget:self action:@selector(modernDockSwitchChanged:) forControlEvents:UIControlEventValueChanged];

                        //[cell.layer setCornerRadius:10];

                        [cell setBackgroundColor: [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:0.4]];//rgb(38, 37, 42)];
                        //Border Color and Width
                        [cell.layer setBorderColor:[UIColor blackColor].CGColor];
                        [cell.layer setBorderWidth:0];

                        //Set Text Col
                        cell.textLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];
                        cell.detailTextLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];

                        cell.clipsToBounds = YES;
                    }
                    return cell;
                }
            }
        }
        case 2: 
        {
            switch ( [indexPath row] ) 
            {
                case 0: 
                {
                    static NSString *CellIdentifier = @"Cell";
                    HPTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (!cell) 
                    {
                        cell = [[HPTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
                    }
                    
                    cell.textLabel.text = [self titleForRowAtIndexPath:indexPath];
                    
                    //[cell.layer setCornerRadius:10];

                    [cell setBackgroundColor: [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:0.4]];//rgb(38, 37, 42)];
                    //Border Color and Width
                    [cell.layer setBorderColor:[UIColor blackColor].CGColor];
                    [cell.layer setBorderWidth:0];

                    //Set Text Col
                    cell.textLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];
                    cell.detailTextLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];

                    cell.clipsToBounds = YES;
                    cell.hidden = NO;

                    return cell;
                }

                case 1: 
                {
                    HPTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

                    if( cell == nil ) 
                    {
                        cell = [[HPTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SwitchCell"];
                        cell.textLabel.text = @"App Switcher Disables Editor";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                        cell.accessoryView = switchView;
                        [switchView setOn:[[HPManager sharedManager] switcherDisables] animated:NO];
                        [switchView addTarget:self action:@selector(switcherSwitchChanged:) forControlEvents:UIControlEventValueChanged];

                        //[cell.layer setCornerRadius:10];

                        [cell setBackgroundColor: [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:0.4]];//rgb(38, 37, 42)];
                        //Border Color and Width
                        [cell.layer setBorderColor:[UIColor blackColor].CGColor];
                        [cell.layer setBorderWidth:0];

                        //Set Text Col
                        cell.textLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];
                        cell.detailTextLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];

                        cell.clipsToBounds = YES;
                    }
                    return cell;
                }
                case 2: 
                {
                    HPTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

                    if( cell == nil ) 
                    {
                        cell = [[HPTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SwitchCell"];
                        cell.textLabel.text = @"Update V. Spacing W/ Rows";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                        cell.accessoryView = switchView;
                        [switchView setOn:[[HPManager sharedManager] vRowUpdates] animated:NO];
                        [switchView addTarget:self action:@selector(vRowSwitchChanged:) forControlEvents:UIControlEventValueChanged];

                        //[cell.layer setCornerRadius:10];

                        [cell setBackgroundColor: [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:0.4]];//rgb(38, 37, 42)];
                        //Border Color and Width
                        [cell.layer setBorderColor:[UIColor blackColor].CGColor];
                        [cell.layer setBorderWidth:0];

                        //Set Text Col
                        cell.textLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];
                        cell.detailTextLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];

                        cell.clipsToBounds = YES;
                    }
                    return cell;
                }
                case 3: 
                {

                    static NSString *CellIdentifier = @"Cell";
                    HPTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    if (!cell) 
                    {
                        cell = [[HPTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
                    }
                    
                    cell.textLabel.text = @"Respring";
                    
                    //[cell.layer setCornerRadius:10];

                    [cell setBackgroundColor: [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:0.4]];//rgb(38, 37, 42)];
                    //Border Color and Width
                    [cell.layer setBorderColor:[UIColor blackColor].CGColor];
                    [cell.layer setBorderWidth:0];

                    //Set Text Col
                    cell.textLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];
                    cell.detailTextLabel.textColor = [UIColor whiteColor];//[prefs colorForKey:@"textTint"];

                    cell.clipsToBounds = YES;
                    cell.hidden = NO;

                    return cell;
                    
                }
            }
        }
        break;
    }
    return nil;
}

- (void)switcherSwitchChanged:(id)sender 
{
    UISwitch *switchControl = sender;
    [[HPManager sharedManager] setSwitcherDisables:switchControl.on];
}

- (void)vRowSwitchChanged:(id)sender 
{
    UISwitch *switchControl = sender;
    [[HPManager sharedManager] setVRowUpdates:switchControl.on];
}

- (void)dockbGSwitchChanged:(id)sender 
{
    UISwitch *switchControl = sender;
    [[HPManager sharedManager] setCurrentLoadoutShouldHideDockBG:switchControl.on];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HPLayoutDockView" object:nil];
}

- (void)modernDockSwitchChanged:(id)sender 
{
    UISwitch *switchControl = sender;
    [[HPManager sharedManager] setCurrentLoadoutModernDock:switchControl.on];
}

- (void)iconLabelSwitchChanged:(id)sender 
{
    UISwitch *switchControl = sender;
    [[HPManager sharedManager] setCurrentLoadoutShouldHideIconLabels:switchControl.on forLocation:@"SBIconLocationRoot"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HPResetIconViews" object:nil];
}

- (void)iconBadgeSwitchChanged:(id)sender 
{
    UISwitch *switchControl = sender;
    [[HPManager sharedManager] setCurrentLoadoutShouldHideIconBadges:switchControl.on  forLocation:@"SBIconLocationRoot"];[[NSNotificationCenter defaultCenter] postNotificationName:@"HPResetIconViews" object:nil];
}

- (void)iconLabelFolderSwitchChanged:(id)sender 
{
    UISwitch *switchControl = sender;
    [[HPManager sharedManager] setCurrentLoadoutShouldHideIconLabels:switchControl.on  forLocation:@"SBIconLocationFolder"];[[NSNotificationCenter defaultCenter] postNotificationName:@"HPResetIconViews" object:nil];
}

#pragma mark - Table View Delegate



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            break;
        case 1: //"Yes" pressed
            [[EditorManager sharedManager] resetAllValuesToDefaults];
            break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aye,"
                                                                    message:@"Are you sure you want to reset everything?"
                                                                delegate:self
                                                        cancelButtonTitle:@"Nah"
                                                        otherButtonTitles:@"Yes", nil];
                    [alert show];
                    break;
                }
                case 3: {
                    
	  pid_t pid;
    const char* args[] = {"killall", "backboardd", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
                    break;
                }
            }
            break;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor clearColor];

    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];

    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
}

@end
