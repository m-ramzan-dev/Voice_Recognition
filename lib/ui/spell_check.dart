import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../list_english_words.dart';

class SpellCheck extends StatefulWidget {
  final CustomTextEdittingController controller;

  const SpellCheck({Key? key, required this.controller}) : super(key: key);

  @override
  State<SpellCheck> createState() => _SpellCheckState();
}

class _SpellCheckState extends State<SpellCheck> {
  final List<String> listErrorTexts = [];

  final List<String> listTexts = [];

  @override
  void initState() {
    //widget.controller = CustomTextEdittingController(listErrorTexts: listErrorTexts);
    super.initState();
  }

  void _handleOnChange(String text) {
    _handleSpellCheck(text, true);
  }

  void _handleSpellCheck(String text, bool ignoreLastWord) {
    if (!text.contains(' ')) {
      return;
    }
    final List<String> arr = text.split(' ');
    if (ignoreLastWord) {
      arr.removeLast();
    }
    for (var word in arr) {
      if (word.isEmpty) {
        continue;
      } else if (_isWordHasNumberOrBracket(word)) {
        continue;
      }
      final wordToCheck = word.replaceAll(RegExp(r"[^\s\w]"), '');
      final wordToCheckInLowercase = wordToCheck.toLowerCase();
      if (!listTexts.contains(wordToCheckInLowercase)) {
        listTexts.add(wordToCheckInLowercase);
        if (!listEnglishWords.contains(wordToCheckInLowercase)) {
          listErrorTexts.add(wordToCheck);
        }
      }
    }
  }

  bool _isWordHasNumberOrBracket(String s) {
    return s.contains(RegExp(r'[0-9\()]'));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            _handleSpellCheck(widget.controller.text, false);
          }
        },
        child: TextFormField(
          controller: widget.controller,
          onChanged: _handleOnChange,
          minLines: 1,
          maxLines: null,
          spellCheckConfiguration: SpellCheckConfiguration(
            spellCheckService: DefaultSpellCheckService(),
            misspelledSelectionColor: Colors.red,
            misspelledTextStyle: const TextStyle(
              color: Colors.red,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.wavy,
              decorationColor: Colors.red,
            ),
          ),
          decoration: const InputDecoration(
            labelText: 'Your Speech',
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
        ),
      ),
    );
  }
}

class CustomTextEdittingController extends TextEditingController {
  final List<String> listErrorTexts;

  CustomTextEdittingController({String? text, this.listErrorTexts = const []})
      : super(text: text);

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final List<TextSpan> children = [];
    if (listErrorTexts.isEmpty) {
      return TextSpan(text: text, style: style);
    }
    try {
      text.splitMapJoin(
          RegExp(r'\b(' + listErrorTexts.join('|').toString() + r')+\b'),
          onMatch: (m) {
        children.add(TextSpan(
          text: m[0],
          style: style!.copyWith(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.wavy,
              decorationColor: Colors.red),
        ));
        return "";
      }, onNonMatch: (n) {
        children.add(TextSpan(text: n, style: style));
        return n;
      });
    } on Exception catch (e) {
      return TextSpan(text: text, style: style);
    }
    return TextSpan(children: children, style: style);
  }
}
