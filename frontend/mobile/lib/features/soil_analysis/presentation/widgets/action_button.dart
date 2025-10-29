import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const ActionButton({required this.text, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007F3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          // Make the button appear disabled when onPressed is null
          foregroundColor: onPressed != null ? null : Colors.grey[600],
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
