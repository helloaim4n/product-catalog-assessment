import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;

  const RatingStars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final color = Colors.amber.shade700;
    final rounded = (rating * 2).round() / 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            rounded >= i
                ? Icons.star_rounded
                : rounded >= i - 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            size: 18,
            color: color,
          ),
      ],
    );
  }
}
