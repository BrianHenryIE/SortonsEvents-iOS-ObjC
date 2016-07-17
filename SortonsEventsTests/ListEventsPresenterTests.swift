//
//  ListEventsPresenterTests.swift
//  SortonsEvents
//
//  Created by Brian Henry on 16/07/2016.
//  Copyright © 2016 Sortons. All rights reserved.
//

import XCTest
import ObjectMapper

class ListEventsPresenterOutputSpy : ListEventsPresenterOutput {
    
    var displaySomethingCalled = false
    
    func displaySomething(viewModel: ListEventsViewModel) {
        displaySomethingCalled = true
    }
}

class ListEventsPresenterTests: XCTestCase {
    
    var events : [DiscoveredEvent]!
    
    let sut = ListEventsPresenter()
    
    override func setUp() {
        super.setUp()
       
        // Read in the file
        let bundle = NSBundle(forClass: self.classForCoder)
        let path = bundle.pathForResource("DiscoveredEventsResponseNUIG30June16", ofType: "json")!
        
        do {
            let content = try String(contentsOfFile: path)
            let nuigJun16 : DiscoveredEventsResponse = Mapper<DiscoveredEventsResponse>().map(content)!
            events = nuigJun16.data
        } catch {
            // stop the tests!
        }
    }
    
    func testShouldDiscardEarlyEvents() {
        var remainingEvents : [DiscoveredEvent]
        var ourTime : NSDate
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = NSDateComponents()
        dateComponents.timeZone = NSTimeZone(abbreviation: "UTC") // prob doesn't matter
        
        // Test data: 9 total
        
        // 8-endTime: 2016-07-23T20:00:00.000Z
        // 9-startTime: 2016-09-24T09:00:00.000Z
        
        dateComponents.year = 2016
        dateComponents.month = 08
        dateComponents.day = 15
        
        ourTime = calendar.dateFromComponents(dateComponents)!
        remainingEvents = sut.filterToOngoingEvents(events, from: ourTime)
        
        XCTAssertEqual(remainingEvents.count, 1, "the wrong number of events were filtered out")
    
        // Events with end times are obvious
        dateComponents.month = 07
        dateComponents.day = 23
        dateComponents.hour = 19
        dateComponents.minute = 00
        
        ourTime = calendar.dateFromComponents(dateComponents)!
        remainingEvents = sut.filterToOngoingEvents(events, from: ourTime)
        
        XCTAssertEqual(remainingEvents.count, 2, "Was the ongoing event properly included?")
 
        dateComponents.hour = 21
        
        ourTime = calendar.dateFromComponents(dateComponents)!
        remainingEvents = sut.filterToOngoingEvents(events, from: ourTime)
        
        XCTAssertEqual(remainingEvents.count, 1, "The event that ended earlier this day should not be counted")
        
        // If the event has no end time but started before 6pm, we assume it to be over at midnight
        // 3rd last event has no end time:
        // "startTime": "2016-07-11T09:00:00.000Z",
        dateComponents.day = 11
        dateComponents.hour = 23
        
        ourTime = calendar.dateFromComponents(dateComponents)!
        remainingEvents = sut.filterToOngoingEvents(events, from: ourTime)
        
        XCTAssertEqual(remainingEvents.count, 3, "Event starting today with no end time should be included")
        
        dateComponents.day = 12
        dateComponents.hour = 02
        
        ourTime = calendar.dateFromComponents(dateComponents)!
        remainingEvents = sut.filterToOngoingEvents(events, from: ourTime)
        
        XCTAssertEqual(remainingEvents.count, 2, "Event starting yesteday before 6pm with no end time should not be included")
        
        // If the event has no end time but started after 6pm, we don't remove it until 6am
        // The choice of nighttime cutoff is arbirtary
        // "startTime": "2016-07-23T19:00:00.000Z",
        dateComponents.day = 24
        dateComponents.hour = 02
        
        ourTime = calendar.dateFromComponents(dateComponents)!
        remainingEvents = sut.filterToOngoingEvents(events, from: ourTime)
        
        XCTAssertEqual(remainingEvents.count, 2, "Event starting yesteday after 6pm with no end time should be included until 6am following")

        dateComponents.hour = 07
        
        ourTime = calendar.dateFromComponents(dateComponents)!
        remainingEvents = sut.filterToOngoingEvents(events, from: ourTime)
        
        XCTAssertEqual(remainingEvents.count, 2, "Event starting yesteday after 6pm with no end time should not be included after 6am following")
        
        // Events without end times who start after the test time are just part of the first test
        
        // All day:
        // "startTime": "2016-06-30T00:00:00.000Z",
        // "dateOnly": true,
        dateComponents.month = 06
        dateComponents.day = 30
        dateComponents.hour = 19
        dateComponents.minute = 00
        
        ourTime = calendar.dateFromComponents(dateComponents)!
        remainingEvents = sut.filterToOngoingEvents(events, from: ourTime)
        
        XCTAssertEqual(remainingEvents.count, 9, "All day events starting today should be included")
        
        dateComponents.month = 07
        dateComponents.day = 01

        ourTime = calendar.dateFromComponents(dateComponents)!
        remainingEvents = sut.filterToOngoingEvents(events, from: ourTime)
        
        XCTAssertEqual(remainingEvents.count, 8, "All day events starting yesterday should not be included")
    }
    
    
    func testFormatFriendlyTime() {
        
        // Testing times: 2016-06-30T20:00:00.000Z
        let displayDate = events[1].startTime
        
        var ourTime : NSDate
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = NSDateComponents()
        
        //  what about timezones? (we'll see once we get to California!)
        dateComponents.timeZone = NSTimeZone(abbreviation: "UTC")
        
        // 1. A normal "not close" date format
        var expected = "Thursday 30 June at 8pm"
        var formatted = sut.formatFriendlyTime(displayDate, allDay : false)
        
        XCTAssertEqual(expected, formatted, "Most basic formatted time is wrong!")
        
        // as all day event
        expected = "Thursday 30 June"
        formatted = sut.formatFriendlyTime(displayDate, allDay : true)
        
        XCTAssertEqual(expected, formatted, "Most basic all-day formatted time is wrong!")
        
        // 2. What about xxx 05 June... should it have the 0 or not? (aesthetically)
        
        // 3. Pretend it's 29 June and the event is tomorrow!
        dateComponents.year = 2016
        dateComponents.month = 06
        dateComponents.day = 29
        
        ourTime = calendar.dateFromComponents(dateComponents)!
        
        expected = "Tomorrow at 8pm"
        formatted = sut.formatFriendlyTime(displayDate, allDay : false, from: ourTime)
        
        XCTAssertEqual(expected, formatted, "Tomorrow's formatted time is wrong!")
        
        // as all day event
        expected = "Tomorrow"
        formatted = sut.formatFriendlyTime(displayDate, allDay : true, from: ourTime)
        
        XCTAssertEqual(expected, formatted, "Tomorrow's all-day formatted time is wrong!")
        
        // 4. Pretend it's 30 June and the event is today
        dateComponents.month = 07
        dateComponents.day = 01
        
        ourTime = calendar.dateFromComponents(dateComponents)!
        
        expected = "Today at 8pm"
        formatted = sut.formatFriendlyTime(displayDate, allDay : false, from: ourTime)
        
        XCTAssertEqual(expected, formatted, "Today's formatted time is wrong!")
       
        // as all day event
        expected = "Today"
        formatted = sut.formatFriendlyTime(displayDate, allDay : true, from: ourTime)
        
        XCTAssertEqual(expected, formatted, "Today's all-day formatted time is wrong!")
        
        // 5. Pretend it's 1 July and the event was yesterday
        dateComponents.month = 07
        dateComponents.day = 01
        
        ourTime = calendar.dateFromComponents(dateComponents)!
        
        expected = "Yesterday at 8pm"
        formatted = sut.formatFriendlyTime(displayDate, allDay : false, from: ourTime)
        
        XCTAssertEqual(expected, formatted, "Yesterday's formatted time is wrong!")
        
        // as all day event (I'm not sure if this one is posisble!)
        expected = "Yesterday"
        formatted = sut.formatFriendlyTime(displayDate, allDay : true, from: ourTime)
        
        XCTAssertEqual(expected, formatted, "Yesterday's all-day formatted time is wrong!")
    }
}