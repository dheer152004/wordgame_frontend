import 'package:flutter_test/flutter_test.dart';
import 'package:nroq/models/word_Content_models.dart';

void main() {
  test('parses language, grammar values, usage, and etymology', () {
    final word = ApiWord.fromJson({
      'id': 11,
      'word': 'Overwhelmed',
      'meaning': 'Feeling that something is too much to handle.',
      'language': {'code': 'en', 'name': 'English'},
      'grammarValues': [
        {'grammarCategory': 'Part of Speech', 'grammarValue': 'Adjective'},
        {'grammarCategory': 'Word Type', 'grammarValue': 'Standard Word'},
      ],
      'wordDetails': {
        'usage': 'Studies: When a student has too many assignments.',
        'etymology': 'The word comes from the verb overwhelm.',
      },
    });

    expect(word.languageCode, 'en');
    expect(word.grammarValues, hasLength(2));
    expect(word.grammarValues.first.category, 'Part of Speech');
    expect(word.grammarValues.first.value, 'Adjective');
    expect(word.usage, 'Studies: When a student has too many assignments.');
    expect(word.etymology, 'The word comes from the verb overwhelm.');
  });
}
