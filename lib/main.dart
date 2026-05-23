import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.purple,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,

            spacing: 20,
            children: [
              Image.asset(
                'assets/images/quiz-logo.png',
                width: 200,
                height: 200,
              ),
              Text(
                'Learn Flutter the fun way!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Start Quiz'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
