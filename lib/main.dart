import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Responsive List/Grid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Responsive List/Grid'),
        ),
        body: const Center(
          child: ResponsiveListGrid(),
        ),
      ),
    );
  }
}

class ResponsiveListGrid extends StatelessWidget {
  const ResponsiveListGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.blue[100 * (index % 9 + 1)],
                child: Center(
                  child: Text('Grid Item $index'),
                ),
              );
            },
          );
        } else {
          return ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                color: Colors.green[100 * (index % 9 + 1)],
                child: ListTile(title: Text('List Item $index')),
              );
            },
          );
        }
      },
    );
  }
}
