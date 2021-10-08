import 'package:flutter/material.dart';

class WalkthroughWidget extends StatelessWidget {
  final ImageProvider image;
  final String textHead;
  final String textSubHead;

  const WalkthroughWidget(
      {Key key, this.image, this.textHead, this.textSubHead})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: [
          Image(
            height: size.height * 0.5,
            fit: BoxFit.fill,
            image: image,
          ),
          SizedBox(
            height: size.height * 0.04,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              textHead,
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              textSubHead,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
