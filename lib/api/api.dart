import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:utter_art/constants.dart';

class Api {
  static Future<String?> uploadFile(File file) async {
    final url = Uri.parse(UPLOAD_FILE_URL);

    var request = http.MultipartRequest('POST', url);

    var fileStream = http.ByteStream(file.openRead());
    var length = await file.length();
    var multipartFile = http.MultipartFile('file', fileStream, length,
        filename: file.path.split('/').last);

    request.files.add(multipartFile);
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var decodedBody = json.decode(responseBody);
      if (decodedBody.containsKey('prediction')) {
        var prediction = decodedBody['prediction'];
        print('Prediction: $prediction');
        return prediction;
      } else {
        print('No prediction variable found in the response body');
      }
    } else {
      print('Failed to upload file. Status code: ${response.statusCode}');
    }
    return null;
  }
}