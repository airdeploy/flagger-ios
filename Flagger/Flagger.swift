//
//  File.swift
//  Flagger
//
//  Created by Herman Havrysh on 16/April/20.
//  Copyright © 2020 Herman Havrysh. All rights reserved.
//

import FlaggerGoWrapper

struct Response<T: Decodable>: Decodable {
    let data: T
    let error: String?
}

public class Flagger {
    public static func initialize(apiKey: String) -> Void {
        FlaggerGoWrapperInit("{\"apiKey\":\""+apiKey+"\",\"sourceURL\":\"http://localhost:3000/config/v3/\",\"sseURL\":\"http://localhost:3000/sse/v3?envKey=x2ftC7QtG7arQW9l\",\"ingestionURL\":\"http://localhost:3000/collector\",\"logLevel\":\"DEBUG\",\"sdkName\":\"ios\",\"sdkVersion\":\"3.0.0\"}")
    }
    
    public static func publish(_ entity: IdEntity) -> Bool {
        let buf: String = "{\"entity\": \(entity.description)}"
        let res = FlaggerGoWrapperPublish(buf)
        guard let data = res.data(using: .utf8) else {return false}
        let reponse: Response<Bool> = try! JSONDecoder().decode(Response<Bool>.self, from: data)
        return reponse.data
    }
    
    public static func track(_ event: Event) -> Bool {
        let buf: String = "{\"event\": \(event.description)}"
        let res = FlaggerGoWrapperTrack(buf)
        guard let data = res.data(using: .utf8) else {return false}
        let reponse: Response<Bool> = try! JSONDecoder().decode(Response<Bool>.self, from: data)
        return reponse.data
    }
    
    public static func shutdown(timeoutMillis: Int) -> Bool {
        let buf: String = "{\"timeout\": \(timeoutMillis)}"
        let res = FlaggerGoWrapperShutdown(buf)
        guard let data = res.data(using: .utf8) else {return false}
        let reponse: Response<Bool> = try! JSONDecoder().decode(Response<Bool>.self, from: data)
        return reponse.data
    }
    
    public static func setEntity(_ entity: IdEntity?) -> Bool {
        let buf: String = "{\"entity\": \(entity != nil ? entity!.description : "null")}"
        let res = FlaggerGoWrapperSetEntity(buf)
        guard let data = res.data(using: .utf8) else {return false}
        let reponse: Response<Bool> = try! JSONDecoder().decode(Response<Bool>.self, from: data)
        return reponse.data
    }
    
    public static func flagIsEnabled(_ codename: String, _ entity: IdEntity) -> Bool {
        let buf: String = "{\"codename\": \"\(codename)\", \"entity\": \(entity.description)}"
        let res = FlaggerGoWrapperFlagIsEnabled(buf)
        guard let data = res.data(using: .utf8) else {return false}
        let reponse: Response<Bool> = try! JSONDecoder().decode(Response<Bool>.self, from: data)
        return reponse.data
    }
    
    public static func flagIsEnabled(_ codename: String) -> Bool {
        let buf = "{\"codename\": \"\(codename)\"}"
        let res = FlaggerGoWrapperFlagIsEnabled(buf)
        guard let data = res.data(using: .utf8) else {return false}
        let reponse: Response<Bool> = try! JSONDecoder().decode(Response<Bool>.self, from: data)
        return reponse.data
    }
    
    public static func flagIsSampled(_ codename: String, _ entity: IdEntity) -> Bool {
        let buf = "{\"codename\": \"\(codename)\", \"entity\": \(entity.description)}"
        let res = FlaggerGoWrapperFlagIsSampled(buf)
        guard let data = res.data(using: .utf8) else {return false}
        let reponse: Response<Bool> = try! JSONDecoder().decode(Response<Bool>.self, from: data)
        return reponse.data
    }
    
    public static func flagIsSampled(_ codename: String) -> Bool {
        let buf = "{\"codename\": \"\(codename)\"}"
        let res = FlaggerGoWrapperFlagIsSampled(buf)
        guard let data = res.data(using: .utf8) else {return false}
        let reponse: Response<Bool> = try! JSONDecoder().decode(Response<Bool>.self, from: data)
        return reponse.data
    }
    
    public static func flagGetVariation(_ codename: String, _ entity: IdEntity) -> String {
        let buf = "{\"codename\": \"\(codename)\", \"entity\": \(entity.description)}"
        let res = FlaggerGoWrapperFlagGetVariation(buf)
        guard let data = res.data(using: .utf8) else {return ""}
        let reponse: Response<String> = try! JSONDecoder().decode(Response<String>.self, from: data)
        return reponse.data
    }
    
    public static func flagGetVariation(_ codename: String) -> String {
        let buf = "{\"codename\": \"\(codename)\"}"
        let res = FlaggerGoWrapperFlagGetVariation(buf)
        guard let data = res.data(using: .utf8) else {return ""}
        let reponse: Response<String> = try! JSONDecoder().decode(Response<String>.self, from: data)
        return reponse.data
    }
    
    public static func flagGetPayload(_ codename: String, _ entity: IdEntity) -> [String:Any] {
        let buf = "{\"codename\": \"\(codename)\", \"entity\": \(entity.description)}"
        let res = FlaggerGoWrapperFlagGetPayload(buf)
        guard let data = res.data(using: .utf8) else {return [:]}
        let reponse:[String:Any] = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
        return reponse["data"] as! [String:Any]
    }
    
    public static func flagGetPayload(_ codename: String) -> [String:Any] {
        let buf = "{\"codename\": \"\(codename)\"}"
        let res = FlaggerGoWrapperFlagGetPayload(buf)
        guard let data = res.data(using: .utf8) else {return [:]}
        let reponse:[String:Any] = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
        return reponse["data"] as! [String:Any]
    }
}

public class Event {
    let name: String
    let attributes: [String: Any] // Value must be Bool/String/Numeric
    let entity: IdEntity?
    
    init(name: String, attributes: [String: Any]) {
        self.name = name
        self.attributes = attributes
        self.entity = nil
    }
    
    init(name: String, attributes: [String: Any], entity: IdEntity) {
        self.name = name
        self.attributes = attributes
        self.entity = entity
    }
    
    public var description: String {
        let jsonDict = [
            "name": self.name as Any,
            "attributes": self.attributes as Any,
            "entity": self.entity as Any
            ] as [String: Any]
        
        
        if JSONSerialization.isValidJSONObject(jsonDict) {
            if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) {
                return String(data: data, encoding: .utf8)!
            }
        }
        return ""
    }
}

public class IdEntity: Encodable {
    let id: String
    
    init(_ id: String){
        self.id = id
    }
    
    init(id: String){
        self.id = id
    }
    
    public var description: String { return "{\"id\": \"\(id)\"}" }
}

public class GroupEntity: IdEntity {
    var type: String?
    var name: String?
    var attributes: [String: Any]? // Value must be Bool/String/Numeric
    
    override init(id: String){
        super.init(id: id)
    }
    
    init?(id: String, type: String?, name: String?, attributes:[String: Any]?){
        super.init(id)
        self.type = type
        self.name = name
        if attributes != nil {
            for attribute in attributes! {
                switch attribute.value {
                case is Bool:
                    continue
                case is String:
                    continue
                case is Int:
                    continue
                case is Float:
                    continue
                case is Double:
                    continue
                default:
                    return nil
                }
            }
        }
        self.attributes = attributes
        
    }
    
    
    public override var description: String {
        let jsonDict = [
            "id": self.id,
            "name": self.name as Any,
            "type": self.type as Any,
            "attributes": self.attributes as Any
            ] as [String: Any]
        
        
        if JSONSerialization.isValidJSONObject(jsonDict) {
            if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) {
                return String(data: data, encoding: .utf8)!
            }
        }
        return ""
    }
    
}
