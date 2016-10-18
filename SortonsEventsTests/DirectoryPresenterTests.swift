//
//  DirectoryPresenterTests.swift
//  SortonsEvents
//
//  Created by Brian Henry on 16/10/2016.
//  Copyright © 2016 Sortons. All rights reserved.
//

import XCTest
@testable import SortonsEvents
import ObjectMapper

class ViewControllerSpy: DirectoryPresenterOutput {
    
    var viewModel: DirectoryViewModel?
    var presentFetchedDirectoryCalled = false
    
    func presentFetchedDirectory(viewModel: DirectoryViewModel) {
        presentFetchedDirectoryCalled = true
        self.viewModel = viewModel
    }
    
    func displayFetchDirectoryFetchError(viewModel: DirectoryViewModel) {
        // TODO
    }
}


class DirectoryPresenterTests: XCTestCase {
    
    var spy = ViewControllerSpy()
    var sut: DirectoryInteractorOutput!
    
    override func setUp() {
        super.setUp()
        
        sut = DirectoryPresenter(output: spy)
    }
    
    func testPresentFetchedDirectory() {
        
        // Get some test data
        let bundle = Bundle(for: self.classForCoder)
        let path = bundle.path(forResource: "ClientPageDataUcdEvents", ofType: "json")!
        var content = "{}"
        do {
            content = try String(contentsOfFile: path)
        } catch {
        }
        let ucdEvents: ClientPageData = Mapper<ClientPageData>().map(JSONString: content)!
        
        sut.presentFetchedDirectory(directory: Directory_FetchDirectory_Response(directory: ucdEvents.includedPages))
        
        XCTAssert(spy.presentFetchedDirectoryCalled, "Presenter did not pass anything to view")
        
        XCTAssertEqual(307, spy.viewModel?.directory.count, "Error building viewmodel in presenter")
    }

//    func testDisplayFetchDirectoryFetchError() {
//        
//        let viewModel: DirectoryViewModel
//        
//        sut.displayFetchDirectoryFetchError(viewModel)
//    }
    
}