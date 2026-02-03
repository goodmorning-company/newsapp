class DataState<T> {
  final T? data;
  final Object? error;

  const DataState._({this.data, this.error});

  const DataState.success(T data) : this._(data: data);
  const DataState.failure(Object error) : this._(error: error);

  bool get isSuccess => error == null;
}
