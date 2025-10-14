import 'package:flutter/material.dart';

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final String type; // upi, card, netbanking, wallet, cod

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });
}