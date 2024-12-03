import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignInEvent extends AuthEvent {
  final String uid;

  SignInEvent(this.uid);

  @override
  List<Object?> get props => [uid];
}

class SignOutEvent extends AuthEvent {}

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final String uid;

  Authenticated(this.uid);

  @override
  List<Object?> get props => [uid];
}

class Unauthenticated extends AuthState {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignInEvent>((event, emit) {
      emit(Authenticated(event.uid));
    });

    on<SignOutEvent>((event, emit) {
      emit(Unauthenticated());
    });
  }
}
