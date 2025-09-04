import 'package:flutter/material.dart';

class SelectorCard extends StatelessWidget {
  final String title;
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final VoidCallback? onRemove;
  const SelectorCard({
    required this.title,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.onRemove,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = !label.contains('Choisir');
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]
        ),
        child: Row(
          children: [
            Text('$title :', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (hasSelection && onRemove != null)
              Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F8EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(label),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onRemove,
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: label.contains('Choisir') ? Colors.blue : Colors.black)
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DateSelectorCard extends StatelessWidget {
  final String title;
  final DateTime? selectedDate;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  const DateSelectorCard({
    required this.title,
    this.selectedDate,
    this.onTap,
    this.onRemove,
    super.key
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedDate != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]
        ),
        child: isSelected
          ? Row(
              children: [
                Text('$title :', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                if (onRemove != null)
                  Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F8EC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(_formatDate(selectedDate!)),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onRemove,
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          : Center(
              child: SizedBox(
                width: 256,
                height: 35,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F5F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sélectionner une date de début',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
