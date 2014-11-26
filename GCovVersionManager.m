//
//  GCovVersionManager.m
//  CoverStory
//
//  Created by Thomas Van Lenten on 6/2/10.
//  Copyright 2010 Google Inc. All rights reserved.
//

#import "GCovVersionManager.h"
#import "GTMNSEnumerator+Filter.h"

@interface GCovVersionManager (PrivateMethods)
+ (NSMutableDictionary*)collectVersionsInFolder:(NSString *)path;
@end

@implementation GCovVersionManager

+ (GCovVersionManager *)defaultManager { 
  static GCovVersionManager *obj;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    obj = [[self alloc] init];
  });
  return obj;
}

- (id)init {
  if ((self = [super init])) {
    // Start with what is in /usr/bin
    NSMutableDictionary *map = [[self class] collectVersionsInFolder:@"/usr/bin"];
    // Override it with what is in the Developer directory's /usr/bin.
    // TODO: Should really use xcode-select -print-path as the starting point.
    [map addEntriesFromDictionary:[[self class] collectVersionsInFolder:@"/Developer/usr/bin"]];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fm fileExistsAtPath:@"/Applications/Xcode.app" isDirectory:&isDir]
        && isDir) {
      [map addEntriesFromDictionary:
       [[self class] collectVersionsInFolder:@"/Applications/Xcode.app/Contents/Developer/usr/bin"]];
    }
    versionMap_ = [map copy];
  }
  return self;
}

- (void) dealloc {
  [versionMap_ release];
  [super dealloc];
}

- (NSString*)defaultGCovPath {
  return [versionMap_ objectForKey:@""];
}

- (NSArray*)installedVersions {
  return [versionMap_ allValues];
}

- (NSString*)gcovForGCovFile:(NSString*)path {
  return [self defaultGCovPath];
}

+ (NSMutableDictionary*)collectVersionsInFolder:(NSString *)path {
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  // http://developer.apple.com/mac/library/documentation/Cocoa/Reference/Foundation/Classes/NSFileManager_Class/Reference/Reference.html#//apple_ref/occ/clm/NSFileManager/defaultManager
  // This is run on a thread, so don't use -defaultManager so we get something
  // thread safe.
  NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
  NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:path];
  // ...filter to gcov* apps...
  NSEnumerator *enumerator2 =
    [enumerator gtm_filteredEnumeratorByMakingEachObjectPerformSelector:@selector(hasPrefix:)
                                                             withObject:@"gcov"];
  // ...turn them all into full paths...
  NSEnumerator *enumerator3 =
    [enumerator2 gtm_enumeratorByTarget:path
                  performOnEachSelector:@selector(stringByAppendingPathComponent:)];
  // ...walk over them validating they are good to use.
  for (NSString *gcovPath in enumerator3) {
    // Must be executable.
    if (![fm isExecutableFileAtPath:gcovPath]) {
      continue;
    }

    // Extract the version.
    NSString *name = [gcovPath lastPathComponent];
    NSString *version = nil;
    if ([name isEqual:@"gcov"]) {
      // It's the default
      version = @"";
    } else {
      NSString *remainder = [name substringFromIndex:4];
      if ([remainder characterAtIndex:0] != '-') {
        NSLog(@"gcov binary name in odd format: %@", gcovPath);
      } else {
        version = [remainder substringFromIndex:1];
      }
    }

    if (version) {
      [result setObject:gcovPath forKey:version];
    }
  }

  return result;
}

@end
