import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);
  await notificationsPlugin.initialize(initSettings);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Demo',
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Notification Demo", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.0,)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: showImmediateNotification,
              child: Text("Immediate Notification"),
            ),
            Text("Voye yon notifikasyon imedyatman"),
            SizedBox(height: 30.0,),
            ElevatedButton(
                onPressed: scheduleNotification,
                child: Text("Scheduled Notification")
            ),
            Text("Pwograme yon notifikasyon pou 10 segonn pita"),
            SizedBox(height: 30.0,),
            ElevatedButton(
                onPressed: repeatNotification,
                child: Text("Repeating Notification")
            ),
            Text("Voye notifikasyon ki repete chak minit"),
            SizedBox(height: 30.0,),
            ElevatedButton(
                onPressed: bigTextNotification,
                child: Text("Big Text Notification")
            ),
            Text("Voye notifikasyon ak tèks long"),
            SizedBox(height: 30.0,),
            ElevatedButton(
                onPressed: imageNotification,
                child: Text("Image Notification")
            ),
            Text("Voye notifikasyon ak imaj"),
          ],
        ),
      ),
    );
  }
}

Future<void> showImmediateNotification() async {
  const AndroidNotificationDetails androidDetails =
  AndroidNotificationDetails(
    'channel1',
    'Immediate',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails details =
  NotificationDetails(android: androidDetails);
  await notificationsPlugin.show(
    0,
    'Hello!',
    'Sa se yon notifikasyon imedya',
    details,
  );
}

Future<void> scheduleNotification() async {
  await notificationsPlugin.zonedSchedule(
    1,
    'Scheduled',
    'Notifikasyon sa ap vini pita',
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
    const NotificationDetails(
      android: AndroidNotificationDetails('channel2', 'Scheduled'),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}

Future<void> repeatNotification() async {
  await notificationsPlugin.periodicallyShow(
    2,
    'Repeating',
    'Sa ap repete chak minit',
    RepeatInterval.everyMinute,
    const NotificationDetails(
      android: AndroidNotificationDetails('channel3', 'Repeat'),
    ),
  );
}

Future<void> bigTextNotification() async {
  const BigTextStyleInformation bigTextStyle =
  BigTextStyleInformation(
    'Sa se yon gwo tèks pou montre plis enfòmasyon nan notifikasyon an. '
        'Li itil pou mesaj long.',
  );
  const AndroidNotificationDetails androidDetails =
  AndroidNotificationDetails(
    'channel4',
    'Big Text',
    styleInformation: bigTextStyle,
  );
  await notificationsPlugin.show(
    3,
    'Big Text',
    'Gade plis detay...',
    const NotificationDetails(android: androidDetails),
  );
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getTemporaryDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> imageNotification() async {
  final String bigPicturePath = await _downloadAndSaveFile(
      'https://images.unsplash.com/photo-1624948465027-6f9b51067557?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
      'bigPicture.jpg');

  final BigPictureStyleInformation bigPictureStyle = BigPictureStyleInformation(
    FilePathAndroidBitmap(bigPicturePath),
    contentTitle: 'Image Notification',
    summaryText: 'Sa se yon notifikasyon ak imaj',
  );

  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel5',
    'Image',
    styleInformation: bigPictureStyle,
    importance: Importance.max,
    priority: Priority.high,
  );

  final NotificationDetails details = NotificationDetails(android: androidDetails);

  await notificationsPlugin.show(
    4,
    'Image Notification',
    'Gade imaj la',
    details,
  );
}