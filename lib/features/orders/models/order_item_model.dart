class OrderItem {
  const OrderItem({
    required this.orderType,
    required this.quantity,
    required this.unitPrice,
    required this.measurementId,
    required this.measurementMap,
  });

  final String orderType;
  final int quantity;
  final double unitPrice;
  final String? measurementId;
  final Map<String, double> measurementMap;

  double get lineTotal => unitPrice * quantity;

  OrderItem copyWith({
    String? orderType,
    int? quantity,
    double? unitPrice,
    String? measurementId,
    Map<String, double>? measurementMap,
  }) {
    return OrderItem(
      orderType: orderType ?? this.orderType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      measurementId: measurementId ?? this.measurementId,
      measurementMap: measurementMap ?? this.measurementMap,
    );
  }
}
