//
// Copyright 2016 Mobile Jazz SL
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

@class MJDEntity;
@class MJModelObject;

/**
 * Protocol that delcares an abstraction of a mapper.
 **/
@protocol MJDEntityMapper <NSObject>

/**
 * Maps an entity to an object.
 * @param entity The input entity.
 * @return The mapped object.
 **/
- (__kindof MJModelObject *)objectFromEntity:(__kindof MJDEntity *)entity;

/**
 * Maps an object to an entity.
 * @param object The input object.
 * @return The mapped entity.
 **/
- (__kindof MJDEntity *)entityFromObject:(__kindof MJModelObject *)object;

@end

/**
 * Converts an array of entities into an array of objects.
 **/
static inline NSArray<__kindof MJModelObject *> *MJModelObjectArrayFromEntitiesArray(NSArray <__kindof MJDEntity *> *array, id <MJDEntityMapper> mapper)
{
    if (mapper == nil)
        return nil;

    if (array.count == 0)
        return @[];

    NSMutableArray <__kindof MJModelObject *> *objects = [NSMutableArray array];
    for (NSInteger i = 0; i < array.count; ++i)
    {
        MJDEntity *entity = (id) [array objectAtIndex:i];
        MJModelObject *object = [mapper objectFromEntity:entity];
        [objects addObject:object];
    }

    return [objects copy];
}


/**
 * Converts an array of objects into an array of entities.
 **/
static inline NSArray<__kindof MJDEntity *> *MJDEntityArrayFromObjectsArray(NSArray <__kindof MJModelObject *> *array, id <MJDEntityMapper> mapper)
{
    if (mapper == nil)
        return nil;

    if (array.count == 0)
        return @[];

    NSMutableArray <__kindof MJDEntity *> *entities = [NSMutableArray array];
    for (NSInteger i = 0; i < array.count; ++i)
    {
        MJModelObject *object = (id) [array objectAtIndex:i];
        MJDEntity *entity = [mapper entityFromObject:object];
        [entities addObject:entity];
    }

    return [entities copy];
}
