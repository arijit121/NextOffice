import 'package:nextoffice/flavors.dart';
import 'package:nextoffice/main.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.stg;
  await runner.main();
}
