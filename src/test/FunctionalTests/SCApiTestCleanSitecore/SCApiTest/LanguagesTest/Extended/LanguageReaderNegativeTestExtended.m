#import "SCAsyncTestCase.h"

@interface LanguageReaderNegativeTestExtended : SCAsyncTestCase
@end

@implementation LanguageReaderNegativeTestExtended

-(void)testContextWrongDefaultLanguage
{
    __weak __block SCApiSession* apiContext_ = nil;
    __block SCItem* item_ = nil;
 
    @autoreleasepool
    {
        __block SCApiSession* strongContext_ = nil;
        void (^block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
        {
            @autoreleasepool
            {

                strongContext_ = [ TestingRequestFactory getNewAdminContextWithShell ];
                apiContext_ = strongContext_;
                
                apiContext_.defaultLanguage = @"en";
                apiContext_.defaultLanguage = @"fr";
                NSString* path_ = SCLanguageItemPath;
                NSSet* fieldNames_ = [ NSSet setWithObject: @"Title" ];
                SCReadItemsRequest* request_ = [ SCReadItemsRequest requestWithItemPath: path_
                                                                                fieldsNames: fieldNames_ ];

                SCDidFinishAsyncOperationHandler doneHandler = ^( NSArray* da_result_, NSError* error_ )
                {
                    if ( [ da_result_ count ] == 0 )
                    {
                        didFinishCallback_();
                        return;
                    }
                    item_ = da_result_[ 0 ];
                    NSLog( @"%@:", item_ );
                    didFinishCallback_();
                };
                
                SCExtendedAsyncOp loader = [ apiContext_.extendedApiSession readItemsOperationWithRequest: request_ ];
                loader(nil, nil, doneHandler);
            }
        };

        [ self performAsyncRequestOnMainThreadWithBlock: block_
                                               selector: _cmd ];
    }
    
    GHAssertTrue( apiContext_ != nil, @"OK" );
    //Test danish item
    GHAssertTrue( item_ != nil, @"OK" );
    SCField* field_ = [ item_ fieldWithName: @"Title" ];
    GHAssertTrue( [ field_.rawValue isEqualToString: @"" ] == TRUE, @"OK" );
}

-(void)testWrongRequestLanguage
{
    __weak __block SCApiSession* apiContext_ = nil;

    __block SCItem* default_result_after_en = nil;
    __block SCItem* default_result_after_da = nil;
    
    @autoreleasepool
    {
        __block SCApiSession* strongContext_ = nil;
    void (^block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
    {
        @autoreleasepool
        {

            strongContext_ = [ TestingRequestFactory getNewAdminContextWithShell ];
            apiContext_ = strongContext_;
            
            NSSet* fields_ = [ NSSet setWithObject: @"Title" ];
            SCReadItemsRequest* request_ = [ SCReadItemsRequest requestWithItemPath: SCLanguageItemPath
                                                                            fieldsNames: fields_ ];
            request_.language = @"en";
            apiContext_.defaultLanguage = @"en";
            
            SCDidFinishAsyncOperationHandler doneHandler = ^( NSArray* en_result_, NSError* error_ )
            {
                if ( [ en_result_ count ] == 0 )
                {
                    didFinishCallback_();
                    return;
                }
                
                request_.language = @"xx";
                apiContext_.defaultLanguage = @"xx";
                
                [ apiContext_ readItemsOperationWithRequest: request_ ]( ^( NSArray* default_result_, NSError* error_ )
                 {
                     if ( [ default_result_ count ] == 0 )
                     {
                         didFinishCallback_();
                         return;
                     }
                     
                     default_result_after_en = default_result_[0];
                    
                     request_.language = @"da";
                     apiContext_.defaultLanguage = @"da";
                     
                         [ apiContext_ readItemsOperationWithRequest: request_ ]( ^( NSArray* default_result_, NSError* error_ )
                         {
                             if ( [ default_result_ count ] == 0 )
                             {
                                 didFinishCallback_();
                                 return;
                             }
                             
                             request_.language = @"xx";
                             apiContext_.defaultLanguage = @"xx";
                             
                                 [ apiContext_ readItemsOperationWithRequest: request_ ]( ^( NSArray* default_result_, NSError* error_ )
                                 {
                                     if ( [ default_result_ count ] == 0 )
                                     {
                                         didFinishCallback_();
                                         return;
                                     }
                                     
                                     default_result_after_da = default_result_[0];
                                     
                                     didFinishCallback_();
                                     
                                 } );
                             
                         } );
                 } );
            };
            
            SCExtendedAsyncOp loader = [ apiContext_.extendedApiSession readItemsOperationWithRequest: request_ ];
            loader(nil, nil, doneHandler);
        }
    };

    [ self performAsyncRequestOnMainThreadWithBlock: block_
                                           selector: _cmd ];
    }
    
    GHAssertTrue( apiContext_ != nil, @"OK" );
    //Test danish item
    GHAssertTrue( default_result_after_en != nil, @"OK" );
    
    SCField* field_ater_en = [ default_result_after_en fieldWithName: @"Title" ];
    SCField* field_ater_da = [ default_result_after_da fieldWithName: @"Title" ];
    
    // @adk : web API returns default language ("en") #394160
    //FIXME: @igk test should not pass!!!  rawValue_en rawValue_da - has random value!!!!!!
    NSString* rawValue_en = field_ater_en.rawValue;
    NSString* rawValue_da = field_ater_da.rawValue;
    
    GHAssertEqualObjects(rawValue_en, rawValue_da, @"field mismatch : [%@] not equal to [%@]", rawValue_en, rawValue_da );
    
    GHAssertTrue( field_ater_en.item == default_result_after_en, @"OK" );
}

-(void)testLanguageReadNotExistedItems
{
    __weak __block SCApiSession* apiContext_ = nil;
    __block SCItem* base_item_ = nil;
    __block NSSet* field_names_ = [ NSSet setWithObjects: @"Title", nil ];
 
    SCItemSourcePOD* webShellDanish = [ SCItemSourcePOD new ];
    {
        webShellDanish.database = @"web";
        webShellDanish.site = @"/sitecore/shell";
        webShellDanish.language = @"da";
    }
    
    @autoreleasepool
    {
        __block SCApiSession* strongContext_ = nil;
     void (^block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
     {
         @autoreleasepool
         {

             strongContext_ = [ TestingRequestFactory getNewAdminContextWithShell ];
             apiContext_ = strongContext_;
             
             SCReadItemsRequest* request_ = [ SCReadItemsRequest new ];
             request_.requestType = SCReadItemRequestQuery;
             request_.request = SCHomePath;
             request_.language = @"da";
             request_.fieldNames = field_names_;
                          
             SCDidFinishAsyncOperationHandler doneHandler = ^( NSArray* da_result_, NSError* error_ )
             {
                 base_item_ = [ apiContext_.extendedApiSession itemWithPath: SCHomePath
                                                                 itemSource: webShellDanish ];
                 NSLog( @"base_item_.field: %@", [ [ base_item_ fieldWithName: @"Title" ] rawValue ]);
                 
                 didFinishCallback_();
             };
             
             SCExtendedAsyncOp loader = [ apiContext_.extendedApiSession readItemsOperationWithRequest: request_ ];
             loader(nil, nil, doneHandler);
         }
     };
 
    [ self performAsyncRequestOnMainThreadWithBlock: block_
                                           selector: _cmd ];
    }
    
    
    GHAssertTrue( apiContext_ != nil, @"OK" );
    //Test base item (is available in danish)
    GHAssertTrue( base_item_ != nil, @"OK" );
    SCField* field_ = [ base_item_ fieldWithName: @"Title" ];
    GHAssertTrue( [ field_.rawValue isEqualToString: @"" ] == TRUE, @"OK" );
    GHAssertTrue( field_.item == base_item_, @"OK" );
}

@end