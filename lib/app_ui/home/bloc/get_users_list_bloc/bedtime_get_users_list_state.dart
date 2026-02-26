import 'package:bedtime_stories/app_ui/home/model/bedtime_get_users_list_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimeGetUsersListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetUsersListInitial extends BedtimeGetUsersListState {}

class BedtimeGetUsersListLoading extends BedtimeGetUsersListState {}

class BedtimeGetUsersListLoaded extends BedtimeGetUsersListState {
  final List<BedtimeGetUsersList> users;

  BedtimeGetUsersListLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class BedtimeGetUsersListFailure extends BedtimeGetUsersListState {
  final String message;

  BedtimeGetUsersListFailure(this.message);

  @override
  List<Object?> get props => [message];
}
