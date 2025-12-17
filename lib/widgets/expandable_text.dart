import 'package:flutter/material.dart';
class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int trimLines;
  final TextScaler textScaler;

  const ExpandableText(
    this.text, {
    super.key,
    this.style,
    this.trimLines = 1,
    this.textScaler = const TextScaler.linear(1.0),
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  bool isOverflowing = false;

 @override
void didChangeDependencies() {
  super.didChangeDependencies();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _checkOverflow();
  });
}

  void _checkOverflow() {
  if (!mounted) return; // ✅ prevent calling after dispose
  final span = TextSpan(text: widget.text, style: widget.style);
  final tp = TextPainter(
    text: span,
    maxLines: widget.trimLines,
    textScaler: widget.textScaler,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: MediaQuery.of(context).size.width);

  if (!mounted) return; // ✅ double check before setState
  setState(() {
    isOverflowing = tp.didExceedMaxLines;
  });
}


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          textScaler: widget.textScaler,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          maxLines: isExpanded ? null : widget.trimLines,
        ),
        if (isOverflowing)
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Text(
              isExpanded ? "Read less" : "Read more...",
              style: widget.style?.copyWith(
                 color: const Color(0xFFFF5E00),// highlight color for action
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textScaler: widget.textScaler,
            ),
          ),
      ],
    );
  }
}
