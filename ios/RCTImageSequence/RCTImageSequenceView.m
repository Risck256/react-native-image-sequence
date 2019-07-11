//
// Created by Mads Lee Jensen on 07/07/16.
// Copyright (c) 2016 Facebook. All rights reserved.
//

#import "RCTImageSequenceView.h"
#import "RCTImageSequenceManager.h"

@implementation RCTImageSequenceView {
    NSUInteger _framesPerSecond;
    NSMutableDictionary *_activeTasks;
    NSMutableDictionary *_imagesLoaded;
    NSArray *_urls;
    NSTimer *_timer;
    BOOL _loop;
}

- (void)setImages:(NSArray *)images {
    __weak RCTImageSequenceView *weakSelf = self;

    self.animationImages = nil;
    _urls = images;
    _activeTasks = [NSMutableDictionary new];
    _imagesLoaded = [NSMutableDictionary new];
    
    [self start];
    
    
    
    
//    for (NSUInteger index = 0; index < images.count; index++) {
//        NSDictionary *item = images[index];
//
//        #ifdef DEBUG
//        NSString *url = item[@"uri"];
//        #else
//        NSString *url = [NSString stringWithFormat:@"file://%@", item[@"uri"]]; // when not in debug, the paths are "local paths" (because resources are bundled in app)
//        #endif
//
//        dispatch_async(dispatch_queue_create("dk.mads-lee.ImageSequence.Downloader", NULL), ^{
//            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
//            dispatch_async(dispatch_get_main_queue(), ^{
//              [weakSelf onImageLoadTaskAtIndex:index image:image];
//            });
//        });
//
//        _activeTasks[@(index)] = url;
//    }
}
- (void)dealloc {
    [self stop];
}
- (void)onImageLoadTaskAtIndex:(NSUInteger)index image:(UIImage *)image {
    if (index == 0) {
        self.image = image;
    }

    [_activeTasks removeObjectForKey:@(index)];

    _imagesLoaded[@(index)] = image;

    if (_activeTasks.allValues.count == 0) {
        [self onImagesLoaded];
    }
}

- (void)onImagesLoaded {
    NSMutableArray *images = [NSMutableArray new];
    for (NSUInteger index = 0; index < _imagesLoaded.allValues.count; index++) {
        UIImage *image = _imagesLoaded[@(index)];
        [images addObject:image];
    }

    [_imagesLoaded removeAllObjects];

    self.image = nil;
    self.animationDuration = images.count * (1.0f / _framesPerSecond);
    self.animationImages = images;
//    self.animationRepeatCount = _loop ? 0 : 1;
    [(RCTImageSequenceManager*)self.delegate startAnimation:self];
    [self startAnimating];
}

- (void)setFramesPerSecond:(NSUInteger)framesPerSecond {
    _framesPerSecond = framesPerSecond;
    [self start];
}

- (void) stop {
    [_timer invalidate];
    _timer = nil;
}
- (void) start {
    [self stop];
     __weak RCTImageSequenceView *weakSelf = self;
    __block NSNumber *count = @0;
    NSInteger imagesCount = [_urls count];
    NSArray* urls = _urls;
    BOOL loop = _loop;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/25.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (loop == FALSE && count.integerValue + 1 >= imagesCount) {
            [timer invalidate];
            return;
        }
        count = @((count.integerValue + 1) % imagesCount);
        
#ifdef DEBUG
        NSString *url = urls[count.integerValue][@"uri"];
#else
        NSString *url = [NSString stringWithFormat:@"file://%@", _urls[count.integerValue][@"uri"]]; // when not in debug, the paths are "local paths" (because resources are bundled in app)
#endif
        
//        dispatch_async(dispatch_queue_create("dk.mads-lee.ImageSequence.Downloader", NULL), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (timer.isValid) {
                    [weakSelf setImage:image];
//                }
                //  [weakSelf onImageLoadTaskAtIndex:index image:image];
//            });
//        });
        
    }];
}
- (void)setLoop:(NSUInteger)loop {
    _loop = loop;
    [self start];
}

@end
