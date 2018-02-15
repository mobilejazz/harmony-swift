#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MJAppLinkRecognizer.h"
#import "MJCocoaCoreCommon.h"
#import "MJDataProviderDirector.h"
#import "MJDEntity.h"
#import "MJDEntityMapper.h"
#import "MJErrorCodes.h"
#import "MJExecutor.h"
#import "MJInteractor.h"
#import "MJModelObject.h"
#import "MJSecureKey.h"
#import "NSString+Additions.h"
#import "MJCocoaCoreFuture.h"
#import "MJFuture.h"
#import "MJFutureBatch.h"
#import "MJFutureHub.h"

FOUNDATION_EXPORT double MJCocoaCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char MJCocoaCoreVersionString[];

