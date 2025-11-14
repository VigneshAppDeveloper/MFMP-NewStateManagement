class AppStateModel {
   final String? token;
  final String? isFirstRegister;
  final String? stateId;
  final String? districtId;

  AppStateModel({
    this.token,
    this.isFirstRegister,
    this.stateId,
    this.districtId,
  });

  bool get isLoggedIn => token != null && token!.isNotEmpty;
  bool get hasLocationSet => stateId?.isNotEmpty == true && districtId?.isNotEmpty == true;
}
