import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  static const String _baseUrl = 'https://api.quotable.io';
  
  // 明日方舟角色数据 - 使用网络立绘资源
  static const List<Map<String, dynamic>> _arknightsCharacters = [
    {
      'name': '阿米娅',
      'codename': 'Amiya',
      'rarity': '5',
      'profession': '术师',
      'subProfession': '核心术师',
      'avatarUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_1001_amiya2.png',
      'illustrationUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_1001_amiya2.png',
      'quotes': [
        '博士，欢迎回来。无论前路如何，我们都会一起走下去。',
        '只要大家团结一心，就没有什么困难是克服不了的。',
        '我会一直陪在博士身边的，这是我的承诺。',
        '要相信明天会更好，因为我们正在为此努力。',
        '不管前路多么艰难，我们都要勇敢地走下去。',
        '希望，是我们前进的动力。',
        '每个人都有自己的价值，包括你也包括我。',
        '罗德岛是我们共同的家，我们要守护它。'
      ]
    },
    {
      'name': '德克萨斯',
      'codename': 'Texas',
      'rarity': '5',
      'profession': '先锋',
      'subProfession': '剑圣先锋',
      'avatarUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_102_texas.png',
      'illustrationUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_102_texas.png',
      'quotes': [
        '工作完成了。',
        '该走了。',
        '别让我等太久。',
        '有些事，必须要有人去做。',
        '企鹅物流，准时送达。',
        '过去的事就让它过去吧。',
        '我只是在做我应该做的事。',
        '没有什么是永恒的，包括痛苦。'
      ]
    },
    {
      'name': '银灰',
      'codename': 'SilverAsh',
      'rarity': '6',
      'profession': '近卫',
      'subProfession': '领主近卫',
      'avatarUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_172_svrash.png',
      'illustrationUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_172_svrash.png',
      'quotes': [
        '真银斩，开！',
        '为了卡西米尔的荣耀！',
        '我会保护重要的人。',
        '胜利的关键在于果断。',
        '这就是贵族的力量。',
        '力量必须配得上责任。',
        '优雅，是面对困境的态度。',
        '传承不仅是血脉，更是信念。'
      ]
    },
    {
      'name': '陈',
      'codename': 'Chen',
      'rarity': '6',
      'profession': '近卫',
      'subProfession': '剑豪近卫',
      'avatarUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_010_chen.png',
      'illustrationUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_010_chen.png',
      'quotes': [
        '为了龙门的和平！',
        '正义，从来不会迟到。',
        '这是我应该做的。',
        '龙门需要秩序。',
        '我会守护这座城市。',
        '法律面前，人人平等。',
        '正义的剑，为弱者而挥。',
        '秩序是文明的基石。'
      ]
    },
    {
      'name': '艾雅法拉',
      'codename': 'Eyjafjalla',
      'rarity': '6',
      'profession': '术师',
      'subProfession': '群攻术师',
      'avatarUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_180_amgoat.png',
      'illustrationUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_180_amgoat.png',
      'quotes': [
        '火山会记住一切。',
        '这是大地的力量。',
        '我们都是星尘的孩子。',
        '让我来守护大家。',
        '地质勘探是很有趣的工作。',
        '知识是人类最宝贵的财富。',
        '自然的力量，需要敬畏。',
        '学习让我们更接近真理。'
      ]
    },
    {
      'name': '能天使',
      'codename': 'Exusiai',
      'rarity': '6',
      'profession': '狙击',
      'subProfession': '速射狙击',
      'avatarUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_103_angel.png',
      'illustrationUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_103_angel.png',
      'quotes': [
        '苹果派最棒了！',
        '企鹅物流，使命必达！',
        '来一发吧！',
        '和我一起享受战斗的乐趣吧！',
        '正义总会到来，虽然有时会迟到。',
        '开心最重要啦！',
        '每一天都要充满活力！',
        '朋友就是要互相帮助的。'
      ]
    },
    {
      'name': '星熊',
      'codename': 'Hoshiguma',
      'rarity': '6',
      'profession': '重装',
      'subProfession': '守护者',
      'avatarUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_136_hsguma.png',
      'illustrationUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_136_hsguma.png',
      'quotes': [
        '交给我来守护。',
        '没有人能突破我的防线。',
        '我会挡在最前面。',
        '龙门的和平由我守护。',
        '有我在，就不用担心。',
        '守护，是我的天职。',
        '坚持到底，这就是我的信念。',
        '即使粉身碎骨，也要保护重要的人。'
      ]
    },
    {
      'name': '夜莺',
      'codename': 'Nightingale',
      'rarity': '6',
      'profession': '医疗',
      'subProfession': '疗养师',
      'avatarUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_179_cgbird.png',
      'illustrationUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_179_cgbird.png',
      'quotes': [
        '请让我来治愈你的伤痛。',
        '生命是珍贵的。',
        '我会保护所有人。',
        '希望之光永不熄灭。',
        '每一个生命都值得被拯救。',
        '温柔是治愈的良药。',
        '黑暗中，我是那盏明灯。',
        '痛苦终将过去，美好必会到来。'
      ]
    },
    {
      'name': '斯卡蒂',
      'codename': 'Skadi',
      'rarity': '6',
      'profession': '近卫',
      'subProfession': '剑豪近卫',
      'avatarUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_263_skadi.png',
      'illustrationUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_263_skadi.png',
      'quotes': [
        '大海的歌声，你听得见吗？',
        '我会斩断一切阻碍。',
        '深海的力量，在我剑中。',
        '孤独，是强者的宿命。',
        '海的另一边，有什么在等着我？',
        '追猎者，永不停歇。',
        '力量的代价，只有我知道。',
        '即使独自一人，我也会前行。'
      ]
    },
    {
      'name': '瑕光',
      'codename': 'Blemishine',
      'rarity': '6',
      'profession': '重装',
      'subProfession': '守护者',
      'avatarUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_423_blemsh.png',
      'illustrationUrl': 'https://web.hycdn.cn/arknights/game/assets/char_skin/char_423_blemsh.png',
      'quotes': [
        '光明会驱散所有黒暗！',
        '为了骑士的荣耀！',
        '正义之光，照耀前路。',
        '我会守护每一个人。',
        '希望的光芒，永不熄灭。',
        '骑士的誓言，神圣不可违背。',
        '即使微弱，光明依然是光明。',
        '勇敢面对，这就是骑士精神。'
      ]
    }
  ];

  // 励志金句库 - 更加深刻和有意境
  static const List<Map<String, String>> _inspirationalQuotes = [
    {
      'text': '纵使前路未卜，但征途不止。',
      'author': '罗德岛档案',
    },
    {
      'text': '希望是黑暗中唯一的光。',
      'author': '医疗部记录',
    },
    {
      'text': '每一步都是向前的进步。',
      'author': '行动记录',
    },
    {
      'text': '团结就是力量，信念就是希望。',
      'author': '作战条例',
    },
    {
      'text': '即使在最黑暗的时刻，也要相信黎明的到来。',
      'author': '罗德岛信条',
    },
    {
      'text': '勇气不是不害怕，而是带着恐惧继续前行。',
      'author': '战地手册',
    },
    {
      'text': '每个人都有自己的使命，我们要坚持到底。',
      'author': '干员守则',
    },
    {
      'text': '真正的强大来自内心的坚持。',
      'author': '心理评估报告',
    },
    {
      'text': '过去塑造了我们，但不会束缚我们。',
      'author': '个人档案',
    },
    {
      'text': '在废墟中寻找希望，在绝望中点燃光明。',
      'author': '灾区报告',
    }
  ];

  // 获取随机角色和金句
  Future<Quote> getRandomCharacterQuote() async {
    final random = Random();
    
    // 随机选择一个角色
    final characterData = _arknightsCharacters[random.nextInt(_arknightsCharacters.length)];
    final character = Character.fromJson(characterData);
    
    // 优先使用角色的专属金句
    String quoteText;
    String author;
    
    if (character.quotes.isNotEmpty && random.nextDouble() > 0.3) {
      // 70%概率使用角色专属金句
      quoteText = character.quotes[random.nextInt(character.quotes.length)];
      author = character.name;
    } else {
      // 30%概率使用励志金句
      final quoteData = _inspirationalQuotes[random.nextInt(_inspirationalQuotes.length)];
      quoteText = quoteData['text']!;
      author = quoteData['author']!;
    }
    
    return Quote(
      text: quoteText,
      author: author,
      character: character,
      tags: ['明日方舟', character.profession],
      date: DateTime.now(),
    );
  }

  // 获取每日角色和金句
  Future<Quote> getDailyCharacterQuote() async {
    // 使用日期作为种子，确保每天返回相同的角色和金句
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);
    
    // 基于日期选择角色
    final characterData = _arknightsCharacters[random.nextInt(_arknightsCharacters.length)];
    final character = Character.fromJson(characterData);
    
    // 选择角色相关的金句
    String quoteText;
    String author;
    
    if (character.quotes.isNotEmpty) {
      quoteText = character.quotes[random.nextInt(character.quotes.length)];
      author = character.name;
    } else {
      final quoteData = _inspirationalQuotes[random.nextInt(_inspirationalQuotes.length)];
      quoteText = quoteData['text']!;
      author = quoteData['author']!;
    }
    
    return Quote(
      text: quoteText,
      author: author,
      character: character,
      tags: ['每日', '明日方舟', character.profession],
      date: today,
    );
  }

  // 获取特定角色的金句
  Future<Quote> getCharacterQuote(String characterName) async {
    final random = Random();
    
    // 查找指定角色
    final characterData = _arknightsCharacters.firstWhere(
      (char) => char['name'] == characterName || char['codename'] == characterName,
      orElse: () => _arknightsCharacters[random.nextInt(_arknightsCharacters.length)],
    );
    
    final character = Character.fromJson(characterData);
    
    String quoteText;
    String author;
    
    if (character.quotes.isNotEmpty) {
      quoteText = character.quotes[random.nextInt(character.quotes.length)];
      author = character.name;
    } else {
      final quoteData = _inspirationalQuotes[random.nextInt(_inspirationalQuotes.length)];
      quoteText = quoteData['text']!;
      author = quoteData['author']!;
    }
    
    return Quote(
      text: quoteText,
      author: author,
      character: character,
      tags: ['明日方舟', character.profession],
      date: DateTime.now(),
    );
  }

  // 获取所有角色列表
  List<Character> getAllCharacters() {
    return _arknightsCharacters.map((data) => Character.fromJson(data)).toList();
  }

  // 获取角色职业列表
  List<String> getProfessions() {
    return _arknightsCharacters
        .map((char) => char['profession'] as String)
        .toSet()
        .toList();
  }

  // 搜索角色
  List<Character> searchCharacters(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _arknightsCharacters
        .where((char) =>
            char['name'].toString().toLowerCase().contains(lowercaseQuery) ||
            char['codename'].toString().toLowerCase().contains(lowercaseQuery) ||
            char['profession'].toString().toLowerCase().contains(lowercaseQuery))
        .map((data) => Character.fromJson(data))
        .toList();
  }

  // 备用方法 - 保持兼容性
  Future<Quote> getRandomQuote() async {
    return getRandomCharacterQuote();
  }

  Future<Quote> getDailyQuote() async {
    return getDailyCharacterQuote();
  }

  // 按主题获取金句
  Future<List<Quote>> getQuotesByTag(String tag) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quotes?tags=$tag&limit=20'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((item) => Quote(
          text: item['content'] ?? '',
          author: item['author'] ?? '未知',
          tags: List<String>.from(item['tags'] ?? []),
          date: DateTime.now(),
        )).toList();
      } else {
        return _getFallbackQuotesByCategory(tag);
      }
    } catch (e) {
      return _getFallbackQuotesByCategory(tag);
    }
  }

  // 搜索金句
  Future<List<Quote>> searchQuotes(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/quotes?query=${Uri.encodeComponent(query)}&limit=20'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((item) => Quote(
          text: item['content'] ?? '',
          author: item['author'] ?? '未知',
          tags: List<String>.from(item['tags'] ?? []),
          date: DateTime.now(),
        )).toList();
      } else {
        return _searchFallbackQuotes(query);
      }
    } catch (e) {
      return _searchFallbackQuotes(query);
    }
  }

  // 获取备用金句
  Quote _getFallbackQuote({int? seed}) {
    final random = seed != null ? Random(seed) : Random();
    final index = random.nextInt(_inspirationalQuotes.length);
    final quoteData = _inspirationalQuotes[index];
    
    return Quote(
      text: quoteData['text']!,
      author: quoteData['author']!,
      tags: ['励志', '人生'],
      date: DateTime.now(),
    );
  }

  // 按分类获取备用金句
  List<Quote> _getFallbackQuotesByCategory(String category) {
    return _inspirationalQuotes.map((quoteData) => Quote(
      text: quoteData['text']!,
      author: quoteData['author']!,
      tags: ['励志', '人生', category],
      date: DateTime.now(),
    )).toList();
  }

  // 搜索备用金句
  List<Quote> _searchFallbackQuotes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _inspirationalQuotes
        .where((quoteData) =>
            quoteData['text']!.toLowerCase().contains(lowercaseQuery) ||
            quoteData['author']!.toLowerCase().contains(lowercaseQuery))
        .map((quoteData) => Quote(
              text: quoteData['text']!,
              author: quoteData['author']!,
              tags: ['励志', '人生'],
              date: DateTime.now(),
            ))
        .toList();
  }

  // 获取金句分类
  List<String> getCategories() {
    return [
      '励志',
      '人生',
      '成功',
      '智慧',
      '爱情',
      '友谊',
      '教育',
      '科学',
      '艺术',
      '哲学',
    ];
  }
} 