import 'package:truk_fleet/models/quote_model.dart';
import 'package:truk_fleet/models/user_model.dart';

class ChattingListModel {
  String id;
  UserModel userModel;
  QuoteModel quoteModel;
  ChattingListModel({
    this.id,
    this.userModel,
    this.quoteModel,
  });
}
