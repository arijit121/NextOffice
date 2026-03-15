enum Flavor {
  prod,
  stg,
  dev,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.prod:
        return 'NextOffice';
      case Flavor.stg:
        return 'Stg NextOffice';
      case Flavor.dev:
        return 'Dev NextOffice';
      default:
        return 'title';
    }
  }

}
