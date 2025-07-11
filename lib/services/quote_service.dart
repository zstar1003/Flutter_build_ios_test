import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  static const String _baseUrl = 'https://api.quotable.io';
  static final Random _random = Random();
  
  static final List<String> _quotes = [
    '路漫漫其修远兮，吾将上下而求索。',
    '举世皆浊我独清，众人皆醉我独醒。',
    '长太息以掩涕兮，哀民生之多艰。',
    '亦余心之所善兮，虽九死其犹未悔。',
    '君不见黄河之水天上来，奔流到海不复回。',
    '天生我材必有用，千金散尽还复来。',
    '长风破浪会有时，直挂云帆济沧海。',
    '抽刀断水水更流，举杯消愁愁更愁。',
    '安能摧眉折腰事权贵，使我不得开心颜。',
    '国破山河在，城春草木深。',
    '感时花溅泪，恨别鸟惊心。',
    '烽火连三月，家书抵万金。',
    '白日放歌须纵酒，青春作伴好还乡。',
    '文章千古事，得失寸心知。',
    '在天愿作比翼鸟，在地愿为连理枝。',
    '天长地久有时尽，此恨绵绵无绝期。',
    '野火烧不尽，春风吹又生。',
    '同是天涯沦落人，相逢何必曾相识。',
    '采菊东篱下，悠然见南山。',
    '悟已往之不谏，知来者之可追。',
    '羁鸟恋旧林，池鱼思故渊。',
    '大漠孤烟直，长河落日圆。',
    '明月松间照，清泉石上流。',
    '劝君更尽一杯酒，西出阳关无故人。',
    '春眠不觉晓，处处闻啼鸟。',
    '夜来风雨声，花落知多少。',
    '山重水复疑无路，柳暗花明又一村。',
    '僵卧孤村不自哀，尚思为国戍轮台。',
    '夜阑卧听风吹雨，铁马冰河入梦来。',
    '寻寻觅觅，冷冷清清，凄凄惨惨戚戚。',
    '生当作人杰，死亦为鬼雄。',
    '至今思项羽，不肯过江东。',
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
    final quoteContent = _quotes[_random.nextInt(_quotes.length)];
    return Quote(
      text: quoteContent,
    );
  }
} 