import 'package:flutter/material.dart';

class StatPage extends StatefulWidget {
  final String userId;
  const StatPage({super.key, required this.userId});

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  @override
  Widget build(BuildContext context) {
    return Text("Stat ");
  }
}