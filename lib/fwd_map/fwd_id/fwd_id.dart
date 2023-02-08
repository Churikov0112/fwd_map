import 'package:equatable/equatable.dart';

class FwdId extends Equatable {
  final String id;

  const FwdId.fromString(this.id);

  @override
  String toString() {
    return id;
  }

  @override
  List<Object> get props => [id];
}
