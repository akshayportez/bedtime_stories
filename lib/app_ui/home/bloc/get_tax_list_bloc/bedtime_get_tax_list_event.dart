import 'package:equatable/equatable.dart';

abstract class BedtimeGetTaxListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetTaxListLoadRequested extends BedtimeGetTaxListEvent {
  final int companyId;

  BedtimeGetTaxListLoadRequested({required this.companyId});

  @override
  List<Object?> get props => [companyId];
}
