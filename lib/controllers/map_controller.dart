import 'package:get/get.dart';
import '../models/org_marker_model.dart';

class MapController extends GetxController {
  final RxList<OrgMarkerModel> providers = <OrgMarkerModel>[].obs;
  final Rxn<OrgMarkerModel> selectedProvider = Rxn<OrgMarkerModel>();

  @override
  void onInit() {
    super.onInit();
    _loadProviders();
  }

  void _loadProviders() {
    providers.assignAll([
      OrgMarkerModel(
        id: '1',
        name: 'Luxury Watch Repair Center',
        address: '104 Madison Ave, New York, NY',
        phone: '+1-212-555-0144',
        dx: 0.35,
        dy: -0.45,
        type: 'service_center',
      ),
      OrgMarkerModel(
        id: '2',
        name: 'Classic Horology Restoration',
        address: '54 Main St, Boston, MA',
        phone: '+1-617-555-0182',
        dx: -0.5,
        dy: 0.25,
        type: 'service_center',
      ),
      OrgMarkerModel(
        id: '3',
        name: 'Vintage Rolex & Omega Spares',
        address: '890 Wilshire Blvd, Los Angeles, CA',
        phone: '+1-310-555-0199',
        dx: 0.15,
        dy: 0.6,
        type: 'authorized_dealer',
      ),
      OrgMarkerModel(
        id: '4',
        name: 'Grand Chrono Authorized Dealer',
        address: '202 Michigan Ave, Chicago, IL',
        phone: '+1-312-555-0111',
        dx: -0.65,
        dy: -0.65,
        type: 'authorized_dealer',
      ),
    ]);
  }

  void selectProvider(OrgMarkerModel provider) {
    selectedProvider.value = provider;
  }

  void deselect() {
    selectedProvider.value = null;
  }
}
