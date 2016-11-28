#import "KVMSystemProfiler.h"

@implementation KVMSystemProfiler

+ (NSArray *)dataType:(NSString *)type {
  return [self dataTypes:@[type]];
}

+ (NSArray *)dataTypes:(NSArray<NSString *> *)types {

  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:@"/usr/sbin/system_profiler"];
  [task setArguments:[types arrayByAddingObject:@"-xml"]];

  NSPipe *out = [NSPipe pipe];
  [task setStandardOutput:out];
  [task launch];

  NSFileHandle *read = [out fileHandleForReading];
  NSData *dataRead = [read readDataToEndOfFile];

  NSError *error;
  NSArray *plist = [NSPropertyListSerialization propertyListWithData:dataRead options:NSPropertyListImmutable format:NULL error:&error];

  return plist;
}

@end
