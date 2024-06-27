#import "AudioSource.h"
#import "ClippingAudioSource.h"
#import "IndexedPlayerItem.h"
#import "UriAudioSource.h"
#import <AVFoundation/AVFoundation.h>

@implementation ClippingAudioSource {
    UriAudioSource *_audioSource;
    CMTime _start;
    CMTime _end;
}

// Initializer for ClippingAudioSource with start and end times for clipping
- (instancetype)initWithId:(NSString *)sid audioSource:(UriAudioSource *)audioSource start:(NSNumber *)start end:(NSNumber *)end {
    self = [super initWithId:sid];
    NSAssert(self, @"super init cannot be nil");
    _audioSource = audioSource;
    _start = start == (id)[NSNull null] ? kCMTimeZero : CMTimeMake([start longLongValue], 1000000);
    _end = end == (id)[NSNull null] ? kCMTimeInvalid : CMTimeMake([end longLongValue], 1000000);
    return self;
}

// Returns the underlying UriAudioSource
- (UriAudioSource *)audioSource {
    return _audioSource;
}

// Indicates whether lazy loading is supported by the underlying UriAudioSource
- (BOOL)lazyLoading {
    return _audioSource.lazyLoading;
}

// Sets lazy loading for the underlying UriAudioSource
- (void)setLazyLoading:(BOOL)lazyLoading {
    _audioSource.lazyLoading = lazyLoading;
}

// Finds audio sources by ID and adds matches to the provided array
- (void)findById:(NSString *)sourceId matches:(NSMutableArray<AudioSource *> *)matches {
    [super findById:sourceId matches:matches];
    [_audioSource findById:sourceId matches:matches];
}

// Attaches the audio source to the AVQueuePlayer with an initial position
- (void)attach:(AVQueuePlayer *)player initialPos:(CMTime)initialPos {
    if (CMTIME_IS_INVALID(initialPos)) {
        initialPos = kCMTimeZero;
    }
    _audioSource.playerItem.forwardPlaybackEndTime = _end;
    [super attach:player initialPos:initialPos];
}

// Returns the primary player item of the underlying UriAudioSource
- (IndexedPlayerItem *)playerItem {
    return _audioSource.playerItem;
}

// Returns the secondary player item of the underlying UriAudioSource
- (IndexedPlayerItem *)playerItem2 {
    return _audioSource.playerItem2;
}

// Returns shuffle indices, always returns @[@(0)] for clipping
- (NSArray<NSNumber *> *)getShuffleIndices {
    return @[@(0)];
}

// No-op methods for play, pause, and stop
- (void)play:(AVQueuePlayer *)player {}
- (void)pause:(AVQueuePlayer *)player {}
- (void)stop:(AVQueuePlayer *)player {}

// Seeks to a specified position within the clipping range
- (void)seek:(CMTime)position completionHandler:(void (^)(BOOL))completionHandler {
    if (!completionHandler || (self.playerItem.status == AVPlayerItemStatusReadyToPlay)) {
        CMTime absPosition = CMTimeAdd(_start, position);
        [_audioSource.playerItem seekToTime:absPosition toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
    } else {
        [super seek:position completionHandler:completionHandler];
    }
}

// Flips the underlying audio source for looping purposes
- (void)flip {
    [_audioSource flip];
}

// Prepares the secondary player item for looping
- (void)preparePlayerItem2 {
    if (self.playerItem2) return;
    [_audioSource preparePlayerItem2];
    IndexedPlayerItem *item = _audioSource.playerItem2;
    item.forwardPlaybackEndTime = _end;
    [item seekToTime:_start toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
}

// Returns the duration of the clipping range
- (CMTime)duration {
    return CMTimeSubtract(CMTIME_IS_INVALID(_end) ? self.playerItem.duration : _end, _start);
}

// No-op for setting duration
- (void)setDuration:(CMTime)duration {}

// Returns the current position within the clipping range
- (CMTime)position {
    return CMTimeSubtract(self.playerItem.currentTime, _start);
}

// Returns the buffered position within the clipping range
- (CMTime)bufferedPosition {
    CMTime pos = CMTimeSubtract(_audioSource.bufferedPosition, _start);
    CMTime dur = [self duration];
    return CMTimeCompare(pos, dur) >= 0 ? dur : pos;
}

// Applies preferred forward buffer duration to the underlying audio source
- (void)applyPreferredForwardBufferDuration {
    [_audioSource applyPreferredForwardBufferDuration];
}

// Applies network resource usage settings for live streaming to the underlying audio source
- (void)applyCanUseNetworkResourcesForLiveStreamingWhilePaused {
    [_audioSource applyCanUseNetworkResourcesForLiveStreamingWhilePaused];
}

// Applies preferred peak bit rate to the underlying audio source
- (void)applyPreferredPeakBitRate {
    [_audioSource applyPreferredPeakBitRate];
}

@end
