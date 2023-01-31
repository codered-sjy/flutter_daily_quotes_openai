import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class QuotePage extends StatefulWidget {
  const QuotePage({Key? key}) : super(key: key);

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    animation = Tween(
        begin: 0.0,
        end: 1.0
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green, Colors.blue
                ])
        ),
        child: Center(
          child: FutureBuilder(
            future: _getQuoteOfTheDay(),
            builder: ((context, data) {
              if (data.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(color: Colors.white);
              }
              final List<String> quote = data.data.toString().replaceAll("\n", "").replaceAll("\"", "").split("~~");
              return FadeTransition(
                opacity: _controller,
                child: Card(
                  color: Colors.black12,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  elevation: 20,
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.format_quote, size: 30, color: Colors.white),
                        const SizedBox(height: 10),
                        Text(quote[0],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              wordSpacing: 10,
                              fontSize: 30, fontWeight: FontWeight.w100, color: Colors.white),),
                        const SizedBox(height: 10),
                        Text(
                          quote[1],
                          style: const TextStyle(
                              wordSpacing: 10,
                              fontSize: 14, fontWeight: FontWeight.w100, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }


  Future<String> _getQuoteOfTheDay() async {
    try {
      final result = await FirebaseFunctions.instance.httpsCallable('generateQuoteOfTheDay').call();
      _controller.forward();
      return result.data;
    } catch (error) {
      return "Error while retrieving data";
    }
  }

}
