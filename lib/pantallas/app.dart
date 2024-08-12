import 'package:flutter/material.dart';
import 'package:mixology2/pantallas/home.dart';
import 'package:mixology2/pantallas/login.dart';


class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() {

    return _AppState();
  }
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mixology',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Quita la etiqueta "debug"
      home: Login(),
    );
  }
}