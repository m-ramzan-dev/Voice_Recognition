import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StartStopButton extends StatelessWidget {
  final VoidCallback onPress;
  final bool isRecording;

  const StartStopButton(
      {Key? key, required this.onPress, required this.isRecording})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onPress,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOutBack,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: isRecording
                ? Container(
                    width: 80,
                    height: 80,
                    key: const ValueKey("Recording"),
                    decoration: BoxDecoration(
                        //color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red)),
                    child: const Icon(
                      CupertinoIcons.mic_fill,
                      color: Colors.red,
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    key: const ValueKey("NotRecording"),
                    decoration: BoxDecoration(
                        //color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey)),
                    child: const Icon(
                      CupertinoIcons.mic,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        if (isRecording)
          const Text(
            "Recording started",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          )
      ],
    );
  }
}
