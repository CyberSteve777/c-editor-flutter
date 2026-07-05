import 'package:c_editor/widgets/asset_image.dart';

/// Dinosaur types available in [DinoWaveActionProps] (dino spawn / dino time).
const List<String> kDinoSpawnTypeIds = [
  'raptor',
  'stego',
  'ptero',
  'tyranno',
  'ankylo',
];

const String _dinoImageDir = 'assets/images/dinos';

/// Primary asset path for a dino spawn preview image.
/// [imageAltCandidates] on [AssetImageWidget] handles other extensions.
String dinoSpawnImageAsset(String typeId) {
  return '$_dinoImageDir/dino_$typeId.png';
}

List<String> dinoSpawnImageCandidates(String typeId) {
  return imageAltCandidates(dinoSpawnImageAsset(typeId));
}
