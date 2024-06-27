#import "AudioSource.h"
#import "LoopingAudioSource.h"
#import <AVFoundation/AVFoundation.h>

@implementation LoopingAudioSource {
    // An array of duplicated audio sources
    NSArray<AudioSource *> *_audioSources;
}

// Initialize the LoopingAudioSource with an array of duplicated audio sources
- (instancetype)initWithId:(NSString *)sid audioSources:(NSArray<AudioSource *> *)audioSources {
    self = [super initWithId:sid];
    NSAssert(self, @"super init cannot be nil");
    _audioSources = audioSources;
    return self;
}

// Check if lazy loading is enabled for the audio sources
- (BOOL)lazyLoading {
    return [_audioSources count] > 0 ? _audioSources[0].lazyLoading : NO;
}

// Set lazy loading for all audio sources
- (void)setLazyLoading:(BOOL)lazyLoading {
    for (int i = 0; i < [_audioSources count]; i++) {
        _audioSources[i].lazyLoading = lazyLoading;
    }
}

// Build the sequence of audio sources
- (int)buildSequence:(NSMutableArray *)sequence treeIndex:(int)treeIndex {
    for (int i = 0; i < [_audioSources count]; i++) {
        treeIndex = [_audioSources[i] buildSequence:sequence treeIndex:treeIndex];
    }
    return treeIndex;
}

// Find audio sources by their ID and add matches to the matches array
- (void)findById:(NSString *)sourceId matches:(NSMutableArray<AudioSource *> *)matches {
    [super.findById:sourceId matches:matches];
    for (int i = 0; i < [_audioSources count]; i++) {
        [_audioSources[i] findById:sourceId matches:matches];
    }
}

// Get the shuffle indices for the audio sources
- (NSArray<NSNumber *> *)getShuffleIndices {
    NSMutableArray<NSNumber *> *order = [NSMutableArray new];
    int offset = (int)[order count];
    for (int i = 0; i < [_audioSources count]; i++) {
        AudioSource *audioSource = _audioSources[i];
        NSArray<NSNumber *> *childShuffleOrder = [audioSource getShuffleIndices];
        for (int j = 0; j < [childShuffleOrder count]; j++) {
            [order addObject:@([childShuffleOrder[j] integerValue] + offset)];
        }
        offset += [childShuffleOrder count];
    }
    return order;
}

// Decode the shuffle order from a dictionary
- (void)decodeShuffleOrder:(NSDictionary *)dict {
    NSDictionary *dictChild = (NSDictionary *)dict[@"child"];
    for (int i = 0; i < [_audioSources count]; i++) {
        AudioSource *child = _audioSources[i];
        [child decodeShuffleOrder:dictChild];
    }
}

@end
