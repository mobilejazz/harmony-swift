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

#import "MJDataProviderDirector.h"

@implementation MJDataProviderDirectorResolver
{
    void (^ _block)(MJDataProviderDirectorResolveRoute route);
}

+ (instancetype)resolverWithBlock:(void (^)(MJDataProviderDirectorResolveRoute route))block
{
    return [[self alloc] initWithBlock:block];
}

- (id)initWithBlock:(void (^)(MJDataProviderDirectorResolveRoute route))block
{
    self = [super init];
    if (self)
    {
        _block = block;
    }
    return self;
}

- (void)resolveWithNetwork
{
    if (_block)
    {
        _block(MJDataProviderDirectorResolveRouteNetwork);
    }
}

- (void)resolveWithCache
{
    if (_block)
    {
        _block(MJDataProviderDirectorResolveRouteCache);
    }
}

@end

@implementation MJDataProviderDirector

- (void)networkBlock:(void (^)(MJDataProviderDirectorResolver *resolver))networkBlock cacheBlock:(void (^)(MJDataProviderDirectorResolver *resolver))cacheBlock
{
    __block __weak MJDataProviderDirectorResolver *weakResolver = nil;

    MJDataProviderDirectorResolver *resolver = [MJDataProviderDirectorResolver resolverWithBlock:^(MJDataProviderDirectorResolveRoute route) {
        __strong MJDataProviderDirectorResolver *strongResolver = weakResolver;

        if (route == MJDataProviderDirectorResolveRouteCache)
        {
            cacheBlock(strongResolver);
        }
        else if (route == MJDataProviderDirectorResolveRouteNetwork)
        {
            networkBlock(strongResolver);
        }
    }];

    weakResolver = resolver;

    if (_defaultRoute == MJDataProviderDirectorResolveRouteNetwork)
    {
        // Use network block

        if (networkBlock)
        {
            // If network block, execute network block
            networkBlock(resolver);
        }
        else
        {
            // Nothing to be done. No block is executed.
        }
    }
    else // if (_defaultRoute == MJDataProviderDirectorResolveRouteCache)
    {
        // Otherwise, use cache block.
        if (cacheBlock)
        {
            // If cache block is defined, execute cache block
            cacheBlock(resolver);
        }
        else
        {
            // Otherwise, resolve cache block with error
            [resolver resolveWithNetwork];
        }
    }
}

@end
