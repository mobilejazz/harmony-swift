//
// Copyright 2015 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, MJDataProviderDirectorResolveRoute)
{
    MJDataProviderDirectorResolveRouteCache,
    MJDataProviderDirectorResolveRouteNetwork,
};


/**
 * Resolver object used as callback to finalize blocks.
 **/
@interface MJDataProviderDirectorResolver : NSObject

/** *************************************************** **
* @name Initializers
** *************************************************** **/

+ (instancetype)resolverWithBlock:(void (^)(MJDataProviderDirectorResolveRoute route))block;
- (id)initWithBlock:(void (^)(MJDataProviderDirectorResolveRoute route))block;

/** *************************************************** **
* @name Resolving blocks
** *************************************************** **/

- (void)resolveWithNetwork;
- (void)resolveWithCache;

@end

#pragma mark -

/**
 * A data provider director executes cache and network blocks.
 **/
@interface MJDataProviderDirector : NSObject

/** *************************************************** **
* @name Properties
** *************************************************** **/

/**
 * Default route. Default value is `MJDataProviderDirectorResolveRouteCache`.
 **/
@property (nonatomic, assign) MJDataProviderDirectorResolveRoute defaultRoute;

/** *************************************************** **
* @name Main methods
** *************************************************** **/

- (void)networkBlock:(void (^)(MJDataProviderDirectorResolver *resolver))networkBlock
          cacheBlock:(void (^)(MJDataProviderDirectorResolver *resolver))cacheBlock;

@end
