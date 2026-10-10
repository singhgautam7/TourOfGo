import 'package:flutter/material.dart';
import '../../../shared/widgets/reader_header.dart';

/// Top bar for the example reader: the shared [ReaderHeader], so both readers
/// look and behave the same.
class ExampleTopBar extends StatelessWidget {
  final String exampleTitle;
  final int currentIndex;
  final int totalExamples;
  final VoidCallback onBack;
  final VoidCallback onInfo;
  final VoidCallback onTitleTap;

  const ExampleTopBar({
    super.key,
    required this.exampleTitle,
    required this.currentIndex,
    required this.totalExamples,
    required this.onBack,
    required this.onInfo,
    required this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return ReaderHeader(
      title: 'Go by Example',
      subtitle: 'Example ${currentIndex + 1} of $totalExamples',
      progress: totalExamples > 0 ? (currentIndex + 1) / totalExamples : 0.0,
      onBack: onBack,
      onTitleTap: onTitleTap,
      infoLabel: 'Example info',
      onInfo: onInfo,
    );
  }
}
