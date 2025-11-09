import 'package:flutter/material.dart';
import 'config/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sport Field App',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      routerConfig: router,
    );
  }
}
