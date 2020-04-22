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
    
    private var attributes: Attributes?
    
    override func setUpWithError() throws {
        let testBundle = Bundle(for: FlaggerTests.self)
        if let url = testBundle.url(forResource: "Urls", withExtension: "plist"),
            let dict = NSDictionary(contentsOf: url) as? [String:Any] {
            Flagger.initialize(apiKey: "fdsfsd", sourceURL: dict["sourceURL"] as! String, backupSourceURL: dict["backupSourceURL"] as! String, sseURL: dict["sseURL"] as! String, ingestionURL: dict["ingestionURL"] as! String, logLevel: LogLevel.debug)
        } else {
            XCTFail("Didn't find Urls.plist")
        }
        
        if let attributes = Attributes.parse(dict: ["isAdmin": true, "age":21, "name":"Leo"]) {
            self.attributes = attributes
        } else {
            XCTFail("all attributes must be parsed")
        }
        
    }
    
    override func tearDownWithError() throws {
        XCTAssertFalse(Flagger.shutdown(timeoutMillis: 1000))
    }
    
    func testPublish() {
        Flagger.publish(Entity("343223"))
    }
    
    func testEntity(){
        if let attributes = self.attributes {
            let e = Entity(id: "57145770", type: "User", group: Group(id: "321", attributes: attributes))
            Flagger.publish(e)
        } else {
            XCTFail("all attributes must be set")
        }
    }
    
    func testTrack(){
        if let attributes = Attributes.parse(dict: ["isAdmin": true]){
            let entity = Entity(id: "57145770", type: "User", group: Group(id: "321", attributes:attributes))
            let event = Event(name: "test", attributes: attributes, entity: entity)
            Flagger.track(event)
        } else {
            XCTFail("all attributes must be parsed")
        }
    }
    
    func testSetEntity() {
        let entity = Entity(id: "57145770")
        Flagger.setEntity(nil) // reset any entity that flagger could have
        XCTAssertFalse(Flagger.flagIsEnabled(codename: "group-messaging"))
        Flagger.setEntity(entity)
        XCTAssert(Flagger.flagIsEnabled(codename: "group-messaging")) // entity is provided by setEntity
        Flagger.setEntity(nil)
        XCTAssertFalse(Flagger.flagIsEnabled(codename: "group-messaging"))
    }
    
    func testFlagIsEnabled() throws {
        XCTAssert(Flagger.flagIsEnabled(codename: "group-messaging", entity: Entity(id: "57145770")))
        XCTAssert(Flagger.flagIsEnabled(codename: "group-messaging", entity: Entity(id: "57145770")))
        XCTAssertFalse(Flagger.flagIsEnabled(codename: "group-messaging", entity: Entity(id: "57145771")))
        XCTAssertFalse(Flagger.flagIsEnabled(codename: "group-messaging"))
    }
    
    func testFlagIsSampled() {
        XCTAssertFalse(Flagger.flagIsSampled(codename: "random-codename"))
    }
    
    func testFlagGetVariation() {
        XCTAssertEqual(Flagger.flagGetVariation(codename: "fdskkdsf"), "off")
    }
    
    func testFlagGetPayload() throws {
        let payload =  Flagger.flagGetPayload(codename: "faq-redesign", entity: Entity(id: "92784783"))
        XCTAssert(payload["show-buttons"] as! Bool)
    }
    
    func testAttributeParsing() throws {
        if Attributes.parse(dict: ["isAdmin": true, "age":21, "name":"Leo"]) != nil {
            
        } else {
            XCTFail("all attributes must be parsed")
        }
        // Date type is not supported
        let attributes = Attributes.parse(dict: ["isAdmin": Date()])
        XCTAssertNil(attributes)
    }
    
}
