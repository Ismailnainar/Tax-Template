class DispatchItem {
  final String id;
  final String salesman;
  final String reqno;
  final String commercialNo;
  final String commercialName;
  final String salesmanName;
  final String cusno;
  final String cusname;
  final String cussite;
  final double disQtyTotal;
  final double disMangerQtyTotal;
  final String date;
  final String deliverydate;
  final double balanceQty;
  final int previousTruckQty;
  final double pickedQty;
  final int returnQty;

  DispatchItem({
    required this.id,
    required this.salesman,
    required this.reqno,
    required this.commercialNo,
    required this.commercialName,
    required this.salesmanName,
    required this.cusno,
    required this.cusname,
    required this.cussite,
    required this.disQtyTotal,
    required this.disMangerQtyTotal,
    required this.date,
    required this.deliverydate,
    required this.balanceQty,
    required this.previousTruckQty,
    required this.pickedQty,
    required this.returnQty,
  });

  factory DispatchItem.fromMap(Map<String, dynamic> map) {
    return DispatchItem(
      id: map['id']?.toString() ?? '',
      salesman: map['salesman']?.toString() ?? '',
      reqno: map['reqno']?.toString() ?? '',
      commercialNo: map['commercialNo']?.toString() ?? '',
      commercialName: map['commercialName']?.toString() ?? '',
      salesmanName: map['salesmanName']?.toString() ?? '',
      cusno: map['cusno']?.toString() ?? '',
      cusname: map['cusname']?.toString() ?? '',
      cussite: map['cussite']?.toString() ?? '',
      disQtyTotal:
          double.tryParse(map['dis_qty_total']?.toString() ?? '0') ?? 0,
      disMangerQtyTotal:
          double.tryParse(map['dis_mangerQty_total']?.toString() ?? '0') ?? 0,
      date: map['date']?.toString() ?? '',
      deliverydate: map['deliverydate']?.toString() ?? '',
      balanceQty: double.tryParse(map['balance_qty']?.toString() ?? '0') ?? 0,
      previousTruckQty:
          int.tryParse(map['previous_truck_qty']?.toString() ?? '0') ?? 0,
      pickedQty: double.tryParse(map['picked_qty']?.toString() ?? '0') ?? 0,
      returnQty: int.tryParse(map['return_qty']?.toString() ?? '0') ?? 0,
    );
  }
}
