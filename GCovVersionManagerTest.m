//
//  GCovVersionManagerTest.m
//  CoverStory
//
//  Created by Thomas Van Lenten on 6/2/10.
//  Copyright 2010 Google Inc.
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "GTMSenTestCase.h"
#import "GCovVersionManager.h"

@interface GCovVersionManagerTest : SenTestCase
@end


@implementation GCovVersionManagerTest

- (void)testCollectionOfInstalled {
  GCovVersionManager *mgr = [GCovVersionManager defaultManager];
  STAssertNotNil(mgr, nil);

  // default should not be an empty string
  STAssertNotNil([mgr defaultGCovPath], nil);
  STAssertGreaterThan([[mgr defaultGCovPath] length], (NSUInteger)0, nil);

  // Should be atleast the default in the list.
  STAssertNotNil([mgr installedVersions], nil);
  STAssertGreaterThanOrEqual([[mgr installedVersions] count], (NSUInteger)1, nil);
}

@end
