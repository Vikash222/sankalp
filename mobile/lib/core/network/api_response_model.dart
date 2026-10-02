class ApiResponseModel<T> {
  final bool success;
  final String? message;
  final T? data;
  final ApiErrorModel? error;
  final Map<String, dynamic>? meta;

  const ApiResponseModel({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.meta,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponseModel<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'] != null
          ? ApiErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }
}

class ApiErrorModel {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ApiErrorModel({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An unexpected error occurred.',
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}
