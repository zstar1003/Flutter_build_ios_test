import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';

class QuoteProvider with ChangeNotifier {
  final QuoteService _quoteService = QuoteService();

  Quote? _currentQuote;
  String? _backgroundImage;
  bool _isLoading = false;
  String? _error;

  Quote? get currentQuote => _currentQuote;
  String? get backgroundImage => _backgroundImage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  QuoteProvider() {
    fetchQuote();
  }

  Future<void> fetchQuote() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First, try to fetch from the network
      _currentQuote = await _quoteService.fetchQuoteFromNetwork();
    } catch (e) {
      // If network fails, fetch from local
      try {
        _currentQuote = _quoteService.getRandomLocalQuote();
        // Optionally, you might want to log the network error or inform the user
        // that they are seeing an offline quote. For now, we just fallback silently.
      } catch (localError) {
        _error = '网络和本地均加载失败: $localError';
      }
    } finally {
      _backgroundImage = _quoteService.getNextBackground();
      _isLoading = false;
      notifyListeners();
    }
  }
} 