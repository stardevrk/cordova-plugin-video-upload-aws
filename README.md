# Cordova Video Upload Plugin

This plugin uses AWS Cognito Pool ID and AWS S3 bucket to upload file to S3. And this plugin support live stream broadcast to your rtmp endpoint.

### Installation

This plugin use the Cordova CLI's plugin command. To install it to your application, simply execute the following (and replace variables).

```
cordova plugin add https://github.com/stardevrk/cordova-plugin-video-upload-aws
```

### Note: 
1. Cognito Pool ID has unauthenticated and authenticated Roles. This plugin based on unauthenticated role. So you must attach following policy to the unauthenticated role of the Cognito Pool ID you created.

```
S3 Bucket IAM Policy
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::YOUR_BUCKET_NAME",
                "arn:aws:s3:::YOUR_BUCKET_NAME/*"
            ]
        }
    ]
}
```
 
2. This plugin requires Cognito Pool ID and S3 bucket will be based on same region. For example 'us-east-1', 'us-east-2'. Please check AWS region types.


### Basic Usage

This plugin includes 2 main features. One is the video upload feature, another is live streaming feature. Every feature is done by calling 2 functions. Initialization and Start feature.

```
    VideoUpload.init(
      {
        poolID: 'YOUR_COGNITO_POOL_ID',
        region: 'YOUR_REGION',
        bucket: 'YOUR_BUCKET',
        folder: 'YOUR_FOLDER',
        cameraWidth: YOUR_CAMERAVIEW_WIDTH,
        cameraHeight: YOUR_CAMERAVIEW_HEIGHT
      }
    );

    VideoUpload.startUpload(
      'standard', // Or 'record' - Plugin Action Type
      function(res) { // Upload Success
          
      }, 
      function(e) { // Upload failed
        
      }
    );

    VideoUpload.initLive(
         {
           cameraWidth: YOUR_CAMERAVIEW_WIDTH,
           cameraHeight: YOUR_CAMERAVIEW_HEIGHT
         }
       );
    VideoUpload.startBroadcast('Your RTMP Endpoint');
```

### Licence MIT

Copyright 2019

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.