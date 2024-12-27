import 'dart:async';
import 'package:alarm_project/Model/Model.dart';
import 'package:alarm_project/Provider/Provider.dart';
import 'package:alarm_project/Screen/Add_Alarm.dart';
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
    initializeDateFormatting('ja_JP');
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
            return ListView.builder(
              itemCount: alarm.filteredList.length,
              itemBuilder: (BuildContext context, int index) {
                final alarmItem = alarm.filteredList[index];
                return Padding(
                  padding: EdgeInsets.all(8.0 * scalingFactor),
                  child: Container(
                    height: screenHeight * (isLandscape ? 0.2 : 0.15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10 * scalingFactor),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.0 * scalingFactor),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    alarmItem.dateTime!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24 * scalingFactor,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8.0 * scalingFactor),
                                    child: Text(
                                      "| + ${alarmItem.label}",
                                      style: TextStyle(fontSize: 18 * scalingFactor),
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoSwitch(
                                value: alarmItem.milliseconds! >=
                                    DateTime.now().millisecondsSinceEpoch
                                    ? alarm.modelist[index].check
                                    : false,
                                onChanged: (v) {
                                  alarm.EditSwitch(index, v);
                                  alarm.CancelNotification(alarmItem.id!);
                                },
                              ),
                            ],
                          ),
                          Text(
                            alarmItem.when!,
                            style: TextStyle(
                              fontSize: 18 * scalingFactor,
                            ),
                          ),
                        ],
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
        height: isLandscape ? double.infinity : screenHeight * 0.1,
        width: isLandscape ? screenWidth * 0.5 : double.infinity,
        child: isLandscape ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 年の表示
            Text(
              DateFormat('yyyy').format(DateTime.now()),
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
        ) : Center(
          // 縦向きの場合
          child: Text(
            DateFormat.yMEd().add_jms().format(DateTime.now()),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40 * scalingFactor,
              color: Colors.black,
            ),
          ),
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
          backgroundColor: const Color(0xFFEEFF5),
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
                fontSize: 30 * scalingFactor,
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
