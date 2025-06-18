extension StringExtensions on String {
  String get toTitleCase => this
      .split(" ")
      .map((str) => str[0].toUpperCase() + str.substring(1))
      .join(" ");
}
