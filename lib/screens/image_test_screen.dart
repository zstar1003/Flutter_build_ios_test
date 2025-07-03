import 'package:flutter/material.dart';

class ImageTestScreen extends StatelessWidget {
  static const List<String> charpack = [
    'assets/charpack/1.png',
    'assets/charpack/2.png',
    'assets/charpack/3.png',
    'assets/charpack/4.png',
    'assets/charpack/5.png',
    'assets/charpack/6.png',
    'assets/charpack/7.png',
    'assets/charpack/8.png',
    'assets/charpack/9.png',
    'assets/charpack/10.png',
  ];
  static const List<String> bg = [
    'assets/bg/1.png',
    'assets/bg/2.png',
    'assets/bg/3.png',
    'assets/bg/4.png',
    'assets/bg/5.png',
    'assets/bg/6.png',
    'assets/bg/7.png',
    'assets/bg/8.png',
    'assets/bg/9.png',
    'assets/bg/10.png',
  ];
  static const List<String> operater = [
    'assets/operater/1.png',
    'assets/operater/2.png',
    'assets/operater/3.png',
    'assets/operater/4.png',
    'assets/operater/5.png',
  ];
  static const List<String> logo = [
    'assets/logo/logo.png',
    'assets/logo/logo_laios.png',
  ];

  static const List<Map<String, dynamic>> groups = [
    {'title': 'charpack', 'list': charpack},
    {'title': 'bg', 'list': bg},
    {'title': 'operater', 'list': operater},
    {'title': 'logo', 'list': logo},
  ];

  const ImageTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图片批量检测')), 
      body: ListView(
        children: [
          for (final group in groups) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                group['title'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: (group['list'] as List).length,
              itemBuilder: (context, idx) {
                final path = group['list'][idx];
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          path,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.red.shade100,
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.red, size: 40),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          path,
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
} 