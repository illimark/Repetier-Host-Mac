/*
 Copyright 2011 repetier repetierdev@googlemail.com
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */


#import "PrinterConfiguration.h"
#import "StringUtil.h"
#import "ThreadedNotification.h"
#import "RHAppDelegate.h"
#import "RHManualControl.h"
#import "GCodeEditorController.h"
#import "RHOpenGLView.h"
#import "PrinterConnection.h"

@implementation PrinterConfiguration

@synthesize name;
@synthesize port;
@synthesize startCode;
@synthesize endCode;
@synthesize filterPrg;

-(id)init {
    if((self = [super init])) {
        [self setName:@"Default"];
        [self setPort:@"None"];
        baud = 57600;
        databits = 8;
        parity = kAMSerialParityNone;
        stopBits = kAMSerialStopBitsOne;
        width = 200;
        height = 100;
        depth = 200;
        afterJobGoDispose = YES;
        afterJobDisableExtruder = YES;
        afterJobDisableHeatedBed = YES;
        pingPongMode = NO;
        receiveCacheSize = 63;
        autocheckTemp = YES;
        dontLogM105 = YES;
        autocheckInterval = 1;
        disposeZ = 0;
        disposeX = 135;
        disposeY = 0;
        travelFeedrate = 4800;
        travelZFeedrate = 100;
        defaultExtruderTemp = 200;
        defaultHeatedBedTemp = 55;
        protocol = 0;
        pingPongMode = NO;
        okAfterResend = YES;
        hasDumpArea = YES;
        dumpAreaLeft = 125;
        dumpAreaFront = 0;
        dumpAreaWidth = 40;
        dumpAreaDepth = 22;
        enableFilterPrg = NO;
        [self setStartCode:@""];
        [self setEndCode:@""];
        [self setFilterPrg:@""];
    }
    return self;
}
-(void)dealloc {
    [name release];
    [port release];
    [super dealloc];
}
-(PrinterConfiguration*)initLoadFromRepository:(NSString*)confname {
    NSString *b = [@"printer." stringByAppendingString:confname];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    self=[self init];
    [self initDefaultsRepository:confname]; // Make sure we have data to read
    [self setName:confname];
    [self setPort:[d objectForKey:[b stringByAppendingString:@".port"]]];
    baud = (int)[d integerForKey:[b stringByAppendingString:@".baud"]];
    parity = (int)[d integerForKey:[b stringByAppendingString:@".parity"]];
    stopBits = (int)[d integerForKey:[b stringByAppendingString:@".stopBits"]];
    databits = (int)[d integerForKey:[b stringByAppendingString:@".databits"]];
    protocol = (int)[d integerForKey:[b stringByAppendingString:@".protocol"]];
    autocheckInterval = (int)[d integerForKey:[b stringByAppendingString:@".autocheckInterval"]];
    defaultExtruderTemp = (int)[d integerForKey:[b stringByAppendingString:@".defaultExtruderTemp"]];
    defaultHeatedBedTemp = (int)[d integerForKey:[b stringByAppendingString:@".defaultHeatedBedTemp"]];
    receiveCacheSize = (int)[d integerForKey:[b stringByAppendingString:@".receiveCacheSize"]];
    afterJobGoDispose = [d boolForKey:[b stringByAppendingString:@".afterJobGoDispose"]];
    afterJobDisableExtruder = [d boolForKey:[b stringByAppendingString:@".afterJobDisableExtruder"]];
    afterJobDisableHeatedBed = [d boolForKey:[b stringByAppendingString:@".afterJobDisableHeatedBed"]];
    dontLogM105 = [d boolForKey:[b stringByAppendingString:@".dontLogM105"]];
    autocheckTemp = [d boolForKey:[b stringByAppendingString:@".autocheckTemp"]];
    okAfterResend = [d boolForKey:[b stringByAppendingString:@".okAfterResend"]];
    pingPongMode = [d boolForKey:[b stringByAppendingString:@".pingPongMode"]];
    width = [d doubleForKey:[b stringByAppendingString:@".width"]];
    height = [d doubleForKey:[b stringByAppendingString:@".height"]];
    depth = [d doubleForKey:[b stringByAppendingString:@".depth"]];
    travelFeedrate = [d doubleForKey:[b stringByAppendingString:@".travelFeedrate"]];
    travelZFeedrate = [d doubleForKey:[b stringByAppendingString:@".travelZFeedrate"]];
    disposeX = [d doubleForKey:[b stringByAppendingString:@".disposeX"]];
    disposeY = [d doubleForKey:[b stringByAppendingString:@".disposeY"]];
    disposeZ = [d doubleForKey:[b stringByAppendingString:@".disposeZ"]];
    [self setStartCode:[d stringForKey:[b stringByAppendingString:@".startCode"]]];
    [self setEndCode:[d stringForKey:[b stringByAppendingString:@".endCode"]]];
    [self setFilterPrg:[d stringForKey:[b stringByAppendingString:@".filterPrg"]]];
    enableFilterPrg = [d boolForKey:[b stringByAppendingString:@".enableFilterPrg"]];
    hasDumpArea = [d boolForKey:[b stringByAppendingString:@".hasDumpArea"]];
    dumpAreaLeft = [d doubleForKey:[b stringByAppendingString:@".dumpAreaLeft"]];
    dumpAreaFront = [d doubleForKey:[b stringByAppendingString:@".dumpAreaFront"]];
    dumpAreaWidth = [d doubleForKey:[b stringByAppendingString:@".dumpAreaWidth"]];
    dumpAreaDepth = [d doubleForKey:[b stringByAppendingString:@".dumpAreaDepth"]];
    return self;
}
-(void)initDefaultsRepository:(NSString*)confname {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    NSString *b = [@"printer." stringByAppendingString:confname];
    [d setObject:port forKey:[b stringByAppendingString:@".port"]];
    [d setObject:[NSNumber numberWithInt:baud] forKey:[b stringByAppendingString:@".baud"]];
    [d setObject:[NSNumber numberWithInt:parity] forKey:[b stringByAppendingString:@".parity"]];
    [d setObject:[NSNumber numberWithInt:stopBits] forKey:[b stringByAppendingString:@".stopBits"]];
    [d setObject:[NSNumber numberWithInt:databits] forKey:[b stringByAppendingString:@".databits"]];
    [d setObject:[NSNumber numberWithInt:protocol] forKey:[b stringByAppendingString:@".protocol"]];
    [d setObject:[NSNumber numberWithInt:autocheckInterval] forKey:[b stringByAppendingString:@".autocheckInterval"]];
    [d setObject:[NSNumber numberWithInt:defaultExtruderTemp] forKey:[b stringByAppendingString:@".defaultExtruderTemp"]];
    [d setObject:[NSNumber numberWithInt:defaultHeatedBedTemp] forKey:[b stringByAppendingString:@".defaultHeatedBedTemp"]];
    [d setObject:[NSNumber numberWithInt:receiveCacheSize] forKey:[b stringByAppendingString:@".receiveCacheSize"]];
    [d setObject:[NSNumber numberWithBool:afterJobGoDispose] forKey:[b stringByAppendingString:@".afterJobGoDispose"]];
    [d setObject:[NSNumber numberWithBool:afterJobDisableExtruder] forKey:[b stringByAppendingString:@".afterJobDisableExtruder"]];
    [d setObject:[NSNumber numberWithBool:afterJobDisableHeatedBed] forKey:[b stringByAppendingString:@".afterJobDisableHeatedBed"]];
    [d setObject:[NSNumber numberWithBool:dontLogM105] forKey:[b stringByAppendingString:@".dontLogM105"]];
    [d setObject:[NSNumber numberWithBool:autocheckTemp] forKey:[b stringByAppendingString:@".autocheckTemp"]];
    [d setObject:[NSNumber numberWithBool:okAfterResend] forKey:[b stringByAppendingString:@".okAfterResend"]];
    [d setObject:[NSNumber numberWithBool:pingPongMode] forKey:[b stringByAppendingString:@".pingPongMode"]];
    [d setObject:[NSNumber numberWithDouble:width] forKey:[b stringByAppendingString:@".width"]];
    [d setObject:[NSNumber numberWithDouble:height] forKey:[b stringByAppendingString:@".height"]];
    [d setObject:[NSNumber numberWithDouble:depth] forKey:[b stringByAppendingString:@".depth"]];
    [d setObject:[NSNumber numberWithDouble:travelFeedrate] forKey:[b stringByAppendingString:@".travelFeedrate"]];
    [d setObject:[NSNumber numberWithDouble:travelZFeedrate] forKey:[b stringByAppendingString:@".travelZFeedrate"]];
    [d setObject:[NSNumber numberWithDouble:disposeX] forKey:[b stringByAppendingString:@".disposeX"]];
    [d setObject:[NSNumber numberWithDouble:disposeY] forKey:[b stringByAppendingString:@".disposeY"]];
    [d setObject:[NSNumber numberWithDouble:disposeZ] forKey:[b stringByAppendingString:@".disposeZ"]];
    [d setObject:@"" forKey:[b stringByAppendingString:@".startCode"]];
    [d setObject:@"" forKey:[b stringByAppendingString:@".endCode"]];
    [d setObject:@"" forKey:[b stringByAppendingString:@".filterPrg"]];
    [d setObject:[NSNumber numberWithBool:enableFilterPrg] forKey:[b stringByAppendingString:@".enableFilterPrg"]];
    
    // Some defaults for the gui
    [d setObject:[NSNumber numberWithDouble:100] forKey:@"fanSpeed"];
    [d setObject:[NSNumber numberWithBool:NO] forKey:@"debugEcho"];
    [d setObject:[NSNumber numberWithBool:YES] forKey:@"debugInfo"];
    [d setObject:[NSNumber numberWithBool:YES] forKey:@"debugErrors"];
    [d setObject:[NSNumber numberWithBool:NO] forKey:@"debugDryRun"];
    [d setObject:[NSNumber numberWithDouble:10] forKey:@"extruder.extrudeLength"];
    [d setObject:[NSNumber numberWithDouble:50] forKey:@"extruder.extrudeSpeed"];
    [d setObject:[NSNumber numberWithBool:YES] forKey:[b stringByAppendingString:@".hasDumpArea"]];
    [d setObject:[NSNumber numberWithDouble:125] forKey:[b stringByAppendingString:@".dumpAreaLeft"]];
    [d setObject:[NSNumber numberWithDouble:0] forKey:[b stringByAppendingString:@".dumpAreaFront"]];
    [d setObject:[NSNumber numberWithDouble:40] forKey:[b stringByAppendingString:@".dumpAreaWidth"]];
    [d setObject:[NSNumber numberWithDouble:22] forKey:[b stringByAppendingString:@".dumpAreaDepth"]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:d];
    //[d release];
}
-(void)saveToRepository{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *b = [@"printer." stringByAppendingString:name];
    [d setObject:port forKey:[b stringByAppendingString:@".port"]];
    [d setInteger:baud forKey:[b stringByAppendingString:@".baud"]];
    [d setInteger:parity forKey:[b stringByAppendingString:@".parity"]];
    [d setInteger:stopBits forKey:[b stringByAppendingString:@".stopBits"]];
    [d setInteger:databits forKey:[b stringByAppendingString:@".databits"]];
    [d setInteger:protocol forKey:[b stringByAppendingString:@".protocol"]];
    [d setInteger:autocheckInterval forKey:[b stringByAppendingString:@".autocheckInterval"]];
    [d setInteger:defaultExtruderTemp forKey:[b stringByAppendingString:@".defaultExtruderTemp"]];
    [d setInteger:defaultHeatedBedTemp forKey:[b stringByAppendingString:@".defaultHeatedBedTemp"]];
    [d setInteger:receiveCacheSize forKey:[b stringByAppendingString:@".receiveCacheSize"]];
    [d setBool:afterJobGoDispose forKey:[b stringByAppendingString:@".afterJobGoDispose"]];
    [d setBool:afterJobDisableExtruder forKey:[b stringByAppendingString:@".afterJobDisableExtruder"]];
    [d setBool:afterJobDisableHeatedBed forKey:[b stringByAppendingString:@".afterJobDisableHeatedBed"]];
    [d setBool:autocheckTemp forKey:[b stringByAppendingString:@".autocheckTemp"]];
    [d setBool:okAfterResend forKey:[b stringByAppendingString:@".okAfterResend"]];
    [d setBool:pingPongMode forKey:[b stringByAppendingString:@".pingPongMode"]];
    [d setBool:dontLogM105 forKey:[b stringByAppendingString:@".dontLogM105"]];
    [d setDouble:width forKey:[b stringByAppendingString:@".width"]];
    [d setDouble:height forKey:[b stringByAppendingString:@".height"]];
    [d setDouble:depth forKey:[b stringByAppendingString:@".depth"]];
    [d setDouble:travelFeedrate forKey:[b stringByAppendingString:@".travelFeedrate"]];
    [d setDouble:travelZFeedrate forKey:[b stringByAppendingString:@".travelZFeedrate"]];
    [d setDouble:disposeX forKey:[b stringByAppendingString:@".disposeX"]];
    [d setDouble:disposeY forKey:[b stringByAppendingString:@".disposeY"]];
    [d setDouble:disposeZ forKey:[b stringByAppendingString:@".disposeZ"]];
    [d setObject:startCode forKey:[b stringByAppendingString:@".startCode"]];
    [d setObject:endCode forKey:[b stringByAppendingString:@".endCode"]];
    [d setObject:filterPrg forKey:[b stringByAppendingString:@".filterPrg"]];
    [d setBool:enableFilterPrg forKey:[b stringByAppendingString:@".enableFilterPrg"]];
    [d setBool:hasDumpArea forKey:[b stringByAppendingString:@".hasDumpArea"]];
    [d setDouble:dumpAreaLeft forKey:[b stringByAppendingString:@".dumpAreaLeft"]];
    [d setDouble:dumpAreaFront forKey:[b stringByAppendingString:@".dumpAreaFront"]];
    [d setDouble:dumpAreaWidth forKey:[b stringByAppendingString:@".dumpAreaWidth"]];
    [d setDouble:dumpAreaDepth forKey:[b stringByAppendingString:@".dumpAreaDepth"]];
    
}
+(void)initPrinter {
    printerConfigurations = [NSMutableArray new];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"" forKey:@"currentPrinter"];
    [dict setObject:@"" forKey:@"printerList"];
    [d registerDefaults:dict];
    NSString *current = [d objectForKey:@"currentPrinter"];
    NSString *sPrinterList = [d objectForKey:@"printerList"];
    NSMutableArray *plist = [StringUtil explode:sPrinterList sep:@";"];
    if([plist count]==0) { // Make default printer
        currentPrinterConfiguration = [[PrinterConfiguration alloc] init];
        [currentPrinterConfiguration saveToRepository];
        [d setObject:[currentPrinterConfiguration name] forKey:@"currentPrinter"];
        [d setObject:[currentPrinterConfiguration name] forKey:@"printerList"];
    } else {
        for(NSString* s in plist) {
            PrinterConfiguration *pconf = [[PrinterConfiguration alloc] initLoadFromRepository:s];
            [printerConfigurations addObject:pconf];
            [pconf release];
        }
        currentPrinterConfiguration = [PrinterConfiguration findPrinter:current];
        [currentPrinterConfiguration retain];
    }    
}
+(PrinterConfiguration*) findPrinter:(NSString *)name {
    for (PrinterConfiguration* conf in printerConfigurations) {
		if([[conf name] isEqualToString:name])
            return conf;
	}  
    return nil;
}
+(void)fillFormsWithCurrent {
    if(!connection->connected) 
        [connection setConfig:currentPrinterConfiguration];
    [app->gcodeView setContent:1 text:currentPrinterConfiguration->startCode];
    [app->gcodeView setContent:2 text:currentPrinterConfiguration->endCode];
    [app->manualControl->extruderTempText setIntValue:currentPrinterConfiguration->defaultExtruderTemp];
    [app->manualControl->heatedBedTempText setIntValue:currentPrinterConfiguration->defaultHeatedBedTemp];
    [app->openGLView redraw];
}
+(PrinterConfiguration*)selectPrinter:(NSString *)name {
    currentPrinterConfiguration = [self findPrinter:name];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:name forKey:@"currentPrinter"];
    return currentPrinterConfiguration;
}
+(BOOL)createPrinter:(NSString *)name {
    PrinterConfiguration *c = [self findPrinter:name];
    if(c!=nil) return NO;
    c = [[PrinterConfiguration alloc] initLoadFromRepository:currentPrinterConfiguration.name];
    [c setName:name];
    [printerConfigurations addObject:c];
    [c release];
    // Update printer list
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:printerConfigurations.count];
    for(PrinterConfiguration *conf in printerConfigurations)
        [arr addObject:conf->name];
    NSString *list = [StringUtil implode:arr sep:@";"];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:list forKey:@"printerList"];
    [ThreadedNotification notifyNow:@"RHPrinterConfigCreated" object:name];
    [self selectPrinter:name];
    return YES;
}
+(BOOL)deletePrinter:(NSString *)name {
    if(printerConfigurations.count<2) return NO;
    PrinterConfiguration *dconf = [self findPrinter:name];
    if(dconf==nil) return NO;
    [printerConfigurations removeObject:dconf];
    if(currentPrinterConfiguration==dconf)
        [self selectPrinter:[printerConfigurations objectAtIndex:0]];
    // Update printer list
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:printerConfigurations.count];
    for(PrinterConfiguration *c in printerConfigurations)
        [arr addObject:c->name];
    NSString *list = [StringUtil implode:arr sep:@";"];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:list forKey:@"printerList"];   
    [ThreadedNotification notifyNow:@"RHPrinterConfigRemoved" object:name];
    return YES;
}
@end

PrinterConfiguration *currentPrinterConfiguration = nil;
NSMutableArray* printerConfigurations = nil;
