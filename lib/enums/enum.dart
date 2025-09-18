enum InternetAvailabilityType {
  turnOnInternet,
  noInternet,
}

enum APIErrorType {
  auth,                  // already exists – generic authentication errors
  other,
  toast,
  statusCode,
  internalServerError,
  urlNotFound,
  unauthorized,          // 🔥 NEW – for 401 unauthorized
  timeout,               // 🔥 NEW – for network timeouts
}
