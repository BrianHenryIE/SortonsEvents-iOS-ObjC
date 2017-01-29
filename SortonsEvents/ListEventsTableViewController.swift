//
//  ListEventsTableViewController.swift
//  SortonsEvents
//
//  Created by Brian Henry on 04/07/2016.
//  Copyright (c) 2016 Sortons. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit

protocol ListEventsTableViewControllerOutputProtocol {
    func fetchEvents(_ request: ListEvents.Fetch.Request)

    func displayEvent(for rowNumber: Int)
}

class ListEventsTableViewController: UITableViewController, ListEventsPresenterOutputProtocol {
    var output: ListEventsTableViewControllerOutputProtocol?
    var data: ListEvents.ViewModel?

    // MARK: Object lifecycle

// MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Start content below (not beneath) the status bar
        let top = UIApplication.shared.statusBarFrame.size.height
        self.tableView.contentInset = UIEdgeInsets(top: top,
                                                  left: 0,
                                                bottom: 49,
                                                 right: 0)

        // Autosizing cell heights
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140

        fetchEventsOnLoad()
    }

    func fetchEventsOnLoad() {
        let request = ListEvents.Fetch.Request()
        output?.fetchEvents(request)
    }

// MARK: Display logic ListEventsPresenterOutput
    func presentFetchedEvents(_ viewModel: ListEvents.ViewModel) {
        data = viewModel
        tableView.reloadData()
    }

    func displayFetchEventsFetchError(_ viewModel: ListEvents.ViewModel) {

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let topVisibleRow = tableView.indexPathsForVisibleRows?[0]

        coordinator.animate(alongsideTransition: { context in

            let top = UIApplication.shared.statusBarFrame.size.height
            self.tableView.contentInset = UIEdgeInsets(top: top,
                                                       left: 0,
                                                       bottom: 49,
                                                       right: 0)

        }, completion: { _ in
            if let topVisibleRow = topVisibleRow {
                self.tableView.scrollToRow(at: topVisibleRow, at: .top, animated: true)
            }
        })
    }
}

// MARK: - Table view data source
extension ListEventsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return data?.discoveredEvents.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let event = data?.discoveredEvents[indexPath.row] else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoveredEventCell", for: indexPath)
            as? ListEventsTableViewCell

        cell?.setDiscoveredEvent(event)

        return cell ?? UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output?.displayEvent(for: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
