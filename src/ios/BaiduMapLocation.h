//
//  BaiduMapLocation.h
//
//  Created by LiuRui on 2017/2/25.
//

#import <Cordova/CDV.h>

#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h> //引入周边雷达功能所有的头文件

@interface BaiduMapLocation : CDVPlugin<BMKGeneralDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKRadarManagerDelegate> {
    BMKLocationService* _locService;
    BMKGeoCodeSearch* _geoCodeSerch;
//    CDVInvokedUrlCommand* _execCommand;
//    NSMutableDictionary* _data;
}

@property (nonatomic)  int _radius;
@property (nonatomic)  bool _is_verify_pass;
@property (nonatomic)  bool _is_near_by;
@property (nonatomic)  bool _is_open_location;
@property (nonatomic, strong) NSString* _callback_id;

//- (void)setRadarConfig:(CDVInvokedUrlCommand*)command;
- (void)setCommandCallback:(CDVInvokedUrlCommand*)command;
//- (void)openLocationService:(CDVInvokedUrlCommand*)command;
//- (void)openGeoCodeSearch:(CDVInvokedUrlCommand*)command;
- (void)getCurrentPosition:(CDVInvokedUrlCommand*)command;
- (void)getNearBy:(CDVInvokedUrlCommand*)command;
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation;

@end
