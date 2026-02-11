import 'package:equatable/equatable.dart';

abstract class BedtimeGetCategoryListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetCategoryListLoadRequested extends BedtimeGetCategoryListEvent {
  final int companyId;

  BedtimeGetCategoryListLoadRequested({required this.companyId});

  @override
  List<Object?> get props => [companyId];
}
