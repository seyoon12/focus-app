import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_calendar_small.dart';
import '../widgets/custom_time_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddEventScreen extends StatefulWidget {
  final Function(DateTime, DateTime, String, String, Color, String) onSave;
  final DateTime? initialDate; // 🔥 추가

  const AddEventScreen({
    super.key,
    required this.onSave,
    this.initialDate, // 🔥 추가
  });

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _captionController = TextEditingController(); // 문구 입력 필드

  bool _isAllDay = false;
  late DateTime _startDate;
  late DateTime _endDate;
  Color _selectedColor = Colors.blue;
  File? _selectedImage;

  final DateFormat _dateFormat = DateFormat('M월 d일 (E)', 'ko');
  final DateFormat _timeFormat = DateFormat('a h:mm', 'ko');

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () async {
                final file = await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () async {
                final file = await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, file);
              },
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _showCustomDatePicker(bool isStart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: const BoxConstraints(maxHeight: 360),
      builder: (_) => CustomCalendarSmall(
        selectedDate: isStart ? _startDate : _endDate,
        onDateSelected: (date) {
          setState(() {
            if (isStart) {
              _startDate = DateTime(date.year, date.month, date.day, _startDate.hour, _startDate.minute);
              if (_startDate.isAfter(_endDate)) {
                _endDate = _startDate.add(const Duration(hours: 1));
              }
            } else {
              _endDate = DateTime(date.year, date.month, date.day, _endDate.hour, _endDate.minute);
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCustomTimePicker({required bool isStart}) {
    final initial = TimeOfDay.fromDateTime(isStart ? _startDate : _endDate);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CustomTimePicker(
        initialTime: initial,
        onTimeSelected: (picked) {
          setState(() {
            final date = isStart ? _startDate : _endDate;
            final newDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              picked.hour,
              picked.minute,
            );
            if (isStart) {
              _startDate = newDateTime;
              if (_startDate.isAfter(_endDate)) {
                _endDate = _startDate.add(const Duration(hours: 1));
              }
            } else {
              _endDate = newDateTime;
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showColorPicker(BuildContext iconContext) async {
    final RenderBox renderBox = iconContext.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    final picked = await showDialog<Color>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => Stack(
        children: [
          Positioned(
            left: offset.dx - 140,
            top: offset.dy + renderBox.size.height + 8,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Colors.red,
                    Colors.pink,
                    Colors.orange,
                    Colors.brown,
                    Colors.yellow,
                    Colors.lightGreen,
                    Colors.teal,
                    Colors.cyan,
                    Colors.blue,
                    Colors.purple
                  ].map((color) {
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, color),
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 16,
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (picked != null) {
      setState(() => _selectedColor = picked);
    }
  }
@override
void initState() {
  super.initState();
  _startDate = widget.initialDate ?? DateTime.now();
  _endDate = _startDate.add(const Duration(hours: 1));
}

  @override
  Widget build(BuildContext context) {
    final bool isContentValid = _contentController.text.trim().isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('일정 추가'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 내용 입력 + 색상
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(hintText: '내용 입력', border: InputBorder.none),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Builder(
                builder: (iconContext) => IconButton(
                  onPressed: () => _showColorPicker(iconContext),
                  icon: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Divider(),

          Row(
            children: [
              const Icon(Icons.access_time),
              const SizedBox(width: 12),
              const Text('하루 종일'),
              const Spacer(),
              Switch(
                value: _isAllDay,
                onChanged: (value) {
                  setState(() {
                    _isAllDay = value;
                    if (value) {
                      _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day, 0, 0);
                      _endDate = DateTime(_startDate.year, _startDate.month, _startDate.day, 23, 59);
                    }
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showCustomDatePicker(true),
                  child: Text(
                    _dateFormat.format(_startDate),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showCustomDatePicker(false),
                  child: Text(
                    _dateFormat.format(_endDate),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (!_isAllDay)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCustomTimePicker(isStart: true),
                    child: Text(
                      _timeFormat.format(_startDate),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCustomTimePicker(isStart: false),
                    child: Text(
                      _timeFormat.format(_endDate),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

          const Divider(height: 32),
          const SizedBox(height: 24),

          // 이미지 + 문구
          Container(
            width: double.infinity,
            height: screenWidth * 4 / 3,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(child: Text('사진 미리보기 또는 업로드 영역')),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    elevation: 6,
                    shape: const CircleBorder(),
                    mini: true,
                    onPressed: _pickImage,
                    child: const Icon(Icons.photo_camera, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 문구 추가 입력 필드
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _captionController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: '사진 아래에 표시될 문구를 입력하세요',
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isContentValid
                    ? () {
                        final content = _contentController.text.trim();
                        final caption = _captionController.text.trim();
                        widget.onSave(
                          _startDate,
                          _endDate,
                          content,
                          _selectedImage?.path ?? '',
                          _selectedColor,
                          caption,
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
