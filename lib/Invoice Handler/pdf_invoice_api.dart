import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:truk_fleet/Invoice%20Handler/pdf_api.dart';
import 'package:truk_fleet/firebase_helper/firebase_helper.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';
import 'Invoice model/invoice.dart';

class PdfInvoiceApi {
  static double horizontalPadding = PdfPageFormat.a4.width * 0.05;

  static const PdfColor pdfPrimaryColor = PdfColor.fromInt(0xffFF7101);

  static Future<void> generate(Invoice invoice, String id) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4.applyMargin(
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
      ),
      build: (context) => [
        buildHeader(invoice),
        pw.SizedBox(height: PdfPageFormat.cm),
        buildOrderDetails(invoice),
        pw.Divider(),
        buildInvoice(invoice),
        pw.SizedBox(height: PdfPageFormat.cm / 2),
        buildTotal(invoice),
      ],
    ));

    final file =
        await PdfApi.saveDocument(name: 'truk_invoice_$id.pdf', pdf: pdf);
    log("Invoice saved");
    String fileName = Uuid().v4();
    TaskSnapshot uploadTask = await FirebaseStorage.instance
        .ref()
        .child('Invoices/$fileName.pdf')
        .putFile(file);
    log("Invoice uploaded");
    String downloadUrl = await uploadTask.ref.getDownloadURL();
    FirebaseFirestore.instance
        .collection(FirebaseHelper.invoiceCollection)
        .doc()
        .set({'invoice': downloadUrl, 'time': DateTime.now(), 'id': id});
  }

  static pw.Widget buildHeader(Invoice invoice) {
    return pw.Container(
      color: pdfPrimaryColor,
      height: PdfPageFormat.a4.height * 0.2,
      width: PdfPageFormat.a4.width,
      alignment: pw.Alignment.center,
      padding: pw.EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // pw.SvgImage(
              //   svg: 'assets/svg/truck_svg.svg',
              //   height: PdfPageFormat.a4.height * 0.03,
              //   colorFilter: PdfColors.white,
              // ),
              pw.Text(
                'Invoice',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                invoice.supplier.name,
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                invoice.supplier.address,
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  static pw.Widget buildOrderDetails(Invoice invoice) {
    return pw.Container(
      width: PdfPageFormat.a4.width,
      padding: pw.EdgeInsets.all(horizontalPadding),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildDeliveryAddress(invoice),
          buildInvoiceDetails(invoice),
        ],
      ),
    );
  }

  static pw.Column buildDeliveryAddress(Invoice invoice) {
    return pw.Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pw.Text(
          'To,',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          invoice.customer.name,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          invoice.customer.address.split(', ').join('\n'),
          style: pw.TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  static pw.Column buildInvoiceDetails(Invoice invoice) {
    return pw.Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        pw.Text(
          'Date',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          invoice.info.date.toString().split(' ').first,
        ),
        pw.Text(
          'Due Date',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          invoice.info.dueDate.toString().split(' ').first,
        ),
      ],
    );
  }

  static pw.Widget buildInvoice(Invoice invoice) {
    final headers = [
      'S.No.',
      'Material Name',
      'Material Type',
      'Quantity (Kg)',
      'Total (Rs)',
      'Payment Mode'
    ];
    final data = invoice.items.map((item) {
      return [
        '${invoice.items.indexOf(item) + 1}',
        item.name,
        item.type,
        '${item.quantity}',
        '${item.total}',
        '${item.mode}',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: FontWeight.bold),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerRight,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget buildTotal(Invoice invoice) {
    final netTotal = invoice.items
        .map((item) => item.total)
        .reduce((item1, item2) => item1 + item2);

    final netQuantity = invoice.items
        .map((item) => item.quantity)
        .reduce((quantity1, quantity2) => quantity1 + quantity2);

    return pw.SizedBox(
      width: PdfPageFormat.a4.width,
      height: PdfPageFormat.a4.height * 0.1,
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 6,
            child: pw.Container(
              child: pw.Text(
                "This is system generated invoice and can't be treated as only receipt\nFor any query, Kindly contact TrukApp Support Team",
                style: pw.TextStyle(fontSize: 12),
              ),
            ),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Container(
              color: pdfPrimaryColor,
              padding: pw.EdgeInsets.all(horizontalPadding),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Total Quantity',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        '$netQuantity',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Total Amount',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        '$netTotal',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
