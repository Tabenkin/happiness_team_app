import 'package:flutter/material.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';

class MyTextArea extends StatefulWidget {
  final String labelText;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final double height;

  const MyTextArea({
    Key? key,
    required this.labelText,
    this.initialValue,
    required this.onChanged,
    this.height = 150, // Default height is 150 and it's fixed
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          widget.labelText,
        ),
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
            maxLines: null, // Allows for multiple lines within the fixed height
            decoration: const InputDecoration(
              hintText: "Enter text here...",
              border: InputBorder.none, // Removes underline
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            ),
            style: Theme.of(context).textTheme.bodyMedium,

            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
