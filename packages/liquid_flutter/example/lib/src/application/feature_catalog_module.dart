import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart' as liquid;

import '../domain/feature_demo.dart';

class FeatureCatalogModule {
  FeatureCatalogModule()
      : tub = liquid.Tub(label: 'feature_catalog'),
        themeMode = liquid.Drop<ThemeMode>(ThemeMode.light, label: 'theme_mode'),
        nestedParentCount = liquid.Drop<int>(0, label: 'nested_parent_count'),
        nestedChildCount = liquid.Drop<int>(0, label: 'nested_child_count'),
        searchQuery = liquid.Drop<String>('', label: 'search_query'),
        folderDepthCount = liquid.Drop<int>(1, label: 'folder_depth_count'),
        editorCharacterCount = liquid.Drop<int>(0, label: 'editor_char_count'),
        streamCounter = liquid.StreamDrop<int>(label: 'stream_counter'),
        rippleCount = liquid.Drop<int>(0, label: 'ripple_count'),
        baseCount = liquid.Drop<int>(0, label: 'base_count') {
    ripple = liquid.Ripple(
      source: baseCount,
      label: 'base_count_ripple',
      effect: () => rippleCount.value = rippleCount.value + 1,
    );
  }

  final liquid.Tub tub;
  final liquid.Drop<ThemeMode> themeMode;
  final liquid.Drop<int> baseCount;
  final liquid.Drop<int> nestedParentCount;
  final liquid.Drop<int> nestedChildCount;
  final liquid.Drop<String> searchQuery;
  final liquid.Drop<int> folderDepthCount;
  final liquid.Drop<int> editorCharacterCount;
  final liquid.StreamDrop<int> streamCounter;
  final liquid.Drop<int> rippleCount;
  late final liquid.Ripple ripple;

  final List<FeatureDefinition> features = const <FeatureDefinition>[
    FeatureDefinition(
      feature: LiquidFeature.drop,
      title: 'Drop',
      description: 'Smallest reactive state unit using a simple counter.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.flow,
      title: 'Flow',
      description: 'Derived counter state (double + triple) with memoized recompute.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.tub,
      title: 'Tub',
      description: 'Scoped state container for counter lifecycle ownership.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.ripple,
      title: 'Ripple',
      description: 'Counter side-effects that react to count changes.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.streamDrop,
      title: 'StreamDrop',
      description: 'Async counter loading state (loading/data/error).',
    ),
    FeatureDefinition(
      feature: LiquidFeature.nestedState,
      title: 'Nested State',
      description: 'Parent counter + child counter composition.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.searchState,
      title: 'Search State',
      description: 'Counter filtering through query state.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.editorState,
      title: 'Editor State',
      description: 'Counter reflected as editable text/character state.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.folderHierarchyState,
      title: 'Folder Hierarchy State',
      description: 'Hierarchical counters by folder depth.',
    ),
    FeatureDefinition(
      feature: LiquidFeature.themeState,
      title: 'Theme State',
      description: 'Counter app theme switching using Liquid state.',
    ),
  ];

  late final liquid.Flow<int> doubled = liquid.Flow<int>(
    () => baseCount.value * 2,
    label: 'doubled_count',
  );

  late final liquid.Flow<int> tripled = liquid.Flow<int>(
    () => baseCount.value * 3,
    label: 'tripled_count',
  );

  late final liquid.Flow<List<int>> searchResults = liquid.Flow<List<int>>(() {
    final String query = searchQuery.value.trim();
    final List<int> source = List<int>.generate(baseCount.value + 1, (int index) => index);
    if (query.isEmpty) {
      return source;
    }
    return source.where((int value) => value.toString().contains(query)).toList(growable: false);
  }, label: 'search_results');

  late final liquid.Flow<int> nestedTotal = liquid.Flow<int>(
    () => nestedParentCount.value + nestedChildCount.value,
    label: 'nested_total',
  );

  late final liquid.Flow<int> hierarchyTotal = liquid.Flow<int>(
    () => baseCount.value * folderDepthCount.value,
    label: 'hierarchy_total',
  );

  void increment() {
    baseCount.value = baseCount.value + 1;
  }

  void decrement() {
    if (baseCount.value == 0) {
      return;
    }
    baseCount.value = baseCount.value - 1;
  }

  void incrementNestedParent() {
    nestedParentCount.value = nestedParentCount.value + 1;
  }

  void incrementNestedChild() {
    nestedChildCount.value = nestedChildCount.value + 1;
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void setFolderDepth(int depth) {
    folderDepthCount.value = depth;
  }

  void setEditorText(String text) {
    editorCharacterCount.value = text.length;
  }

  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> loadAsyncCounter() async {
    await streamCounter.run(() async {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      return baseCount.value;
    });
  }

  void dispose() {
    ripple.dispose();
    tub.dispose();
  }
}
