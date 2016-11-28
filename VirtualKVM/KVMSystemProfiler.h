#import <Foundation/Foundation.h>

@interface KVMSystemProfiler : NSObject

+ (NSArray *)dataType:(NSString *)type;
+ (NSArray *)dataTypes:(NSArray<NSString *> *)types;

@end
