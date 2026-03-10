import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseView<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T model, Widget? child) builder;
  final T model;
  final Function(T)? onModelReady;

  const BaseView({
    required this.builder,
    required this.model,
    this.onModelReady,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (_) {
        if (onModelReady != null) onModelReady!(model);
        return model;
      },
      child: Consumer<T>(builder: builder),
    );
  }
}
