//
//  UBMouseHandler.h
//  
//
//  Created by Felix Hageloh on 23/11/15.
//
//

#import <Foundation/Foundation.h>
@class UBWindow;
@class UBPreferencesController;


@interface UBMouseHandler : NSObject

- (id)initWithWindow:(UBWindow*)aWindow andPreferences:(UBPreferencesController*)thePreferences;

@end
