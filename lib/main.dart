import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/storage/hive_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/network/network_info.dart';

import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

import 'features/products/data/datasources/product_local_data_source.dart';
import 'features/products/data/datasources/product_remote_data_source.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/presentation/cubits/product_list_cubit.dart';

import 'features/wishlist/data/datasources/wishlist_local_data_source.dart';
import 'features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'features/wishlist/domain/repositories/wishlist_repository.dart';
import 'features/wishlist/presentation/cubits/wishlist_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveStorage.init();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferences>.value(value: sharedPreferences),
        RepositoryProvider<Dio>(create: (context) => Dio()),
        RepositoryProvider<Connectivity>(create: (context) => Connectivity()),
        RepositoryProvider<NetworkInfo>(
          create: (context) => NetworkInfoImpl(context.read<Connectivity>()),
        ),
        RepositoryProvider<AuthLocalDataSource>(
          create: (context) => AuthLocalDataSourceImpl(context.read<SharedPreferences>()),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(context.read<AuthLocalDataSource>()),
        ),
        RepositoryProvider<ProductLocalDataSource>(
          create: (context) => ProductLocalDataSourceImpl(HiveStorage.getBox(HiveStorage.productsBoxName)),
        ),
        RepositoryProvider<ProductRemoteDataSource>(
          create: (context) => ProductRemoteDataSourceImpl(context.read<Dio>()),
        ),
        RepositoryProvider<ProductRepository>(
          create: (context) => ProductRepositoryImpl(
            remoteDataSource: context.read<ProductRemoteDataSource>(),
            localDataSource: context.read<ProductLocalDataSource>(),
            networkInfo: context.read<NetworkInfo>(),
          ),
        ),
        RepositoryProvider<WishlistLocalDataSource>(
          create: (context) => WishlistLocalDataSourceImpl(HiveStorage.getBox(HiveStorage.wishlistBoxName)),
        ),
        RepositoryProvider<WishlistRepository>(
          create: (context) => WishlistRepositoryImpl(context.read<WishlistLocalDataSource>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider<WishlistCubit>(
            create: (context) => WishlistCubit(context.read<WishlistRepository>()),
          ),
          BlocProvider<ProductListCubit>(
            create: (context) => ProductListCubit(context.read<ProductRepository>()),
          ),
        ],
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;

    return MaterialApp(
      title: 'SwiftShop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
