# AWS SigV4 Dart Client

The AWS SigV4 Dart Client is a library that allows you to make secure AWS API requests by generating AWS Signature Version 4 (SigV4) authorization headers. It simplifies the process of creating and signing AWS requests in Dart applications.


## Features

- Generate SigV4 authorization headers for AWS service requests.
- Easily specify AWS credentials, service name, region, and session token.
- Automatically handle content types and accept types in HTTP requests.


## Installation

To use this library in your Dart project, add it to your `pubspec.yaml`:

```yaml
dependencies:
  amplify_storage_easy: ^1.0.2
```

Then, run pub get to install the dependency.


## Usage

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


## Contributing
Contributions are welcome! If you have any suggestions, feature requests, or bug reports, please open an issue or submit a pull request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.