import 'package:flutter/material.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';

class MyTextArea extends StatefulWidget {
  final String? labelText;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final double height;
  final String? placeholder;

  const MyTextArea({
    Key? key,
    this.labelText,
    this.initialValue,
    required this.onChanged,
    this.height = 150,
    this.placeholder,
  }) : super(key: key);

  @override
  _MyTextAreaState createState() => _MyTextAreaState();
}

class _MyTextAreaState extends State<MyTextArea> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? "";
  }

  @override
  Widget build(BuildContext context) {
    // Current device text scale factor
    double currentScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Base font size for scale factor 1.0
    double baseFontSize = 16;

    // Calculate adjusted font sizes
    double adjustedFontSize = baseFontSize / currentScaleFactor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null && widget.labelText!.isNotEmpty)
          MyText(
            widget.labelText!,
          ),
        if (widget.labelText != null && widget.labelText!.isNotEmpty)
          const SizedBox(height: 8),
        Container(
          height: widget.height, // Fixed height for the container
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            maxLines: null, // Allows for multiple lines within the fixed height
            decoration: InputDecoration(
              hintText: widget.placeholder,
              border: InputBorder.none, // Removes underline
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            ),
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: adjustedFontSize),

            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
