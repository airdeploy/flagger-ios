//
//  File.swift
//  Flagger
//
//  Created by Herman Havrysh on 16/April/20.
//  Copyright © 2020 Herman Havrysh. All rights reserved.
//

import FlaggerGoWrapper

public enum LogLevel:String {
    case debug, warning, error;
}

private func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

fileprivate func parseResponse<T>(response: String) -> T? {
    if let parsedDict = convertToDictionary(text: response){
        if let data = parsedDict["data"] {
            return data as? T
        }
    }
    return nil
}

public class Flagger {
    public static func initialize(apiKey: String, sourceURL: String, backupSourceURL: String, sseURL: String, ingestionURL: String, logLevel: LogLevel = LogLevel.error) -> Void {
        
        var version = "3.0.0"
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            if let v = dict["version"]{
                version = v
            }
        }
        
        FlaggerGoWrapperInit("{\"apiKey\":\"\(apiKey)\",\"sourceURL\":\"\(sourceURL)\",\"backupSourceURL\":\"\(backupSourceURL)\", \"sseURL\":\"\(sseURL)\",\"ingestionURL\":\"\(ingestionURL)\",\"logLevel\":\"\(logLevel)\",\"sdkName\":\"ios\",\"sdkVersion\":\"\(version)\"}"
        )
        // todo: change sdkVersion from hardcode to a defined via plist
    }
    
    public static func initialize(apiKey: String, logLevel: LogLevel = LogLevel.error) -> Void {
        var isInit = false
        
        // load flaggerConfig from plist
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            if let sourceURL = dict["sourceURL"],let backupSourceURL = dict["backupSourceURL"], let sseURL = dict["sseURL"], let ingestionURL = dict["ingestionURL"] {
                initialize(apiKey: apiKey, sourceURL: sourceURL, backupSourceURL: backupSourceURL, sseURL: sseURL + apiKey, ingestionURL: ingestionURL, logLevel: logLevel)
                isInit = true
            }
        }
        
        // load flagger with default values
        if !isInit {
            initialize(apiKey: apiKey, sourceURL: "https://api.airdeploy.io/configurations/",
                       backupSourceURL:"https://backup-api.airdeploy.io/configurations/",
                       sseURL:"https://sse.airdeploy.io/sse/v3/?envKey=",
                       ingestionURL: "https://ingestion.airdeploy.io/collector?envKey=",
                       logLevel: logLevel
            )
        }
    }
    
    public static func publish(_ entity: Entity) -> Void {
        let buf: String = "{\"entity\": \(entity.description)}"
        let _ = FlaggerGoWrapperPublish(buf)
    }
    
    public static func track(_ event: Event) -> Void {
        let buf: String = "{\"event\": \(event.description)}"
        let _ = FlaggerGoWrapperTrack(buf)
    }
    
    public static func shutdown(timeoutMillis: Int) -> Bool {
        let buf: String = "{\"timeout\": \(timeoutMillis)}"
        let res = FlaggerGoWrapperShutdown(buf)
        
        if let isShutdown: Bool = parseResponse(response: res){
            return isShutdown
        }
        return false
    }
    
    public static func setEntity(_ entity: Entity?) -> Void {
        let buf: String = "{\"entity\": \(entity != nil ? entity!.description : "null")}"
        let _ = FlaggerGoWrapperSetEntity(buf)
    }
    
    public static func flagIsEnabled(codename: String, entity: Entity) -> Bool {
        let buf: String = "{\"codename\": \"\(codename)\", \"entity\": \(entity.description)}"
        let res = FlaggerGoWrapperFlagIsEnabled(buf)
        if let isEnabled: Bool = parseResponse(response: res){
            return isEnabled
        }
        return false
    }
    
    public static func flagIsEnabled(codename: String) -> Bool {
        let buf = "{\"codename\": \"\(codename)\"}"
        let res = FlaggerGoWrapperFlagIsEnabled(buf)
        if let isEnabled: Bool = parseResponse(response: res){
            return isEnabled
        }
        return false
    }
    
    public static func flagIsSampled(codename: String, entity: Entity) -> Bool {
        let buf = "{\"codename\": \"\(codename)\", \"entity\": \(entity.description)}"
        let res = FlaggerGoWrapperFlagIsSampled(buf)
        if let isSampled: Bool = parseResponse(response: res){
            return isSampled
        }
        return false
    }
    
    public static func flagIsSampled(codename: String) -> Bool {
        let buf = "{\"codename\": \"\(codename)\"}"
        let res = FlaggerGoWrapperFlagIsSampled(buf)
        if let isSampled: Bool = parseResponse(response: res){
            return isSampled
        }
        return false
    }
    
    public static func flagGetVariation(codename: String, entity: Entity) -> String {
        let buf = "{\"codename\": \"\(codename)\", \"entity\": \(entity.description)}"
        let res = FlaggerGoWrapperFlagGetVariation(buf)
        if let variation: String = parseResponse(response: res){
            return variation
        }
        return "off"
    }
    
    public static func flagGetVariation(codename: String) -> String {
        let buf = "{\"codename\": \"\(codename)\"}"
        let res = FlaggerGoWrapperFlagGetVariation(buf)
        if let variation: String = parseResponse(response: res){
            return variation
        }
        return "off"
    }
    
    public static func flagGetPayload(codename: String, entity: Entity) -> [String:Any] {
        let buf = "{\"codename\": \"\(codename)\", \"entity\": \(entity.description)}"
        let res = FlaggerGoWrapperFlagGetPayload(buf)
        if let payload: [String: Any] = parseResponse(response: res){
            return payload
        }
        return [:]
    }
    
    public static func flagGetPayload(codename: String) -> [String:Any] {
        let buf = "{\"codename\": \"\(codename)\"}"
        let res = FlaggerGoWrapperFlagGetPayload(buf)
        if let payload: [String: Any] = parseResponse(response: res){
            return payload
        }
        return [:]
    }
}

public class Event {
    let name: String
    let attributes: Attributes
    let entity: Entity?
    
    init(name: String, attributes: Attributes) {
        self.name = name
        self.attributes = attributes
        self.entity = nil
    }
    
    init(name: String, attributes: Attributes, entity: Entity) {
        self.name = name
        self.attributes = attributes
        self.entity = entity
    }
    
    public var description: String {
        var jsonDict: [String: Any] = [
            "name": self.name
        ]
        jsonDict["attributes"] = self.attributes.asDict()
        
        if let entity = self.entity {
            jsonDict["entity"] = entity.asDict()
        }
        
        if JSONSerialization.isValidJSONObject(jsonDict) {
            if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) {
                return String(data: data, encoding: .utf8)!
            }
        }
        return "{}"
    }
}

public class Entity {
    let id: String
    let type: String?
    let name: String?
    let group: Group?
    let attributes: Attributes?
    
    init(_ id: String){
        self.id = id
        self.type = nil
        self.name = nil
        self.group = nil
        self.attributes = nil
    }
    
    convenience init(id: String){
        self.init(id)
    }
    
    init(id:String, type: String? = nil, name: String? = nil, group: Group? = nil, attributes: Attributes? = nil){
        self.id = id
        self.type = type
        self.name = name
        self.group = group
        self.attributes = attributes
    }
    
    fileprivate func asDict() -> [String: Any]{
        var jsonDict:[String: Any] = [
            "id": self.id
        ]
        
        if let type = self.type  {
            jsonDict["type"] = type
        }
        
        if let name = self.name  {
            jsonDict["name"] = name
        }
        
        if let group = self.group  {
            jsonDict["group"] = group.asDict()
        }
        
        if let attributes = self.attributes {
            jsonDict["attributes"] = attributes.asDict()
        }
        return jsonDict
    }
    
    public var description: String {
        
        let dict = asDict()
        if JSONSerialization.isValidJSONObject(dict) {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                return String(data: data, encoding: .utf8)!
            }
        }
        return "{}"
    }
}

public class Attributes {
    private var dict: [String: Any] = [:]
    
    private init(dict: [String: Any]){
        self.dict = dict
    }
    
    /*
     returns Attributes if all type of every value in dict is either Bool, String or Number
     return nil otherwise
     */
    public static func parse(dict: [String: Any]) -> Attributes? {
        for (_,value) in dict {
            switch value {
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
        
        return Attributes(dict: dict)
    }
    
    public func asDict() -> [String: Any] {
        return dict
    }
}

public class Group {
    var id: String
    var type: String?
    var attributes: Attributes? // Value must be Bool/String/Numeric
    
    init(_ id: String){
        self.id = id
    }
    
    convenience init?(id: String, type: String? = nil, attributes:Attributes? = nil){
        self.init(id)
        self.type = type
        self.attributes = attributes
    }
    
    
    fileprivate func asDict() -> [String: Any]{
        var jsonDict:[String: Any] = [
            "id": self.id
        ]
        
        if let type = self.type  {
            jsonDict["type"] = type
        }
        
        if let attributes = self.attributes {
            jsonDict["attributes"] =  attributes.asDict()
        }
        
        return jsonDict
    }
    
    public var description: String {
        let dict = asDict()
        if JSONSerialization.isValidJSONObject(dict) {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                return String(data: data, encoding: .utf8)!
            }
        }
        return "{}"
    }
    
}
