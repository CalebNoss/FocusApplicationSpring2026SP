import 'package:flutter/material.dart';

import '../audio_player_widget.dart';

class AudioControlsSidePanel extends StatelessWidget {
  final bool isOpen;
  final double panelWidth;
  final double topPadding;

  const AudioControlsSidePanel({
    super.key,
    required this.isOpen,
    required this.panelWidth,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      top: 0,
      bottom: 0,
      right: isOpen ? 0 : -panelWidth,
      child: Material(
        color: Colors.black,
        elevation: 18,
        child: SafeArea(
          child: SizedBox(
            width: panelWidth,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, topPadding, 16, 12),
              child: const Column(
                children: [
                  Center(
                    child: Text(
                      'Audio Controls',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AudioPlayerWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AudioToggleButton extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onPressed;

  const AudioToggleButton({
    super.key,
    required this.isOpen,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: isOpen ? Colors.white24 : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.graphic_eq, color: Colors.white),
        tooltip: 'Audio',
        onPressed: onPressed,
      ),
    );
  }
}