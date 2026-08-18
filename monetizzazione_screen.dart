import 'package:app_pubblicita_monetizazione/widget/dialog_monetization_app.dart';
import 'package:flutter/material.dart';

class MonetizzazioneScreen extends StatelessWidget {
  const MonetizzazioneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monetizazione',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () async {
                await DialogMonetizationApp.showDialog(context);
              },
              child: Text('Acquistare servizio premium'),
            ),
          ],
        ),
      ),
    );
  }
}
