import 'package:flutter/material.dart';

class MyTextInput extends StatefulWidget {
  final String? labelText;
  final String? placeholder;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool isPassword;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  const MyTextInput({
    Key? key,
    this.labelText,
    this.initialValue,
    this.placeholder,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.onSubmitted,
  }) : super(key: key);

  @override
  _MyTextInputState createState() => _MyTextInputState();
}

class _MyTextInputState extends State<MyTextInput> {
  late bool _isObscured;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.initialValue ?? "";

    super.initState();
    _isObscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null && widget.labelText!.isNotEmpty)
          Text(
            widget.labelText!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        if (widget.labelText != null && widget.labelText!.isNotEmpty)
          const SizedBox(height: 8),
        TextField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          obscureText: _isObscured,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            hintText: widget.placeholder,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      // Choose the icon based on the password visibility
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : null,
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      ],
    );
  }
}
