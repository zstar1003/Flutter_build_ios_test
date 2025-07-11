import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  final Random _random = Random();

  Future<Quote> fetchQuoteFromNetwork() async {
    try {
      final response = await http
          .get(Uri.parse('https://hub.saintic.com/openservice/sentence/'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final quoteData = responseData['data'];

        if (quoteData != null && responseData['success'] == true) {
          return Quote(
            text: quoteData['sentence'] ?? '未知诗句',
            author: quoteData['author'] ?? '佚名',
            source: quoteData['name'] ?? '',
          );
        } else {
          throw Exception('Failed to parse quote from network response');
        }
      } else {
        throw Exception('Failed to load quote from network');
      }
    } catch (e) {
      rethrow;
    }
  }

  final List<Map<String, String>> _localQuotes = [
    {
      "text": "山有木兮木有枝，心悦君兮君不知。",
      "author": "佚名",
      "source": "《越人歌》"
    },
    {
      "text": "人生若只如初见，何事秋风悲画扇。",
      "author": "纳兰性德",
      "source": "《木兰词·拟古决绝词柬友》"
    },
    {
      "text": "十年生死两茫茫，不思量，自难忘。",
      "author": "苏轼",
      "source": "《江城子·乙卯正月二十日夜记梦》"
    },
    {
      "text": "曾经沧海难为水，除却巫山不是云。",
      "author": "元稹",
      "source": "《离思五首·其四》"
    },
    {
      "text": "玲珑骰子安红豆，入骨相思知不知。",
      "author": "温庭筠",
      "source": "《南歌子词二首 / 新添声杨柳枝词》"
    },
    {
      "text": "身无彩凤双飞翼，心有灵犀一点通。",
      "author": "李商隐",
      "source": "《无题·昨夜星辰昨夜风》"
    },
    {
      "text": "此情可待成追忆，只是当时已惘然。",
      "author": "李商隐",
      "source": "《锦瑟》"
    },
    {
      "text": "衣带渐宽终不悔，为伊消得人憔悴。",
      "author": "柳永",
      "source": "《蝶恋花·伫倚危楼风细细》"
    },
    {
      "text": "众里寻他千百度，蓦然回首，那人却在，灯火阑珊处。",
      "author": "辛弃疾",
      "source": "《青玉案·元夕》"
    },
    {
      "text": "愿得一心人，白头不相离。",
      "author": "卓文君",
      "source": "《白头吟》"
    }
  ];

  Quote getRandomLocalQuote() {
    final quoteData = _localQuotes[_random.nextInt(_localQuotes.length)];
    return Quote(
      text: quoteData['text']!,
      author: quoteData['author']!,
      source: quoteData['source']!,
    );
  }

  String getNextBackground() {
    return 'assets/bg/${_random.nextInt(10) + 1}.jpg';
  }
} 