import 'package:flutter/material.dart';

class ToggleSwitchWidget extends StatefulWidget {
  final VoidCallback onToggleOn;
  final VoidCallback onToggleOff;

  const ToggleSwitchWidget({super.key, required this.onToggleOn, required this.onToggleOff});

  @override
  State<ToggleSwitchWidget> createState() => _ToggleSwitchWidgetState();
}

class _ToggleSwitchWidgetState extends State<ToggleSwitchWidget> {
  bool _isOn = false;

  void _handleToggle(bool value) {
    setState(() {
      _isOn = value;
    });
    if (_isOn) {
      widget.onToggleOn();
    } else {
      widget.onToggleOff();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_isOn ? 'Stop self-managed FG service' : 'Start self-managed FG service'), // Display the label based on switch state
          Switch(
            value: _isOn,
            onChanged: _handleToggle,
          ),
        ],
      ),
    );
  }
}