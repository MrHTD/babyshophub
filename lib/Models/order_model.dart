class OrderModel {
  final String productId;
  final String productName;
  final String fullPrice;
  final List imageUrls;
  final String deliveryTime;
  final String productDescription;
  final dynamic createdAt;
  final dynamic confirmedAt;
  final dynamic shippedAt;
  final dynamic deliveredAt;
  final dynamic cancelledAt;
  final dynamic updatedAt;
  final int productQuantity;
  final double productTotalPrice;
  final String customerId;
  final String customerName;
  final String status;
  final String address;
  final String city;
  final String state;
  final String zipcode;
  final String contact;
  final String customerDeviceToken;
  final String orderId;
  final String trackingId;
  final bool useCardPayment;
  final bool useCodPayment;

  OrderModel({
    required this.productId,
    required this.productName,
    required this.fullPrice,
    required this.imageUrls,
    required this.deliveryTime,
    required this.productDescription,
    required this.createdAt,
    required this.confirmedAt,
    required this.shippedAt,
    required this.deliveredAt,
    required this.cancelledAt,
    required this.updatedAt,
    required this.productQuantity,
    required this.productTotalPrice,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.address,
    required this.city,
    required this.state,
    required this.zipcode,
    required this.contact,
    required this.customerDeviceToken,
    required this.orderId,
    required this.trackingId,
    required this.useCardPayment,
    required this.useCodPayment,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'fullPrice': fullPrice,
      'imageUrls': imageUrls,
      'deliveryTime': deliveryTime,
      'productDescription': productDescription,
      'createdAt': createdAt,
      'confirmedAt': confirmedAt,
      'shippedAt': shippedAt,
      'deliveredAt': deliveredAt,
      'cancelledAt': cancelledAt,
      'updatedAt': updatedAt,
      'productQuantity': productQuantity,
      'productTotalPrice': productTotalPrice,
      'customerId': customerId,
      'customerName': customerName,
      'status': status,
      'address': address,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'contact': contact,
      'customerDeviceToken': customerDeviceToken,
      'orderId': orderId,
      'trackingId': trackingId,
      'useCardPayment': useCardPayment,
      'useCodPayment': useCodPayment,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> json) {
    return OrderModel(
      productId: json['productId'],
      productName: json['productName'],
      fullPrice: json['fullPrice'],
      imageUrls: json['imageUrls'],
      deliveryTime: json['deliveryTime'],
      productDescription: json['productDescription'],
      createdAt: json['createdAt'],
      confirmedAt: json['confirmedAt'],
      shippedAt: json['shippedAt'],
      deliveredAt: json['deliveredAt'],
      cancelledAt: json['cancelledAt'],
      updatedAt: json['updatedAt'],
      productQuantity: json['productQuantity'],
      productTotalPrice: json['productTotalPrice'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      status: json['status'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipcode: json['zipcode'],
      contact: json['contact'],
      customerDeviceToken: json['customerDeviceToken'],
      orderId: json['orderId'],
      trackingId: json['trackingId'],
      useCardPayment: json['useCardPayment'],
      useCodPayment: json['useCodPayment'],
    );
  }
}
