import 'package:flutter/material.dart';

class EditableTextWidget extends StatefulWidget {
  final String initialText;
  final Function onSubmit;

  const EditableTextWidget({
    super.key,
    required this.initialText,
    required this.onSubmit,
  });

  @override
  EditableTextWidgetState createState() => EditableTextWidgetState();
}

class EditableTextWidgetState extends State<EditableTextWidget> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
      },
      child: _isEditing
          ? Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  setState(() {
                    _isEditing = false;
                    if (widget.initialText != _controller.text) {
                      widget.onSubmit(widget.initialText, _controller.text);
                    }
                  });
                }
              },
              child: TextField(
                controller: _controller,
                autofocus: true,
                // AV: we do not need onsubmit because onFocus change will
                // automatically activate when pressed submit
                // onSubmitted: (_) {
                //   setState(() {
                //     _isEditing = false;
                //   });
                // },
              ),
            )
          : Text(_controller.text, style: TextStyle(fontSize: 16)),
    );
  }
}
