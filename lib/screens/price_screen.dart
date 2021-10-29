import 'dart:async';
import 'dart:convert';

import 'package:altcoin_ticker/services/coin_data.dart' show CoinData;
import 'package:altcoin_ticker/widgets/coin_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/cupertino.dart';

import 'detail_screen.dart';

class PriceScreen extends StatefulWidget {
  const PriceScreen({Key? key}) : super(key: key);

  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  late final Future<Map<String, dynamic>> currencyFuture;
  late final Map<String, dynamic> currencies;
  String selectedCurrency = 'CAD';
  // late Timer timer;
  Map<String, String> coinPrices = {
    'BTC': '0.0',
    'ETH': '0.0',
    'DOGE': '0.0',
  };

  @override
  void initState() {
    super.initState();
    loadCurrencyData();
    updatePrices(selectedCurrency);
    // timer = Timer.periodic(
    //     Duration(seconds: 5), (Timer t) => updatePrices(selectedCurrency));
  }

  DropdownButton<String> androidDropdown(Map<String, dynamic> currencies) {
    return DropdownButton<String>(
      value: selectedCurrency,
      dropdownColor: Colors.blue,
      items: currencies.entries.map<DropdownMenuItem<String>>((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(
            entry.value['name'],
            style: const TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(
        () {
          selectedCurrency = value ?? selectedCurrency;
          updatePrices(selectedCurrency);
        },
      ),
    );
  }

  CupertinoPicker iOSPicker(Map<String, dynamic> currencies) {
    return CupertinoPicker(
      itemExtent: 32.0,
      onSelectedItemChanged: (index) => setState(() {
        selectedCurrency = currencies.keys.toList()[index];
        updatePrices(selectedCurrency);
      }),
      children: currencies.entries
          .map<Widget>(
            (entry) => Text(
              entry.value['name'],
              style: const TextStyle(color: Colors.black),
            ),
          )
          .toList(),
    );
  }

  Future loadCurrencyData() async {
    currencyFuture = DefaultAssetBundle.of(context)
        .loadString('assets/data/currencies.json')
        .then((data) => jsonDecode(data));

    // save currency data for later use
    currencies = await currencyFuture;

    return currencyFuture;
  }

  void updatePrices(String currency) async {
    List<String> coins = coinPrices.keys.toList();
    var newPrices = await CoinData.getCoinPricesInCurrency(
        coins: coins, currency: currency);
    if (newPrices.containsKey('Error')) {
    } else {
      setState(() {
        coinPrices = newPrices;
      });
    }
  }

  List<Widget> getCoinCards() {
    return coinPrices.entries
        .map<InkWell>(
          (entry) => InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailScreen(coin: entry.key, currency: selectedCurrency),
                ),
              );
            },
            child: CoinCard(text: '1 ${entry.key} = ${entry.value}'),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Altcoin Price Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<Map<String, dynamic>>(
              future: currencyFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: getCoinCards(),
                  );
                } else {
                  return const SpinKitRotatingCircle(
                    color: Colors.blue,
                    size: 50.0,
                  );
                }
              }),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            color: Colors.blue,
            padding: const EdgeInsets.only(bottom: 30.0),
            child: FutureBuilder<Map<String, dynamic>>(
                future: currencyFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Theme.of(context).platform == TargetPlatform.iOS
                        ? iOSPicker(snapshot.data!)
                        : androidDropdown(snapshot.data!);
                  } else if (snapshot.hasError) {
                    return const Text('Error retrieving currency data');
                  } else {
                    return const SpinKitRotatingCircle(
                      color: Colors.blue,
                      size: 50.0,
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}
