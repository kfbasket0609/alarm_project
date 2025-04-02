import 'dart:async';
import 'package:alarm_project/Model/Model.dart';
import 'package:alarm_project/Provider/Provider.dart';
import 'package:alarm_project/Screen/Add_Alarm.dart';
import 'package:alarm_project/Screen/alarm_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:io' show Platform;
import 'package:another_flushbar/flushbar.dart';
import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  tz.initializeTimeZones();

  // プラットフォームに応じた通知許可のリクエスト
  if (Platform.isAndroid){
  //   AndroidではrequestPermissionは不要なので削除
  //   Android向けの初期化などを行う
  } else if (Platform.isIOS) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(alert: true, badge: true, sound: true);
  }

  runApp(ChangeNotifierProvider(
    create: (context) => alarmprovider(),
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool value = false;
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ja_JP',null);
    context.read<alarmprovider>().Inituilize(context);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    context.read<alarmprovider>().GetData();
  }
  @override
  Widget build(BuildContext context) {
    // デバックコード
    // final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double scalingFactor = screenWidth / 1000;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    print('Orientation: ${isLandscape ? "Landscape" : "Portrait"}');


    Widget buildAlarmList() {
      return Expanded(
        child: Consumer<alarmprovider>(
          builder: (context, alarm, child) {
            final sortedAlarms = List<Model>.from(alarm.filteredList)
              ..sort((a,b) => (a.milliseconds ?? 0).compareTo(b.milliseconds ?? 0));
            return ListView.builder(
              itemCount: sortedAlarms.length,
              itemBuilder: (BuildContext context, int index) {
                final alarmItem = sortedAlarms[index];
                final originalIndex = alarm.filteredList.indexWhere((item) => item.id == alarmItem.id);

                return Padding(
                  padding: EdgeInsets.all(8.0 * scalingFactor),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlarmDetailPage(alarm: alarmItem),
                        ),
                      );
                    },
                    child: Container(
                      height: screenHeight * (isLandscape ? 0.15 : 0.1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30 * scalingFactor),
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0 * scalingFactor,
                          vertical: 8.0 * scalingFactor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 時刻とラベルを横並びに表示
                            Row(
                              children: [
                                Text(
                                  alarmItem.dateTime!, // 時刻
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30 * scalingFactor,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 12 * scalingFactor),
                                Text(
                                  alarmItem.label!, // ラベル
                                  style: TextStyle(
                                    fontSize: 20 * scalingFactor,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            // スイッチ
                            CupertinoSwitch(
                              value: alarmItem.milliseconds! >=
                                  DateTime.now().millisecondsSinceEpoch
                                  ? alarm.modelist[originalIndex].check
                                  : false,
                              onChanged: (v) {
                                alarm.EditSwitch(originalIndex, v);
                                alarm.CancelNotification(alarmItem.id!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }

    Widget buildTimeDisplay() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isLandscape
              ? const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          )
              : const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        height: isLandscape ? double.infinity : screenHeight * 0.20,
        width: isLandscape ? screenWidth * 0.5 : double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 年の表示
            Text(
              DateFormat('yyyy年', 'ja_JP').format(DateTime.now()),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 36 * scalingFactor,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20 * scalingFactor),
            // 月日と曜日の表示
            Text(
              DateFormat('M月d日 (E)', 'ja_JP').format(DateTime.now()),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 48 * scalingFactor,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20 * scalingFactor),
            // 時刻の表示
            Text(
              DateFormat('H:mm').format(DateTime.now()),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 72 * scalingFactor,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }
    Widget buildAddButton() {
      return Container(
        height: screenHeight * 0.1,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: Colors.white,
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddAlarm()),
              );
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0 * scalingFactor),
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            bottom: TabBar(
                onTap: (index){
                  context.read<alarmprovider>().changeTab(index);
                },
                labelColor:Colors.black,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.black,
                labelStyle: TextStyle(
                  fontSize: 30 * scalingFactor,
                  fontWeight: FontWeight.bold
                ),
              unselectedLabelStyle: TextStyle(
                fontSize: 20 * scalingFactor,
            ),
                tabs: const[
                  Tab(text: '日'),
                  Tab(text: '週'),
                  Tab(text: '月'),
                ],
            ),
              toolbarHeight : isLandscape ? 40 : null
          ),
          body: TabBarView(
            children: [
              // 日タブのコンテンツ
              isLandscape
                  ? Row(
                children: [
                  buildTimeDisplay(),
                  Expanded(
                    child: Column(
                      children: [
                        buildAlarmList(),
                        buildAddButton(),
                      ],
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  buildTimeDisplay(),
                  buildAlarmList(),
                  buildAddButton(),
                ],
              ),
              // 週タブのコンテンツ
              // 週タブのコンテンツ
              isLandscape
                  ? Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(16.0 * scalingFactor),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.all(16.0 * scalingFactor),
                  child: Column(
                    children: [
                      // 週の表示
                      Text(
                        '${DateFormat('yyyy年M月', 'ja_JP').format(DateTime.now())}',
                        style: TextStyle(
                          fontSize: 24 * scalingFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20 * scalingFactor),
                      Row(
                        children: List<Widget>.generate(7, (index) =>
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8.0 * scalingFactor),
                                width: 90 * scalingFactor,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                ),
                                child: Column(
                                children: [
                                  Text(
                                ['月', '火', '水', '木', '金', '土', '日'][index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20 * scalingFactor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                  SizedBox(height: 4 * scalingFactor),
                                  Text(
                                    '${DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index)).day}日',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18 * scalingFactor,
                                      fontWeight: DateTime.now().day ==
                                          DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index)).day ?
                                      FontWeight.bold : FontWeight.normal,
                                  )
                                  )
                                ],
                                )
                              ),
                            ),
                        ),
                      ),
                      SizedBox(height: 10 * scalingFactor),
                      // 曜日ごとの予定リスト
                      Expanded(
                        child: Consumer<alarmprovider>(
                          builder: (context, alarm, child) {
                            return Row(
                              children: List.generate(7, (dayIndex) {
                                // 現在の週の開始日を取得
                                final now = DateTime.now();
                                final weekStart = now.subtract(Duration(days: now.weekday - 1));
                                final currentDay = weekStart.add(Duration(days: dayIndex));

                                // 当日の予定を取得
                                final schedules = alarm.filteredList.where((item) {
                                  final itemDate = DateTime.fromMillisecondsSinceEpoch(item.milliseconds!);
                                  return itemDate.year == currentDay.year &&
                                      itemDate.month == currentDay.month &&
                                      itemDate.day == currentDay.day;
                                }).toList()
                                ..sort((a,b){
                                  return a.milliseconds!.compareTo(b.milliseconds!);
                                });
                                print('filteredList: ${alarm.filteredList}');
                                for (var model in alarm.filteredList) {
                                  print('Model details: $model');
                                }
                                return Expanded(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4 * scalingFactor),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: schedules.isEmpty
                                          ? [Container()] // 空の場合何も表示しない
                                          : schedules.map((schedule) {
                                        final scheduleTime = DateTime.fromMillisecondsSinceEpoch(schedule.milliseconds!);
                                        final formattedTime = DateFormat('HH:mm').format(scheduleTime);
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AlarmDetailPage(alarm: schedule),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: EdgeInsets.all(4 * scalingFactor),
                                            padding: EdgeInsets.all(4 * scalingFactor),
                                            width: 120 * scalingFactor,
                                            height: 80 * scalingFactor,  // ここにカンマを追加
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  formattedTime,
                                                  style: TextStyle(
                                                    fontSize: 25 * scalingFactor,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                SizedBox(height: 4 * scalingFactor),
                                                Text(
                                                  schedule.label!,
                                                  style: TextStyle(fontSize: 14 * scalingFactor),
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )

                  : Column(
                children: [
                  buildTimeDisplay(),
                  buildAlarmList(),
                  buildAddButton(),
                ],
              ),
              // 月タブのコンテンツ
              isLandscape
                  ? Row(
                children: [
                  buildTimeDisplay(),
                  Expanded(
                    child: Column(
                      children: [
                        buildAlarmList(),
                        buildAddButton(),
                      ],
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  buildTimeDisplay(),
                  buildAlarmList(),
                  buildAddButton(),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
