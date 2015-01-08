//
//  RDVCalendarYearPickerView.m
//  RDVCalendar
//
// Copyright (c) 2015 Douglas Drouillard
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

#import "RDVCalendarMonthPickerView.h"
#import "RDVCalendarPickerCell.h"

@interface RDVCalendarMonthPickerView (){
    NSMutableArray* _visibleCells;
    
    BOOL _showingYearPicker;
}

@end


@implementation RDVCalendarMonthPickerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _visibleCells = [[NSMutableArray alloc] initWithCapacity:12];
        
        _title = [[UIButton alloc] init];
        [_title setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_title.titleLabel setFont:[UIFont systemFontOfSize:22]];
        [_title.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_title addTarget:self action:@selector(showYearPicker)
              forControlEvents:UIControlEventTouchUpInside];
        
//        _title = [[UILabel alloc]initWithFrame:CGRectMake(0,0, self.bounds.size.width, 150)];
//        _title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_title];
        
        _backButton = [[UIButton alloc] init];
        [_backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_backButton setTitle:@"Prev" forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(showPreviousYear)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        _forwardButton = [[UIButton alloc] init];
        [_forwardButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_forwardButton setTitle:@"Next" forState:UIControlStateNormal];
        [_forwardButton addTarget:self action:@selector(showNextYear)
                 forControlEvents:UIControlEventTouchUpInside];
       [self addSubview:_forwardButton];
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self configureSwipeEvents];
    }
    
    return self;
}


- (void)layoutSubviews
{
    if(_showingYearPicker){
        return;
    }
    
    CGSize viewSize = self.frame.size;
    CGSize headerSize = CGSizeMake(viewSize.width, 60.0f);
    CGFloat backButtonWidth = MAX([[self backButton] sizeThatFits:CGSizeMake(100, 50)].width, 44);
    CGFloat forwardButtonWidth = MAX([[self forwardButton] sizeThatFits:CGSizeMake(100, 50)].width, 44);
    
    CGSize previousMonthButtonSize = CGSizeMake(backButtonWidth, 50);
    CGSize nextMonthButtonSize = CGSizeMake(forwardButtonWidth, 50);
    CGSize titleSize = CGSizeMake(viewSize.width - previousMonthButtonSize.width - nextMonthButtonSize.width - 10 - 10,
                                  50);
    
    // Layout header view
    [[self backButton] setFrame:CGRectMake(10, roundf(headerSize.height / 2 - previousMonthButtonSize.height / 2),
                                           previousMonthButtonSize.width, previousMonthButtonSize.height)];
    
    [[self title] setFrame:CGRectMake(roundf(headerSize.width / 2 - titleSize.width / 2),
                                      roundf(headerSize.height / 2 - titleSize.height / 2),
                                      titleSize.width, titleSize.height)];
    
    [[self forwardButton] setFrame:CGRectMake(headerSize.width - 10 - nextMonthButtonSize.width,
                                              roundf(headerSize.height / 2 - nextMonthButtonSize.height / 2),
                                              nextMonthButtonSize.width, nextMonthButtonSize.height)];
    
    CGFloat monthCellWidth = 0;
    monthCellWidth = roundf(viewSize.width / 4);
    
    CGFloat yearRangeHeaderEndY = CGRectGetMaxY([[self title] frame]);
    CGFloat monthCellHeight = 0;
    
    if (viewSize.width > viewSize.height) {
        monthCellHeight = roundf((viewSize.height - yearRangeHeaderEndY) / 3);
    }
    else {
        monthCellHeight = roundf((viewSize.height - yearRangeHeaderEndY) / 4);
    }
    
    //clear existing year cells
    for (RDVCalendarPickerCell* visibleCell in _visibleCells) {
        [visibleCell removeFromSuperview];
    }
    
    [_visibleCells removeAllObjects];
    
    int row = 0;
    int column = 0;
    
    //Set up month cells in grid format
    for (NSInteger month = 1; month <= 12; month++ ){
        
        CGRect monthCellFrame = CGRectMake(column * monthCellWidth, yearRangeHeaderEndY + row * monthCellHeight, monthCellWidth, monthCellHeight);
        RDVCalendarPickerCell* monthCell = [[RDVCalendarPickerCell alloc] initWithFrame:monthCellFrame];

        [monthCell setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        [monthCell setTitleColor:[UIColor whiteColor] forState: UIControlStateSelected];
        [monthCell setTitleColor:[UIColor whiteColor] forState: UIControlStateHighlighted];
        [monthCell setBackgroundImage:[RDVCalendarPickerCell imageFromColor:_normalMonthColor] forState: UIControlStateNormal];
        
        [monthCell setBackgroundImage:[RDVCalendarPickerCell imageFromColor:_selectedMonthColor] forState: UIControlStateSelected ];
        
        [monthCell setBackgroundImage:[RDVCalendarPickerCell imageFromColor:_selectedMonthColor] forState: UIControlStateHighlighted];
        [monthCell addTarget:self action:@selector(selectedMonth:) forControlEvents:UIControlEventTouchUpInside];

        [_visibleCells addObject:monthCell];
        
        [self addSubview:monthCell];
        
        //Reset to beginning of next row
        if (column == 3) {
            column = 0;
            
            row++;
        } else {
            column++;
        }
    }
    
    [self reloadData];
}

- (NSCalendar *)calendar
{
    static NSCalendar *calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    return calendar;
}

- (void) setDisplayedMonth:(NSDateComponents *)month
{
    _displayedMonth = [month copy];
    [self setDisplayedYearTitle:month];
}


- (void) setCurrentMonth:(NSDateComponents *)month
{
    _currentMonth = month;
    [self setDisplayedMonth:month];
}

- (void) reloadData
{

    //Our visible cells are stored in a 0-based array
    //Where as months start at 1 -> Jan
    NSInteger indexOfCell = 0;
    NSCalendar *calendar = [self calendar];
    int displayedYear = (int)[self.displayedMonth year];
    
    for (NSInteger month = 1; month <= 12; month++ ){
        RDVCalendarPickerCell* monthCell = _visibleCells[indexOfCell];
        [monthCell reset];
        [monthCell setBackgroundImage:[RDVCalendarPickerCell imageFromColor:_normalMonthColor] forState: UIControlStateNormal];
        
        NSDateComponents *dateComponent = [NSDateComponents alloc];
        [dateComponent setCalendar:calendar];
        [dateComponent setYear:displayedYear];
        [dateComponent setMonth:month];
        
        monthCell.dateComponents = dateComponent;
        
        NSString *labelText = [monthCell getDisplayMonth];
        
        [monthCell setTitle:labelText forState:UIControlStateNormal];
        
        //if selected
        if(month == [_selectedMonth month] && displayedYear == [_selectedMonth year]){
            [monthCell setSelected:YES];
        }
        
        //if the initial month set
        if(month == [_currentMonth month] && displayedYear == [_currentMonth year]){
            [monthCell setBackgroundImage:[RDVCalendarPickerCell imageFromColor:_currentMonthColor] forState: UIControlStateNormal];
        }
        
        indexOfCell++;
    }
    
}


- (void) setDisplayedYearTitle:(NSDateComponents *)month
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy";
    
    NSDate *date = [month.calendar dateFromComponents:month];
    NSString* yearTitle = [[NSString alloc] initWithString:[formatter stringFromDate:date]];
    
    [self.title setTitle:yearTitle forState:UIControlStateNormal];
}


- (void) setDisplayedYear:(NSInteger)year
{
    [self.displayedMonth setYear:year];
    [self setDisplayedYearTitle:self.displayedMonth];
}

- (void) showNextYear
{
    NSInteger year = [[self displayedMonth] year] + 1;
    [self setDisplayedYear:year];
    [self reloadData];
}

- (void) showPreviousYear
{
    NSInteger year = [[self displayedMonth] year] - 1;
    [self setDisplayedYear:year];
    [self reloadData];
}


-(void) configureSwipeEvents
{
    // support for swiping forward/back year ranges
    UISwipeGestureRecognizer* swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    
    UISwipeGestureRecognizer* swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGestureRecognizer];
    
}

- (void)swipeLeft:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [self showNextYear];
    }];
}

- (void)swipeRight:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [self showPreviousYear];
    }];
}

- (void) selectedMonth:(id)sender
{
    RDVCalendarPickerCell* selectedCell = (RDVCalendarPickerCell*) sender;
    NSDateComponents* monthSelected = selectedCell.dateComponents;
    
    [_visibleCells makeObjectsPerformSelector:@selector(reset)];
    
    [selectedCell setSelected:YES];
    [self setSelectedMonth:monthSelected];
    
    if ([self.delegate respondsToSelector:@selector(monthPickerView:didSelectMonth:)]) {
        [self.delegate monthPickerView:self didSelectMonth:monthSelected];
    }
}

#pragma mark - Navigation

- (void)showYearPicker{
    CGRect yearPickerFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    _yearPickerView = [[RDVCalendarYearPickerView  alloc] initWithFrame:yearPickerFrame];
    
    [_yearPickerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_yearPickerView  setBackgroundColor:[UIColor whiteColor]];
    [_yearPickerView  setDelegate:self];
    [_yearPickerView setAnchorYear:[self.displayedMonth year] ];
    [_yearPickerView setSelectedYear:[self.displayedMonth year]];
    
    _yearPickerView.currentYearColor = _currentMonthColor;
    _yearPickerView.selectedYearColor = _selectedMonthColor;
    _yearPickerView.normalYearColor = _normalMonthColor;
    
    [_yearPickerView.backButton setTitleColor:[self.backButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    _yearPickerView.backButton.titleLabel.font = self.backButton.titleLabel.font;
    
    [_yearPickerView.forwardButton setTitleColor:[self.forwardButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    _yearPickerView.forwardButton.titleLabel.font = self.forwardButton.titleLabel.font;
    
    _yearPickerView.title.font = self.title.font;
    
    _showingYearPicker = true;
    [self addSubview: _yearPickerView];
}

- (void)yearPickerView:(RDVCalendarYearPickerView *)yearPickerView didSelectYear:(NSInteger)year
{
    _showingYearPicker = false;
    
    [self setDisplayedYear:year];
    
    [_yearPickerView removeFromSuperview];
    
}



@end