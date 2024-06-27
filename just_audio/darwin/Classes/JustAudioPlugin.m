#import "JustAudioPlugin.h"
#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#include <TargetConditionals.h>

@implementation JustAudioPlugin {
    NSObject<FlutterPluginRegistrar>* _registrar;
    NSMutableDictionary<NSString *, AudioPlayer *> *_players;
}

// Registers the plugin with the Flutter plugin registrar
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"com.ryanheise.just_audio.methods"
              binaryMessenger:[registrar messenger]];
    JustAudioPlugin* instance = [[JustAudioPlugin alloc] initWithRegistrar:registrar];
    [registrar addMethodCallDelegate:instance channel:channel];
}

// Initializer for the plugin, sets up the registrar and initializes the players dictionary
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _registrar = registrar;
    _players = [[NSMutableDictionary alloc] init];
    return self;
}

// Handles method calls from Flutter
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"init" isEqualToString:call.method]) {
        [self handleInitCall:call result:result];
    } else if ([@"disposePlayer" isEqualToString:call.method]) {
        [self handleDisposePlayerCall:call result:result];
    } else if ([@"disposeAllPlayers" isEqualToString:call.method]) {
        [self handleDisposeAllPlayersCall:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

// Handles the "init" method call
- (void)handleInitCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *request = (NSDictionary *)call.arguments;
    NSString *playerId = (NSString *)request[@"id"];
    NSDictionary *loadConfiguration = (NSDictionary *)request[@"audioLoadConfiguration"];
    
    if ([_players objectForKey:playerId] != nil) {
        FlutterError *flutterError = [FlutterError errorWithCode:@"error" message:@"Platform player already exists" details:nil];
        result(flutterError);
    } else {
        AudioPlayer* player = [[AudioPlayer alloc] initWithRegistrar:_registrar playerId:playerId loadConfiguration:loadConfiguration];
        [_players setValue:player forKey:playerId];
        result(nil);
    }
}

// Handles the "disposePlayer" method call
- (void)handleDisposePlayerCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *request = (NSDictionary *)call.arguments;
    NSString *playerId = request[@"id"];
    
    if ([_players objectForKey:playerId] != nil) {
        [_players[playerId] dispose];
        [_players removeObjectForKey:playerId];
        result(@{});
    } else {
        FlutterError *flutterError = [FlutterError errorWithCode:@"error" message:@"Player not found" details:nil];
        result(flutterError);
    }
}

// Handles the "disposeAllPlayers" method call
- (void)handleDisposeAllPlayersCall:(FlutterResult)result {
    for (NSString *playerId in _players) {
        [_players[playerId] dispose];
    }
    [_players removeAllObjects];
    result(@{});
}

// Deallocates resources and disposes all players when the plugin is deallocated
- (void)dealloc {
    for (NSString *playerId in _players) {
        [_players[playerId] dispose];
    }
    [_players removeAllObjects];
}

@end
