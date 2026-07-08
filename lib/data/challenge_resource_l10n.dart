import 'package:flutter/widgets.dart';
import 'package:c_editor/l10n/resource_names.dart';

/// Star challenge field / enum labels from [assets/l10n/resource_*.json].
abstract class ChallengeResourceL10n {
  ChallengeResourceL10n._();

  static String _lookup(BuildContext context, String key, String fallback) {
    final localized = ResourceNames.lookup(context, key);
    return localized != key ? localized : fallback;
  }

  static String title(
    BuildContext context,
    String objClass, {
    String? fallback,
  }) =>
      _lookup(context, 'starChallenge_${objClass}_title', fallback ?? objClass);

  static String description(BuildContext context, String objClass) =>
      _lookup(context, 'starChallenge_${objClass}_desc', '');

  static String property(
    BuildContext context,
    String objClass,
    String propertyName, [
    String? fallback,
  ]) {
    final key = '${objClass}_$propertyName';
    final localized = ResourceNames.lookup(context, key);
    if (localized != key) return localized;
    return field(context, propertyName, fallback);
  }

  static String listTypeOption(
    BuildContext context,
    String objClass,
    String value,
  ) {
    final key = '${objClass}_ListType_$value';
    final localized = ResourceNames.lookup(context, key);
    if (localized != key) return localized;
    return listType(context, value);
  }

  static String field(
    BuildContext context,
    String fieldName, [
    String? fallback,
  ]) {
    final key = 'starChallengeField_$fieldName';
    final localized = ResourceNames.lookup(context, key);
    return localized != key ? localized : (fallback ?? fieldName);
  }

  static String listType(BuildContext context, String listType) {
    final key = 'starChallengeListType_$listType';
    final localized = ResourceNames.lookup(context, key);
    return localized != key ? localized : listType;
  }

  static String profession(BuildContext context, String professionId) {
    final key = 'starChallengeProfession_$professionId';
    final localized = ResourceNames.lookup(context, key);
    return localized != key ? localized : professionId;
  }
}
