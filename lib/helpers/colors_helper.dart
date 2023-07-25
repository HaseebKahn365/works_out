import 'package:flutter/material.dart';

Color getColor(BuildContext context, double percent) {
  if (percent >= 0.50) {
    return Theme.of(context).colorScheme.secondary;
  } else if (percent >= 0.25) {
    return Theme.of(context).colorScheme.errorContainer;
  } else {
    return Theme.of(context).colorScheme.error;
  }
}
