class AccountValidation {
  dynamic findAccount({List data, String address}) {
    return data.firstWhere((account) => account['address'] == address,
        orElse: () => null);
  }
}
