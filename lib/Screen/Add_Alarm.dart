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

  @override
  void initState() {
    titleController = TextEditingController();
    locationController = TextEditingController();
    memoController = TextEditingController();
    context.read<alarmprovider>().GetData();
    super.initState();
  }

  // ウィジットの定義
  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Widget? leading,
  }) {
    return ListTile(
      leading: leading,
      title: Text(
          title,
          style: const TextStyle(
          fontSize: 24
      ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: const TextStyle(
          fontSize: 20
        )
      ) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
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
                [],                   // repeatDays
              );
              context.read<alarmprovider>().SetData();
              context.read<alarmprovider>()
                  .SecduleNotification(notificationtime!, randomNumber);
              Navigator.pop(context);
            },
            child: const Text('追加'),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // タイトルセクション
          _buildSectionHeader('タイトル'),
          Container(
            color: Colors.white,
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'スケジュールの内容を入力',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),

          // 日時セクション
          _buildSectionHeader('開始'),
          Container(
            color: Colors.white,
            child: _buildListTile(
              title: dateTime ?? DateFormat('MM月dd日 HH:mm').format(DateTime.now()),
              onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (BuildContext context, Widget? child) {
                      final double width = MediaQuery.of(context).size.width;
                      final double height = MediaQuery.of(context).size.height;
                      return Theme(
                        data: ThemeData.light(),
                        child: Center(
                          child: Container(
                            width: width * 0.9, // 横幅を画面の90%に設定
                            height: height * 0.8, // 高さを画面の80%に設定
                            child: child,
                          ),
                        ),
                      );
                    },
                  );

                  if (pickedDate != null){
                    final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null){
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
              },
            ),
          ),

          // 場所セクション
          _buildSectionHeader('場所'),
          Container(
            color: Colors.white,
            child: TextField(
              controller: locationController,
              decoration: const InputDecoration(
                hintText: '場所を入力',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),

          // 通知設定セクション
          _buildSectionHeader('通知設定'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildListTile(
                  title: '繰り返し',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(repeat ? 'Everyday' : 'なし'),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      repeat = !repeat;
                      name = repeat ? 'Everyday' : 'none';
                    });
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  title: 'リマインド',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('なし'),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildListTile(
                  title: '通知音',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(notificationSound!),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildListTile(
                  title: '通知画像',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(notificationImage!),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // メモセクション
          _buildSectionHeader('メモ'),
          Container(
            color: Colors.white,
            child: TextField(
              controller: memoController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'メモを入力',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}