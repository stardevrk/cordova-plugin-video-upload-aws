# cordova-plugin-videoupload-aws

This plugin uses AWS Cognito Pool ID and AWS S3 bucket to upload file to S3.

### Note: 
1. Cognito Pool ID has unauthenticated and authenticated Roles. This plugin based on unauthenticated role. So you must attach following policy to the unauthenticated role of the Cognito Pool ID you created.

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

 
2. This plugin requires Cognito Pool ID and S3 bucket will be based on same region. For example 'us-east-1', 'us-east-2'. Please check AWS region types.
