

class ModelAllCat {
  bool status;
  String msg;
  String imagePath;
  List<SubData> sub_category;


  ModelAllCat(this.status, this.msg,this.sub_category,this.imagePath);

  factory ModelAllCat.fromJson(Map<String, dynamic> json) {
    List<SubData> d=   List<SubData>.from(json["sub_category"].map((x) => SubData.fromJson(x)));



    return ModelAllCat(json['status'],
        json['msg'],
      d
        ,json['imagePath'] ?? ''
    );
  }
}

/*class DataCat {

  String cat_name = "";
  String imagePath = "";
  List<SubData> sub_category;
  DataCat(this.cat_name,this.imagePath, this.sub_category);
  factory DataCat.fromJson(Map<String, dynamic> json) {

    List<SubData> d=   List<SubData>.from(json["sub_category"].map((x) => SubData.fromJson(x)));


    return DataCat(json['cat_name'],json['imagePath'] ?? '', d);
  }

}*/

class SubData {
  int id ;
  String name = "";
  String slug = "";
  String image ="";
  int is_featured;
  int is_trending;
  int is_recommended;

  SubData(this.id, this.name, this.slug, this.image,this.is_featured, this.is_trending, this.is_recommended);
  factory SubData.fromJson(Map<String, dynamic> json) {
    return SubData(json['id'],json['name'],json['slug'],json['image'] ?? '',json['is_featured'],json['is_trending'],json['is_recommended']);
  }

}



