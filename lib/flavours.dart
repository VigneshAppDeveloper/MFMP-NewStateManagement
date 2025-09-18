enum Flavor {
  dev,
  prod,
  demo,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'MyFood MyPrice Dev';
      case Flavor.prod:
        return 'MyFood MyPrice';
      case Flavor.demo:
        return 'MyFood MyPrice Demo';
      default:
        return 'title';
    }
  }
}
