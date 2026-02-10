import 'package:equatable/equatable.dart';

abstract class BedtimeProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load Default Projects
class BedtimeProjectLoadRequested extends BedtimeProjectEvent {
  final int companyId;
  final int userId;

  BedtimeProjectLoadRequested({
    required this.companyId,
    required this.userId,
  });
}

/// Search Projects API Call
class BedtimeProjectSearchRequested extends BedtimeProjectEvent {
  final int companyId;
  final int userId;
  final String search;

  BedtimeProjectSearchRequested({
    required this.companyId,
    required this.userId,
    required this.search,
  });
}
