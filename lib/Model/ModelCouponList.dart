

class ModelCouponList {
  bool status;
  String msg;

  List<DataPlan> data;


  ModelCouponList(this.status, this.msg,this.data);

  factory ModelCouponList.fromJson(Map<String, dynamic> json) {


    List<DataPlan> d=   List<DataPlan>.from(json["data"].map((x) => DataPlan.fromJson(x)));

    return ModelCouponList(json['status'],
        json['msg'],

      d
    );
  }
}


class DataPlan {
  int id;
  int discount_type ;
  int discount ;
  String coupon_code="" ;
  String description ="";
  int coupon_used_count ;
  String starting_date ;
  String expiry_date ;
  int applicable_on ;
  String created_at = "";
  String updated_at = "";
  DataPlan(this.id, this.discount_type,
      this.discount, this.coupon_code,
      this.description, this.coupon_used_count,
      this.starting_date, this.expiry_date,
      this.applicable_on, this.created_at,this.updated_at);
  factory DataPlan.fromJson(Map<String, dynamic> json) {
    return DataPlan(
        json['id'],
        json['discount_type'],
        json['discount'],
        json['coupon_code'],
        json['description'],
        json['coupon_used_count'],
        json['starting_date'],
        json['expiry_date'],
        json['applicable_on'],
        json['created_at'],
        json['updated_at'],
   );
  }
}






