#import "IndexedAudioSource.h"
#import "IndexedPlayerItem.h"
#import <AVFoundation/AVFoundation.h>

@implementation IndexedAudioSource {
    BOOL _isAttached;
    BOOL _lazyLoading;
    CMTime _queuedSeekPos;
    void (^_queuedSeekCompletionHandler)(BOOL);
}

// Initializer for IndexedAudioSource
- (instancetype)initWithId:(NSString *)sid {
    self = [super initWithId:sid];
    NSAssert(self, @"super init cannot be nil");
    _isAttached = NO;
    _lazyLoading = NO;
    _queuedSeekPos = kCMTimeInvalid;
    _queuedSeekCompletionHandler = nil;
    return self;
}

// Method called when the status of the player item changes
- (void)onStatusChanged:(AVPlayerItemStatus)status {
    if (status == AVPlayerItemStatusReadyToPlay) {
        // Handle pending seek during load
        if (_queuedSeekCompletionHandler) {
            [self seek:_queuedSeekPos completionHandler:_queuedSeekCompletionHandler];
            _queuedSeekPos = kCMTimeInvalid;
            _queuedSeekCompletionHandler = nil;
        }
    }
}

// Getter for player item (to be overridden by subclasses)
- (IndexedPlayerItem *)playerItem {
    return nil;
}

// Getter for secondary player item (to be overridden by subclasses)
- (IndexedPlayerItem *)playerItem2 {
    return nil;
}

// Getter for attachment status
- (BOOL)isAttached {
    return _isAttached;
}

// Getter for lazy loading status
- (BOOL)lazyLoading {
    return _lazyLoading;
}

// Setter for lazy loading status
- (void)setLazyLoading:(BOOL)lazyLoading {
    _lazyLoading = lazyLoading;
}

// Builds a sequence of audio sources and returns the updated tree index
- (int)buildSequence:(NSMutableArray *)sequence treeIndex:(int)treeIndex {
    [sequence addObject:self];
    return treeIndex + 1;
}

// Attaches the audio source to a player and sets the initial position if provided
- (void)attach:(AVQueuePlayer *)player initialPos:(CMTime)initialPos {
    _isAttached = YES;
    if (CMTIME_IS_VALID(initialPos)) {
        [self seek:initialPos];
    }
}

// Placeholder method for playing the audio source (to be overridden by subclasses)
- (void)play:(AVQueuePlayer *)player {
}

// Placeholder method for pausing the audio source (to be overridden by subclasses)
- (void)pause:(AVQueuePlayer *)player {
}

// Placeholder method for stopping the audio source (to be overridden by subclasses)
- (void)stop:(AVQueuePlayer *)player {
}

// Seeks to a specified position in the audio source
- (void)seek:(CMTime)position {
    [self seek:position completionHandler:nil];
}

// Seeks to a specified position in the audio source with a completion handler
- (void)seek:(CMTime)position completionHandler:(void (^)(BOOL))completionHandler {
    if (completionHandler && (self.playerItem.status != AVPlayerItemStatusReadyToPlay)) {
        _queuedSeekPos = position;
        _queuedSeekCompletionHandler = completionHandler;
    }
}

// Placeholder method for flipping the audio source (to be overridden by subclasses)
- (void)flip {
}

// Placeholder method for preparing a secondary player item (to be overridden by subclasses)
- (void)preparePlayerItem2 {
}

// Getter for the duration of the audio source (to be overridden by subclasses)
- (CMTime)duration {
    return kCMTimeInvalid;
}

// Setter for the duration of the audio source (to be overridden by subclasses)
- (void)setDuration:(CMTime)duration {
}

// Getter for the current position in the audio source (to be overridden by subclasses)
- (CMTime)position {
    return kCMTimeInvalid;
}

// Getter for the buffered position in the audio source (to be overridden by subclasses)
- (CMTime)bufferedPosition {
    return kCMTimeInvalid;
}

// Applies the preferred forward buffer duration to the audio source
- (void)applyPreferredForwardBufferDuration {
}

// Allows using network resources for live streaming while paused
- (void)applyCanUseNetworkResourcesForLiveStreamingWhilePaused {
}

// Applies the preferred peak bit rate to the audio source
- (void)applyPreferredPeakBitRate {
}

@end
