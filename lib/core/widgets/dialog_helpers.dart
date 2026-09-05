import 'package:flutter/material.dart';

/// Wraps [child] so it is centred and never wider than 500 px.
///
/// Use as the `content:` value of any [AlertDialog] or as the root widget
/// returned from a [showModalBottomSheet] builder.
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => AlertDialog(
///     title: const Text('Confirm'),
///     content: constrainedDialogContent(const Text('Are you sure?')),
///   ),
/// );
///
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => constrainedDialogContent(_MySheetWidget()),
/// );
/// ```
Widget constrainedDialogContent(Widget child) {
  return Align(
    alignment: Alignment.center,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: child,
    ),
  );
}
