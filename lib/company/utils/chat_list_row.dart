import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truk_fleet/helper/request_status.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:truk_fleet/models/chatting_list_model.dart';
import 'package:truk_fleet/screens/quote_summary_screen.dart';
import 'package:truk_fleet/utils/constants.dart';

class ChatListRow extends StatelessWidget {
  final ChattingListModel model;
  final Function onPriceUpdate;
  const ChatListRow({Key key, this.model, this.onPriceUpdate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Locale locale = AppLocalizations.of(context).locale;
    print(model.quoteModel.status);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => QuoteSummaryScreen(
              quoteModel: model.quoteModel,
              onlyView: true,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/no_data.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${model.quoteModel.bookingId}',
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      '${model.quoteModel.pickupDate}',
                      // '${AppLocalizations.getLocalizationValue(locale, LocaleKey.date)} : ${model.quoteModel.pickupDate}',
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      '\u20B9 ${model.quoteModel.price}',
                      style: TextStyle(fontSize: 18, color: primaryColor),
                    ),
                  ],
                ),

                /// --------- [Fare Update Button] -----------------

                // Spacer(),
                // ElevatedButton(
                //   onPressed: model.quoteModel.status ==
                //               RequestStatus.accepted ||
                //           model.quoteModel.status == RequestStatus.assigned ||
                //           model.quoteModel.status == RequestStatus.cancelled
                //       ? null
                //       : onPriceUpdate,
                //   style: ElevatedButton.styleFrom(
                //     primary: primaryColor,
                //   ),
                //   child: Text(
                //     "${AppLocalizations.getLocalizationValue(locale, LocaleKey.fare)} ${AppLocalizations.getLocalizationValue(locale, LocaleKey.update)}",
                //     style: TextStyle(color: Colors.white),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
