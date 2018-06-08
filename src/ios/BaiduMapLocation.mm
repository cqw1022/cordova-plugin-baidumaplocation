//
//  BaiduMapLocation.mm
//
//  Created by LiuRui on 2017/2/25.
//

#import "BaiduMapLocation.h"

@implementation BaiduMapLocation

- (void)pluginInitialize
{
    NSDictionary *plistDic = [[NSBundle mainBundle] infoDictionary];
    NSString* IOS_KEY = [[plistDic objectForKey:@"BaiduMapLocation"] objectForKey:@"IOS_KEY"];
    
    
    [[[BMKMapManager alloc] init] start:IOS_KEY generalDelegate:self];
    
//    _data = [[NSMutableDictionary alloc] init];
    
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    
    _geoCodeSerch = [[BMKGeoCodeSearch alloc] init];
    _geoCodeSerch.delegate = self;
    
    self._is_verify_pass = false;
    self._is_open_location = false;
}

- (void)setCommandCallback:(CDVInvokedUrlCommand *) command
{
    self._callback_id = command.callbackId;
}

- (void)setRadarId:(CDVInvokedUrlCommand*)command
{
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    NSString *userId = nil;
    // check the params
    if (![params objectForKey:@"userId"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"userId参数错误"];
        return ;
    }
    userId = [params objectForKey:@"userId"];
    
    BMKRadarManager *_radarManager = [BMKRadarManager getRadarManagerInstance];
    _radarManager.userId = userId;
    self._radius = 8000;
    [_radarManager addRadarManagerDelegate:self];
    // _radarManager.startAutoUpload(5);
//    [BMKRadarManager releaseRadarManagerInstance];
    [self successWithCallbackID:command.callbackId];
}


//- (void)setRadarConfig:(CDVInvokedUrlCommand*)command
//{
//    NSDictionary *params = [command.arguments objectAtIndex:0];
//    if (!params)
//    {
//        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
//        return ;
//    }
//    
//    int radius = 8000;
//    // check the params
//    if (![params objectForKey:@"radius"])
//    {
//        [self failWithCallbackID:command.callbackId withMessage:@"userId参数错误"];
//        return ;
//    }
//    radius = [[params objectForKey:@"radius"] intValue];
//    
//    self._radius = radius;
//    
//}



- (void)getCurrentPosition:(CDVInvokedUrlCommand*)command
{
//    _execCommand = command;
    if (self._is_open_location){
        return;
    }
    self._is_near_by = false;
    [_locService startUserLocationService];
}


- (void)getNearBy:(CDVInvokedUrlCommand*)command
{
    //    _execCommand = command;
//    int radius = 8000;
    // check the params
    if (self._is_open_location){
        return;
    }
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    if (![params objectForKey:@"radius"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"radius参数错误"];
        return ;
    }
    self._is_near_by = true;
    self._radius = [[params objectForKey:@"radius"] intValue];
    [_locService startUserLocationService];
}

- (void)onGetPermissionState:(int)iError
{
    if(iError==0){
        self._is_verify_pass = true;
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"initSuccess" forKey:@"action_type"];
        
        [self commanCallback:params];
//        [self successWithCallbackID:self._callback_id withMessage:[self dictionaryToJson:params]];
    } else {
        self._is_verify_pass = false;
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"initFailed" forKey:@"action_type"];
        [params setValue:[NSString stringWithFormat:@"%d",iError] forKey:@"error_code"];
        
        [self commanCallback:params];
//        [self successWithCallbackID:self._callback_id withMessage:[self dictionaryToJson:params]];
    }
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//    if(_execCommand != nil)
//    {
        NSDate* time = userLocation.location.timestamp;
        NSNumber* latitude = [NSNumber numberWithDouble:userLocation.location.coordinate.latitude];
        NSNumber* longitude = [NSNumber numberWithDouble:userLocation.location.coordinate.longitude];
        NSNumber* radius = [NSNumber numberWithDouble:userLocation.location.horizontalAccuracy];
        NSString* title = userLocation.title;
        NSString* subtitle = userLocation.subtitle;
    
        NSMutableDictionary* _data = [[NSMutableDictionary alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
        [_data setValue:@"onLocation" forKey:@"action_type"];
        [_data setValue:[dateFormatter stringFromDate:time] forKey:@"time"];
        [_data setValue:latitude forKey:@"latitude"];
        [_data setValue:longitude forKey:@"longitude"];
        [_data setValue:radius forKey:@"radius"];
        [_data setValue:title forKey:@"title"];
        [_data setValue:subtitle forKey:@"subtitle"];
    
        [self commanCallback:_data];
    
        CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
        if (latitude!= 0  && longitude!= 0){
            pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
        }
    
        if (self._is_near_by) {
            BMKRadarNearbySearchOption *option = [[BMKRadarNearbySearchOption alloc] init];
            option.radius = self._radius;//检索半径
            option.sortType = BMK_RADAR_SORT_TYPE_DISTANCE_FROM_NEAR_TO_FAR;//排序方式
            option.centerPt = pt;
            //        option.centerPt = _CLLocationCoordinate2DMake(39.916, 116.404);//检索中心点
            //发起检索
            BMKRadarManager *_radarManager = [BMKRadarManager getRadarManagerInstance];
            BOOL res = [_radarManager getRadarNearbySearchRequest:option];
            if (res) {
                NSLog(@"get 成功");
            } else {
                NSLog(@"get 失败");
            }
//            [BMKRadarManager releaseRadarManagerInstance];
            
                    [_locService stopUserLocationService];
        }
        else{
            BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
            reverseGeocodeSearchOption.reverseGeoPoint = pt;
            [_geoCodeSerch reverseGeoCode:reverseGeocodeSearchOption];
        }
    
}

- (void)onGetRadarNearbySearchResult:(BMKRadarNearbyResult *)result error:(BMKRadarErrorCode)error {
    NSLog(@"onGetRadarNearbySearchResult  %d", error);
    if (error == BMK_RADAR_NO_ERROR) {
        self._is_open_location = false;
        [_locService stopUserLocationService];
    }
}

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        
        BMKAddressComponent *component=[[BMKAddressComponent alloc]init];
        component=result.addressDetail;
        
        NSString* countryCode = component.countryCode;
        NSString* country = component.country;
        //NSString* adCode = component.adCode;
        NSString* city = component.city;
        NSString* district = component.district;
        NSString* streetName = component.streetName;
        NSString* province = component.province;
        NSString* addr = result.address;
        NSString* sematicDescription = result.sematicDescription;
        
        NSMutableDictionary* _data = [[NSMutableDictionary alloc] init];
        [_data setValue:@"onGetReverseGeoCode" forKey:@"action_type"];
        [_data setValue:countryCode forKey:@"countryCode"];
        [_data setValue:country forKey:@"country"];
        //[_data setValue:adCode forKey:@"citycode"];
        [_data setValue:city forKey:@"city"];
        [_data setValue:district forKey:@"district"];
        [_data setValue:streetName forKey:@"street"];
        [_data setValue:province forKey:@"province"];
        [_data setValue:addr forKey:@"addr"];
        [_data setValue:sematicDescription forKey:@"locationDescribe"];
        
        
        [self commanCallback:_data];
//        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_data];
//        [result setKeepCallbackAsBool:TRUE];
        [_locService stopUserLocationService];
        
//        [self.commandDelegate sendPluginResult:result callbackId:_execCommand.callbackId];
//        _execCommand = nil;
    }
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}


- (void)successWithCallbackID:(NSString *)callbackID
{
    [self successWithCallbackID:callbackID withMessage:@"OK"];
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)commanCallback:(NSDictionary *) params
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self dictionaryToJson:params]];
    [commandResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:commandResult callbackId:self._callback_id];
}

- (NSString*) dictionaryToJson:(NSMutableDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return str;
}

@end
