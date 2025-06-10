import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:par_impar_game/game_api_client.dart';
import 'package:par_impar_game/action_button.dart';
import 'package:par_impar_game/opponent_list_item.dart';
import '../user_profile.dart';

class ArenaScreen extends StatefulWidget {
  final UserProfile currentUser;

  const ArenaScreen({super.key, required this.currentUser});

  @override
  State<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends State<ArenaScreen> {
  final GameApiClient _apiClient = GameApiClient();
  late UserProfile _playerProfile;
  List<UserProfile> _opponents = [];
  UserProfile? _selectedOpponent;
  String? _lastGameResult;
  bool _isLoadingData = false;
  bool _isBetting = false;
  bool _isPlaying = false;
  String? _betConfirmationMessage;

  final _betAmountController = TextEditingController();
  final _numberPickController = TextEditingController();
  int? _oddEvenChoice;

  @override
  void initState() {
    super.initState();
    _playerProfile = widget.currentUser;
    _loadInitialArenaData();
  }

  Future<void> _loadInitialArenaData() async {
    setState(() {
      _isLoadingData = true;
    });
    await _refreshPlayerPoints();
    await _fetchOpponentList();
    if (!mounted) return;
    setState(() {
      _isLoadingData = false;
    });
  }

  Future<void> _refreshPlayerPoints() async {
    UserProfile? updatedProfile = await _apiClient.fetchPlayerPoints(
      _playerProfile.gamerTag,
    );
    if (updatedProfile != null && mounted) {
      setState(() {
        _playerProfile = updatedProfile;
      });
    }
  }

  Future<void> _fetchOpponentList() async {
    List<UserProfile> fetchedOpponents = await _apiClient
        .listAvailablePlayers();
    if (mounted) {
      setState(() {
        _opponents = fetchedOpponents
            .where((op) => op.gamerTag != _playerProfile.gamerTag)
            .toList();
        if (_selectedOpponent != null) {
          final String previousOpponentTag = _selectedOpponent!.gamerTag;
          _selectedOpponent = _opponents.cast<UserProfile?>().firstWhere(
            (op) => op?.gamerTag == previousOpponentTag,
            orElse: () => null,
          );
          if (_selectedOpponent == null && _opponents.isNotEmpty) {
            _selectedOpponent = _opponents.first;
          } else if (_opponents.isEmpty) {
            _selectedOpponent = null;
          }
        }
      });
    }
  }

  void _handlePlaceBet() async {
    if (_betAmountController.text.isEmpty ||
        _numberPickController.text.isEmpty ||
        _oddEvenChoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos os campos da aposta.')),
      );
      return;
    }
    final int amount = int.tryParse(_betAmountController.text) ?? 0;
    final int number = int.tryParse(_numberPickController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aposta deve ser maior que zero.')),
      );
      return;
    }
    if (number < 1 || number > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número escolhido deve ser de 1 a 5.')),
      );
      return;
    }

    setState(() {
      _isBetting = true;
      _betConfirmationMessage = null;
    });
    bool success = await _apiClient.submitPlayerBet(
      _playerProfile.gamerTag,
      amount,
      _oddEvenChoice!,
      number,
    );
    if (!mounted) return;
    setState(() {
      _isBetting = false;
      _betConfirmationMessage = success
          ? 'Aposta registrada com sucesso!'
          : 'Falha ao registrar aposta.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_betConfirmationMessage!),
          backgroundColor: success
              ? Colors.green.shade600
              : Colors.red.shade600,
        ),
      );
    });
  }

  void _handleStartGame() async {
    if (_selectedOpponent == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um oponente!')));
      return;
    }
    if (_betConfirmationMessage == null ||
        !_betConfirmationMessage!.contains("sucesso")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Realize uma aposta válida primeiro.')),
      );
      return;
    }

    setState(() {
      _isPlaying = true;
      _lastGameResult = null;
    });
    Map<String, dynamic>? gameData = await _apiClient.executeGame(
      _playerProfile.gamerTag,
      _selectedOpponent!.gamerTag,
    );
    if (!mounted) return;

    if (gameData != null && gameData.containsKey('vencedor')) {
      final winner = gameData['vencedor'];
      final loser = gameData['perdedor'];
      _lastGameResult =
          'Vencedor: ${winner['username']} (${winner['parimpar'] == 2 ? "Par" : "Ímpar"}, N°${winner['numero']})\n'
          'Perdedor: ${loser['username']} (${loser['parimpar'] == 2 ? "Par" : "Ímpar"}, N°${loser['numero']})';
    } else {
      _lastGameResult = 'Ocorreu um erro ao processar o jogo. Tente novamente.';
    }
    await _refreshPlayerPoints();
    await _fetchOpponentList();
    setState(() {
      _isPlaying = false;
      _betAmountController.clear();
      _numberPickController.clear();
      _oddEvenChoice = null;
      _betConfirmationMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arena: ${_playerProfile.gamerTag}'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingData || _isBetting || _isPlaying
                ? null
                : _loadInitialArenaData,
          ),
        ],
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : RefreshIndicator(
              onRefresh: _loadInitialArenaData,
              color: Colors.deepPurple,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  _buildPlayerPointsCard(),
                  const SizedBox(height: 24),
                  _buildBettingSection(),
                  const SizedBox(height: 24),
                  _buildOpponentSelectionSection(),
                  const SizedBox(height: 24),
                  if (_isPlaying)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  if (!_isPlaying)
                    ActionButton(
                      text: 'Iniciar Duelo!',
                      onPressed:
                          (_selectedOpponent != null &&
                              (_betConfirmationMessage?.contains("sucesso") ??
                                  false))
                          ? _handleStartGame
                          : null,
                      color: Colors.green.shade700,
                      icon: Icons.play_arrow,
                    ),
                  const SizedBox(height: 20),
                  if (_lastGameResult != null) _buildGameResultCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildPlayerPointsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars, color: Colors.amber.shade700, size: 28),
            const SizedBox(width: 10),
            Text(
              'Pontuação: ${_playerProfile.currentPoints}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBettingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sua Aposta',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.deepPurple.shade700,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _betAmountController,
          decoration: const InputDecoration(
            labelText: 'Valor da Aposta',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _numberPickController,
          decoration: const InputDecoration(
            labelText: 'Escolha um Número (1-5)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.format_list_numbered),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Par ou Ímpar?',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.help_center_outlined),
          ),
          value: _oddEvenChoice,
          items: const [
            DropdownMenuItem(value: 1, child: Text('Ímpar')),
            DropdownMenuItem(value: 2, child: Text('Par')),
          ],
          onChanged: (value) => setState(() => _oddEvenChoice = value),
        ),
        const SizedBox(height: 16),
        Center(
          child: _isBetting
              ? const CircularProgressIndicator(color: Colors.deepPurple)
              : ActionButton(
                  text: 'Confirmar Aposta',
                  onPressed: _handlePlaceBet,
                  color: Colors.orange.shade700,
                  icon: Icons.check_circle_outline,
                ),
        ),
      ],
    );
  }

  Widget _buildOpponentSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione o Oponente',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.deepPurple.shade700,
          ),
        ),
        const SizedBox(height: 12),
        _opponents.isEmpty
            ? const Center(
                child: Text('Nenhum oponente disponível ou carregando...'),
              )
            : SizedBox(
                height: 250,
                child: ListView.separated(
                  itemCount: _opponents.length,
                  itemBuilder: (context, index) {
                    final opponent = _opponents[index];
                    return OpponentListItem(
                      opponent: opponent,
                      isSelected:
                          _selectedOpponent?.gamerTag == opponent.gamerTag,
                      onTap: () => setState(() => _selectedOpponent = opponent),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                ),
              ),
      ],
    );
  }

  Widget _buildGameResultCard() {
    return Card(
      elevation: 3,
      color: Colors.blueGrey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Resultado do Duelo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.deepPurple.shade800,
              ),
            ),
            const Divider(height: 20, thickness: 1),
            Text(
              _lastGameResult!,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
