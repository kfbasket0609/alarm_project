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

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    context.read<alarmprovider>().Inituilize(context);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    context.read<alarmprovider>().GetData();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final double scalingFactor = screenWidth / 1000;

    return Scaffold(
      backgroundColor: Color(0xFFEEEFF5),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          'Alarm Clock',
          style: TextStyle(
            color: Colors.white,
            fontSize: 60 * scalingFactor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 上部の時刻表示コンテナ
          Container(
            decoration: const BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            height: screenHeight * 0.1,
            child: Center(
              child: Text(
                DateFormat.yMEd().add_jms().format(DateTime.now()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40 * scalingFactor,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // リスト部分
          Expanded(
            child: Consumer<alarmprovider>(
              builder: (context, alarm, child) {
                return ListView.builder(
                  itemCount: alarm.modelist.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.all(8.0 * scalingFactor),
                      child: Container(
                        height: screenHeight * 0.15, // 固定の高さを設定
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              10 * scalingFactor),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0 * scalingFactor),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        alarm.modelist[index].dateTime!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24 * scalingFactor,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 8.0 * scalingFactor),
                                        child: Text(
                                          "| + ${alarm.modelist[index].label}",
                                          style: TextStyle(
                                              fontSize: 18 * scalingFactor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  CupertinoSwitch(
                                    value: alarm.modelist[index]
                                        .milliseconds! >=
                                        DateTime
                                            .now()
                                            .millisecondsSinceEpoch
                                        ? alarm.modelist[index].check
                                        : false,
                                    onChanged: (v) {
                                      alarm.EditSwitch(index, v);
                                      alarm.CancelNotification(
                                          alarm.modelist[index].id!);
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                alarm.modelist[index].when!,
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
          ),
          // 下部のコンテナ
          Container(
            height: screenHeight * 0.1,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              color: Colors.deepPurpleAccent,
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0 * scalingFactor),
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
