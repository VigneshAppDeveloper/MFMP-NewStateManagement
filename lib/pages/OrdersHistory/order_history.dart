import 'package:flutter/material.dart';

import '../../widgets/app_bar.dart';


class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
          appBar:const CommonAppBar(title: "", showBack: true),
      //body: SafeArea(child: child),
    );
  }
}