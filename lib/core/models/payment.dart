import 'enums.dart';

class PaymentPlan {
  const PaymentPlan({
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.status,
    required this.nextDueDate,
    required this.dueAmount,
  });

  final String name;
  final double amount;
  final String billingCycle;
  final PaymentStatus status;
  final DateTime nextDueDate;
  final double dueAmount;
}

class PaymentReceipt {
  const PaymentReceipt({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final PaymentStatus status;
}
