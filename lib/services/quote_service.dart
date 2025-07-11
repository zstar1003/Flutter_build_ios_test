import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  static const String _baseUrl = 'https://api.quotable.io';
  static final Random _random = Random();
  
  static final List<Map<String, String>> _quotes = [
    {'text': '路漫漫其修远兮，吾将上下而求索。', 'author': '屈原', 'source': '《离骚》'},
    {'text': '亦余心之所善兮，虽九死其犹未悔。', 'author': '屈原', 'source': '《离骚》'},
    {'text': '君不见黄河之水天上来，奔流到海不复回。', 'author': '李白', 'source': '《将进酒》'},
    {'text': '天生我材必有用，千金散尽还复来。', 'author': '李白', 'source': '《将进酒》'},
    {'text': '长风破浪会有时，直挂云帆济沧海。', 'author': '李白', 'source': '《行路难·其一》'},
    {'text': '国破山河在，城春草木深。', 'author': '杜甫', 'source': '《春望》'},
    {'text': '安得广厦千万间，大庇天下寒士俱欢颜。', 'author': '杜甫', 'source': '《茅屋为秋风所破歌》'},
    {'text': '在天愿作比翼鸟，在地愿为连理枝。', 'author': '白居易', 'source': '《长恨歌》'},
    {'text': '野火烧不尽，春风吹又生。', 'author': '白居易', 'source': '《赋得古原草送别》'},
    {'text': '但愿人长久，千里共婵娟。', 'author': '苏轼', 'source': '《水调歌头·明月几时有》'},
    {'text': '不识庐山真面目，只缘身在此山中。', 'author': '苏轼', 'source': '《题西林壁》'},
    {'text': '寻寻觅觅，冷冷清清，凄凄惨惨戚戚。', 'author': '李清照', 'source': '《声声慢·寻寻觅觅》'},
    {'text': '生当作人杰，死亦为鬼雄。', 'author': '李清照', 'source': '《夏日绝句》'},
    {'text': '采菊东篱下，悠然见南山。', 'author': '陶渊明', 'source': '《饮酒·其五》'},
    {'text': '大漠孤烟直，长河落日圆。', 'author': '王维', 'source': '《使至塞上》'},
    {'text': '山重水复疑无路，柳暗花明又一村。', 'author': '陆游', 'source': '《游山西村》'},
    {'text': '夜阑卧听风吹雨，铁马冰河入梦来。', 'author': '陆游', 'source': '《十一月四日风雨大作》'},
  ];

  Future<Quote> fetchRandomQuote() async {
    final response = await http.get(Uri.parse('$_baseUrl/random'));
    if (response.statusCode == 200) {
      return Quote.fromJson(jsonDecode(response.body));
    } else {
      // Fallback to local quotes if API fails
      return _getRandomLocalQuote();
    }
  }

  static Future<Quote> getRandomQuote() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    return _getRandomLocalQuote();
  }

  static Quote _getRandomLocalQuote() {
    final quoteData = _quotes[_random.nextInt(_quotes.length)];
    return Quote(
      text: quoteData['text']!,
      author: quoteData['author']!,
      source: quoteData['source']!,
    );
  }
} 