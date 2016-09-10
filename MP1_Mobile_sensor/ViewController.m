//
//  ViewController.m
//  MP1_Mobile_sensor
//
//  Created by Yifang Zhang on 9/3/16.
//  Copyright © 2016 Yifang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <MFMailComposeViewControllerDelegate>



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init the dictionaries
    self.collectAcc = [[NSMutableArray alloc] init];
    [self.collectAcc addObject:@"timestamp,Acc_x,Acc_y,Acc_z\n"];
    self.collectGyro = [[NSMutableArray alloc] init];
    [self.collectGyro addObject:@"timestamp,Gyro_x,Gyro_y,Gyro_z\n"];
    self.collectMag = [[NSMutableArray alloc] init];
    [self.collectMag addObject:@"timestamp,Mag_x,Mag_y,Mag_z\n"];
    self.collectTime = [[NSMutableArray alloc] init];
    
    // init the motion manager
    self.motionManager = [[CMMotionManager alloc] init];
    ///////HERE

    
    self.acc_x.text = @"0";
    self.acc_y.text = @"0";
    self.acc_z.text = @"0";
    self.gyro_x.text = @"0";
    self.gyro_y.text = @"0";
    self.gyro_z.text = @"0";
    self.mag_x.text = @"0";
    self.mag_y.text = @"0";
    self.mag_z.text = @"0";
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.motionManager.accelerometerUpdateInterval = 0.02;
    self.motionManager.gyroUpdateInterval = 0.02;
    self.motionManager.magnetometerUpdateInterval = 0.02;
    
    
    // set the time to the correct format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yy_HH-mm-ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    self.timestamp.text = [dateFormatter stringFromDate:[NSDate date]];

    // init with flag as false
    self.flag = false;
    
    // init the temp file of csv
    self.tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", self.timestamp.text]];
    NSLog(self.tempFilePath);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)sum:(id)sender {
    
    /*int sum = 0;
    
    for(NSInteger i = 1; i <self.collectAcc.count; i++){
        sum = sum + (int)[[self.collectAcc objectAtIndex:i] objectAtIndex:2];
    }
    
    int avg_acc_y = sum/self.collectAcc.count;/*
    /*sum = 0;
    for(NSInteger i = 1; i <self.collectAcc.count; i++){
        sum = sum + (int)[[self.collectAcc objectAtIndex:i] objectAtIndex:3];
    }
    
    int avg_acc_z = sum/self.collectAcc.count;*/
    NSLog(@"%lu", (unsigned long)self.collectAcc.count);
    NSString * curAcc = (NSString *)[self.collectAcc objectAtIndex:1];
    NSLog(@"%@", curAcc);
    NSArray * curAccSep = [curAcc componentsSeparatedByString:@","];
    NSLog(@"%@", (NSString *)[curAccSep objectAtIndex:0]);
    NSLog(@"%f", [(NSString *)[curAccSep objectAtIndex:1] floatValue]);
    NSLog(@"%f", [(NSString *)[curAccSep objectAtIndex:2] floatValue]);
    NSLog(@"%f", [(NSString *)[curAccSep objectAtIndex:3] floatValue]);
//    NSInteger sum_int = [sum integerValue];
//    NSUInteger arrayLength = [acc_x count];
//    NSInteger avg = sum_int/arrayLength;
//    int asdf = 0;
//    if(arrayLength ==0){
    //self.result.text = [NSString stringWithFormat:@"%d%d", avg_acc_y, avg_acc_z];
    
    
    //NSMutableArray *y_vals = [[NSMutableArray alloc] init];
    double y_vals [self.collectAcc.count-1];
    double z_vals [self.collectAcc.count-1];

    double y_sum = 0;
    double z_sum = 0;
    
    for(NSInteger i = 1; i <self.collectAcc.count; i++){
        
        NSString * curAcc_1 = (NSString *)[self.collectAcc objectAtIndex:i];
        NSArray * curAccSep_1 = [curAcc_1 componentsSeparatedByString:@","];
        
        y_vals [i-1] = [(NSString *)[curAccSep_1 objectAtIndex:2] floatValue];
        y_sum = y_sum + y_vals[i-1];
        
        NSString * curAcc_2 = (NSString *)[self.collectAcc objectAtIndex:i];
        NSArray * curAccSep_2 = [curAcc_2 componentsSeparatedByString:@","];
        
        z_vals [i-1] = [(NSString *)[curAccSep_2 objectAtIndex:3] floatValue];
        z_sum = z_sum + z_vals[i-1];

    }
    
    double y_avg = y_sum/(double)self.collectAcc.count;
    double z_avg = z_sum/(double)self.collectAcc.count;
    
    double y_std = 0;
    double z_std = 0;
    
    for(NSInteger j=0; j<(self.collectAcc.count-1); ++j){
        
        y_std = y_std + (y_vals[j]-y_avg)*(y_vals[j]-y_avg);
        z_std = z_std + (z_vals[j]-z_avg)*(z_vals[j]-z_avg);
    }
    
    y_std = sqrt(y_std/(double)self.collectAcc.count);
    z_std = sqrt(z_std/(double)self.collectAcc.count);

    NSLog(@"y average: %f", y_avg);
    NSLog(@"y std: %f", y_std);
    NSLog(@"z std: %f", z_std);
    
    
    
}


- (IBAction)switcher:(id)sender {
    if(self.flag == false){
        self.flag = true;
        //[self.motionManager startAccelerometerUpdates];
        [
        self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
            withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error)
        {
            [self outputAccelertionData:accelerometerData.acceleration];
            if(error){
                NSLog(@"%@", error);
            }
        }
        ];
        [
         self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]withHandler:^(CMGyroData *gyroData, NSError *error) {
             [self outputGyroData:gyroData.rotationRate];
             if(error){
                 NSLog(@"%@", error);
             }
         }
         
         ];
        
        [
         self.motionManager startMagnetometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
             [self outputMagData:magnetometerData.magneticField];
             if(error){
                 NSLog(@"%@", error);
             }
         }
         
         ];
    }
    else{
        [self.motionManager stopAccelerometerUpdates];
        [self.motionManager stopGyroUpdates];
        [self.motionManager stopMagnetometerUpdates];
        self.flag = false;
        NSLog(@"%lu", (unsigned long)[self.collectAcc count]);
    }

}

- (IBAction)sendMail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        // device is configured to send mail
    
        
        NSString * writeString = @"";
        for (NSString * acc in self.collectAcc) {
            writeString = [NSString stringWithFormat:@"%@%@", writeString, acc];
        }
        for (NSString * gyro in self.collectGyro) {
            writeString = [NSString stringWithFormat:@"%@%@", writeString, gyro];
        }
        for (NSString * mag in self.collectMag) {
            writeString = [NSString stringWithFormat:@"%@%@", writeString, mag];
        }
        NSData* writeData = [writeString dataUsingEncoding:NSUTF8StringEncoding];
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setMessageBody:@"Here is some main text in the email!" isHTML:NO];
        [mailer setToRecipients:@[@"yifangzhang2009@gmail.com", @"aaronmann613348@gmail.com"]];
        [mailer setSubject:@"CSV File"];
        [mailer addAttachmentData:writeData
                         mimeType:@"text/csv"
                         fileName:@"FileName.csv"];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The Mail is not Avaliable"
                                                        message:@"You need open up the Mail app and set up account in order to use the mail sending functionality."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}


-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    self.acc_x.text = [NSString stringWithFormat:@"%f", acceleration.x];
    self.acc_y.text = [NSString stringWithFormat:@"%f", acceleration.y];
    self.acc_z.text = [NSString stringWithFormat:@"%f", acceleration.z];
    
    // set the time to the correct format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yy_HH-mm-ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    self.timestamp.text = [dateFormatter stringFromDate:[NSDate date]];
    [self.collectAcc addObject:[NSString stringWithFormat:@"%@,%@,%@,%@\n",self.timestamp.text, self.acc_x.text, self.acc_y.text, self.acc_z.text]];
}

-(void)outputGyroData:(CMRotationRate)rotationRate
{
    self.gyro_x.text = [NSString stringWithFormat:@"%f", rotationRate.x];
    self.gyro_y.text = [NSString stringWithFormat:@"%f", rotationRate.y];
    self.gyro_z.text = [NSString stringWithFormat:@"%f", rotationRate.z];
    
    
    // set the time to the correct format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yy_HH-mm-ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    self.timestamp.text = [dateFormatter stringFromDate:[NSDate date]];
    [self.collectGyro addObject:[NSString stringWithFormat:@"%@,%@,%@,%@\n", self.timestamp.text, self.gyro_x.text, self.gyro_y.text, self.gyro_z.text]];
}

-(void)outputMagData:(CMMagneticField) magneticField{
    self.mag_x.text = [NSString stringWithFormat:@"%f", magneticField.x];
    self.mag_y.text = [NSString stringWithFormat:@"%f", magneticField.y];
    self.mag_z.text = [NSString stringWithFormat:@"%f", magneticField.z];
    
    //[mag_x addObject: [NSString stringWithFormat:@"%f", magneticField.x]];
    
   
    // set the time to the correct format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yy_HH-mm-ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    self.timestamp.text = [dateFormatter stringFromDate:[NSDate date]];
    [self.collectMag addObject:[NSString stringWithFormat:@"%@,%@,%@,%@\n", self.timestamp.text, self.mag_x.text, self.mag_y.text, self.mag_z.text]];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
