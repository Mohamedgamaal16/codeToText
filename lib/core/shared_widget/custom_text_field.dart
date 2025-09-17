import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundtotext/core/Styles/colors.dart';
import 'package:soundtotext/core/Styles/text_styles.dart';
class CustomTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final bool isPassword;
  final bool isNumberOnly;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final Widget? icon;
  final double borderRadius;
  final double height;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.isPassword = false,
    this.isNumberOnly = false,
    this.borderRadius = 25,
    this.validator,
    this.onSaved,
    this.icon,
    this.height = 56,
    this.controller,
    this.onChanged,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  String? _validationMessage;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _validateInput(String value) {
    if (!_hasInteracted && value.isNotEmpty) {
      _hasInteracted = true;
    }
    
    if (_hasInteracted && widget.validator != null) {
      setState(() {
        _validationMessage = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authOutlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.height,
            ),
            child: TextFormField(
              controller: widget.controller,
              onChanged: (value) {
                _validateInput(value);
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintTextDirection: TextDirection.rtl,
                fillColor: Colors.white,
                filled: true,
                hintText: widget.hintText,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle:  AppStyles.regular16(context)?.copyWith(
                  color: AppColors.kBlackColor,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.kBlackColor,
                        ),
                        onPressed: _togglePasswordVisibility,
                      )
                    : widget.icon,
                border: authOutlineInputBorder,
                enabledBorder: authOutlineInputBorder.copyWith(
                  borderSide: BorderSide(
                    color: _validationMessage != null 
                        ? AppColors.kRedColor 
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: authOutlineInputBorder.copyWith(
                  borderSide: BorderSide(
                    color: _validationMessage != null 
                        ? AppColors.kRedColor 
                        : AppColors.kRedColor,
                  ),
                ),
                // Remove errorText to prevent Flutter's default error behavior
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
              keyboardType: widget.isNumberOnly
                  ? TextInputType.number
                  : widget.isPassword
                      ? TextInputType.visiblePassword
                      : TextInputType.multiline,
              inputFormatters: widget.isNumberOnly 
                  ? [FilteringTextInputFormatter.digitsOnly] 
                  : [],
              // This validator will still work for form validation
              validator: widget.validator,
              onSaved: widget.onSaved,
            ),
          ),
          // Validation message container - only for visual feedback
          if (_validationMessage != null && _hasInteracted)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.kRedColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.kRedColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validationMessage!,
                      style: AppStyles.regular11(context)?.copyWith(
                                                color: AppColors.kRedColor,

                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}