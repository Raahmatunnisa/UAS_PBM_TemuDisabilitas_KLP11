import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool outlined;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minHeight = MediaQuery.textScalerOf(context).scale(52.0);

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: minHeight,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                )
              : Icon(icon ?? Icons.touch_app),
          label: Text(label, semanticsLabel: label),
        ),
      );
    }

    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: double.infinity,
        height: minHeight,
        child: FilledButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor ?? theme.colorScheme.primary,
            foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
          ),
          icon: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foregroundColor ?? theme.colorScheme.onPrimary,
                  ),
                )
              : Icon(icon ?? Icons.check),
          label: Text(label),
        ),
      ),
    );
  }
}
