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
          final screenWidth = MediaQuery.of(context).size.width;

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
                          Container(
                            width: screenWidth * 0.85,
                            constraints: const BoxConstraints(
                              maxWidth: 550,
                            ),
                            child: _TimeBar(nextRefreshTime: _nextRefreshTime)
                          ),
                          const SizedBox(height: 30),
                          QuoteDisplay(quote: quote),
                          const SizedBox(height: 20),
                          _TimelineIndicator(nextRefreshTime: _nextRefreshTime),
                          const SizedBox(height: 80), // Push content up
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
    final dateStr = '${now.month.toString().padLeft(2, '0')}月${now.day.toString().padLeft(2, '0')}日';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final timeUntilRefresh = nextRefreshTime.difference(now);
    final minutesUntilRefresh = timeUntilRefresh.inMinutes;
    final refreshText = minutesUntilRefresh > 0 ? '$minutesUntilRefresh 分钟后刷新' : '即将刷新...';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(Icons.access_time, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Text(
            timeStr,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Text(
            dateStr,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(width: 12),
          Text(
            refreshText,
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _TimelineIndicator extends StatelessWidget {
  final DateTime nextRefreshTime;

  const _TimelineIndicator({required this.nextRefreshTime});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final now = DateTime.now();
    final timeUntilRefresh = nextRefreshTime.difference(now);
    const totalDuration = Duration(hours: 1);
    
    final double progress = (totalDuration.inSeconds - timeUntilRefresh.inSeconds) / totalDuration.inSeconds;

    return Container(
      width: screenWidth * 0.85,
      constraints: const BoxConstraints(
        maxWidth: 550,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
          minHeight: 4,
        ),
      ),
    );
  }
} 