## Example

Here's an example of how to use the AWS SigV4 Dart Client:

```dart
import 'package:amplify_storage_easy/amplify_client.dart'

uploadData() {
    // initialize AWSClient before using
AWSClient.init(
    accessKeyId: '', // your accessKeyId
    secretKeyId: '', // your secretKeyId
    region: '', // eg: ap-south-1
    bucketname: '', // bucket name
    s3Endpoint: '', // eg: https://your_bucket_name.s3-ap-south-1.amazonaws.com
);

String? url = await AWSClient.uploadData(
folderName, fileName, data,
).then((res) {
    if(res is String){
        return res;
    }else {
        if(kDebugMode) {
            print(res);
        }
        return null;
    }
});
}
```
