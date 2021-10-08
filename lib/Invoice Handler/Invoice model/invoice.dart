import 'package:flutter/cupertino.dart';
import 'package:truk_fleet/Invoice%20Handler/Invoice%20model/supplier.dart';
import 'customer.dart';

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;

  const Invoice({
    this.info,
    @required this.supplier,
    @required this.customer,
    @required this.items,
  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;
  final DateTime dueDate;

  const InvoiceInfo({
    @required this.description,
    @required this.number,
    @required this.date,
    @required this.dueDate,
  });
}

class InvoiceItem {
  final String name;
  final String mode;
  final String type;
  final double quantity;
  final String total;

  const InvoiceItem({
    @required this.quantity,
    @required this.name,
    @required this.type,
    @required this.mode,
    @required this.total
  });
}
