//
//  ClientPageDataTest.swift
//  SortonsEvents
//
//  Created by Brian Henry on 30/06/2016.
//  Copyright © 2016 Sortons. All rights reserved.
//

import XCTest
@testable import SortonsEvents
import ObjectMapper

class ClientPageDataTest: XCTestCase {

    func testClientPageDataParsing() throws {

        // Read in the file
        let bundle = Bundle(for: self.classForCoder)
        let path = bundle.path(forResource: "ClientPageDataUcdEvents", ofType: "json")!
        
        let content = try String(contentsOfFile: path)
        
        // Use objectmapper
        let ucdEvents: ClientPageData = Mapper<ClientPageData>().map(JSONString: content)!
        
        XCTAssertEqual(ucdEvents.clientPageId, "197528567092983")
        XCTAssertEqual(ucdEvents.clientPage.pageId, "197528567092983")
        
        XCTAssertEqual(ucdEvents.includedPages.count, 307)
       
    }
}
