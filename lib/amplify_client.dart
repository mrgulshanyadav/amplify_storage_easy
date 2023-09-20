import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'sig_v4.dart';

class AWSClient {
  /// replace with your own access key
  /// eg: AKPAAH6EDUOYSGTSJVFB
  static String _accessKeyId = '';

  /// replace with your own secret key
  /// eg: imLP837nxYarh/DWP+sLskPZqTCFHRS5PVzMRVcP
  static String _secretKeyId = '';

  /// replace with your account's region name
  /// eg: ap-south-1
  static String _region = '';

  /// replace with your S3's bucket name
  /// eg: your_bucket_name
  static String _bucketname = '';

  /// update the endpoint url for your bucket
  /// eg: https://your_bucket_name.s3-ap-south-1.amazonaws.com
  static String _s3Endpoint = '';

  static init({
    required String accessKeyId,
    required String secretKeyId,
    required String region,
    required String bucketname,
    required String s3Endpoint,
  }) {
    _accessKeyId = accessKeyId;
    _secretKeyId = secretKeyId;
    _region = region;
    _bucketname = bucketname;
    _s3Endpoint = s3Endpoint;
  }

  static Future uploadData(
    String folderName,
    String fileName,
    Uint8List data,
  ) async {
    final length = data.length;

    final uri = Uri.parse(_s3Endpoint);
    final req = http.MultipartRequest("POST", uri);
    final multipartFile = http.MultipartFile(
        'file', http.ByteStream.fromBytes(data), length,
        filename: fileName);

    final policy = Policy.fromS3PresignedPost(
        '$folderName/$fileName', _bucketname, _accessKeyId, 15, length,
        region: _region);
    final key =
        SigV4.calculateSigningKey(_secretKeyId, policy.datetime, _region, 's3');
    final signature = SigV4.calculateSignature(key, policy.encode());

    req.files.add(multipartFile);
    req.fields['key'] = policy.key;
    req.fields['acl'] = 'public-read';
    req.fields['X-Amz-Credential'] = policy.credential;
    req.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
    req.fields['X-Amz-Date'] = policy.datetime;
    req.fields['Policy'] = policy.encode();
    req.fields['X-Amz-Signature'] = signature;

    try {
      final res = await req.send();
      await for (var value in res.stream.transform(utf8.decoder)) {
        if (kDebugMode) {
          print(value);
        }

        return value;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      return e;
    }
  }
}

class Policy {
  String expiration;
  String region;
  String bucket;
  String key;
  String credential;
  String datetime;
  int maxFileSize;

  Policy(this.key, this.bucket, this.datetime, this.expiration, this.credential,
      this.maxFileSize,
      {this.region = 'us-east-1'});

  factory Policy.fromS3PresignedPost(
    String key,
    String bucket,
    String accessKeyId,
    int expiryMinutes,
    int maxFileSize, {
    required String region,
  }) {
    final datetime = SigV4.generateDatetime();
    final expiration = (DateTime.now())
        .add(Duration(minutes: expiryMinutes))
        .toUtc()
        .toString()
        .split(' ')
        .join('T');
    final cred =
        '$accessKeyId/${SigV4.buildCredentialScope(datetime, region, 's3')}';
    final p = Policy(key, bucket, datetime, expiration, cred, maxFileSize,
        region: region);
    return p;
  }

  String encode() {
    final bytes = utf8.encode(toString());
    return base64.encode(bytes);
  }

  @override
  String toString() {
    return '''
{ "expiration": "$expiration",
  "conditions": [
    {"bucket": "$bucket"},
    ["starts-with", "\$key", "$key"],
    {"acl": "public-read"},
    ["content-length-range", 1, $maxFileSize],
    {"x-amz-credential": "$credential"},
    {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
    {"x-amz-date": "$datetime" }
  ]
}
''';
  }
}
