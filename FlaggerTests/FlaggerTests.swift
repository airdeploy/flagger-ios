import XCTest
@testable import Flagger

class FlaggerTests: XCTestCase {
    
    private var attributes: Attributes?

    override func setUp() {
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
        let entity = Entity(id: "57145770", type: "User", group: Group(id: "321", attributes:Attributes().put(key: "isAdmin", value: true)))
        let event = Event(name: "test", attributes: Attributes().put(key: "isAdmin", value: true), entity: entity)
        Flagger.track(event)
        
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
        Flagger.setEntity(nil)
        XCTAssert(Flagger.flagIsEnabled(codename: "group-messaging", entity: Entity(id: "57145770")))
        XCTAssertFalse(Flagger.flagIsEnabled(codename: "group-messaging"))
        
        // group example
        XCTAssert(Flagger.flagIsEnabled(codename: "group-messaging", entity: Entity(id: "randomid", group: Group(id: "4576815", type: "Company"))))
    }
    
    func testFlagIsSampled() {
        let attributes: Attributes = Attributes().put(key:"createdAt", value:"2014-09-20T00:00:00Z")
        XCTAssertTrue(Flagger.flagIsSampled(codename: "company-profiles", entity: Entity(id: "9139fdsds5", attributes: attributes)))

        // group example
        XCTAssertTrue(Flagger.flagIsSampled(codename: "org-chart", entity: Entity(id: "41", type: "User", group: Group(id:"543", type:"Company"))))
    }
    
    func testFlagGetVariation() {
        XCTAssertEqual(Flagger.flagGetVariation(codename: "group-messaging", entity: Entity(id: "57145770", type: "User")), "enabled")
    }
    
    func testFlagGetPayload() throws {
        let payload =  Flagger.flagGetPayload(codename: "faq-redesign", entity: Entity(id: "92784783"))
        if let showButtonsPayload = payload["show-buttons"]{
          
            if let showButtons = showButtonsPayload as? Bool{
                XCTAssert(showButtons)
            } else {
                XCTFail("Must be Bool")
            }
        } else {
            XCTFail("Must return payload")
        }
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
