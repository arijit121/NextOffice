import 'package:nextoffice/features/landing/domain/entities/landing_banner.dart';
import 'package:nextoffice/features/landing/domain/repositories/landing_repository.dart';

class GetSplashBannerUseCase {
  final LandingRepository repository;

  GetSplashBannerUseCase(this.repository);

  Future<LandingBanner?> call() async {
    return await repository.getSplashBanner();
  }
}
