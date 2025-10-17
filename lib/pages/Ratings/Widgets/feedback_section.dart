import 'package:flutter/material.dart';

import '../../../Providers/ratings_provider.dart';
import '../../../util/color_constant.dart';
import '../../../util/styles.dart';

class FeedbackSection extends StatefulWidget {
  final TextEditingController controller;
  final RatingsProvider provider;
  final Future<void> Function() onSubmit;

  const FeedbackSection({
    super.key,
    required this.controller,
    required this.provider,
    required this.onSubmit,
  });

  @override
  State<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  bool _isSubmitting = false;
  late final VoidCallback _textListener;
  @override
  void initState() {
    super.initState();
    _textListener = () {
      if (mounted) setState(() {});
    };
    widget.controller.addListener(_textListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textListener); // ✅ proper cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        widget.provider.canSubmit(widget.controller.text) && !_isSubmitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Feedback & Others",
          style: Styles.textSmall(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          maxLines: 3,
          cursorColor: Colors.black54,
          decoration: InputDecoration(
            hintText: "Enter your feedback...",
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black54, width: 0.5),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black54, width: 0.5),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black54, width: 0.5),
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed:
                canSubmit
                    ? () async {
                      setState(() => _isSubmitting = true);
                      await widget.onSubmit();
                      if (mounted) setState(() => _isSubmitting = false);
                    }
                    : null,
            icon: const Icon(Icons.send, color: Colors.white),
            label: Text(
              _isSubmitting ? "Submitting..." : "Submit",
              style: Styles.textSmall(context, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit ? AppColor.maincolor : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
