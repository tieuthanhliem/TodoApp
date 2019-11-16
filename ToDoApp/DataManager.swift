//
//  DataManager.swift
//  ToDoApp
//
//  Created by Tieu Thanh Liem on 11/14/19.
//  Copyright © 2019 Tieu Thanh Liem. All rights reserved.
//

import Foundation

public class DataManager {
  // Get document directory
  static fileprivate func getDcumentDirectory() -> URL {
    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      return url
    } else {
      fatalError("Unable to access document directory")
    }
  }
  
  static func getFileURL(_ fileName:String) -> URL{
    return getDcumentDirectory().appendingPathComponent(fileName, isDirectory: false)
  }
  
  // Save any kind of codable object
  static func save<T:Encodable> (_ object: T, with filename:String){
    let url = getFileURL(filename)
    
    let encoder =  JSONEncoder()
    do{
      let data = try encoder.encode(object)
      
      if FileManager.default.fileExists(atPath: url.path) {
        try FileManager.default.removeItem(at: url)
      }
      FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
      
    } catch {
      fatalError(error.localizedDescription)
    }
  }
  
  // Load any kind of codable object
  static func load<T:Decodable> (_ filename:String, with type:T.Type)->T{
    
    guard let data = loadData(filename) else {
      fatalError("Load data error")
    }
    
    do {
      let model = try JSONDecoder().decode(type, from: data)
      return model
    } catch {
      delete(filename)
      fatalError(error.localizedDescription)
    }
  }
  
  // Load data from a file
  static func loadData(_ filename:String)->Data?{
    let url = getFileURL(filename)
    guard FileManager.default.fileExists(atPath: url.path) else {
      fatalError("File not found at path \(url.path)")
    }
    
    guard let data = FileManager.default.contents(atPath: url.path) else {
      fatalError("File is unavailable at path \(url.path)")
    }
    
    return data
  }
  
  // Load all files from directory
  static func loadAll<T:Decodable> (_ type:T.Type)->[T]{
    do {
      let files = try FileManager.default.contentsOfDirectory(atPath: getDcumentDirectory().path)
      
      var modelObjects = [T]()
      
      for fileName in files {
        modelObjects.append(load(fileName, with: type))
      }
      
      return modelObjects
    } catch {
      fatalError("Could not load any file")
    }
  }
  
  // Delete a file
  static func delete(_ filename:String){
    let url = getFileURL(filename)
    if FileManager.default.fileExists(atPath: url.path) {
      do {
        try FileManager.default.removeItem(at: url)
      } catch {
        fatalError(error.localizedDescription)
      }
    }
  }
}
