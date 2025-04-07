import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchCompanyDescription(String companyName) async {
  final encodedName = Uri.encodeComponent(companyName);
  final url = "http://withyou.me:8080/companies/$encodedName";
  
  final response = await http.get(Uri.parse(url), headers: {
    'accept': 'application/json;charset=UTF-8',
  });

  if (response.statusCode == 200) {
    return utf8.decode(response.bodyBytes); // 한글 깨짐 방지
  } else {
    throw Exception('Failed to load company description');
  }
}
