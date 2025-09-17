import 'package:flutter/material.dart';
import 'package:soundtotext/core/Styles/colors.dart';
import 'package:soundtotext/core/Styles/text_styles.dart';
class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    this.color = AppColors.kRedColor,
    required this.labelName,
    this.textColor = AppColors.kWhiteColor,
    this.onPressed,
    this.haveBorder = false,
    this.isBold = true,
    this.borderRadius = 25,
    this.height = 45,
    this.width = double.infinity,
    this.fontSize = 18,
    this.icon,
    this.iconSize,
    this.transform,
    this.hasShadow = false,
    this.shadowColor,
    this.shadowOffset,
    this.shadowBlurRadius = 8,
    this.shadowSpreadRadius = 0,
  });

  final bool hasShadow;
  final Color? color, textColor;
  final String labelName;
  final void Function()? onPressed;
  final bool haveBorder, isBold;
  final double borderRadius, height, width, fontSize;
  final IconData? icon;
  final double? iconSize;
  final bool? transform;
  
  // Shadow properties
  final Color? shadowColor;
  final Offset? shadowOffset;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, isHover ? -10 : 0, 0),
      decoration: widget.hasShadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: widget.shadowColor ?? 
                         (  
                          AppColors.kLightBlackColor),
                  offset: widget.shadowOffset ?? const Offset(0, 4),
                  blurRadius: widget.shadowBlurRadius,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHover = true),
        onExit: (_) => setState(() => isHover = false),
        cursor: SystemMouseCursors.click,
        child: TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            backgroundColor: widget.color,
            padding: const EdgeInsets.all(10),
            minimumSize: Size(widget.width, widget.height),
            maximumSize: Size(widget.width, widget.height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              side: widget.haveBorder
                  ? const BorderSide(color: AppColors.kWhiteColor, width: 2)
                  : BorderSide.none,
            ),
            // Remove default elevation to prevent conflicts with custom shadow
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.transform == true
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159),
                        child: Icon(
                          widget.icon,
                          color: widget.textColor,
                          size: widget.iconSize,
                        ),
                      )
                    : Icon(
                        widget.icon,
                        color: widget.textColor,
                        size: widget.iconSize,
                      ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.labelName,
                style: (widget.isBold
                        ? AppStyles.textButton(context)
                        : AppStyles.textButton(context))
                    ?.copyWith(
                        fontSize: widget.fontSize, color: widget.textColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}