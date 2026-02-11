import 'package:equatable/equatable.dart';

abstract class BedtimeGetAccountsListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetAccountsListLoadRequested
    extends BedtimeGetAccountsListEvent {
  final int companyId;

  BedtimeGetAccountsListLoadRequested({required this.companyId});

  @override
  List<Object?> get props => [companyId];
}

