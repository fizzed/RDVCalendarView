//
//  RDVCalendarMonthPickerView.h
//  RDVCalendarView
//
//  Created by Douglas Drouillard on 1/6/15.
//  Copyright (c) 2015 Douglas Drouillard All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RDVCalendarYearPickerView.h"

@class RDVCalendarMonthPickerView;

#pragma mark - Managing the Delegate

@protocol RDVCalendarMonthPickerViewDelegate <NSObject>
@optional

/**
 * Tells the delegate that the specified month is now selected.
 */
- (void)monthPickerView:(RDVCalendarMonthPickerView *)monthPickerView didSelectMonth:(NSDateComponents *)month;

@end

@interface RDVCalendarMonthPickerView : UIView<RDVCalendarYearPickerViewDelegate>
/**
 * The object that acts as the delegate of the receiving month Picker View.
 */
@property (nonatomic, weak) id <RDVCalendarMonthPickerViewDelegate> delegate;

/**
 * Returns the view used to pick a new year for the displayed month. (read-only)
 */
@property (nonatomic, readonly) RDVCalendarYearPickerView* yearPickerView;

/**
 * The Title for range of months displayed
 */
@property UIButton *title;

/**
 * Returns the back (previous month) button. (read-only)
 */
@property (nonatomic, readonly) UIButton *backButton;

/**
 * Returns the forward (next month) button. (read-only)
 */
@property (nonatomic, readonly) UIButton *forwardButton;

/**
 * Returs the color of the current month picker cell.
 */
@property (nonatomic) UIColor *currentMonthColor;

/**
 * Returs the color of normal month picker cell.
 */
@property (nonatomic) UIColor *normalMonthColor;

/**
 * Returs the color of the selected month picker cell.
 */
@property (nonatomic) UIColor *selectedMonthColor;

/**
 * The initial month.
 */
@property (nonatomic) NSDateComponents *currentMonth;

/**
 * The current month being shown.
 */
@property (nonatomic) NSDateComponents *displayedMonth;

/**
 * Returns the currently selected month.
 */
@property (nonatomic) NSDateComponents *selectedMonth;

/**
 * Sets the selected month picker cell.
 */
-(void) setCurrentMonth:(NSDateComponents *)month;


@end
