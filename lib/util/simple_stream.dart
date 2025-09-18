
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SimpleStream<T> extends ChangeNotifier {
  bool loading = false;
  Object? error;
  T? data;

  SimpleStream(this.data, {this.error, this.loading = false});

  bool get hasData => error != null && !loading;

  SimpleStreamState get state {
    if (loading) {
      return SimpleStreamState.loading;
    }
    if (error != null) {
      return SimpleStreamState.hasError;
    }
    return SimpleStreamState.hasData;
  }

  addLoading(bool loading) {
    this.loading = loading;
    notifyListeners();
  }

  add(T data) {
    this.data = data;
    this.error = null;
    this.loading = false;
    notifyListeners();
  }

  clear() {
    this.data = null;
    this.error = null;
    this.loading = false;
    notifyListeners();
  }

  addError(Object e) {
    this.error = e;
    this.data = null;
    this.loading = false;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleStream &&
          runtimeType == other.runtimeType &&
          loading == other.loading &&
          error == other.error &&
          data == other.data;

  @override
  int get hashCode => loading.hashCode ^ error.hashCode ^ data.hashCode;
}

class PaginationStream<T> extends ChangeNotifier {
  final int count;
  int page = 1;
  bool loading = false;
  bool secondaryLoading = false;
  Object? error;
  Object? paginationError;
  List<T>? data;

  void clear() {
    page = 1;
    loading = false;
    secondaryLoading = false;
    error = null;
    paginationError = null;
    data = null;
    notifyListeners();
  }

  PaginationStream({
    this.data,
    required this.count,
    this.page = 1,
    this.error,
    this.paginationError,
    this.loading = false,
    this.secondaryLoading = false,
  });

  bool get hasData => error != null && !loading;

  SimpleStreamState get state {
    if (loading) {
      return SimpleStreamState.loading;
    }
    if (error != null) {
      return SimpleStreamState.hasError;
    }
    return SimpleStreamState.hasData;
  }

  addLoading(bool loading) {
    if (page == 1) {
      this.loading = loading;
    } else {
      this.secondaryLoading = loading;
    }
    notifyListeners();
  }

  add(List<T> data) {
    if (page == 1) {
      this.data = data;
      page++;
    } else if (data.isNotEmpty) {
      this.data!.addAll(data);
      page++;
      // if (data.length >= count) {
      //
      // }
    }

    this.error = null;
    this.loading = false;
    this.secondaryLoading = false;

    notifyListeners();
  }

  addError(Object e) {
    if (page == 1) {
      this.error = e;
      this.data = null;
      this.loading = false;
      this.secondaryLoading = false;
    } else {
      this.paginationError = e;
      this.loading = false;
      this.secondaryLoading = false;
    }
    notifyListeners();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationStream &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          page == other.page &&
          loading == other.loading &&
          secondaryLoading == other.secondaryLoading &&
          error == other.error &&
          paginationError == other.paginationError &&
          data == other.data;

  @override
  int get hashCode =>
      count.hashCode ^
      page.hashCode ^
      loading.hashCode ^
      secondaryLoading.hashCode ^
      error.hashCode ^
      paginationError.hashCode ^
      data.hashCode;
}

class AppRefreshableWidget extends StatelessWidget {
  final Widget child;

  const AppRefreshableWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: child,
        ),
      ],
    );
  }
}



enum SimpleStreamState {
  loading,
  hasData,
  hasError,
}

extension SimpleStreamStateExt on SimpleStreamState {
  bool get loading => this == SimpleStreamState.loading;
  bool get hasError => this == SimpleStreamState.hasError;
}

extension BuildContextExt on BuildContext {
  SimpleStream<K> selectStream<T, K>(
      SimpleStream<K> Function(T value) selector) {
    final loading = select((T value) => selector(value).loading);
    final data = select((T value) => selector(value).data);
    final error = select((T value) => selector(value).error);
    return SimpleStream(data, error: error, loading: loading);
  }

  PaginationStream<K> selectPagination<T, K>(
      PaginationStream<K> Function(T value) selector) {
    final loading = select((T value) => selector(value).loading);
    final data = select((T value) => selector(value).data);
    final error = select((T value) => selector(value).error);
    final count = select((T value) => selector(value).count);
    final page = select((T value) => selector(value).page);
    final paginationError =
        select((T value) => selector(value).paginationError);
    final secondaryLoading =
        select((T value) => selector(value).secondaryLoading);
    return PaginationStream(
      data: data,
      error: error,
      loading: loading,
      count: count,
      page: page,
      paginationError: paginationError,
      secondaryLoading: secondaryLoading,
    );
  }
}

