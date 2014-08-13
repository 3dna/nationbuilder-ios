//
//  NBPersonCellView.m
//  NBClientExample
//
//  Created by Peng Wang on 7/23/14.
//  Copyright (c) 2014 NationBuilder. All rights reserved.
//

#import "NBPersonCellView.h"

#import "NBPersonDataSource.h"

static NSString *LabelViewKey = @"view";
static NSString *LabelOriginalColorKey = @"originalColor";

static NSString *NeedsDeleteKeyPath;
static void *observationContext = &observationContext;

@interface NBPersonCellView ()

@property (nonatomic, weak, readwrite) IBOutlet UIView *bottomBorderView;

@property (nonatomic, weak) IBOutlet UISwitch *deleteSwitch;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *tagsLabel;

@property (nonatomic, strong) NSArray *borderViews;
@property (nonatomic, strong) NSArray *labeledViews;

- (IBAction)toggleNeedsDelete:(id)sender;

@end

@implementation NBPersonCellView

@synthesize dataSource = _dataSource;

- (void)awakeFromNib
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NeedsDeleteKeyPath = NSStringFromSelector(@selector(needsDelete));
    });
    [super awakeFromNib];
    self.bottomBorderView.backgroundColor = self.borderColor;
    self.deleteSwitch.alpha = self.deleteSwitchDimmedAlpha.floatValue;
    self.deleteSwitch.tintColor = self.borderColor;
    if (!self.selectedBackgroundColor) {
        self.selectedBackgroundColor = self.tintColor;
    }
    self.selectedBackgroundView = [[UIView alloc] init];
}

- (void)prepareForReuse
{
    self.dataSource = nil;
    self.deleteSwitch.alpha = self.deleteSwitchDimmedAlpha.floatValue;
}

- (void)setHighlighted:(BOOL)highlighted
{
    super.highlighted = highlighted;
    self.selectedBackgroundView.backgroundColor = self.highlightedBackgroundColor;
    if (!self.areBordersDisabled) {
        for (UIView *view in self.borderViews) {
            view.hidden = highlighted;
        }
    }
    [self.delegate collectionViewCell:self didSetHighlighted:highlighted];
}

- (void)setSelected:(BOOL)selected
{
    super.selected = selected;
    self.selectedBackgroundView.backgroundColor = self.selectedBackgroundColor;
    if (!self.areBordersDisabled) {
        for (UIView *view in self.borderViews) {
            view.hidden = selected;
        }
    }
    for (NSDictionary *view in self.labeledViews) {
        UIColor *color = selected ? self.selectedForegroundColor : view[LabelOriginalColorKey];
        [view[LabelViewKey] setTextColor:color];
    }
    // Additional.
    self.deleteSwitch.hidden = selected;
    // END: Additional.
    [self.delegate collectionViewCell:self didSetSelected:selected];
}

#pragma mark - NBViewCell

- (void)refreshWithData:(NSDictionary *)data
{
    if (data) {
        self.deleteSwitch.hidden = NO;
        self.nameLabel.text = data[@"full_name"];
        self.tagsLabel.text = [data[@"tags"] componentsJoinedByString:
                               [NSString stringWithFormat:@" %@ ", self.tagDelimiterString]];
    } else {
        self.nameLabel.text =
        self.tagsLabel.text = nil;
        self.deleteSwitch.hidden = YES;
    }
}

- (void)setDataSource:(id<NBDataSource>)dataSource
{
    if (self.dataSource) {
        [(id)self.dataSource removeObserver:self forKeyPath:NeedsDeleteKeyPath context:&observationContext];
    }
    // Boilerplate.
    static NSString *key;
    key = key ?: NSStringFromSelector(@selector(dataSource));
    [self willChangeValueForKey:key];
    _dataSource = dataSource;
    [self didChangeValueForKey:key];
    // END: Boilerplate.
    if (self.dataSource) {
        NSAssert([self.dataSource isKindOfClass:[NBPersonDataSource class]], @"Data source must be of certain type.");
        NBPersonDataSource *dataSource = self.dataSource;
        self.deleteSwitch.on = dataSource.needsDelete;
        [self refreshWithData:dataSource.person];
        [(id)self.dataSource addObserver:self forKeyPath:NeedsDeleteKeyPath options:0 context:&observationContext];
    } else {
        [self refreshWithData:nil];
    }
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &observationContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if ([keyPath isEqual:NeedsDeleteKeyPath]) {
        NBPersonDataSource *dataSource = self.dataSource;
        [self.deleteSwitch setOn:dataSource.needsDelete animated:YES];
    }
}

#pragma mark - Public

- (void)setBorderColor:(UIColor *)borderColor
{
    static NSString *key;
    key = key ?: NSStringFromSelector(@selector(borderColor));
    [self willChangeValueForKey:key];
    _borderColor = borderColor;
    [self didChangeValueForKey:key];
    // Bind.
    self.bottomBorderView.backgroundColor = borderColor;
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    static NSString *key;
    key = key ?: NSStringFromSelector(@selector(selectedBackgroundColor));
    [self willChangeValueForKey:key];
    _selectedBackgroundColor = selectedBackgroundColor;
    [self didChangeValueForKey:key];
    // Bind.
    self.selectedBackgroundView.backgroundColor = selectedBackgroundColor;
}

- (void)setBordersDisabled:(BOOL)bordersDisabled
{
    static NSString *key;
    key = key ?: NSStringFromSelector(@selector(areBordersDisabled));
    [self willChangeValueForKey:key];
    _bordersDisabled = bordersDisabled;
    [self didChangeValueForKey:key];
    // Bind.
    for (UIView *view in self.borderViews) {
        view.hidden = self.bordersDisabled;
    }
}

#pragma mark - Private

- (NSArray *)borderViews
{
    if (_borderViews) {
        return _borderViews;
    }
    self.borderViews = @[ self.bottomBorderView ];
    return _borderViews;
}

- (NSArray *)labeledViews
{
    if (_labeledViews) {
        return _labeledViews;
    }
    NSMutableArray *views = [NSMutableArray array];
    for (id view in @[ self.nameLabel, self.tagsLabel ]) {
        [views addObject:@{ LabelViewKey: view,
                            LabelOriginalColorKey: [view textColor] }];
    }
    self.labeledViews = views;
    return _labeledViews;
}

#pragma mark Delete

- (IBAction)toggleNeedsDelete:(id)sender
{
    if (sender == self.deleteSwitch) {
        NBPersonDataSource *dataSource = self.dataSource;
        BOOL needsDelete = self.deleteSwitch.on;
        dataSource.needsDelete = needsDelete;
        [self.delegate collectionViewCell:self didSetNeedsDelete:needsDelete];
        // Update appearance.
        self.highlighted = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.highlighted = NO;
        });
        [UIView animateWithDuration:0.3f animations:^{
            self.deleteSwitch.alpha = needsDelete ?  1.0f : self.deleteSwitchDimmedAlpha.floatValue;
        }];
    }
}

@end
