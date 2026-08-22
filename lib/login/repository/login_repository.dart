class LoginRepository {
  const LoginRepository();

  Future<bool> login(String mobileNumber) async {
    // TODO: replace with a real authentication API call.
    await Future.delayed(const Duration(seconds: 1));
    return mobileNumber.isNotEmpty;
  }
}
