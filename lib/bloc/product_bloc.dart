import 'package:bloc/bloc.dart';
import '../repo/product_repository.dart';

abstract class ProductEvent {}
class LoadProducts extends ProductEvent {}

abstract class ProductState {}
class ProductInitial extends ProductState {}
class ProductLoading extends ProductState {}
class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);
}
class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}

enum BottomNavState { home, wishlist, cart }

class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit() : super(BottomNavState.home);

  void showHome() => emit(BottomNavState.home);
  void showWishlist() => emit(BottomNavState.wishlist);
  void showCart() => emit(BottomNavState.cart);
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc(this.repository) : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await repository.fetchProducts();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError('Failed to fetch products.'));
      }
    });
  }
}
