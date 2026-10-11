class OrgMarkerModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double dx; // X position percentage on radar (-1.0 to 1.0)
  final double dy; // Y position percentage on radar (-1.0 to 1.0)
  final String type; // 'service_center' or 'authorized_dealer'

  OrgMarkerModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.dx,
    required this.dy,
    required this.type,
  });
}
