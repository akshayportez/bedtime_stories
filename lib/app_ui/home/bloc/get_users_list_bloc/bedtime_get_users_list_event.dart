import 'package:equatable/equatable.dart';

abstract class BedtimeGetUsersListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetUsersListLoadRequested extends BedtimeGetUsersListEvent {
  final int companyId;
  final String search;

  BedtimeGetUsersListLoadRequested({
    required this.companyId,
    this.search = "",
  });

  @override
  List<Object?> get props => [companyId, search];
}
