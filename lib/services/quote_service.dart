import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quote.dart';
import 'fallback_quotes.dart';

/// Fetches a motivational quote from DummyJSON.
///
/// This should never throw. If anything goes wrong we hand back a local
/// quote instead, so the home screen doesn't break without internet.
class QuoteService {
  QuoteService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _randomQuoteUrl =
      Uri.parse('https://dummyjson.com/quotes/random');

  final http.Client _client;

  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await _client
          .get(_randomQuoteUrl)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return randomFallbackQuote();
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final quote = Quote.fromJson(data);

      // an empty quote would just look like a broken banner
      if (quote.text.isEmpty) {
        return randomFallbackQuote();
      }
      return quote;
    } catch (_) {
      // timeout, no connection, bad json - all handled the same way
      return randomFallbackQuote();
    }
  }

  void dispose() => _client.close();
}
