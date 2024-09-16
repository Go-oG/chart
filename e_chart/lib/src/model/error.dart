class ChartError extends Error {
  final String? message;

  ChartError([this.message]);
}

class ArgumentsError extends ChartError {
  ArgumentsError([super.message]);
}

class TypeMatchError extends ChartError {
  TypeMatchError([super.message]);
}

class UnSupportError extends ChartError {
  UnSupportError([super.message]);
}

class IllegalStatusError extends ChartError {
  IllegalStatusError([super.message]);
}
