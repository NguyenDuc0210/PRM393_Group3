import 'package:flutter/material.dart';
import '../models/location.dart';

class TitleSection extends StatelessWidget {
  final Location location;

  const TitleSection({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                location.address,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.star,
          color: Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          location.countStar.toString(),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}