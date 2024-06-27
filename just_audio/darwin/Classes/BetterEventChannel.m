#import "BetterEventChannel.h"

@implementation BetterEventChannel {
    FlutterEventChannel *_eventChannel;
    FlutterEventSink _eventSink;
}

// Initializes the BetterEventChannel with a specified name and messenger
- (instancetype)initWithName:(NSString*)name messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    // Create a new FlutterEventChannel with the specified name and messenger
    _eventChannel = [FlutterEventChannel eventChannelWithName:name binaryMessenger:messenger];
    // Set self as the stream handler for the event channel
    [_eventChannel setStreamHandler:self];
    _eventSink = nil;
    return self;
}

// Handles event listening from Flutter
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    return nil;
}

// Handles event cancellation from Flutter
- (FlutterError*)onCancelWithArguments:(id)arguments {
    _eventSink = nil;
    return nil;
}

// Sends an event to Flutter if an event sink is available
- (void)sendEvent:(id)event {
    if (!_eventSink) return;
    _eventSink(event);
}

// Disposes of the event channel by removing the stream handler
- (void)dispose {
    [_eventChannel setStreamHandler:nil];
}

@end
