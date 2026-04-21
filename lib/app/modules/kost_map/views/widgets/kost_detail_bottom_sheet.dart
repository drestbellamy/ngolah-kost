import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';
import '../../../../data/models/kost_with_status_model.dart';
import '../../../../data/enums/room_availability_status.dart';

class KostDetailBottomSheet extends StatelessWidget {
  final KostWithStatus kost;
  final VoidCallback onRoutePressed;
  final VoidCallback onDetailPressed;

  const KostDetailBottomSheet({
    super.key,
    required this.kost,
    required this.onRoutePressed,
    required this.onDetailPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Name and Distance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kost.name,
                            style: AppTextStyles.titleLarge.colored(const Color(0xFF1F2937)),
                          ),
                          const SizedBox(height: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(
                                kost.availabilityStatus.badgeBackgroundColor,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Color(
                                      kost.availabilityStatus.markerColor,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getStatusIndonesia(kost.availabilityStatus),
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontSize: 13,
                                    color: Color(
                                      kost.availabilityStatus.badgeTextColor,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Distance badge
                    if (kost.distanceFromAdmin != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0ED),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me,
                              size: 16,
                              color: Color(0xFF6B8E7F),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              kost.formattedDistance,
                              style: AppTextStyles.body14.copyWith(
                                color: const Color(0xFF6B8E7F),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Address
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0ED),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 20,
                          color: Color(0xFF6B8E7F),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          kost.address,
                          style: AppTextStyles.body14.colored(const Color(0xFF4B5563)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Room Statistics
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.meeting_room_outlined,
                        label: 'Total Kamar',
                        value: kost.roomCount.toString(),
                        color: const Color(0xFF6B8E7F),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle_outline,
                        label: 'Tersedia',
                        value: kost.availableRooms.toString(),
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_outline,
                        label: 'Terisi',
                        value: kost.occupiedRooms.toString(),
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    // Route button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRoutePressed,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B8E7F),
                          side: const BorderSide(
                            color: Color(0xFF6B8E7F),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Rute',
                              style: AppTextStyles.buttonMedium.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Detail button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: onDetailPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B8E7F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Lihat Detail Kost',
                              style: AppTextStyles.buttonMedium.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Safe area padding for bottom
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.header18.colored(color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.colored(const Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatusIndonesia(RoomAvailabilityStatus status) {
    switch (status) {
      case RoomAvailabilityStatus.allAvailable:
        return 'Tersedia';
      case RoomAvailabilityStatus.partiallyOccupied:
        return 'Sebagian';
      case RoomAvailabilityStatus.allOccupied:
        return 'Penuh';
    }
  }


}
