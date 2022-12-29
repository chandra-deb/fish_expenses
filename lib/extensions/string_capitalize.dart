extension StringCapitalize on String {
  toCapitalize() {
    String st = this[0].toUpperCase();
    return replaceFirst(RegExp(this[0]), st);
  }
}
