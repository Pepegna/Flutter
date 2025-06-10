import 'package:flutter/material.dart';
import '../user_profile.dart';

class OpponentListItem extends StatelessWidget {
  final UserProfile opponent;
  final bool isSelected;
  final VoidCallback onTap;

  const OpponentListItem({
    super.key,
    required this.opponent,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 5 : 2,
      color: isSelected ? Colors.deepPurple.shade100 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? Colors.deepPurple : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade300,
          child: Text(
            opponent.gamerTag.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          opponent.gamerTag,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('Pontos: ${opponent.currentPoints}'),
        trailing: isSelected
            ? const Icon(Icons.check_box, color: Colors.deepPurple)
            : const Icon(Icons.radio_button_unchecked),
        onTap: onTap,
      ),
    );
  }
}
