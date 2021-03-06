// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'having_matcher.dart';
import 'interfaces.dart';

/// A [Matcher] subclass that supports validating the [Type] of the target
/// object.
///
/// ```dart
/// expect(shouldBeDuration, new TypeMatcher<Duration>());
/// ```
///
/// If you want to further validate attributes of the specified [Type], use the
/// [having] function.
///
/// ```dart
/// void shouldThrowRangeError(int value) {
///   throw new RangeError.range(value, 10, 20);
/// }
///
/// expect(
///     () => shouldThrowRangeError(5),
///     throwsA(const TypeMatcher<RangeError>()
///         .having((e) => e.start, 'start', greaterThanOrEqualTo(10))
///         .having((e) => e.end, 'end', lessThanOrEqualTo(20))));
/// ```
///
/// Notice that you can chain multiple calls to [having] to verify multiple
/// aspects of an object.
///
/// Note: All of the top-level `isType` matchers exposed by this package are
/// instances of [TypeMatcher], so you can use the [having] function without
/// creating your own instance.
///
/// ```dart
/// expect(
///     () => shouldThrowRangeError(5),
///     throwsA(isRangeError
///         .having((e) => e.start, 'start', greaterThanOrEqualTo(10))
///         .having((e) => e.end, 'end', lessThanOrEqualTo(20))));
/// ```
class TypeMatcher<T> extends Matcher {
  final String _name;
  const TypeMatcher(
      [@Deprecated('Provide a type argument to TypeMatcher and omit the name. '
          'This argument will be removed in the next release.')
          String name])
      : _name =
            // ignore: deprecated_member_use
            name;

  /// Returns a new [TypeMatcher] that validates the existing type as well as
  /// a specific [feature] of the object with the provided [matcher].
  ///
  /// Provides a human-readable [description] of the [feature] to make debugging
  /// failures easier.
  ///
  /// ```dart
  /// /// Validates that the object is a [RangeError] with a message containing
  /// /// the string 'details' and `start` and `end` properties that are `null`.
  /// final _rangeMatcher = isRangeError
  ///    .having((e) => e.message, 'message', contains('details'))
  ///    .having((e) => e.start, 'start', isNull)
  ///    .having((e) => e.end, 'end', isNull);
  /// ```
  TypeMatcher<T> having(
          Object feature(T source), String description, Object matcher) =>
      HavingMatcher(this, description, feature, matcher);

  Description describe(Description description) {
    var name = _name ?? _stripDynamic(T);
    return description.add("<Instance of '$name'>");
  }

  bool matches(Object item, Map matchState) => item is T;
}

final _dart2DynamicArgs = RegExp('<dynamic(, dynamic)*>');

/// With this expression `{}.runtimeType.toString`,
/// Dart 1: "<Instance of Map>
/// Dart 2: "<Instance of Map<dynamic, dynamic>>"
///
/// This functions returns the Dart 1 output, when Dart 2 runtime semantics
/// are enabled.
String _stripDynamic(Type type) =>
    type.toString().replaceAll(_dart2DynamicArgs, '');
