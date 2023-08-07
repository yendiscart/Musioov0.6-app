class ModelPlayListYT{
List<Items> items;

ModelPlayListYT(this.items);
factory ModelPlayListYT.fromJson(Map<dynamic, dynamic> json) {

  return ModelPlayListYT(List<Items>.from(json["items"].map((x) => Items.fromJson(x))));
}
}

class Items{
Snippet snippet;

Items(this.snippet);
factory Items.fromJson(Map<dynamic, dynamic> json) {

  return Items(new Snippet.fromJson(json['snippet']));
}


}
class Snippet{
String title;
String description;
Thumbnails thumbnails;
ResourceId resourceId;

Snippet(this.title, this.description, this.thumbnails, this.resourceId);
factory Snippet.fromJson(Map<dynamic, dynamic> json) {

  return Snippet(json['title'] ?? '',json['description'] ?? '',new Thumbnails.fromJson(json['thumbnails']),new ResourceId.fromJson(json['resourceId']));
}

}

class ResourceId{
String videoId;

ResourceId(this.videoId);

factory ResourceId.fromJson(Map<dynamic, dynamic> json) {

  return ResourceId(json['videoId']);
}
}

class Thumbnails{
  Medium medium;

  Thumbnails(this.medium);

  factory Thumbnails.fromJson(Map<dynamic, dynamic> json) {

    return Thumbnails(new Medium.fromJson(json['medium']));
  }
}

class Medium{
String url;
int width;
int height;

Medium(this.url, this.width, this.height);
factory Medium.fromJson(Map<dynamic, dynamic> json) {

  return Medium(
      json['url'] ?? '',
      json['width'] ?? 0,
      json['height'] ?? 0,
  );
}
}