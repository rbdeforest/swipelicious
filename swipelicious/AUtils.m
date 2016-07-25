#import "AUtils.h"

@implementation AUtils

+ (NSString*) stringFromDate: (NSDate*) date {
 
    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [newDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [newDateFormatter setTimeZone:timeZone];
    
    return [newDateFormatter stringFromDate: date];
}

+ (NSDate*) dateFromString: (NSString*) string {

    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [newDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [newDateFormatter setTimeZone:timeZone];
    
    return [newDateFormatter dateFromString: string];
}

@end