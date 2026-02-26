import 'package:flutter/material.dart';

import 'login_screen.dart';

// stateless class - when a screen is just displaying things (no changing data), write:
class HomeScreen extends StatelessWidget
{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      backgroundColor: Colors.black,
      body: Center
      (
        child:Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children:
          [
            Text
            (
              'Focus',
              style: TextStyle
              (
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold, // takes a special Flutter constant, not a number
              )
            ),
            SizedBox(height: 8),
            Text
            (
              'Choose your experience',
              style: TextStyle
              (
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.normal,
              )
            ),
            SizedBox(height: 20),

            Row
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children:
              [
                // Now calling _CardWidget instead of _buildCard
                // because the card needs its own state (hover memory)
                _CardWidget
                (
                  title: 'Deep Dive',
                  subtitle: 'Submerge into calm depths',
                  color: Colors.blueAccent,
                  icon: Icons.water_outlined,
                ),
                _CardWidget
                (
                  title: 'Trail Walk',
                  subtitle: 'Wander through natural paths',
                  color: Color(0xFF3fe882),
                  icon: Icons.explore_outlined,
                ),
                _CardWidget
                (
                  title: 'Peak Ascent',
                  subtitle: 'Rise to elevated heights',
                  color: Color(0xFF9fa4cf),
                  icon: Icons.landscape_outlined,
                ),
              ]
            )
          ]
        ),
      )
    );
  }
}

// In Flutter, when you want to reuse the same UI pattern
// (like 3 cards that look the same but have different content),
// you make a helper function instead of copy-pasting code 3 times.

// StatefulWidget has TWO classes — the widget and its state
// We need StatefulWidget (not Stateless) because the card needs to
// "remember" whether the mouse is hovering over it or not
class _CardWidget extends StatefulWidget
{
  // "final" means these values are set once and never change
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _CardWidget
  (
    {
      required this.title,
      required this.subtitle,
      required this.color,
      required this.icon,
    }
  );

  @override
  State<_CardWidget> createState() => _CardWidgetState();
}

// This is the "state" class — it holds the memory and logic for the card
class _CardWidgetState extends State<_CardWidget>
{
  // This is the "memory" — tracks if the mouse is hovering
  // When this changes, Flutter redraws the card automatically
  bool isHovered = false;

  @override
  Widget build(BuildContext context)
  {
    // MouseRegion detects when the mouse enters or leaves the card
    return MouseRegion
    (
      // When mouse enters: set isHovered to true and redraw
      // setState() tells Flutter "something changed, redraw the screen"
      onEnter: (_) => setState(() => isHovered = true),

      // When mouse leaves: set isHovered to false and redraw
      onExit: (_) => setState(() => isHovered = false),

      child: GestureDetector
      (
        // Inside StatefulWidget, you access your parameters with "widget."
        // e.g. widget.title instead of just title
        onTap: ()
        {
          print('${widget.title} tapped!');
        },

        // AnimatedContainer is like Container but smoothly animates
        // any changes (size, color, etc.) instead of snapping instantly
        child: AnimatedContainer
        (
          duration: const Duration(milliseconds: 200), // how fast the animation is
          margin: const EdgeInsets.symmetric(horizontal: 12),

          // Ternary operator: condition ? valueIfTrue : valueIfFalse
          // Same as other languages — if hovered, use bigger size
          width: isHovered ? 230 : 200,
          height: isHovered ? 330 : 300,

          decoration: BoxDecoration
          (
            gradient: LinearGradient
            (
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
              [
                // When hovered: show the card's color. When not: dark grey
                isHovered ? widget.color : const Color(0xFF1C1C1E),
                Colors.black,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),

          child: Column
          (
            mainAxisAlignment: MainAxisAlignment.center,
            children:
            [
              CircleAvatar
              (
                radius: 36,
                backgroundColor: widget.color,
                child: Icon
                (
                  widget.icon, color: Colors.white, size: 28
                ),
              ),
              SizedBox(height: 16),
              Text
              (
                widget.title,
                style: TextStyle
                (
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold, // takes a special Flutter constant, not a number
                )
              ),
              SizedBox(height: 8),
              Text
              (
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle
                (
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}