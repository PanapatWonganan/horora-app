import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SoundControl extends StatelessWidget {
  final List<Map<String, dynamic>> availableSoundscapes;
  final String selectedSoundscape;
  final bool isSoundOn;
  final double volume;
  final Function(String) onSoundscapeChanged;
  final Function(bool) onSoundToggled;
  final Function(double) onVolumeChanged;

  const SoundControl({
    Key? key,
    required this.availableSoundscapes,
    required this.selectedSoundscape,
    required this.isSoundOn,
    required this.volume,
    required this.onSoundscapeChanged,
    required this.onSoundToggled,
    required this.onVolumeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sound title and toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'เสียงพื้นหลัง',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16.0,
                ),
              ),
              Switch(
                value: isSoundOn,
                onChanged: onSoundToggled,
                activeColor: AppColors.primary,
              ),
            ],
          ),
          
          // Volume slider
          if (isSoundOn) ...[
            Row(
              children: [
                const Icon(
                  Icons.volume_down,
                  color: Colors.white54,
                  size: 20.0,
                ),
                Expanded(
                  child: Slider(
                    value: volume,
                    onChanged: onVolumeChanged,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white24,
                  ),
                ),
                const Icon(
                  Icons.volume_up,
                  color: Colors.white54,
                  size: 20.0,
                ),
              ],
            ),
            
            const SizedBox(height: 16.0),
            
            // Soundscape selection
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: availableSoundscapes.map((soundscape) {
                final bool isSelected = soundscape['value'] == selectedSoundscape;
                return GestureDetector(
                  onTap: () => onSoundscapeChanged(soundscape['value']),
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.3) 
                          : Colors.black26,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primary 
                            : Colors.white24,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          soundscape['icon'],
                          color: isSelected 
                              ? AppColors.primary 
                              : Colors.white54,
                          size: 28.0,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          soundscape['label'],
                          style: TextStyle(
                            color: isSelected 
                                ? Colors.white 
                                : Colors.white70,
                            fontSize: 12.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
} 