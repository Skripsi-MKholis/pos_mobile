import 'package:flutter/material.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';

class KosongPage extends StatelessWidget {
  const KosongPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.BG,
      appBar: MyAppBar(title: 'Empty Page'),
      body: Center(child: Column()),
    );
  }
}
