import 'dart:convert';

class BlogModel {
  bool status;
  String msg;
  Data data;

  BlogModel(this.status, this.msg, this.data);

  factory BlogModel.fromJson(Map<dynamic, dynamic> json) {
    return BlogModel(
        json['status'], json['msg'] ?? '', new Data.fromJson(json['data']));
  }
}

class Data {
  List<Blogs> blogs;

  Data(this.blogs);

  factory Data.fromJson(Map<String, dynamic> json) {
    return
      Data(List<Blogs>.from(json["blogs"].map((x) => Blogs.fromJson(x))));
  }
}

class Blogs {
  String title;
  String blog_cat_name;
  String detail;
  String image;
  String created_at;

  Blogs(this.title,this.detail,this.image,this.created_at,this.blog_cat_name);

  factory Blogs.fromJson(Map<dynamic, dynamic> json) {
    return Blogs(
        json['title'] ?? '',
        json['detail'] ?? '',
        json['image'] ?? '',
        json['created_at']  ?? '',
        json['blog_cat_name'] ?? '');
  }
}
