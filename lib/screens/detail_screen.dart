import 'dart:async';

import 'package:altcoin_ticker/services/coin_data.dart';
import 'package:altcoin_ticker/widgets/coin_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DetailScreen extends StatefulWidget {
  DetailScreen({Key? key, required this.coin, required this.currency})
      : super(key: key);

  final String coin;
  final String currency;
  late Future<Map<String, String>> coinDetailFuture;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    widget.coinDetailFuture = getCoinDetails();
    super.initState();
  }

  // Future<Map<String, String>> refreshCoinDetails() async {
  //   Timer timer = Timer(Duration(seconds: 5), (timer t) => getCoinDetails());
  // }

  Future<Map<String, String>> getCoinDetails() async {
    return CoinData.getCoinDetailInCurrency(
        coin: widget.coin, currency: widget.currency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.coin)),
      body: SafeArea(
        child: FutureBuilder(
            future: widget.coinDetailFuture,
            builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: snapshot.data!.entries
                      .map<Widget>((entry) =>
                          CoinCard(text: '${entry.key}: ${entry.value}'))
                      .toList(),
                );
              } else if (snapshot.hasError) {
                return const Text("Error");
              } else {
                return const Center(
                  child: SpinKitRotatingCircle(
                    color: Colors.blue,
                    size: 50.0,
                  ),
                );
              }
            }),
      ),
    );
  }
}
