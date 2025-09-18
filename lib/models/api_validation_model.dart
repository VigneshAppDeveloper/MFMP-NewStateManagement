class ApiValidationModel {
  ApiValidationModel({
    required this.status,
    required this.message,
    required this.validationErrors,
  });

  final bool? status;
  final String? message;
  final List<ValidationError> validationErrors;

  factory ApiValidationModel.fromJson(Map<String, dynamic> json) {
    return ApiValidationModel(
      status: json["status"],
      message: json["message"],
      validationErrors: json["validation_errors"] == null
          ? []
          : List<ValidationError>.from(json["validation_errors"]!
              .map((x) => ValidationError.fromJson(x))),
    );
  }

  @override
  String toString() {
    return "$status, $message, $validationErrors, ";
  }
}

class ValidationError {
  ValidationError({
    required this.field,
    required this.message,
  });

  final String? field;
  final String? message;

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json["field"],
      message: json["message"],
    );
  }

  @override
  String toString() {
    return "$field, $message, ";
  }
}
