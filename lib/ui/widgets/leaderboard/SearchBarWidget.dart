import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const SearchBarWidget({super.key, required this.onChanged});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  void _onTextChanged(String value) {
    setState(() {
      _hasText = value.isNotEmpty;
    });
    widget.onChanged(value);
  }

  void _clearText() {
    _controller.clear();
    _onTextChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            hintText: "Rechercher un utilisateur...",
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _hasText
                ? IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: _clearText,
            )
                : null,
            filled: true,
            fillColor: Colors.transparent, // On utilise la couleur du Container
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.8),
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
