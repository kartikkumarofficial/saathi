import 'package:flutter/material.dart';


class FadedDividerHorizontal extends StatelessWidget {
  const FadedDividerHorizontal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1, // thickness of the divider
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey[300]!.withAlpha(0), // faded at start
            Colors.grey[300]!,               // solid at center
            Colors.grey[300]!.withAlpha(0), // faded at end
          ],
          stops: [0.0, 0.5, 1.0], //  where solid starts/ends
        ),
      ),
    );
  }
}




class FadedDividerVertical extends StatelessWidget {
  const FadedDividerVertical({super.key, this.height = 50});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(

      width: 1.5,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[300]!.withAlpha(0), // faded at top
            Colors.grey[300]!,               // solid at middle
            Colors.grey[300]!.withAlpha(0), // faded at bottom
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
