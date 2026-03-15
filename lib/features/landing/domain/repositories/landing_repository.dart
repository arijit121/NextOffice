import 'package:nextoffice/features/landing/domain/entities/landing_banner.dart';

abstract class LandingRepository {
  Future<LandingBanner?> getSplashBanner();
}
