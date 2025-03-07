import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/adapters.dart';

import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(MyTodoAdapter());
  Hive.registerAdapter(TodoPriorityAdapter());

  //open a box

  await Hive.openBox("My_Box");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}


