import 'package:equatable/equatable.dart';
import 'package:uuid/data.dart';
import 'package:uuid/rng.dart';
import 'package:uuid/uuid.dart';

class FwdId extends Equatable {
  factory FwdId.fromJson(dynamic json) {
    if (json.runtimeType == int) {
      return FwdId.fromInt(json as int);
    }
    if (json.runtimeType == String) {
      return FwdId.fromString(json as String);
    }
    // ignore: avoid_dynamic_calls
    return FwdId.fromString(json['id'] as String);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'id': _id};

  final String? _id;

  const FwdId.absent()
      : _id = null,
        super();

  const FwdId.fromString(String id)
      : _id = id,
        super();

  FwdId.fromNumber(num id)
      : _id = id.toString(),
        super();

  FwdId.fromInt(int id)
      : _id = id.toString(),
        super();

  FwdId.fromDouble(double id)
      : _id = id.toString(),
        super();

  factory FwdId.generateFromRandomUUID() {
    return FwdId.fromString(
      Uuid(
        goptions: GlobalOptions(CryptoRNG()),
      ).v4(),
    );
  }

  bool get isAbsent => _id == null;

  String parseToString() => _id!;
  num parseToNumber() => num.parse(_id!);
  int parseToInt() => int.parse(_id!);
  double parseToDouble() => double.parse(_id!);

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [_id];
}
