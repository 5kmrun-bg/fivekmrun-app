import 'package:flutter/material.dart';

class NoResultsComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          Text("Няма подходящи бягания!",
              style: Theme.of(context).textTheme.subtitle1),
          Padding(
            padding: const EdgeInsets.only(
                left: 36.0, top: 36.0, right: 36.0, bottom: 18.0),
            child: Text(
                "Участието в класацията е възможно с бягания отговарящи на следните условия:"),
          ),
          Column(
            children: [
              Text(
                  "1. Бягането е качено в Strava и е направено в текущата седмица\n\n2. Бягането е от тип Run и не е на пътека\n\n3. Дължината на бягането е поне 5км\n\n4. Към бягането има карта, която е видима за всички потребители",
                  textAlign: TextAlign.left),
            ],
          ),
        ],
      ),
    );
  }
}
