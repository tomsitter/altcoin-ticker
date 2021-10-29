import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const List<String> cryptoList = [
  'BTC',
  'ETH',
  'LTC',
];

class CoinData {
  static String apiKey =
      'ed7af786c44b896e6c7b37a8c962e315abc85a007d1a37c73b587574db3ac809';

  static String createCoinPricesUrl(
      {required String coin, required String currency}) {
    final queryParams = {
      'fsyms': coin,
      'tsyms': currency,
      'api_key': apiKey,
    };

    final uri =
        Uri.https('min-api.cryptocompare.com', '/data/pricemulti', queryParams);
    return uri.toString();
  }

  static String createCoinDetailsUrl(
      {required String coin, required String currency}) {
    final queryParams = {
      'fsyms': coin,
      'tsyms': currency,
      'api_key': apiKey,
    };

    final uri = Uri.https(
        'min-api.cryptocompare.com', '/data/pricemultifull', queryParams);
    return uri.toString();
  }

  static Future<Map<String, String>> getCoinPricesInCurrency(
      {required List<String> coins, required String currency}) async {
    try {
      return await NetworkHelper.getJsonData(
              url: createCoinPricesUrl(
                  coin: coins.join(','), currency: currency))
          .then((data) {
        var formatter = NumberFormat.simpleCurrency();
        return <String, String>{
          for (var coin in data.keys)
            coin: formatter.format(data[coin][currency])
        };
      });
    } catch (err) {
      return {'Error': err.toString()};
    }
  }

  static Future<Map<String, String>> getCoinDetailInCurrency(
      {required String coin, required String currency}) async {
    try {
      return await NetworkHelper.getJsonData(
              url: createCoinDetailsUrl(coin: coin, currency: currency))
          .then((data) {
        var moneyFormatter = NumberFormat.simpleCurrency();
        var percentFormatter = NumberFormat("##0.00\%");
        return {
          'Price': moneyFormatter.format(data['RAW'][coin][currency]['PRICE']),
          'Change Last Hour':
              moneyFormatter.format(data['RAW'][coin][currency]['CHANGEHOUR']),
          'Percent Change Last Hour': percentFormatter
              .format(data['RAW'][coin][currency]['CHANGEPCTHOUR']),
          'Change Last 24H': moneyFormatter
              .format(data['RAW'][coin][currency]['CHANGE24HOUR']),
          'Percent Change Last 24H': percentFormatter
              .format(data['RAW'][coin][currency]['CHANGEPCT24HOUR']),
        };
      });
    } catch (err) {
      return {'Error': err.toString()};
    }
  }
}

/// Helper class for making API calls and decoding returned JSON
class NetworkHelper {
  static Future<Map<String, dynamic>> getJsonData({required String url}) async {
    var uri = Uri.parse(url);
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      //Forecast forecast = fromJson(jsonDecode(response.body));
      // String weather = jsonDecode(data)['weather']['main'];

      return json.decode(response.body);
      //print(forecast.main);
    } else {
      return {'Error': '${response.statusCode}'};
    }
  }
}
