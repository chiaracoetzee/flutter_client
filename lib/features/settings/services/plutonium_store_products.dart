// TEMP: Remove once play store is fully setup
bool get plutoniumStorePurchasesEnabled => false;

const String kPlutoniumStoreMonthlyProductId = 'plutonium_monthly';
const String kPlutoniumStoreYearlyProductId = 'plutonium_yearly';

const Set<String> kPlutoniumStoreProductIds = {
  kPlutoniumStoreMonthlyProductId,
  kPlutoniumStoreYearlyProductId,
};

int? plutoniumYearlySavingsPercent({
  required double monthlyRawPrice,
  required double yearlyRawPrice,
}) {
  if (monthlyRawPrice <= 0 || yearlyRawPrice <= 0) {
    return null;
  }
  final double fullYear = monthlyRawPrice * 12;
  if (yearlyRawPrice >= fullYear) {
    return null;
  }
  final int percent = ((fullYear - yearlyRawPrice) / fullYear * 100).round();
  if (percent <= 0) {
    return null;
  }
  return percent;
}
