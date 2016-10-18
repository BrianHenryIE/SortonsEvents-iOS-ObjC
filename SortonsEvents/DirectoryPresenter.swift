//
//  DirectoryPresenter.swift
//  SortonsEvents
//
//  Created by Brian Henry on 16/10/2016.
//  Copyright © 2016 Sortons. All rights reserved.
//

import UIKit

class DirectoryPresenter: DirectoryInteractorOutput {

    var output: DirectoryPresenterOutput?
    
    init(output: DirectoryPresenterOutput) {
        self.output = output
    }
    
    func presentFetchedDirectory(directory: Directory_FetchDirectory_Response) {
        
        let viewModelDirectory = directory.directory.map({
            DirectoryTableViewCellModel(name: $0.name, details: $0.friendlyLocationString, imageUrl: URL(string: "https://graph.facebook.com/\($0.pageId!)/picture?type=square")!)
        })
        
        let viewModel = DirectoryViewModel(directory: viewModelDirectory)
        
        output?.presentFetchedDirectory(viewModel: viewModel)
    }
}