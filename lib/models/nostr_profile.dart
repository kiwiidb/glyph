class Profile {
  String? name;
  String? picture;
  String? about;
  String? nip05;

  Profile({this.name, this.picture, this.about, this.nip05});

  Profile.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    picture = json['picture'];
    about = json['about'];
    nip05 = json['nip05'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['picture'] = picture;
    data['about'] = about;
    data['nip05'] = nip05;
    return data;
  }
}
