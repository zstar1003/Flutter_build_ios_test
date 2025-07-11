import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/quote.dart';
import '../services/quote_service.dart';

class QuoteProvider extends ChangeNotifier {
  Quote? _currentQuote;
  String? _backgroundImage;
  List<Quote> _favorites = [];
  
  bool _isLoading = false;
  String? _error;
  final Random _random = Random();

  // Getters
  Quote? get currentQuote => _currentQuote;
  String? get backgroundImage => _backgroundImage;
  List<Quote> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  QuoteProvider() {
    _loadFavorites();
    fetchQuote();
  }

  Future<void> fetchQuote() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final quote = await QuoteService.getRandomQuote();
      _currentQuote = quote.copyWith(isFavorite: isFavorite(quote));
      _backgroundImage = 'assets/bg/${_random.nextInt(10) + 1}.jpg';
      notifyListeners();
    } catch (e) {
      _setError('获取金句失败：${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleFavorite(Quote quote) async {
    final index = _favorites.indexWhere((fav) => fav.text == quote.text && fav.author == quote.author);
    
    if (index != -1) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(quote.copyWith(isFavorite: true));
    }
    
    await _saveFavorites();
    
    if (_currentQuote != null && 
        _currentQuote!.text == quote.text && 
        _currentQuote!.author == quote.author) {
      _currentQuote = _currentQuote!.copyWith(isFavorite: !_currentQuote!.isFavorite);
    }
    
    notifyListeners();
  }

  bool isFavorite(Quote quote) {
    return _favorites.any((fav) => fav.text == quote.text && fav.author == quote.author);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = _favorites.map((quote) => quote.toJson()).toList();
    await prefs.setString('favorites', json.encode(favoritesJson));
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString('favorites');
      if (favoritesString != null) {
        final favoritesJson = json.decode(favoritesString) as List;
        _favorites = favoritesJson.map((json) => Quote.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('加载收藏失败：$e');
    }
  }
} 