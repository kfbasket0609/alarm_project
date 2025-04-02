import 'dart:math';
import 'package:alarm_project/Provider/Provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddAlarm extends StatefulWidget {
  const AddAlarm({super.key});

  @override
  State<AddAlarm> createState() => _AddAlaramState();
}

class _AddAlaramState extends State<AddAlarm> {
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController memoController;

  String? dateTime;
  bool repeat = false;
  String? notificationSound = "デフォルト1";
  String? notificationImage = "なし";
  DateTime? notificationtime;
  String? name = "none";
  int? milliseconds;

  // 選択可能な繰り返し曜日
  List<String> weekdays = ['月', '火', '水', '木', '金', '土', '日'];
  List<String> selectedDays = [];

  @override
  void initState() {
    titleController = TextEditingController();
    locationController = TextEditingController();
    memoController = TextEditingController();
    context.read<alarmprovider>().GetData();
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    memoController.dispose();
    super.dispose();
  }

  // 共通のヘッダーウィジェット
  Widget _buildSectionHeader(String title, {IconData? icon}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scalingFactor = screenWidth / 1000;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 16 * scalingFactor,
          vertical: 12 * scalingFactor
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.blue[700],
              size: 24 * scalingFactor,
            ),
            SizedBox(width: 8 * scalingFactor),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 22 * scalingFactor,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  // 入力フィールドのカードウィジェット
  Widget _buildInputCard({
    required Widget child,
    double verticalPadding = 12.0,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scalingFactor = screenWidth / 1000;

    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(
        horizontal: 12 * scalingFactor,
        vertical: 4 * scalingFactor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * scalingFactor),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scalingFactor,
          vertical: verticalPadding * scalingFactor,
        ),
        child: child,
      ),
    );
  }

  // 設定項目用のリストタイル
  Widget _buildSettingTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    Color iconColor = Colors.blue,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scalingFactor = screenWidth / 1000;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
        size: 28 * scalingFactor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18 * scalingFactor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          fontSize: 16 * scalingFactor,
        ),
      )
          : null,
      trailing: trailing ?? Icon(
        Icons.chevron_right,
        size: 24 * scalingFactor,
      ),
      onTap: onTap,
    );
  }

  // 日時選択ダイアログ
  Future<void> _selectDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: notificationtime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      locale: const Locale('ja', 'JP'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue[700]!,
                onPrimary: Colors.white,
              ),
              timePickerTheme: TimePickerThemeData(
                dialHandColor: Colors.blue[700],
                hourMinuteColor: Colors.blue.shade50,
                hourMinuteTextColor: Colors.blue[700],
                dayPeriodColor: Colors.blue.shade50,
                dayPeriodTextColor: Colors.blue[700],
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          dateTime = DateFormat('MM月dd日 HH:mm').format(pickedDateTime);
          notificationtime = pickedDateTime;
          milliseconds = pickedDateTime.millisecondsSinceEpoch;
        });
      }
    }
  }

  // 繰り返し設定ダイアログ
  void _showRepeatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final double screenWidth = MediaQuery.of(context).size.width;
            final double scalingFactor = screenWidth / 1000;

            return AlertDialog(
              title: Text(
                '繰り返し設定',
                style: TextStyle(
                  fontSize: 22 * scalingFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 毎日/繰り返しなしの切り替え
                    SwitchListTile(
                      title: Text(
                        '繰り返し',
                        style: TextStyle(
                          fontSize: 18 * scalingFactor,
                        ),
                      ),
                      subtitle: Text(
                        repeat ? '有効' : '無効',
                        style: TextStyle(
                          fontSize: 16 * scalingFactor,
                        ),
                      ),
                      value: repeat,
                      onChanged: (bool value) {
                        setDialogState(() {
                          repeat = value;
                          if (value) {
                            name = 'Everyday';
                          } else {
                            name = 'none';
                            selectedDays.clear();
                          }
                        });
                      },
                    ),

                    if (repeat) ...[
                      Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0 * scalingFactor),
                        child: Text(
                          '曜日を選択',
                          style: TextStyle(
                            fontSize: 18 * scalingFactor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8 * scalingFactor,
                        children: weekdays.map((day) {
                          final bool isSelected = selectedDays.contains(day);
                          return FilterChip(
                            label: Text(
                              day,
                              style: TextStyle(
                                fontSize: 16 * scalingFactor,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setDialogState(() {
                                if (selected) {
                                  selectedDays.add(day);
                                } else {
                                  selectedDays.remove(day);
                                }

                                if (selectedDays.isEmpty) {
                                  repeat = false;
                                  name = 'none';
                                } else if (selectedDays.length == 7) {
                                  name = 'Everyday';
                                } else {
                                  name = '毎週 ${selectedDays.join('・')}';
                                }
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: Colors.blue[700],
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      fontSize: 16 * scalingFactor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(
                    '確定',
                    style: TextStyle(
                      fontSize: 16 * scalingFactor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      // ダイアログの状態をメインの状態に反映
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 通知音選択ダイアログ
  void _showSoundDialog() {
    final List<String> soundOptions = [
      'デフォルト1', 'デフォルト2', 'デフォルト3', '優しい音', '穏やかな音'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double scalingFactor = screenWidth / 1000;

        return AlertDialog(
          title: Text(
            '通知音の選択',
            style: TextStyle(
              fontSize: 22 * scalingFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: soundOptions.map((sound) {
                return RadioListTile<String>(
                  title: Text(
                    sound,
                    style: TextStyle(
                      fontSize: 18 * scalingFactor,
                    ),
                  ),
                  value: sound,
                  groupValue: notificationSound,
                  onChanged: (String? value) {
                    setState(() {
                      notificationSound = value;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'キャンセル',
                style: TextStyle(
                  fontSize: 16 * scalingFactor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 通知画像選択ダイアログ
  void _showImageDialog() {
    final List<String> imageOptions = [
      'なし', 'デフォルト画像', '写真1', '写真2'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double scalingFactor = screenWidth / 1000;

        return AlertDialog(
          title: Text(
            '通知画像の選択',
            style: TextStyle(
              fontSize: 22 * scalingFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: imageOptions.map((image) {
                return RadioListTile<String>(
                  title: Text(
                    image,
                    style: TextStyle(
                      fontSize: 18 * scalingFactor,
                    ),
                  ),
                  value: image,
                  groupValue: notificationImage,
                  onChanged: (String? value) {
                    setState(() {
                      notificationImage = value;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'キャンセル',
                style: TextStyle(
                  fontSize: 16 * scalingFactor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scalingFactor = screenWidth / 1000;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    Widget mainContent = ListView(
      children: [
        // タイトルセクション
        _buildSectionHeader('タイトル', icon: Icons.title),
        _buildInputCard(
          child: TextField(
            controller: titleController,
            style: TextStyle(
              fontSize: 22 * scalingFactor,
            ),
            decoration: InputDecoration(
              hintText: 'スケジュールの内容を入力',
              hintStyle: TextStyle(
                fontSize: 18 * scalingFactor,
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        // 日時セクション
        _buildSectionHeader('開始日時', icon: Icons.calendar_today),
        _buildInputCard(
          child: InkWell(
            onTap: _selectDateTime,
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.blue[600],
                  size: 28 * scalingFactor,
                ),
                SizedBox(width: 16 * scalingFactor),
                Text(
                  dateTime ?? DateFormat('MM月dd日 HH:mm').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 22 * scalingFactor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.edit,
                  color: Colors.grey[600],
                  size: 24 * scalingFactor,
                ),
              ],
            ),
          ),
        ),

        // 場所セクション
        _buildSectionHeader('場所', icon: Icons.location_on),
        _buildInputCard(
          child: TextField(
            controller: locationController,
            style: TextStyle(
              fontSize: 22 * scalingFactor,
            ),
            decoration: InputDecoration(
              hintText: '場所を入力',
              hintStyle: TextStyle(
                fontSize: 18 * scalingFactor,
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        // 通知設定セクション
        _buildSectionHeader('通知設定', icon: Icons.notifications_active),
        _buildInputCard(
          verticalPadding: 0,
          child: Column(
            children: [
              _buildSettingTile(
                title: '繰り返し',
                subtitle: repeat ? name : 'なし',
                icon: Icons.repeat,
                iconColor: Colors.purple,
                onTap: _showRepeatDialog,
              ),
              Divider(height: 1),
              _buildSettingTile(
                title: '通知音',
                subtitle: notificationSound,
                icon: Icons.music_note,
                iconColor: Colors.amber,
                onTap: _showSoundDialog,
              ),
              Divider(height: 1),
              _buildSettingTile(
                title: '通知画像',
                subtitle: notificationImage,
                icon: Icons.image,
                iconColor: Colors.teal,
                onTap: _showImageDialog,
              ),
            ],
          ),
        ),

        // メモセクション
        _buildSectionHeader('メモ', icon: Icons.note),
        _buildInputCard(
          verticalPadding: 16,
          child: TextField(
            controller: memoController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 18 * scalingFactor,
            ),
            decoration: InputDecoration(
              hintText: 'メモを入力',
              hintStyle: TextStyle(
                fontSize: 18 * scalingFactor,
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        SizedBox(height: 20 * scalingFactor),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          iconSize: 24 * scalingFactor,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '新しいスケジュール',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22 * scalingFactor,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('タイトルを入力してください'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (dateTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('日時を設定してください'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Random random = Random();
              int randomNumber = random.nextInt(100);

              context.read<alarmprovider>().SetAlaram(
                titleController.text, // label
                dateTime!,            // dateTime
                true,                 // check
                name!,                // repeat
                randomNumber,         // id
                milliseconds!,        // milliseconds
                titleController.text, // title
                locationController.text, // location
                memoController.text,  // memo
                notificationSound!,   // notificationSound
                notificationImage!,   // notificationImage
                selectedDays,         // repeatDays
              );
              context.read<alarmprovider>().SetData();
              context.read<alarmprovider>()
                  .SecduleNotification(notificationtime!, randomNumber);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20 * scalingFactor),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scalingFactor,
                vertical: 8 * scalingFactor,
              ),
            ),
            child: Text(
              '追加',
              style: TextStyle(
                fontSize: 18 * scalingFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8 * scalingFactor),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0 * scalingFactor),
          child: isLandscape
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.all(8.0 * scalingFactor),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16 * scalingFactor),
                  ),
                  padding: EdgeInsets.all(16.0 * scalingFactor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 64 * scalingFactor,
                        color: Colors.blue[700],
                      ),
                      SizedBox(height: 16 * scalingFactor),
                      Text(
                        'スケジュール\n作成',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24 * scalingFactor,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 16 * scalingFactor),
                      Text(
                        '必要な情報を\n入力してください',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16 * scalingFactor,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: mainContent,
              ),
            ],
          )
              : mainContent,
        ),
      ),
    );
  }
}