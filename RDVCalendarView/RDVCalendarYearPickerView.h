//
//  RDVCalendarYearPickerView.h
//  RDVCalendar
//
// Copyright (c) 2014 Douglas Drouillard
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import "RDVCalendarYearPickerCell.h"

/**
 * 'RDVCalendarYearPickerView' allows for easily selecting the year to use when displaying a Calendar.
 * It is designed to be a complement to the existing 'RDVCalendarView' by allowing to quickly
 * select the year of the month that is currently being shown. 
 * 
 * 'RDVCalendarYearPickerView' works by displaying a range of selectable years that are created around
 * an 'anchor' year. Once the range has been created, the user can then 'select' a year, or
 * can page between ranges of years using the prev/next buttons or by swiping left/right.
 *
 * anchor year - The year the range of displayed years is created around. Updated by user through
 * forward/back buttons or swiping.
 *
 * selected year - The year the user wishes to use in the associated calendar's month view. Updated by
 * user tapping on a year cell.
*/

@class RDVCalendarYearPickerView;

#pragma mark - Managing the Delegate

@protocol RDVCalendarYearPickerViewDelegate <NSObject>
@optional

/**
 * Tells the delegate that the specified year is now selected.
 */
- (void)yearPickerView:(RDVCalendarYearPickerView *)yearPickerView didSelectYear:(NSInteger)year;

@end

@interface RDVCalendarYearPickerView : UIView

/**
 * The object that acts as the delegate of the receiving Year Picker View.
 */
@property (nonatomic, weak) id <RDVCalendarYearPickerViewDelegate> delegate;

/**
 * Returns the back (previous month) button. (read-only)
 */
@property (nonatomic, readonly) UIButton *backButton;

/**
 * Returns the forward (next month) button. (read-only)
 */
@property (nonatomic, readonly) UIButton *forwardButton;

/**
 * The current year the range of years shown is being anchored around.
 */
@property NSInteger currentAnchorYear;

/**
 * Returns the currently selected year.
 */
@property NSInteger selectedYear;

/**
 * Returs the color of the current year picker cell.
 */
@property (nonatomic) UIColor *currentYearColor;

/**
 * Returs the color of normal year picker cell.
 */
@property (nonatomic) UIColor *normalYearColor;

/**
 * Returs the color of the selected year picker cell.
 */
@property (nonatomic) UIColor *selectedYearColor;

/**
 * The Title for range of years displayed
 */
@property UILabel *title;

/**
 * Sets the year which to anchor the year range around.
 */
-(void) setAnchorYear:(NSInteger)year;

/**
 * Returs the color of the selected year picker cell.
 */
-(void) setSelectedYear:(NSInteger)year;

@end
