import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';

class PriorityFilter extends StatelessWidget {
  final Priority selectedPriority;
  final Function(Priority) onPriorityChanged;

  const PriorityFilter({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrer par priorité',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Toutes',
                  isSelected: selectedPriority == Priority.all,
                  onTap: () => onPriorityChanged(Priority.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Haute',
                  isSelected: selectedPriority == Priority.high,
                  color: Colors.red,
                  onTap: () => onPriorityChanged(Priority.high),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Moyenne',
                  isSelected: selectedPriority == Priority.medium,
                  color: Colors.orange,
                  onTap: () => onPriorityChanged(Priority.medium),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Basse',
                  isSelected: selectedPriority == Priority.low,
                  color: Colors.green,
                  onTap: () => onPriorityChanged(Priority.low),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? Colors.blue).withOpacity(0.2)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected ? (color ?? Colors.blue) : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (color != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? (color ?? Colors.blue) : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}