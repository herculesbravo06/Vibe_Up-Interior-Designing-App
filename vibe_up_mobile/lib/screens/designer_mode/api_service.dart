import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static Future<List<dynamic>> getProjects(String designerId) async {

    final url = Uri.parse(
        "http://192.168.1.8/scratch/admin_panel/api/projects.php?designer_id=$designerId"
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load projects");
    }

  }

}
