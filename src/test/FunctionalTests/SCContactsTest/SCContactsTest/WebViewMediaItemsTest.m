#import "SCAsyncTestCase.h"
#import <SitecoreMobileSDK/SitecoreMobileSDK.h>

@interface WebViewMediaItemsTest : SCAsyncTestCase
@end

@implementation WebViewMediaItemsTest

-(void)testCreateMediaItem
{
    __block NSString* failDescription_;
    NSString* host = [ TestHostConfig testInstance ];
    
    void (^afterTest_)( NSDictionary* ) = ^( NSDictionary* result_ )
    {
        NSString* itemId_ = [ [ result_ objectForKey: @"itemId" ] lastObject ];

        if ( [ itemId_ length ] == 0 )
        {
            failDescription_ = @"no item id from js";
            return;
        }

        [ self prepare ];

        SCApiSession* apiContext_ = [ SCApiSession sessionWithHost: host
                                                             login: @"admin"
                                                          password: @"b" ];
        apiContext_.defaultSite = @"/sitecore/shell";

        //STODO test fields
        [ apiContext_ readItemOperationForItemId: itemId_ ]( ^( SCItem* result_, NSError* error_ )
        {
            if ( result_ )
            {
                [ result_ removeItemOperation ]( nil );
            }
            failDescription_ = [ error_ description ];

            [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
        } );

        [ self waitForStatus: kGHUnitWaitStatusSuccess
                     timeout: 300. ];
    };

    [ self runTestWithSelector: _cmd
                     testsPath: @"media_items"
                     javasript: @"testCreateMediaItem()"
                     afterTest: afterTest_ ];

    if ( failDescription_ )
    {
        GHFail( failDescription_ );
    }
}

-(void)testCreateLargeMediaItem
{
    __block NSString* failDescription_;
    NSString* host = [ TestHostConfig testInstance ];
    
    void (^afterTest_)( NSDictionary* ) = ^( NSDictionary* result_ )
    {
        NSString* itemId_ = [ [ result_ objectForKey: @"itemId" ] lastObject ];
        
        if ( [ itemId_ length ] == 0 )
        {
            failDescription_ = @"no item id from js";
            return;
        }
        
        [ self prepare ];
        
        SCApiSession* apiContext_ = [ SCApiSession sessionWithHost: host
                                                             login: @"admin"
                                                          password: @"b" ];
        apiContext_.defaultDatabase = @"core";
        apiContext_.defaultSite = @"/sitecore/shell";
        
        //STODO test fields
        [ apiContext_ readItemOperationForItemId: itemId_ ]( ^( SCItem* result_, NSError* error_ )
         {
             if ( result_ )
             {
                 [ result_ removeItemOperation ]( nil );
                 failDescription_ = [ error_ description ];
             }
             [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
             
         } );
        
        [ self waitForStatus: kGHUnitWaitStatusSuccess
                     timeout: 300. ];
    };
    
    [ self runTestWithSelector: _cmd
                     testsPath: @"media_items"
                     javasript: @"testCreateLargeMediaItem()"
                     afterTest: afterTest_ ];
    
    if ( failDescription_ )
    {
        GHFail( failDescription_ );
    }
}


@end
