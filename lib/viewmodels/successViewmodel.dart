class CreateTripSuccessViewModel {
  final String tripName;
  final String startTime;

  CreateTripSuccessViewModel({
    this.tripName = "Your trip",
    this.startTime = "the selected start time",
  });

  String get title => "Trip Created Successfully!";

  String get subtitle => "$tripName is ready for your adventure!";

  String get trackingText => "Tracking will start at $startTime";

  String get gpsMessage =>
      "📡 GPS tracking activates at trip start time. Activities and locations will be detected automatically.";

  String get notificationMessage =>
      "🔔 Invited friends will receive a notification. A reminder will be sent before the trip starts.";
}