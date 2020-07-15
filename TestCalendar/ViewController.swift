//
//  ViewController.swift
//  TestCalendar
//
//  Created by Mustafa Khalil on 7/13/20.
//

import UIKit
import HorizonCalendar

// MARK: - structs

struct Event {
    var event1: Bool
    var event2: Bool
}

// MARK: - MOCK presenter

class Presenter {
    
    weak var controller: ViewController?
    
    init(controller: ViewController) {
        self.controller = controller
    }
    
    func fetch() {
        // simulate network requests
        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 40000)) { [weak self] in
            // returns a fake events object
            let events = [
                "2020-07-16": Event(event1: true, event2: false),
                "2020-07-13": Event(event1: false, event2: true),
                "2020-07-17": Event(event1: true, event2: false),
                "2020-07-29": Event(event1: true, event2: true),
                "2020-07-30": Event(event1: false, event2: false),
            ]
            DispatchQueue.main.async {
                self?.controller?.setEvents(events: events)
            }
        }
    }
}

// MARK: - MOCK ViewController

class ViewController: UIViewController {
    
    fileprivate var isSelectRange = false
    fileprivate var isEnabled = true
    
    let today = Date()
    let calendar = Calendar(identifier: .gregorian)
    var selectedDates: Set<Date> = Set()
    
    var events: [String: Any] = [:]
    
    lazy var calendarView = CalendarView(initialContent: makeContent())
    
    var presenter: Presenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // layout
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
        
        calendarView.daySelectionHandler = { [weak self] day in
            guard let self = self else { return }
            self.prepareDaySelection(day: day)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.fetch()
    }
    
    func setEvents(events: [String: Any]) {
        // makes sure we are on the main thread
        dispatchPrecondition(condition: .onQueue(.main))
        
        // makes sure we are on the main thread
        self.events = events
        
        // refresh the view with the new events
        let newContent = makeContent()
        calendarView.setContent(newContent)
    }
    
    func prepareDaySelection(day: Day) {
        let currentDay = calendar.date(from: day.components)!
        if selectedDates.contains(currentDay) {
            selectedDates.remove(currentDay)
        } else {
            selectedDates.insert(currentDay)
        }
        
        let newContent = makeContent()
        calendarView.setContent(newContent)
    }
    
    func changeRange(isEnabled: Bool) {
        isSelectRange = isEnabled
    }
    
    func getSelectedDates() -> [Date] {
        return selectedDates.map { $0 }
    }
    
    func makeContent() -> CalendarViewContent {
        
        let startDate = today
        let endDate = calendar.date(from: DateComponents(year: 2022, month: 12, day: 31))!
        
        return CalendarViewContent(calendar: calendar,
                                   visibleDateRange: startDate...endDate,
                                   monthsLayout: .horizontal(monthWidth: min(view.frame.height, view.frame.width) - 40))
            .withDayItemProvider { day -> CalendarItem<EventLabel, Day> in
                let date = self.calendar.date(from: day.components)!
                let isToday = self.calendar.isDateInToday(date)
                let isSelectedDay = self.selectedDates.contains(date)
                return CalendarItem<EventLabel, Day>(
                    viewModel: day,
                    styleID: isSelectedDay ? "SelectedDayLabelStyle" : "DayLabelStyle",
                    buildView: {
                        return EventLabel()
                    },
                    updateViewModel: { label, day in
                        
                        label.text = "\(day.day)"
                        label.hasNoEvents()
                        
                        if self.today > date {
                            label.textColor = .lightGray
                        } else {
                            label.textColor = isSelectedDay ? .white : .darkGray
                        }
                        
                        if isSelectedDay {
                            label.backgroundColor = .purple
                        } else {
                            label.backgroundColor = isToday ? .blue : .clear
                        }
                        
                        // this code is just here! shouldnt affect the app
                        guard let object = self.events[day.description] as? Event else {
                            return
                        }
                        
                        if object.event1 {
                            label.hasEvent1()
                            label.textColor = .lightGray
                            return
                        }
                        
                        if object.event2 {
                            label.hasEvent2()
                            return
                        }
                    })
            }
            .withInterMonthSpacing(16)
            .withVerticalDayMargin(8)
            .withHorizontalDayMargin(8)
    }
}
