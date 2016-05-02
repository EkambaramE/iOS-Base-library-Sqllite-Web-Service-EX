//
//  ViewController.m
//  WebServiceEx
//
//  Created by EkambaramE on 21/08/15.
//  Copyright (c) 2015 EkambaramE. All rights reserved.
//

#import "ViewController.h"
#import "ServerHandler.h"
#import "DataOperation.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UITabBarDelegate,ServerHandlerDelegate,DataOperationDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSDictionary *getDict;
@property (strong,nonatomic) NSDictionary *postDict;
@property (strong,nonatomic) NSOperationQueue *myQueue;
@property (strong,nonatomic) NSArray *finalResult;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.postDict = [[NSDictionary alloc]init];
    self.getDict = [[NSDictionary alloc]init];
    self.finalResult = [NSArray array];
    
#pragma mark - Get Request
    
    NSString *getURL = @"http://192.168.1.138:9001/Azzimov_dev/v2.1/app/index.php/friends/5doujb0m4psXNsTwihDLP56V7P5.E6gmKXCXlerKw97xgwYXYlZ05drp3FDiA~TM";
    ServerHandler *getHandler = [[ServerHandler alloc]initWithURL:getURL withRequestParameter:@"" andRequestType:@"GET" andTimeout:60 andPostDict:nil];
    
#pragma mark - Post Request
    
    NSMutableDictionary *myDict = [[NSMutableDictionary alloc]init];
    [myDict setValue:@"5doujb0m4psY1m9vReXkBDC69sqXg6Blrye4oUnUOFk-" forKey:@"userId"];
    [myDict setValue:@"25" forKey:@"userAge"];
    [myDict setValue:@"May be Im Amazed!" forKey:@"aboutMeText"];
    [myDict setValue:@"Coding" forKey:@"interest"];
    
    NSString *postURl = @"http://192.168.1.138:9001/azzimov_dev/v2.1/app/index.php/updateUserProfile";
    ServerHandler *postHandler = [[ServerHandler alloc]initWithURL:postURl withRequestParameter:@"" andRequestType:@"POST" andTimeout:60 andPostDict:myDict];
    
    //  postHandler.queuePriority = NSOperationQueuePriorityVeryHigh;
    
  postHandler.delegate = self;
    getHandler.delegate = self;
    
    
     [getHandler addDependency:postHandler]; // setting dependencies betten operaion
    
    
    self.myQueue = [[NSOperationQueue alloc] init]; //Its running on different thread
    [self.myQueue setQualityOfService:NSQualityOfServiceBackground];
    [self.myQueue addOperation:getHandler];
    [self.myQueue addOperation:postHandler];
    
    // [getHandler start]; //If single operation we can use this
}

#pragma mark - ServerHandlerDelegate

-(void)serverHandler:(ServerHandler *)serverHandler andRequestStatus:(BOOL)status andReponseData:(id)responseData andErrorMessage:(NSString *)errorMessage
{
    //  NSLog(@"%@ AND ERROR MESSAGE %@",responseData,errorMessage);
    
    if (responseData){
    
    if ([responseData isKindOfClass:[NSDictionary class]]) { // JSON Object
        
        if([[responseData valueForKey:@"status"] boolValue]) {
            
            if ([[responseData valueForKey:@"referer"] isEqualToString:@"Member informations"] ) {
                
                //                NSArray *friendsListArray = [[NSArray alloc]init];   //Incase json Object Array
                //                friendsListArray = [responseData valueForKey:@"data"];
                //                if(friendsListArray.count>0)
                //                {
                //                    for(NSDictionary *dataDict in friendsListArray) {
                //
                //                    }
                //
                //                }
               // NSDictionary *getDict = [[NSDictionary alloc]init];
                self.getDict = [responseData valueForKey:@"data"];
                
                NSLog(@"Member informations : %@",self.getDict);
                
    #pragma mark - Database Operation
                
                
                NSString *postQuery = @"CREATE TABLE IF NOT EXISTS POST_DATABASE(STATUS TEXT)";
                
                DataOperation *postDataOperation = [[DataOperation alloc]initWithQuery:postQuery andOperation:CREATE];
                postDataOperation.delegate = self;
                
                
                NSString *getQuery = @"CREATE TABLE IF NOT EXISTS GET_DATABASE(FNAME TEXT,LNAME TEXT,ABOUT TEXT,INTEREST TEXT,LASTACTIVE TEXT,PROFILEIMG TEXT,UID TEXT,AGE TEXT)";
                
                DataOperation *getDataOperation = [[DataOperation alloc]initWithQuery:getQuery andOperation:CREATE];
                getDataOperation.delegate = self;

                
                
                NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO GET_DATABASE (FNAME,LNAME,ABOUT,INTEREST,LASTACTIVE,PROFILEIMG,UID,AGE) VALUES('%@','%@','%@','%@','%@','%@','%@','%@')",[self.getDict valueForKey:@"userFname"],[self.getDict valueForKey:@"userLname"],[self.getDict valueForKey:@"aboutMeText"],[self.getDict valueForKey:@"interest"],[self.getDict valueForKey:@"lastActiveTimestamp"],[self.getDict valueForKey:@"profileImagePath"],[self.getDict valueForKey:@"userId"],[self.getDict valueForKey:@"userAge"]];
                                         //[self.getDict valueForKey:@"userFname"],[self.getDict valueForKey:@"userLname"],[self.getDict valueForKey:@"aboutMeText"],[self.getDict valueForKey:@"interest"],[self.getDict valueForKey:@"lastActiveTimestamp"],[self.getDict valueForKey:@"profileImagePath"],[self.getDict valueForKey:@"userId"],[self.getDict valueForKey:@"userAge"]];
                
               // NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO GET_DATABASE VALUES('%@','%@','%@','%@','%@','%@','%@',%d)",[self.getDict valueForKey:@"userFname"],[self.getDict valueForKey:@"userLname"],[self.getDict valueForKey:@"aboutMeText"],[self.getDict valueForKey:@"interest"],[self.getDict valueForKey:@"lastActiveTimestamp"],[self.getDict valueForKey:@"profileImagePath"],[self.getDict valueForKey:@"userId"],[[self.getDict valueForKey:@"userAge"] intValue]];

                NSLog(@"Insert Query %@",insertQuery);
                
                DataOperation *insertDataOperation = [[DataOperation alloc]initWithQuery:insertQuery andOperation:INSERT];
                insertDataOperation.delegate = self;
                [insertDataOperation addDependency:getDataOperation];
                
                NSString *selectQuery = @"SELECT * FROM GET_DATABASE";
                
                DataOperation *selectDataOperation = [[DataOperation alloc]initWithQuery:selectQuery andOperation:SELECT];
                selectDataOperation.delegate = self;
                [selectDataOperation addDependency:insertDataOperation];
                
                
                [self.myQueue addOperation:getDataOperation];
                [self.myQueue addOperation:insertDataOperation];
                [self.myQueue addOperation:selectDataOperation];
                
                
            }
            
        } if([[responseData valueForKey:@"referer"] isEqualToString:@"Update Member Information"]){
            
            //NSDictionary *postDict = [[NSDictionary alloc]init];
            self.postDict = [responseData valueForKey:@"data"];
            NSLog(@"Update Member Information: %@",[self.postDict valueForKey:@"message"]);
        }
        
    }  else if ([responseData isKindOfClass:[NSArray class]]) { // JSON Array
        
        
    }
    [self.tableView reloadData];
    }else{
        NSLog(@"Error: %@",errorMessage);
    }
}


#pragma mark - DatabaseHandlerDelegate

- (void)dataOperation:(DataOperation *)dataOperation OperationStatus:(BOOL)operationStatus resultDataArray:(NSArray *)dataArray andItsCount:(int)dataCount
{
    if (operationStatus && dataArray) // select, count
    {
        NSLog(@" selected Data Array %@",dataArray);
        self.finalResult = dataArray;
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        });
    }
    else if (operationStatus) // Insert , Create, Delete, Update
    {
        
    } else
    {
        // error
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    
    NSDictionary *dataDict = (NSDictionary *)self.finalResult[indexPath.row];
    cell.textLabel.text =[dataDict valueForKey:@"FNAME"];
    cell.detailTextLabel.text = [dataDict valueForKey:@"ABOUT"];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.finalResult count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

@end
