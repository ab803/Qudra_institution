class SubscribtionInstitutionmodel {
  final int id;
  final DateTime createdAt;
  final int amount;
  final String institutionId;
  final String paymentMethod;
  final  DateTime startDate;
  final  DateTime endDate;
  final int bundleId;

  SubscribtionInstitutionmodel({
    required this.id,
    required this.createdAt,
    required this.amount,
    required this.institutionId,
    required this.paymentMethod,
    required this.startDate,
    required this.endDate,
    required this.bundleId});

  factory SubscribtionInstitutionmodel.fromJson(Map<String,dynamic>json){
    return SubscribtionInstitutionmodel(
        id: json['id'] as int,
        createdAt: DateTime.parse(json['created_at']as String),
        amount: json['Amount'] as int,
        institutionId:json['institution_id'] as String ,
        paymentMethod: json['payment_method'] as String,
        startDate: DateTime.parse(json['start_date']as String),
        endDate: DateTime.parse(json['end_date']as String),
        bundleId: json['bundle_id'] as int
    );
  }
  Map<String,dynamic>toJson(){
    return{
      'Amount':amount,
      'institution_id':institutionId,
      'payment_method':paymentMethod,
      'start_date':startDate.toIso8601String(),
      'end_date':endDate.toIso8601String(),
      'bundle_id':bundleId
    };
  }


}