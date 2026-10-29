import 'package:app_theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('spacing steps sit on the 4-point grid and grow', () {
    const steps = [AppSpacing.xs, AppSpacing.s, AppSpacing.m, AppSpacing.l, AppSpacing.xl, AppSpacing.xxl];
    for (final step in steps) {
      expect(step % 4, 0, reason: '$step is off the 4-point grid');
    }
    expect(steps, orderedEquals([...steps]..sort()));
  });

  test('text sizes grow from caption to display', () {
    const sizes = [
      AppTextSize.micro,
      AppTextSize.caption,
      AppTextSize.body,
      AppTextSize.bodyLarge,
      AppTextSize.title,
      AppTextSize.headline,
      AppTextSize.display,
    ];
    expect(sizes, orderedEquals([...sizes]..sort()));
    expect(AppTextSize.body, 14, reason: 'body matches the TextViewWidget default');
  });

  test('the minimum tap target follows platform guidelines', () {
    expect(AppSpacing.minTapTarget, greaterThanOrEqualTo(48));
  });
}
