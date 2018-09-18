class Slink {

  final Map payload;
  final String uid;
  final String intent;
  final String urlSelf;

  Slink({this.payload, this.uid, this.intent, this.urlSelf});

  factory Slink.fromJson(Map<String, dynamic> json) {
    return Slink(
      payload: json['payload'],
      uid: json['uid'],
      intent: json['intent'],
      urlSelf: json['metadata.url_self'],
    );
  }
}