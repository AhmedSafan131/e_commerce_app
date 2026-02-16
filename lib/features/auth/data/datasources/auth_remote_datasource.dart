import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_commerce_app/core/errors/failures.dart';
import 'package:e_commerce_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> login(String email, String password) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

    if (userCredential.user == null) {
      throw const ServerFailure('User is null');
    }

    return UserModel.fromFirebaseUser(userCredential.user!);
  }

  @override
  Future<UserModel> register(String email, String password) async {
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    if (userCredential.user == null) {
      throw const ServerFailure('User is null');
    }

    return UserModel.fromFirebaseUser(userCredential.user!);
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    } else {
      throw const ServerFailure('No user logged in');
    }
  }
}
