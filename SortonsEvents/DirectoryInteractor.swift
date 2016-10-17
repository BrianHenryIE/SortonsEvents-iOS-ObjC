//
//  DirectoryInteractor.swift
//  SortonsEvents
//
//  Created by Brian Henry on 16/10/2016.
//  Copyright © 2016 Sortons. All rights reserved.
//

import UIKit
import ObjectMapper

class DirectoryInteractor: DirectoryViewControllerOutput {

    var directory = [SourcePage]()
    var displayedDirectory = [SourcePage]()
    var currentFilter = ""
    
    var fomoId: String
    var output: DirectoryInteractorOutput!
    
    var cacheWorker: DirectoryCacheWorkerProtocol!
    var networkWorker: DirectoryNetworkWorkerProtocol!
    
    init(fomoId: String, presenter: DirectoryInteractorOutput, cache: DirectoryCacheWorkerProtocol, network: DirectoryNetworkWorkerProtocol) {
        self.fomoId = fomoId
        output = presenter
        cacheWorker = cache
        networkWorker = network
    }
    
    func fetchDirectory(withRequest: Directory_FetchDirectory_Request) {
        
        if let cacheString = cacheWorker.fetch() {
            let directoryFromCache: ClientPageData = Mapper<ClientPageData>().map(JSONString: cacheString)!
            if let data = directoryFromCache.includedPages {
                directory = data
                self.outputDirectoryToPresenter()
            }
        }
        
        networkWorker.fetchDirectory(fomoId, completionHandler: {(networkString) -> Void in
            let directoryFromNetwork: ClientPageData = Mapper<ClientPageData>().map(JSONString: networkString)!
            if let data = directoryFromNetwork.includedPages {
                self.directory = data
                self.cacheWorker.save(networkString)
                self.outputDirectoryToPresenter()
            }
        })
    }

    func filterDirectoryTo(searchBarInput: String) {
        currentFilter = searchBarInput.lowercased()
        outputDirectoryToPresenter()
    }
    
    func outputDirectoryToPresenter() {
        // filter directory using currentfilter and save to displayedDirectory
        
        displayedDirectory = directory.filter({
            ($0.name.lowercased()).contains(currentFilter)
        })
        
        let response = Directory_FetchDirectory_Response(directory: displayedDirectory)
        self.output.presentFetchedDirectory(directory: response)
    }
    
    func displaySelectedPageFrom(rowNumber: Int) {
        
        let fbId = displayedDirectory[rowNumber].pageId
        
        let appUrl = URL(string: "fb://profile/\(fbId)")!
        let safariUrl = URL(string: "https://facebook.com/\(fbId)")!
        
        if UIApplication.shared.canOpenURL(appUrl) {
            UIApplication.shared.openURL(appUrl)
        } else {
            UIApplication.shared.openURL(safariUrl)
        }
    }
}
