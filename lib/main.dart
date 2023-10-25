import 'package:easy_commit_client/setup/setup.dart';
import 'package:flutter/material.dart';
import 'fundamental/type_selector.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'commit_message/commit_msg.dart';
import 'package:easy_commit_client/fundamental/local_storage.dart';
import 'package:window_manager/window_manager.dart';


class LaunchConfig {
  int page;
  String? commitMsgFile;

  LaunchConfig(this.page, this.commitMsgFile);
}

Future<void> main(List<String> arguments) async {
  int page = 0;
  String? commitMsgFile;

  if (arguments.isNotEmpty) {
    if (arguments[0] == "commit_message") {
        if (arguments[1].isEmpty) {
          // TODO: show error msg
          return;
        }
        page = 1;
        commitMsgFile = arguments[1];
    }
    // Insert your code using arguments here.
  }
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();

  LaunchConfig launchConfig = LaunchConfig(page, commitMsgFile);


  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MyApp(launchConfig: launchConfig));
}

class MyApp extends StatelessWidget {
  LaunchConfig launchConfig;
  
  MyApp({Key? key,  required this.launchConfig}): super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Commit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Easy Commit', launchConfig: launchConfig),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title, required this.launchConfig});

  final String title;
  final LaunchConfig launchConfig;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.launchConfig.page,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            toolbarHeight: 0,
          // title: Text(widget.title, style: const TextStyle(fontSize: 16)),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                iconMargin: EdgeInsets.all(0),
                height: 40,
                text: 'Workspace',
                icon: Icon(Icons.home, size: 20),
              ),
              Tab(
                iconMargin: EdgeInsets.all(0),
                height: 40,
                text: 'Commit',
                icon: Icon(Icons.message, size: 20),
              ),
              // Tab(
              //   icon: Icon(Icons.brightness_5_sharp),
              // ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: SetupPage(),
            ),
            Center(
                child: CommitMsgPage(file: widget.launchConfig.commitMsgFile),
            ),
            // Center(
            //   child: Text("It's setting here"),
            // ),
          ],
        ),
      ),
    );
  }
}
