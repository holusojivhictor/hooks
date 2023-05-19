enum Font {
  clashDisplay('ClashDisplay'),
  ubuntu('Ubuntu'),
  ubuntuMono('Ubuntu Mono'),
  notoSerif('Noto Serif', isSerif: true);

  const Font(this.uiLabel, {this.isSerif = false});

  final String uiLabel;
  final bool isSerif;

  static Font fromString(String? val) {
    switch (val) {
      case 'ubuntu':
        return Font.ubuntu;
      case 'ubuntuMono':
        return Font.ubuntuMono;
      case 'notoSerif':
        return Font.notoSerif;
      case 'ClashDisplay':
      default:
        return Font.clashDisplay;
    }
  }
}
