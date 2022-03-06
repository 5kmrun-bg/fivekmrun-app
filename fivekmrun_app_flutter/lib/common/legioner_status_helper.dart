import 'package:flutter/material.dart';

class LegionerStatusHelper {
  static Color getLegionerColor(Color defaultColor, int totalRuns) {
    Color legionerColor = defaultColor;
    // print("TOTAL RUNS: " + totalRuns.toString());

    if (totalRuns >= 50 && totalRuns < 100)
      legionerColor = Color.fromRGBO(36, 132, 208, 1);
    if (totalRuns >= 100 && totalRuns < 200)
      legionerColor = Color.fromRGBO(202, 202, 202, 1);
    if (totalRuns >= 200 && totalRuns < 300)
      legionerColor = Color.fromRGBO(65, 170, 71, 1);
    if (totalRuns >= 300 && totalRuns < 400)
      legionerColor = Color.fromRGBO(129, 74, 177, 1);
    if (totalRuns >= 400 && totalRuns < 500)
      legionerColor = Color.fromRGBO(255, 22, 17, 1);
    if (totalRuns >= 500 && totalRuns < 600)
      legionerColor = Color.fromRGBO(222, 198, 62, 1);
    if (totalRuns >= 600) legionerColor = Color.fromRGBO(50, 173, 159, 1);

    // print("COLOR: " + legionerColor.toString());

    return legionerColor;
  }

  static int getNextMilestone(int currentRuns) {
    if (currentRuns < 50) return 50;
    if (currentRuns >= 50 && currentRuns < 100) return 100;
    if (currentRuns >= 100 && currentRuns < 200) return 200;
    if (currentRuns >= 200 && currentRuns < 300) return 300;
    if (currentRuns >= 300 && currentRuns < 400) return 400;
    if (currentRuns >= 400 && currentRuns < 500) return 500;
    if (currentRuns >= 500 && currentRuns < 600) return 600;

    return 1000;
  }
}
