import 'package:flutter/material.dart';
import '../../../../data/models/map_state_model.dart';

class MapFloatingButtons extends StatelessWidget {
  final VoidCallback onMyLocationPressed;
  final VoidCallback onToggleViewPressed;
  final VoidCallback onFitAllPressed;
  final bool isLoadingLocation;
  final MapViewMode viewMode;

  const MapFloatingButtons({
    super.key,
    required this.onMyLocationPressed,
    required this.onToggleViewPressed,
    required this.onFitAllPressed,
    required this.isLoadingLocation,
    required this.viewMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fit All Markers Button
        FloatingActionButton(
          heroTag: 'fit_all',
          onPressed: onFitAllPressed,
          backgroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.fit_screen, color: Color(0xFF6B8E7F)),
        ),

        const SizedBox(height: 12),

        // My Location Button
        FloatingActionButton(
          heroTag: 'my_location',
          onPressed: isLoadingLocation ? null : onMyLocationPressed,
          backgroundColor: Colors.white,
          elevation: 4,
          child: isLoadingLocation
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6B8E7F),
                    ),
                  ),
                )
              : const Icon(Icons.my_location, color: Color(0xFF6B8E7F)),
        ),

        const SizedBox(height: 12),

        // Toggle View Button
        FloatingActionButton(
          heroTag: 'toggle_view',
          onPressed: onToggleViewPressed,
          backgroundColor: const Color(0xFF6B8E7F),
          elevation: 4,
          child: Icon(
            viewMode == MapViewMode.map ? Icons.list : Icons.map,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
