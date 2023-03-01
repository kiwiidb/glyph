class Profile {
  String? name;
  String? picture;
  String? about;
  String? nip05;
  String? lightning;

  Profile({this.name, this.picture, this.about, this.nip05, this.lightning});

  Profile.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    picture = json['picture'];
    about = json['about'];
    nip05 = json['nip05'];
    lightning = json['lightning'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['picture'] = picture;
    data['about'] = about;
    data['nip05'] = nip05;
    data['lightning'] = lightning;
    return data;
  }
}
