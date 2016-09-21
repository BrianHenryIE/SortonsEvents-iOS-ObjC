//
//  ListEventsWireframe.swift
//  SortonsEvents
//
//  Created by Brian Henry on 24/08/2016.
//  Copyright © 2016 Sortons. All rights reserved.
//

import UIKit
import Foundation

class ListEventsWireframe {

    let listEventsView : ListEventsTableViewController!
    
    init(fomoId : String) {
        
        let storyboard = UIStoryboard(name: "ListEvents", bundle: NSBundle.mainBundle())
        
        listEventsView = storyboard.instantiateViewControllerWithIdentifier("ListEventsStoryboard") as! ListEventsTableViewController
     
        let listEventsPresenter = ListEventsPresenter(output: listEventsView)

        let listEventsInteractor = ListEventsInteractor(fomoId: fomoId, output: listEventsPresenter, listEventsNetworkWorker: ListEventsNetworkWorker(), listEventsCacheWorker: ListEventsCacheWorker())
        
        listEventsView.output = listEventsInteractor
    
        
    }

}