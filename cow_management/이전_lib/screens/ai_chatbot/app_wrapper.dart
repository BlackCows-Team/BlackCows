// app_wrapper.dart

import 'package:flutter/material.dart';
import 'floating_chatbot_button.dart';

class AppWrapper extends StatefulWidget {
  final Widget child;
  const AppWrapper({required this.child, super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  double _x = 20;
  double _y = 80;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          right: _x,
          bottom: _y,
          child: Draggable(
            feedback: const FloatingChatbotButton(),
            childWhenDragging: Container(),
            onDragEnd: (details) {
                final size = MediaQuery.of(context).size;

                setState(() {
                    _x = size.width - details.offset.dx - 60;  // 60은 버튼 크기
                    _y = size.height - details.offset.dy - 60;
                });
            },
            child: const FloatingChatbotButton(),
          ),
        ),
      ],
    );
  }
}
