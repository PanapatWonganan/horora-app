import 'package:flutter/material.dart';

/// A widget that displays a loading indicator with an optional message.
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).primaryColor,
            ),
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                message!,
                style: TextStyle(
                  color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
} 