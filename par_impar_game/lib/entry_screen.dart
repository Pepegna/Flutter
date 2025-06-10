import 'package:flutter/material.dart';
import 'package:par_impar_game/game_api_client.dart';
import 'package:par_impar_game/action_button.dart';
import '../user_profile.dart';
import '../app_routes.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _gamerTagController = TextEditingController();
  final GameApiClient _apiClient = GameApiClient();
  bool _isLoggingIn = false;

  void _processLogin() async {
    if (_gamerTagController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, digite seu GamerTag!')),
      );
      return;
    }
    setState(() {
      _isLoggingIn = true;
    });

    UserProfile? user = await _apiClient.attemptLoginOrRegister(
      _gamerTagController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _isLoggingIn = false;
    });

    if (user != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.arena, arguments: user);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao conectar. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.casino_outlined,
                  size: 80,
                  color: Colors.deepPurple.shade300,
                ),
                const SizedBox(height: 20),
                Text(
                  'OddEven Arena',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _gamerTagController,
                  decoration: InputDecoration(
                    hintText: 'Seu GamerTag',
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.deepPurple.shade300,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                _isLoggingIn
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                        ),
                      )
                    : ActionButton(
                        text: 'Entrar na Arena',
                        onPressed: _processLogin,
                        icon: Icons.login,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
