import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/presentation/screens/blocked_apps_screen.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();

  
}

class _FocusTimerScreenState extends State<FocusTimerScreen> with WidgetsBindingObserver {
  Duration _focusDuration = const Duration(minutes: 25);
  Duration _remaining = const Duration(minutes: 25);
  Timer? _timer;
  bool _isRunning = false;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTimerState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _saveTimerState();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveTimerState();
    } else if (state == AppLifecycleState.resumed) {
      _loadTimerState();
    }
  }

  void _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isRunning && _endTime != null) {
      prefs.setString('focus_end_time', _endTime!.toIso8601String());
    } else {
      prefs.remove('focus_end_time');
    }
  }

  void _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final endTimeStr = prefs.getString('focus_end_time');

    if (endTimeStr != null) {
      final endTime = DateTime.tryParse(endTimeStr);
      if (endTime != null) {
        final now = DateTime.now();
        final diff = endTime.difference(now);

        if (diff > Duration.zero) {
          setState(() {
            _endTime = endTime;
            _remaining = diff;
            _isRunning = true;
          });
          _startTimer();
        } else {
          _resetTimer();
        }
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _endTime = DateTime.now().add(_remaining);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = _endTime!.difference(now);

      if (diff <= Duration.zero) {
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
          _isRunning = false;
        });
      } else {
        setState(() {
          _remaining = diff;
        });
      }
    });

    setState(() {
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_endTime != null) {
        _remaining = _endTime!.difference(DateTime.now());
      }
    });
    _saveTimerState();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remaining = _focusDuration;
      _isRunning = false;
      _endTime = null;
    });
    _saveTimerState();
  }

  void _selectTime() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Duration tempDuration = _focusDuration;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Icon(Icons.keyboard_arrow_down, size: 28),
            const SizedBox(height: 4),
            const Text('집중 시간 설정',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 180,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hms,
                initialTimerDuration: _focusDuration,
                onTimerDurationChanged: (Duration newDuration) {
                  tempDuration = newDuration;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _focusDuration = tempDuration;
                    _remaining = _focusDuration;
                  });
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            )
          ],
        );
      },
    );
  }

  String _formatTime(Duration duration) {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final percent = _focusDuration.inSeconds == 0
        ? 0.0
        : 1 - (_remaining.inSeconds / _focusDuration.inSeconds);

    return Scaffold(
      backgroundColor: Colors.cyan,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            GestureDetector(
              onTap: _selectTime,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 10,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Take a Break',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatTime(_remaining),
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Icon(Icons.notifications_none, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            const Text(
              'Reminder',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tap the arrow or center\nto set time or return to timer',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.cyan,
                    backgroundColor: Colors.white,
                  ),
                  child: Text(_isRunning ? '일시정지' : '시작'),
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BlockedAppCategoryScreen()),
                    );

                    if (result != null && result is List<String>) {
                      print('차단 앱 리스트: $result');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}