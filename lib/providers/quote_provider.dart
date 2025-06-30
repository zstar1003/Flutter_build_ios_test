import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/quote.dart';
import '../services/quote_service.dart';

class QuoteProvider extends ChangeNotifier {
  final QuoteService _quoteService = QuoteService();
  
  Quote? _currentQuote;
  Quote? _dailyQuote;
  List<Quote> _favorites = [];
  List<Quote> _recentQuotes = [];
  List<Character> _characters = [];
  Character? _currentCharacter;
  
  bool _isLoading = false;
  String? _error;

  // Getters
  Quote? get currentQuote => _currentQuote;
  Quote? get dailyQuote => _dailyQuote;
  List<Quote> get favorites => _favorites;
  List<Quote> get recentQuotes => _recentQuotes;
  List<Character> get characters => _characters;
  Character? get currentCharacter => _currentCharacter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  QuoteProvider() {
    _loadFavorites();
    _loadRecentQuotes();
    _loadCharacters();
    loadDailyQuote();
  }

  // 加载每日金句和角色
  Future<void> loadDailyQuote() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final quote = await _quoteService.getDailyCharacterQuote();
      _dailyQuote = quote;
      _currentQuote = quote;
      _currentCharacter = quote.character;
      _addToRecentQuotes(quote);
      notifyListeners();
    } catch (e) {
      _setError('加载每日金句失败：${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 获取随机角色金句
  Future<void> getRandomCharacterQuote() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final quote = await _quoteService.getRandomCharacterQuote();
      _currentQuote = quote;
      _currentCharacter = quote.character;
      _addToRecentQuotes(quote);
      notifyListeners();
    } catch (e) {
      _setError('获取金句失败：${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 获取特定角色的金句
  Future<void> getCharacterQuote(String characterName) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final quote = await _quoteService.getCharacterQuote(characterName);
      _currentQuote = quote;
      _currentCharacter = quote.character;
      _addToRecentQuotes(quote);
      notifyListeners();
    } catch (e) {
      _setError('获取角色金句失败：${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }



  // 切换收藏状态
  Future<void> toggleFavorite(Quote quote) async {
    final index = _favorites.indexWhere((fav) => fav.text == quote.text && fav.author == quote.author);
    
    if (index != -1) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(quote.copyWith(isFavorite: true));
    }
    
    await _saveFavorites();
    
    // 更新当前金句的收藏状态
    if (_currentQuote != null && 
        _currentQuote!.text == quote.text && 
        _currentQuote!.author == quote.author) {
      _currentQuote = _currentQuote!.copyWith(isFavorite: !_currentQuote!.isFavorite);
    }
    
    notifyListeners();
  }

  // 检查是否已收藏
  bool isFavorite(Quote quote) {
    return _favorites.any((fav) => fav.text == quote.text && fav.author == quote.author);
  }

  // 删除收藏
  Future<void> removeFavorite(Quote quote) async {
    _favorites.removeWhere((fav) => fav.text == quote.text && fav.author == quote.author);
    await _saveFavorites();
    notifyListeners();
  }



  // 设置当前金句
  void setCurrentQuote(Quote quote) {
    _currentQuote = quote.copyWith(isFavorite: isFavorite(quote));
    _currentCharacter = quote.character;
    _addToRecentQuotes(quote);
    notifyListeners();
  }

  // 搜索角色
  List<Character> searchCharacters(String query) {
    return _quoteService.searchCharacters(query);
  }

  // 获取所有职业
  List<String> getProfessions() {
    return _quoteService.getProfessions();
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _addToRecentQuotes(Quote quote) {
    _recentQuotes.removeWhere((recent) => recent.text == quote.text && recent.author == quote.author);
    _recentQuotes.insert(0, quote);
    if (_recentQuotes.length > 10) {
      _recentQuotes = _recentQuotes.take(10).toList();
    }
    _saveRecentQuotes();
  }

  void _loadCharacters() {
    _characters = _quoteService.getAllCharacters();
    notifyListeners();
  }

  // 本地存储方法
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

  Future<void> _saveRecentQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final recentJson = _recentQuotes.map((quote) => quote.toJson()).toList();
    await prefs.setString('recent_quotes', json.encode(recentJson));
  }

  Future<void> _loadRecentQuotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentString = prefs.getString('recent_quotes');
      if (recentString != null) {
        final recentJson = json.decode(recentString) as List;
        _recentQuotes = recentJson.map((json) => Quote.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('加载历史记录失败：$e');
    }
  }



  // 保持兼容性的方法
  Future<void> getRandomQuote() async {
    return getRandomCharacterQuote();
  }
} 