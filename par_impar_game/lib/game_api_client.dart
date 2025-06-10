import 'dart:convert';
import 'package:http/http.dart' as http;
import '../user_profile.dart';

class GameApiClient {
  final String _apiDomain = 'https://par-impar.glitch.me';

  Future<UserProfile?> attemptLoginOrRegister(String tag) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiDomain/novo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': tag}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['usuarios'] != null && (data['usuarios'] as List).isNotEmpty) {
          var userData = (data['usuarios'] as List).firstWhere(
            (u) => u['username'] == tag,
            orElse: () => data['usuarios'][0],
          );
          return UserProfile.fromJson(userData);
        } else if (data['username'] != null) {
          return UserProfile.fromJson(data);
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<List<UserProfile>> listAvailablePlayers() async {
    try {
      final response = await http.get(Uri.parse('$_apiDomain/jogadores'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['jogadores'] != null) {
          List<dynamic> playerList = data['jogadores'];
          return playerList.map((json) => UserProfile.fromJson(json)).toList();
        }
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  Future<bool> submitPlayerBet(
    String tag,
    int betValue,
    int choice,
    int number,
  ) async {
    final url = Uri.parse('$_apiDomain/aposta');
    final body = jsonEncode({
      'username': tag,
      'valor': betValue,
      'parimpar': choice,
      'numero': number,
    });
    print('--- SUBMITTING BET ---');
    print('URL: $url');
    print('Body: $body');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print('Response Status (Bet): ${response.statusCode}');
      print('Response Body (Bet): ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error submitting bet: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> executeGame(String tag1, String tag2) async {
    final url = Uri.parse('$_apiDomain/jogar/$tag1/$tag2');
    print('--- EXECUTING GAME ---');
    print('URL: $url');
    try {
      final response = await http.get(url);
      print('Response Status (Game): ${response.statusCode}');
      print('Response Body (Game): ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error executing game: $e');
      return null;
    }
    return null;
  }

  Future<UserProfile?> fetchPlayerPoints(String tag) async {
    final url = Uri.parse('$_apiDomain/pontos/$tag');
    print('--- FETCHING POINTS for $tag ---');
    print('URL: $url');
    try {
      final response = await http.get(url);
      print('Response Status (Points for $tag): ${response.statusCode}');
      print('Response Body (Points for $tag): ${response.body}');
      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error fetching points for $tag: $e');
      return null;
    }
    return null;
  }
}
