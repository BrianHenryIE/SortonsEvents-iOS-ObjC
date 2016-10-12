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

class ListEventsTableViewController: UITableViewController, ListEventsPresenterOutput
{
    var output: ListEventsTableViewControllerOutput!
    var data : ListEventsViewModel?

    // MARK: Object lifecycle


    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchEventsOnLoad()
    }

    func fetchEventsOnLoad() {
        let request = ListEvents_FetchEvents_Request()
        output.fetchEvents(request)
    }

// MARK: Display logic ListEventsPresenterOutput

    func presentFetchedEvents(_ viewModel: ListEventsViewModel) {
        data = viewModel
        tableView.reloadData()
    }
}



// MARK: - Table view data source

extension ListEventsTableViewController
{

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (data?.discoveredEvents.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let event = data!.discoveredEvents[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoveredEventCell", for: indexPath) as! DiscoveredEventTableViewCell
        cell.setDiscoveredEvent(event)
        return cell
    }
}
 
