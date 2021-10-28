import 'package:truk_fleet/Invoice%20Handler/Invoice%20model/customer.dart';
import 'package:truk_fleet/Invoice%20Handler/Invoice%20model/invoice.dart';
import 'package:truk_fleet/Invoice%20Handler/Invoice%20model/supplier.dart';
import 'package:truk_fleet/helper/helper.dart';
import 'package:truk_fleet/models/shipment_model.dart';
import '../pdf_invoice_api.dart';

class PdfPage {
  generateInvoice(ShipmentModel model, user, List<InvoiceItem> items) async {
    final date = DateTime.now();
    final dueDate = date.add(Duration(days: 7));

    final invoice = Invoice(
      info: InvoiceInfo(
        date: date,
        dueDate: dueDate,
      ),
      supplier: Supplier(
        name: user,
        address: await Helper().setLocationText(model.source),
        paymentInfo: model.paymentStatus,
      ),
      customer: Customer(
        name: user,
        address: await Helper().setLocationText(model.destination),
      ),
      items: items,
    );
    await PdfInvoiceApi.generate(invoice, model.id);
  }
}
