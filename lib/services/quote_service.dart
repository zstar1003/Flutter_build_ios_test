import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  static const String _baseUrl = 'https://api.quotable.io';
  static final Random _random = Random();
  
  // 明日方舟角色数据 - 使用本地资源
  static const List<Character> _arknightsCharacters = [
    // 1. 银灰
    Character(
      name: '银灰',
      codename: 'SilverAsh',
      rarity: '6',
      profession: 'GUARD',
      avatarUrl: 'assets/charpack/1.png',
      illustrationUrl: 'assets/charpack/1.png',
      backgroundUrl: 'assets/bg/1.png',
      quotes: [
        '真银斩，开启。',
        '为了卡西米尔的荣耀！',
        '我会保护重要的人。',
        '胜利的关键在于果断。',
        '这就是贵族的力量。',
        '战略的精髓，在于掌握时机。',
        '家族的荣誉，由我来守护。',
        '让暴风雪来得更猛烈些吧。'
      ],
    ),
    
    // 2. 星极
    Character(
      name: '星极',
      codename: 'Astgenne',
      rarity: '6',
      profession: 'DEFENDER',
      avatarUrl: 'assets/charpack/2.png',
      illustrationUrl: 'assets/charpack/2.png',
      backgroundUrl: 'assets/bg/2.png',
      quotes: [
        '星光指引着前路。',
        '我会守护每一个人。',
        '黑暗中，我是那道光芒。',
        '星空见证我的誓言。',
        '即使在最深的黑夜，星光也不会熄灭。',
        '这就是星极的力量。',
        '守护是我的使命。',
        '光明永远战胜黑暗。'
      ],
    ),
    
    // 3. 菲亚梅塔
    Character(
      name: '菲亚梅塔',
      codename: 'Fiammetta',
      rarity: '6',
      profession: 'SNIPER',
      avatarUrl: 'assets/charpack/3.png',
      illustrationUrl: 'assets/charpack/3.png',
      backgroundUrl: 'assets/bg/3.png',
      quotes: [
        '审判的时刻到了。',
        '罪恶必须得到净化。',
        '火焰会洗涤一切罪孽。',
        '这就是天使的力量。',
        '正义的审判，不容质疑。',
        '净化之火，燃烧不息。',
        '背叛者的末日已经来临。',
        '圣光指引着我的道路。'
      ],
    ),
    
    // 4. 史尔特尔
    Character(
      name: '史尔特尔',
      codename: 'Surtr',
      rarity: '6',
      profession: 'GUARD',
      avatarUrl: 'assets/charpack/4.png',
      illustrationUrl: 'assets/charpack/4.png',
      backgroundUrl: 'assets/bg/4.png',
      quotes: [
        '一切都会燃烧殆尽。',
        '这就是终结的力量。',
        '没有什么能阻挡我的剑。',
        '毁灭，是新生的开始。',
        '烈焰与黄昏的见证者。',
        '末日的钟声已经响起。',
        '我就是终结本身。',
        '在烈火中获得重生。'
      ],
    ),
    
    // 5. 迷迭香
    Character(
      name: '迷迭香',
      codename: 'Rosemary',
      rarity: '6',
      profession: 'CASTER',
      avatarUrl: 'assets/charpack/5.png',
      illustrationUrl: 'assets/charpack/5.png',
      backgroundUrl: 'assets/bg/5.png',
      quotes: [
        '命运的齿轮开始转动。',
        '未来，由我来书写。',
        '这就是预言的力量。',
        '时间会证明一切。',
        '星辰指引着前进的方向。',
        '命运早已注定。',
        '智慧的光芒照耀前路。',
        '让我来预见未来。'
      ],
    ),
    
    // 6. 羽毛笔
    Character(
      name: '羽毛笔',
      codename: 'Quill',
      rarity: '5',
      profession: 'SUPPORTER',
      avatarUrl: 'assets/charpack/6.png',
      illustrationUrl: 'assets/charpack/6.png',
      backgroundUrl: 'assets/bg/6.png',
      quotes: [
        '知识就是力量。',
        '让我来记录这一切。',
        '历史的真相必须被保存。',
        '文字的力量超乎想象。',
        '真理只有一个。',
        '记录下这重要的时刻。',
        '智慧之光永不熄灭。',
        '每一个字都有其价值。'
      ],
    ),
    
    // 7. 阿米娅
    Character(
      name: '阿米娅',
      codename: 'Amiya',
      rarity: '5',
      profession: 'CASTER',
      avatarUrl: 'assets/charpack/7.png',
      illustrationUrl: 'assets/charpack/7.png',
      backgroundUrl: 'assets/bg/7.png',
      quotes: [
        '博士，欢迎回来。无论前路如何，我们都会一起走下去。',
        '只要大家团结一心，就没有什么困难是克服不了的。',
        '我会一直陪在博士身边的，这是我的承诺。',
        '要相信明天会更好，因为我们正在为此努力。',
        '不管前路多么艰难，我们都要勇敢地走下去。',
        '每个人都有属于自己的光芒。',
        '罗德岛的大家，都是我最重要的伙伴。',
        '为了大家的未来，我愿意承担一切。'
      ],
    ),
    
    // 8. 新约能天使
    Character(
      name: '新约能天使',
      codename: 'Exusiai_Alter',
      rarity: '6',
      profession: 'SNIPER',
      avatarUrl: 'assets/charpack/8.png',
      illustrationUrl: 'assets/charpack/8.png',
      backgroundUrl: 'assets/bg/8.png',
      quotes: [
        '苹果派的味道，依然那么美好。',
        '这就是新的力量。',
        '企鹅物流，永远不变。',
        '正义的子弹，精准无误。',
        '为了更美好的明天而战。',
        '守护重要的人和事。',
        '这份热忱，永远不会消失。',
        '让世界充满甜蜜与正义。'
      ],
    ),
    
    // 9. 令
    Character(
      name: '令',
      codename: 'Ling',
      rarity: '6',
      profession: 'SUPPORTER',
      avatarUrl: 'assets/charpack/9.png',
      illustrationUrl: 'assets/charpack/9.png',
      backgroundUrl: 'assets/bg/9.png',
      quotes: [
        '龙的力量，古老而强大。',
        '岁月流转，唯有传承不变。',
        '这就是龙王的威严。',
        '古老的智慧指引着道路。',
        '传统与现代的完美融合。',
        '龙之血脉，永不断绝。',
        '千年的积淀，今日绽放。',
        '守护着这片土地的安宁。'
      ],
    ),
    
    // 10. 重岳
    Character(
      name: '重岳',
      codename: 'Chongyue',
      rarity: '6',
      profession: 'GUARD',
      avatarUrl: 'assets/charpack/10.png',
      illustrationUrl: 'assets/charpack/10.png',
      backgroundUrl: 'assets/bg/10.png',
      quotes: [
        '山岳的力量，坚不可摧。',
        '大地为我作证。',
        '这就是不屈的意志。',
        '如山般稳重，如岳般坚定。',
        '承载着大地的厚重。',
        '千钧之力，一击必杀。',
        '稳如泰山，动若雷霆。',
        '守护之心，重如山岳。'
      ],
    ),
  ];

  // 备用励志金句
  static const List<Map<String, String>> _inspirationalQuotes = [
    {
      'text': '每一个黎明都是新的开始，每一个挑战都是成长的机会。',
      'author': '泰拉观察者',
    },
    {
      'text': '在最黑暗的时刻，希望的光芒最为珍贵。',
      'author': '罗德岛档案',
    },
    {
      'text': '团结的力量能够战胜一切困难。',
      'author': '作战记录',
    },
    {
      'text': '勇气不是没有恐惧，而是面对恐惧依然前行。',
      'author': '心理评估',
    },
    {
      'text': '每个人都有属于自己的战场，关键是坚持到底。',
      'author': '医疗报告',
    },
    {
      'text': '智慧在于知道何时前进，何时等待。',
      'author': '战术手册',
    },
    {
      'text': '友谊是最强大的武器，也是最温暖的港湾。',
      'author': '人员档案',
    },
    {
      'text': '改变世界从改变自己开始。',
      'author': '个人日志',
    },
    {
      'text': '梦想是前进的动力，行动是实现的途径。',
      'author': '培训记录',
    },
    {
      'text': '在废墟中播种希望，在绝望中点亮明灯。',
      'author': '重建计划',
    },
    {
      'text': '时间会治愈伤痛，但经历会让我们更加坚强。',
      'author': '康复日记',
    },
    {
      'text': '每个人的存在都有其意义，每份努力都值得尊重。',
      'author': '价值评估',
    },
    {
      'text': '困难是成长的阶梯，挫折是智慧的源泉。',
      'author': '成长记录',
    },
    {
      'text': '保持初心，方得始终。',
      'author': '新人指导',
    },
    {
      'text': '相信明天会更好，因为我们正在努力让它变得更好。',
      'author': '未来规划',
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

  // 获取所有角色
  static List<Character> getAllCharacters() {
    return _arknightsCharacters;
  }

  // 根据索引获取角色
  static Character getCharacterByIndex(int index) {
    return _arknightsCharacters[index % _arknightsCharacters.length];
  }

  // 获取随机角色
  static Character getRandomCharacter() {
    return _arknightsCharacters[_random.nextInt(_arknightsCharacters.length)];
  }

  // 获取每日角色（基于日期的固定随机）
  static Character getDailyCharacter() {
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);
    return _arknightsCharacters[random.nextInt(_arknightsCharacters.length)];
  }

  // 获取每日金句
  static String getDailyQuote() {
    final character = getDailyCharacter();
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);
    return character.quotes[random.nextInt(character.quotes.length)];
  }

  // 备用方法：从网络API获取英文金句
  static Future<String> getRandomQuoteFromAPI() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/random'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return '${data['content']} - ${data['author']}';
      }
    } catch (e) {
      // 忽略网络错误
    }
    
    // 如果网络请求失败，返回默认金句
    return getDailyQuote();
  }

  // 获取特定角色的金句
  Future<Quote> getCharacterQuote(String characterName) async {
    final random = Random();
    
    // 查找指定角色
    final characterData = _arknightsCharacters.firstWhere(
      (char) => char.name == characterName || char.codename == characterName,
      orElse: () => _arknightsCharacters[random.nextInt(_arknightsCharacters.length)],
    );
    
    final character = characterData;
    
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

  // 获取角色职业列表
  List<String> getProfessions() {
    return _arknightsCharacters
        .map((char) => char.profession)
        .toSet()
        .toList();
  }

  // 搜索角色
  List<Character> searchCharacters(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _arknightsCharacters
        .where((char) =>
            char.name.toLowerCase().contains(lowercaseQuery) ||
            char.codename.toLowerCase().contains(lowercaseQuery) ||
            char.profession.toLowerCase().contains(lowercaseQuery))
        .toList();
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