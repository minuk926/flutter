class ApiResponse<T> {
  final bool success;
  final int code;
  final String message;
  final T data;
  final int totalCount;

  ApiResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
    required this.totalCount,
  });
}
