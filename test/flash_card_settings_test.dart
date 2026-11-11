import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nroq/models/word_Content_models.dart';
import 'package:nroq/widgets/flash_card_settings.dart';
import 'package:nroq/widgets/swipe_feature.dart';

void main() {
  testWidgets('flash-card settings expose independent size controls', (
    tester,
  ) async {
    var wordSize = 1.0;
    var meaningSize = 1.0;
    var imageSize = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlashCardSettings(
            showPreviousCardButton: false,
            onShowPreviousCardButtonChanged: (_) {},
            wordSizeScale: wordSize,
            onWordSizeScaleChanged: (value) => wordSize = value,
            onWordSizeScaleChangeEnd: (_) {},
            meaningSizeScale: meaningSize,
            onMeaningSizeScaleChanged: (value) => meaningSize = value,
            onMeaningSizeScaleChangeEnd: (_) {},
            imageSizeScale: imageSize,
            onImageSizeScaleChanged: (value) => imageSize = value,
            onImageSizeScaleChangeEnd: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(Slider), findsNWidgets(3));
    expect(find.text('Word size'), findsOneWidget);
    expect(find.text('Meaning size'), findsOneWidget);
    expect(find.text('Image size'), findsOneWidget);

    await tester.drag(find.byType(Slider).first, const Offset(80, 0));
    expect(wordSize, greaterThan(1));
  });

  testWidgets('flash card remains scrollable with enlarged system text', (
    tester,
  ) async {
    final word = ApiWord(
      id: 1,
      word: 'Slay',
      meaning:
          'To do something exceptionally well or look extremely impressive. '
          'This long description should remain readable when the system text '
          'size is increased.',
      wordImageUrl: '',
      categoryName: 'Words',
      examples: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              height: 300,
              child: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: SwipeCard(
                  word: word,
                  width: 340,
                  height: 300,
                  progress: 0,
                  isDragging: false,
                  onShareWord: (_) async {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
