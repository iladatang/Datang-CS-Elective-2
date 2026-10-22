import 'package:flutter/material.dart';

class NicknameDialog extends StatefulWidget {
  const NicknameDialog({
    required this.pokemonName,
    required this.initialNickname,
    super.key,
  });

  final String pokemonName;
  final String initialNickname;

  @override
  State<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<NicknameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.pokemonName;
    final title = name.isEmpty
        ? name
        : '${name[0].toUpperCase()}${name.substring(1)}';

    return AlertDialog(
      title: Text('Nickname for $title'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 24,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Nickname',
          hintText: 'Leave blank to remove',
        ),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
