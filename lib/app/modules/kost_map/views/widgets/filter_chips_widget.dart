import 'package:flutter/material.dart';
import '../../../../data/models/map_state_model.dart';

class FilterChipsWidget extends StatelessWidget {
  final StatusFilter selectedFilter;
  final Function(StatusFilter) onFilterChanged;
  final VoidCallback onClearAll;
  final bool hasActiveFilters;

  const FilterChipsWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onClearAll,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: Row(
        children: [
          // Filter Chips
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  filter: StatusFilter.all,
                  isSelected: selectedFilter == StatusFilter.all,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Tersedia',
                  filter: StatusFilter.hasEmptyRooms,
                  isSelected: selectedFilter == StatusFilter.hasEmptyRooms,
                  color: const Color(0xFF4CAF50), // Green
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Penuh',
                  filter: StatusFilter.full,
                  isSelected: selectedFilter == StatusFilter.full,
                  color: const Color(0xFFF44336), // Red
                ),
              ],
            ),
          ),

          // Clear All Button
          if (hasActiveFilters) ...[
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onClearAll,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.clear_all,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required StatusFilter filter,
    required bool isSelected,
    Color? color,
  }) {
    final chipColor = color ?? const Color(0xFF6B8E7F);

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? chipColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? chipColor : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onFilterChanged(filter),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Color indicator for status filters
                if (filter != StatusFilter.all) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : chipColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
