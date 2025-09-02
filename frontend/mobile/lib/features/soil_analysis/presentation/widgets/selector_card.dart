import 'package:flutter/material.dart';

class SelectorCard extends StatelessWidget {
  final String title;
  final String label;
  final VoidCallback? onTap;
  const SelectorCard({required this.title, required this.label, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
      child: Row(
        children: [
          Text('$title :', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Text(label, style: TextStyle(color: label.contains('Choisir') ? Colors.blue : Colors.black)),
            ),
          ),
          if (onTap != null) const Icon(Icons.keyboard_arrow_down)
        ],
      ),
    );
  }
}
