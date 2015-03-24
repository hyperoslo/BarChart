@import UIKit;

@protocol BarChartViewDataSource;

@interface BarChartView : UIView

@property (weak, nonatomic) id<BarChartViewDataSource> dataSource;

@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) CGFloat progressBarUpToColumn;
@property (nonatomic) UIColor *progressBarColor;

@property (nonatomic) UIColor *verticalStripeGradientStartColor;
@property (nonatomic) UIColor *verticalStripeGradientFinishColor;
@property (nonatomic) UIColor *horizontalLabelBackgroundColor;
@property (nonatomic) UIColor *horizontalLabelTextColor;
@property (nonatomic) UIColor *barColor;
@property (nonatomic) UIColor *secondaryBarColor;
@property (nonatomic) UIColor *minimumAndMaximumLabelTextColor;
@property (nonatomic) UIColor *sectionTitleTextColor;

@property (nonatomic) UIFont *minimumAndMaximumLabelFont;
@property (nonatomic) UIFont *horizontalLabelFont;
@property (nonatomic) UIFont *sectionTitleFont;

// to make minimum and maximum value labels sticky, owner needs to set the scrollView property and also make sure this scroll view delegate method gets called
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end

@protocol BarChartViewDataSource <NSObject>

- (CGFloat)minimumValueInBarChartView:(BarChartView *)barChartView;
- (CGFloat)maximumValueInBarChartView:(BarChartView *)barChartView;
- (NSString *)minimumValueFormattedInBarChartView:(BarChartView *)barChartView;
- (NSString *)maximumValueFormattedInBarChartView:(BarChartView *)barChartView;

- (NSUInteger)numberOfSectionsInBarChartView:(BarChartView *)barChartView;
- (NSUInteger)barChartView:(BarChartView *)barChartView numberOfColumnsInSection:(NSUInteger)section;
- (NSString *)barChartView:(BarChartView *)barChartView titleForSection:(NSUInteger)section;

- (BOOL)barChartView:(BarChartView *)barChartView hasValueAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)barChartView:(BarChartView *)barChartView valueAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)barChartView:(BarChartView *)barChartView textAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)barChartView:(BarChartView *)barChartView hasSecondaryValueAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)barChartView:(BarChartView *)barChartView secondaryValueAtIndexPath:(NSIndexPath *)indexPath;

@end
