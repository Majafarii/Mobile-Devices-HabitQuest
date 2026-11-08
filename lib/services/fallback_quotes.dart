import 'dart:math';

import '../models/quote.dart';

/// Used when the quote API can't be reached (no wifi, API down, demo day...)
const List<Quote> fallbackQuotes = [
  Quote(
    text: 'The secret of getting ahead is getting started.',
    author: 'Mark Twain',
  ),
  Quote(
    text: 'We are what we repeatedly do. Excellence, then, is a habit.',
    author: 'Will Durant',
  ),
  Quote(
    text: 'It does not matter how slowly you go as long as you do not stop.',
    author: 'Confucius',
  ),
  Quote(
    text: 'Small daily improvements lead to stunning results over time.',
    author: 'Robin Sharma',
  ),
  Quote(
    text: 'Motivation gets you going, but habit keeps you growing.',
    author: 'HabitQuest',
  ),
];

final _random = Random();

Quote randomFallbackQuote() {
  return fallbackQuotes[_random.nextInt(fallbackQuotes.length)];
}
