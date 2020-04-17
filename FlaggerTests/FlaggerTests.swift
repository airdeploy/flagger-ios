//
//  FlaggerTests.swift
//  FlaggerTests
//
//  Created by Herman Havrysh on 16/April/20.
//  Copyright © 2020 Herman Havrysh. All rights reserved.
//

import XCTest
@testable import Flagger

class FlaggerTests: XCTestCase {
    
    override func setUpWithError() throws {
        
        Flagger.initialize(apiKey: "fdsfsd")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        XCTAssert(Flagger.flagIsEnabled("group-messaging", IdEntity(id: "57145770")))
        
        
        XCTAssert(Flagger.flagIsEnabled("group-messaging", GroupEntity(id: "57145770")))
        XCTAssertFalse(Flagger.flagIsEnabled("group-messaging", IdEntity(id: "57145771")))
        
        XCTAssertFalse(Flagger.flagIsEnabled("group-messaging"))
    }
    
    func testFlagGetPayload() throws {
        let payload =  Flagger.flagGetPayload("faq-redesign", IdEntity(id: "92784783"))
        XCTAssert(payload["show-buttons"] as! Bool)
    }
    
    func testGroupEntity() throws {
        XCTAssertNotNil(GroupEntity(id: "sda", type: "User", name: "test", attributes: ["isAdmin": true]))
        XCTAssertNotNil(GroupEntity(id: "sda", type: "User", name: "test", attributes: ["age": 21]))
        XCTAssertNotNil(GroupEntity(id: "sda", type: "User", name: "test", attributes: ["floatValue": 232.32]))
        XCTAssertNotNil(GroupEntity(id: "sda", type: "User", name: "test", attributes: ["lastname": "Tolstoy"]))
        
        XCTAssertNil(GroupEntity(id: "sda", type: "User", name: "test", attributes: ["isAdmin": Date()]))
    }
    
}
