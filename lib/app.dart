import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yolo/screens/loginScreen.dart';
import 'package:yolo/services/postsProviderServices.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PostsProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
