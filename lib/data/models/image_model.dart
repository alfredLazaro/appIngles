class Image_Model {
  int? id;
  int? wordId;
  String? name;
  String? url;
  String? tinyurl;
  String? author;
  String? source;

  Image_Model(
      {this.id,
      this.wordId,
      required this.name,
      this.url,
      this.tinyurl,
      this.author,
      this.source});
  //convertir un objeto en un mapa (para insertar en la base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wordId': wordId,
      'name': name,
      'url': url,
      'tinyurl': tinyurl,
      'author': author,
      'source': source
    };
  }

  //crear un objeto desde un map (desde la base de datos)
  factory Image_Model.fromMap(Map<String, dynamic> map) {
    return Image_Model(
        id: map['id'],
        wordId: map['wordId'],
        name: map['nameImg'],
        url: map['url'],
        tinyurl: map['tinyurl'],
        author: map['author'],
        source: map['source']);
  }
}
