extension IntX on int {
  Duration get millis => Duration(milliseconds: this);
  Duration get mins => Duration(minutes: this);
  Duration get secs => Duration(seconds: this);
  Duration get hours => Duration(hours: this);
}
