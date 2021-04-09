class AccountValidation {
  dynamic findAccount({required List data, String? address}) {
    return data.firstWhere((account) => account['address'] == address,
        orElse: () => null);
  }
}
