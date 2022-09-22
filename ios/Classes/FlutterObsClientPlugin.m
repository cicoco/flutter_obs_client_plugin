#import "FlutterObsClientPlugin.h"
#import <OBS/OBS.h>


@implementation FlutterObsClientPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    ObsClientAPISetup(registrar.messenger, [FlutterObsClientPlugin new]);
}

- (nullable ObsResponse *)uploadFileRequest:(ObsRequest *)request error:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
    
    NSString *filePath = request.filePath;
    NSString *accessKey = request.accessKey;
    NSString *secretKey = request.secretKey;
    NSString *endpoint = request.endpoint;
    NSString *bucket = request.bucket;
    NSString *securityToken = request.securityToken;
    //文件夹前缀，可以为空，比如桶名为jingwei，我们可以上传到jingwei桶下app文件夹下，这里就传app，为空这里直接放到根路径下
    NSString *prefix = request.prefix;
    // 文件名，可以为空，指定上传文件名，为空则自动读取filePath的文件名称
    NSString *fileName = request.fileName;
    
    if([filePath hasPrefix:@"file://"]){
       filePath  = [filePath substringFromIndex:7];
    }
    
    // TODO 参数合法性校验

    OBSStaticCredentialProvider *credentailProvider = [[OBSStaticCredentialProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
    credentailProvider.securityToken = securityToken;

    OBSServiceConfiguration *conf = [[OBSServiceConfiguration alloc] initWithURLString:endpoint credentialProvider:credentailProvider];
    OBSClient *client  = [[OBSClient alloc] initWithConfiguration:conf];

    NSString* _fileName = ([fileName length] == 0)? [filePath lastPathComponent] : fileName;
    NSString* objectKey = @"";
    if ([prefix length] > 0) {
        objectKey = [prefix stringByAppendingString: @"/"];
    }
    objectKey = [objectKey stringByAppendingString: _fileName];
    OBSPutObjectWithFileRequest *putRequest = [[OBSPutObjectWithFileRequest alloc]initWithBucketName:bucket objectKey:objectKey uploadFilePath:filePath];
    if([self syncPutObject:client request:putRequest]){
        NSURL* url = [NSURL URLWithString:endpoint];
        NSString* returned = [NSString stringWithFormat:@"%@://%@.%@/%@", [url scheme], bucket, [url host], objectKey];
        
        ObsResponse *response = [ObsResponse new];
        response.objectUrl = returned;
        return response;
    }
    
    return nil;
}

-(BOOL) syncPutObject:(OBSClient*)client request:(OBSPutObjectWithFileRequest*)request {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL result;
    [client putObject:request completionHandler:^(OBSPutObjectResponse *response, NSError *err){

        if(!err && [@"200" isEqualToString:response.statusCode]){
            result = YES;
        } else {
            result = NO;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return result;
}

@end
