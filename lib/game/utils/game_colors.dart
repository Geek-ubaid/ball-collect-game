// lib/game/utils/game_colors.dart
import 'package:flutter/material.dart';
import 'dart:math';

final Random _random = Random();

const List<Color> gameColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.purple,
];

Color getRandomGameColor(List<Color>? availableColors) {
  final colorsToUse = availableColors ?? gameColors;
  if (colorsToUse.isEmpty) return Colors.grey; // Fallback
  return colorsToUse[_random.nextInt(colorsToUse.length)];
}

Color getDifferentRandomGameColor(Color currentColor, List<Color>? availableColors) {
  final colorsToUse = availableColors ?? gameColors;
  if (colorsToUse.length <= 1) return getRandomGameColor(colorsToUse);
  Color newColor;
  do {
    newColor = getRandomGameColor(colorsToUse);
  } while (newColor == currentColor && colorsToUse.length > 1);
  return newColor;
}