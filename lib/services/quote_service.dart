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
      profession: '近卫',
      avatarUrl: 'assets/charpack/1.png',
      illustrationUrl: 'assets/charpack/1.png',
      backgroundUrl: 'assets/bg/1.png',
      quotes: [
        '银灰，你的盟友，前来助力。你不会让我失望的，对吗。',
        '拿出你们全部的实力——这样至少能让我尽兴。',
        '雪下大了......远方谢拉格的风雪年年依旧，而政治棋局上的变动却不曾停息片刻。所有无法追赶上变化的，都会被这陈年风雪所掩埋。',
        '没什么变化啊，我的盟友。',
        '不错的战斗，即使是我都能感到心潮澎湃。',
        '罗德岛已经不止一次向我展示了，它作为一家医疗公司的能力与责任。但是我很好奇，你的目光，会仅仅停留在矿石病上吗？未来，你会带给这片大地什么新的波澜？我很期待。'
      ],
    ),
    
    // 2. 星极
    Character(
      name: '星极',
      codename: 'Astgenne',
      rarity: '6',
      profession: '近卫',
      avatarUrl: 'assets/charpack/2.png',
      illustrationUrl: 'assets/charpack/2.png',
      backgroundUrl: 'assets/bg/2.png',
      quotes: [
        '我在这里，博士。',
        '群星为我们照亮前路。',
        '游禽翱翔星海，借您羽翼一用！',
        '早安，博士。',
        '我之剑光，即为星光！',
        '夜晚总会结束，群星也终将落幕，如果这就是一切的尽头，那我该做些有意义的事情了。比如？唔......博士，您介意我每天清晨叫醒您吗？'
      ],
    ),
    
    // 3. 菲亚梅塔
    Character(
      name: '菲亚梅塔',
      codename: 'Fiammetta',
      rarity: '6',
      profession: '狙击',
      avatarUrl: 'assets/charpack/3.png',
      illustrationUrl: 'assets/charpack/3.png',
      backgroundUrl: 'assets/bg/3.png',
      quotes: [
        '我去过很多国家，不是没有比拉特兰更打动我的地方，但现在我很清楚自己要的是什么。这座拉特兰城，任何人都别想伤害它。我已经不必再找谁要什么答案了。',
        '......不许叫我"苦难陈述者"，"神选监工"和"燃烧使者"也不行！够了，不管莫斯提马那混蛋还和你说了什么，现在就给我全部忘掉！立刻，马上！',
        '拉特兰的规矩是谁弄坏的东西，谁自己赔。不过任务中合理的财物损失可以报销。是你让我出手，赔偿费当然也算你头上......怎么，你该不会后悔了吧。',
        '别闹出太大动静。',
        '别来无恙。'
      ],
    ),
    
    // 4. 史尔特尔
    Character(
      name: '史尔特尔',
      codename: 'Surtr',
      rarity: '6',
      profession: '近卫',
      avatarUrl: 'assets/charpack/4.png',
      illustrationUrl: 'assets/charpack/4.png',
      backgroundUrl: 'assets/bg/4.png',
      quotes: [
        '不要让我去给其他人做法术指导了，我可没兴趣去跟一群普通人玩源石技艺游戏。',
        '我是史尔特尔，你就是他们说的博士吗。今后我会在罗德岛工作，希望你们不要让我觉得无聊。',
        '莱万汀！',
        '没用的人都赶快撤退！这里我来。',
        '看重的不是这能力，而是我本身？既然你都这样说了，那我也拿出相应的努力来回报你吧。'
      ],
    ),
    
    // 5. 迷迭香
    Character(
      name: '迷迭香',
      codename: 'Rosemary',
      rarity: '6',
      profession: '狙击',
      avatarUrl: 'assets/charpack/5.png',
      illustrationUrl: 'assets/charpack/5.png',
      backgroundUrl: 'assets/bg/5.png',
      quotes: [
        '罗德岛的大家是我的朋友，精英干员和我的队员们是我的家人。凯尔希不想我把他们当做亲人，最开始我不明白，现在我懂了。他们就像花瓶里的花一样，稍不注意就会枯掉。但我只有他们了。',
        '我现在在读什么？啊，这是前两天的记事。可露希尔早上打翻了咖啡，弄脏了书库里的好几册卷轴，所以她被诅咒了呢，好像是，说满五句话就一定会有唾沫飞到别人脸上的那种诅咒。很可怕？',
        '痛的事情，伤心的事情，可怕的事情，一不小心就会消失。但我不能忘，我要记住，因为那些情感还留在我的身体里。我不想哭的时候不知道是为了什么在哭。记忆是负担，我只有自己去背。',
        '这片大地不会那么轻易就变好的，人却很容易就随着周围的东西一起变坏了。博士，我们不可以变成坏人。你要是变坏，会很坏很坏。我不会让你变成那样。'
      ],
    ),
    
    // 6. 羽毛笔
    Character(
      name: '羽毛笔',
      codename: 'Quill',
      rarity: '5',
      profession: '近卫',
      avatarUrl: 'assets/charpack/6.png',
      illustrationUrl: 'assets/charpack/6.png',
      backgroundUrl: 'assets/bg/6.png',
      quotes: [
        '做博士的护卫？好哦。',
        '多索雷斯虽然很吵闹，也有许多坏人，但是在那里的生活还是比在外面的玻利瓦尔要好许多呢......博士没有去过吗？那下次一起去吧。',
        '呼......一整天都待在房间里感觉好闷。博士，我们一起去甲板上呼吸新鲜空气吧？博士工作了这么久也累了吧。',
        '欸，要出任务了吗？',
        '快点结束掉吧。'
      ],
    ),
    
    // 7. 阿米娅
    Character(
      name: '阿米娅',
      codename: 'Amiya',
      rarity: '5',
      profession: '术师',
      avatarUrl: 'assets/charpack/7.png',
      illustrationUrl: 'assets/charpack/7.png',
      backgroundUrl: 'assets/bg/7.png',
      quotes: [
        '罗德岛全舰正处于通常航行状态。博士，整理下航程信息吧？',
        '嘿嘿，博士，悄悄告诉你一件事——我重新开始练小提琴了。',
        '有时候，我会想起寒冷的家乡，那里就连空气中都弥漫着铜锈的味道。相比之下罗德岛是如此的温暖。所以，为了守护好这里，我必须更加努力才行。',
        '能再一次和您并肩作战真是太好了，博士！',
        '无论多么艰难的任务，只要有博士在，就一定能完成，我一直这样坚信着！'
      ],
    ),
    
    // 8. 新约能天使
    Character(
      name: '新约能天使',
      codename: 'Exusiai_Alter',
      rarity: '6',
      profession: '特种',
      avatarUrl: 'assets/charpack/8.png',
      illustrationUrl: 'assets/charpack/8.png',
      backgroundUrl: 'assets/bg/8.png',
      quotes: [
        '老板，快递放你门口了，记得有空从文件堆里抬个头扫码签收哦！哎，奇怪......明明你分配出去那么多的差事，怎么自己却越来越忙了？',
        '啊——啊嚏！嗯？唉，刚刚打个喷嚏老姐都要发条短讯问一下。不要啊，共感太强也有不方便啊！老姐，你最近简直就像住在我的脑子里一样，亲密过头可是会失去私密空间的！',
        '这家店怎么还在歇业？唉，灾异过后，修补建筑要好久，律法也变了，新的共感方式大家也要花时间适应，不知道未来会变成什么样？欸，冰淇淋车？老板，快跟我追上去！未来？未来就在新口味里！',
        '缺少照明设备？没关系，我头上这顶日光灯会把前面的路照清楚......如果它不熄灭的话。应该不会了吧？',
        '想吃子弹，就给我一个一个排好队——！'
      ],
    ),
    
    // 9. 令
    Character(
      name: '令',
      codename: 'Ling',
      rarity: '6',
      profession: '辅助',
      avatarUrl: 'assets/charpack/9.png',
      illustrationUrl: 'assets/charpack/9.png',
      backgroundUrl: 'assets/bg/9.png',
      quotes: [
        '真让人怀念，很多年前，我也曾如今天这般走入那谋臣似雨的阁楼。',
        '在心为志，发言为诗，若满腔胸臆，气象万千，不写出来岂不是愧对自己？嗯？尾巴？呵呵，笔自然也是用的，但毕竟是外物，不方便嘛，我身既是逍遥身，谁说用尾巴就不行？',
        '本以为总算能遇见一位故人，说不定，还是故知，不曾想，你却是如今这般模样。不知我是我，与大梦何异？不过博士，就当你自己也无妨，我与我周旋久，宁做我。',
        '醉了？呵......尚未见天开月明，海走冰散，真等到世人皆醒，也不过枯枝一新芽，真要大醉一场，还为时尚早......博士呀，你怎么能说我醉了呢？',
        '云峦波涛，千里枯路，江山故人我，晚秋行舟。',
        '直抒胸臆，酣畅淋漓。',
        '万物一言，方有大气象。'
      ],
    ),
    
    // 10. 重岳
    Character(
      name: '重岳',
      codename: 'Chongyue',
      rarity: '6',
      profession: '最强近卫',
      avatarUrl: 'assets/charpack/10.png',
      illustrationUrl: 'assets/charpack/10.png',
      backgroundUrl: 'assets/bg/10.png',
      quotes: [
        '"博士"，这个称呼让我想起打过交道的大炎学士，体察万千，见微知著。你我似是故人？那场混沌梦醒后，我确实去过许多地方......知交越多，越是寥落，可能在这点上，我们有些相似吧。',
        '如你所见，我时常记下来的，只是一些体悟，而非具体的武功招式。武道在"意"，受限于那些花哨的形式便再难突破。好比看不出夕画里的意境，非抓着她讨论笔力技法，免不了要吃闭门羹。',
        '城头的烽火，总是这样熄了又燃。',
        '日落飞锦绣长河，天地壮我行色。',
        '征蓬未定，甲胄在身。',
        '形不成形，意不在意，再去练练吧。',
        '千招百式在一息！',
        '劲发江潮落，气收秋毫平！',
        '征鼓一声千军动，掬罢黄沙浣铁衣......好一场大胜！'
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