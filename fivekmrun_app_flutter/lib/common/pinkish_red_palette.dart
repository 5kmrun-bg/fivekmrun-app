import 'package:charts_flutter/flutter.dart' as charts;

class PinkishRedColor extends charts.Color {
  PinkishRedColor() : super(r: 252, g: 24, b: 81); //#FC1851

  // Copied implementation from charts.Palette, because charts.Palette is not exposed for inheriting
  List<charts.Color> makeShades(int colorCnt) {
    final colors = <charts.Color>[this];

    final lighterColor = colorCnt < 3
        ? this.lighter
        : _getSteppedColor(this, (colorCnt * 2) - 1, colorCnt * 2);

    // Divide the space between 255 and c500 evenly according to the colorCnt.
    for (int i = 1; i < colorCnt; i++) {
      colors.add(_getSteppedColor(this, i, colorCnt,
          darker: this.darker, lighter: lighterColor));
    }

    colors.add(new charts.Color.fromOther(color: this, lighter: lighterColor));
    return colors;
  }

  charts.Color _getSteppedColor(charts.Color color, int index, int steps,
      {charts.Color darker, charts.Color lighter}) {
    final fraction = index / steps;
    return new charts.Color(
      r: color.r + ((255 - color.r) * fraction).round(),
      g: color.g + ((255 - color.g) * fraction).round(),
      b: color.b + ((255 - color.b) * fraction).round(),
      a: color.a + ((255 - color.a) * fraction).round(),
      darker: darker,
      lighter: lighter,
    );
  }

  List<charts.Color> getPalette() {
    return [
      charts.Color.fromHex(code: "#560000"),
      charts.Color.fromHex(code: "#880000"),
      charts.Color.fromHex(code: "#c10029"),
      charts.Color.fromHex(code: "#fb4d52"),
      charts.Color.fromHex(code: "#ff827e"),
    //  charts.Color.fromHex(code: "#ffb4ad"),
    ];
  }
}
