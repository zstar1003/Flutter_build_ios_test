import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quote_provider.dart';
import '../widgets/quote_display.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _autoRefreshTimer;
  late Timer _timeUpdateTimer;
  DateTime _nextRefreshTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    _setupTimers();
  }

  void _setupTimers() {
    // Timer for auto-refreshing the quote every hour
    _autoRefreshTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (mounted) {
        Provider.of<QuoteProvider>(context, listen: false).fetchQuote();
        setState(() {
          _nextRefreshTime = DateTime.now().add(const Duration(hours: 1));
        });
      }
    });

    // Timer to update the time display every second
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer.cancel();
    _timeUpdateTimer.cancel();
    super.dispose();
  }

  void _manualRefresh() {
    Provider.of<QuoteProvider>(context, listen: false).fetchQuote();
    setState(() {
      _nextRefreshTime = DateTime.now().add(const Duration(hours: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentQuote == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '加载失败: ${provider.error}\n点击屏幕重试',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            );
          }
          
          final quote = provider.currentQuote;
          final backgroundImage = provider.backgroundImage;

          return GestureDetector(
            onTap: _manualRefresh,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (backgroundImage != null)
                  Image.asset(
                    backgroundImage,
                    fit: BoxFit.cover,
                    key: ValueKey(backgroundImage), // Ensures image transition on change
                  ),
                
                Container(
                  color: Colors.black.withOpacity(0.4),
                ),

                if (quote != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),
                          QuoteDisplay(quote: quote),
                          const Spacer(flex: 2),
                          _TimeBar(nextRefreshTime: _nextRefreshTime),
                          const Spacer(flex: 1),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TimeBar extends StatelessWidget {
  final DateTime nextRefreshTime;
  
  const _TimeBar({required this.nextRefreshTime});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final timeUntilRefresh = nextRefreshTime.difference(now);
    final minutesUntilRefresh = timeUntilRefresh.inMinutes;
    final refreshText = minutesUntilRefresh > 0 ? '$minutesUntilRefresh 分钟后刷新' : '即将刷新...';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            timeStr,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Text(
            dateStr,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(width: 12),
          Text(
            refreshText,
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
          ),
        ],
      ),
    );
  }
} 