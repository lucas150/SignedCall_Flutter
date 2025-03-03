class FCMProcessingNotification {
  String title;
  String subTitle;
  String cancelCTA;

  FCMProcessingNotification({
    required this.title,
    required this.subTitle,
    required this.cancelCTA,
  });

  // Convert the object to a map for encoding as JSON
  Map<String, String> toMap() {
    return {
      'title': title,
      'subTitle': subTitle,
      'cancelCTA': cancelCTA,
    };
  }

  // Create an object from a map (decoding JSON)
  factory FCMProcessingNotification.fromMap(Map<String, String> map) {
    return FCMProcessingNotification(
      title: map['title'] ?? '',
      subTitle: map['subTitle'] ?? '',
      cancelCTA: map['cancelCTA'] ?? '',
    );
  }
}