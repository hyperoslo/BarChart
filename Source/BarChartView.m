#import "BarChartView.h"
#import "UIColor+Hex.h"

static CGFloat BarChartTopMarginHeight = 12.0f;
static CGFloat BarChartBottomMarginHeight = 16.0f;
static CGFloat BarChartMinimumAndMaximumValueLabelLeftMargin = 8.0f;
static CGFloat BarChartMaximumValueLabelTopMargin = 9.0f;
static CGFloat BarChartMinimumValueLabelBottomMargin = 18.0f;
static CGFloat BarChartMinimumAndMaximumValueLabelWidth = 60.0f;
static CGFloat BarChartMinimumAndMaximumValueLabelHeight = 14.0f;
static CGFloat BarChartBarWidth = 9.0f;
static CGFloat BarChartBarDisplacement = 15.0f;
static CGFloat BarChartSecondaryBarDisplacement = -5.0f;

@interface BarChartView ()

@property (nonatomic) NSUInteger numberOfColumns;
@property (nonatomic) CGFloat columnWidth;
@property (nonatomic) CGFloat columnHeight;
@property (nonatomic) CGFloat minimumValue;
@property (nonatomic) CGFloat maximumValue;
@property (nonatomic) UILabel *minimumValueLabel;
@property (nonatomic) UILabel *maximumValueLabel;

@end

@implementation BarChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.verticalStripeGradientStartColor = [UIColor colorFromHex:@"0E223E"];
    self.verticalStripeGradientFinishColor = [UIColor colorFromHex:@"132B49"];
    self.horizontalLabelBackgroundColor = [UIColor colorFromHex:@"0F1E36"];
    self.horizontalLabelTextColor = [UIColor whiteColor];
    self.barColor = [UIColor colorFromHex:@"F5F5F8"];
    self.secondaryBarColor = [UIColor colorFromHex:@"3DAFEB"];
    self.minimumAndMaximumLabelTextColor = [UIColor colorFromHex:@"B1B1B1"];
    self.sectionTitleTextColor = [UIColor whiteColor];

    self.minimumAndMaximumLabelFont = [UIFont boldSystemFontOfSize:12];
    self.horizontalLabelFont = [UIFont systemFontOfSize:9];
    self.sectionTitleFont = [UIFont systemFontOfSize:12];

    [self addSubview:self.minimumValueLabel];
    [self addSubview:self.maximumValueLabel];

    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.numberOfColumns = 0;
    for (NSUInteger section = 0; section < [self.dataSource numberOfSectionsInBarChartView:self]; section++) {
        self.numberOfColumns += [self.dataSource barChartView:self numberOfColumnsInSection:section];
    }
    self.columnWidth = self.bounds.size.width / self.numberOfColumns;
    self.columnHeight = self.bounds.size.height - (BarChartTopMarginHeight + BarChartBottomMarginHeight * 1.5);
    self.minimumValue = [self.dataSource minimumValueInBarChartView:self];
    self.maximumValue = [self.dataSource maximumValueInBarChartView:self];

    [self drawVerticalStripes];
    [self drawBarsAndHorizontalLabels];
    [self drawVerticalSeparatorsAndSectionTitles];
    [self drawMinimumAndMaximumValues];
}

- (void)drawVerticalStripes
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    NSArray *colors = @[(__bridge id) ([self.verticalStripeGradientStartColor CGColor]), (__bridge id) ([self.verticalStripeGradientFinishColor CGColor])];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    for (NSUInteger i = 0; i < self.numberOfColumns; i++) {
        if (i % 2 == 0) {
            CGContextSaveGState(context);
            CGContextAddRect(context, CGRectMake(i * self.columnWidth, 0, self.columnWidth, self.bounds.size.height));
            CGContextClip(context);
            CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, 100), kCGGradientDrawsAfterEndLocation);
            CGContextRestoreGState(context);
        }
    }
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawBarsAndHorizontalLabels
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self.horizontalLabelBackgroundColor CGColor]);
    CGContextFillRect(context, CGRectMake(0, self.bounds.size.height - BarChartBottomMarginHeight, self.bounds.size.width, BarChartBottomMarginHeight));

    NSUInteger index = 0;
    for (NSUInteger section = 0; section < [self.dataSource numberOfSectionsInBarChartView:self]; section++) {
        for (NSUInteger col = 0; col < [self.dataSource barChartView:self numberOfColumnsInSection:section]; col++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:col inSection:section];
            CGFloat x = [self lineXAtIndex:index];
            if ([self.dataSource barChartView:self hasValueAtIndexPath:indexPath]) {
                CGFloat x0 = x - BarChartBarWidth / 2;
                CGFloat x1 = x + BarChartBarWidth / 2;
                CGFloat val = [self.dataSource barChartView:self valueAtIndexPath:indexPath];
                CGFloat y0 = self.bounds.size.height - BarChartBottomMarginHeight;
                CGFloat y1 = [self lineYForValue:val];
                CGContextSetFillColorWithColor(context, [self.barColor CGColor]);
                CGContextFillRect(context, CGRectMake(x0, y1, (x1 - x0), (y0 - y1)));
            }
            if ([self.dataSource barChartView:self hasSecondaryValueAtIndexPath:indexPath]) {
                CGFloat x0 = x - BarChartBarWidth / 2 + BarChartSecondaryBarDisplacement;
                CGFloat x1 = x + BarChartBarWidth / 2 + BarChartSecondaryBarDisplacement;
                CGFloat val = [self.dataSource barChartView:self secondaryValueAtIndexPath:indexPath];
                CGFloat y0 = self.bounds.size.height - BarChartBottomMarginHeight;
                CGFloat y1 = [self lineYForValue:val];
                CGContextSetFillColorWithColor(context, [self.secondaryBarColor CGColor]);
                CGContextFillRect(context, CGRectMake(x0, y1, (x1 - x0), (y0 - y1)));
            }

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.columnWidth, BarChartBottomMarginHeight)];
            label.font = self.horizontalLabelFont;
            label.textColor = self.horizontalLabelTextColor;
            label.text = [self.dataSource barChartView:self textAtIndexPath:indexPath];
            label.textAlignment = NSTextAlignmentCenter;
            label.center = CGPointMake(x, self.bounds.size.height - BarChartBottomMarginHeight / 2);
            [self addSubview:label];

            ++index;
        }
    }
}

- (void)drawVerticalSeparatorsAndSectionTitles
{
    if ([self.dataSource numberOfSectionsInBarChartView:self] > 1) {
        NSUInteger index = 0;
        // TODO: add asset to pod
        UIImage *image = [UIImage imageNamed:@"chart_vertical_separator"];
        for (NSUInteger section = 0; section < [self.dataSource numberOfSectionsInBarChartView:self]; section++) {
            if (section > 0) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake([self lineXAtIndex:index] - self.columnWidth / 2, 8, image.size.width, 128.0f)];
                imageView.image = image;
                [self addSubview:imageView];
            }

            NSString *title = [self.dataSource barChartView:self titleForSection:section];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([self lineXAtIndex:index] - self.columnWidth / 2 + 8, 8, 60.0f, 16.0f)];
            titleLabel.font = self.sectionTitleFont;
            titleLabel.textColor = self.sectionTitleTextColor;
            titleLabel.text = title;
            [self addSubview:titleLabel];

            index += [self.dataSource barChartView:self numberOfColumnsInSection:section];
        }
    }
}

- (void)drawMinimumAndMaximumValues
{
    self.minimumValueLabel.text = [self.dataSource minimumValueFormattedInBarChartView:self];
    self.maximumValueLabel.text = [self.dataSource maximumValueFormattedInBarChartView:self];
}

- (CGFloat)lineXAtIndex:(NSUInteger)index
{
    return index * self.columnWidth + BarChartBarDisplacement + BarChartBarWidth / 2;
}

- (CGFloat)lineYForValue:(CGFloat)val
{
    if (fabs(self.maximumValue - self.minimumValue) < 1e-5) {
        return 0.0f;
    } else {
        return BarChartTopMarginHeight + (self.columnHeight - BarChartTopMarginHeight) * (1.0 - ((val - self.minimumValue) / (self.maximumValue - self.minimumValue)));
    }
}

#pragma mark - Getters

- (UILabel *)minimumValueLabel
{
    if (_minimumValueLabel) return _minimumValueLabel;

    _minimumValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.contentOffset.x + BarChartMinimumAndMaximumValueLabelLeftMargin, self.bounds.size.height - (BarChartMinimumAndMaximumValueLabelHeight + BarChartMinimumValueLabelBottomMargin), BarChartMinimumAndMaximumValueLabelWidth, BarChartMinimumAndMaximumValueLabelHeight)];
    _minimumValueLabel.font = self.minimumAndMaximumLabelFont;
    _minimumValueLabel.textColor = self.minimumAndMaximumLabelTextColor;

    return _minimumValueLabel;
}

- (UILabel *)maximumValueLabel
{
    if (_maximumValueLabel) return _maximumValueLabel;

    _maximumValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.contentOffset.x + BarChartMinimumAndMaximumValueLabelLeftMargin, BarChartMaximumValueLabelTopMargin, BarChartMinimumAndMaximumValueLabelWidth, BarChartMinimumAndMaximumValueLabelHeight)];
    _maximumValueLabel.font = self.minimumAndMaximumLabelFont;
    _maximumValueLabel.textColor = self.minimumAndMaximumLabelTextColor;

    return _maximumValueLabel;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect frame = self.minimumValueLabel.frame;
    frame.origin.x = scrollView.contentOffset.x + BarChartMinimumAndMaximumValueLabelLeftMargin;
    self.minimumValueLabel.frame = frame;

    frame = self.maximumValueLabel.frame;
    frame.origin.x = scrollView.contentOffset.x + BarChartMinimumAndMaximumValueLabelLeftMargin;
    self.maximumValueLabel.frame = frame;
}

@end
