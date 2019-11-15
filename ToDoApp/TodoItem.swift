//
//  ToDoItem.swift
//  ToDoApp
//
//  Created by Tieu Thanh Liem on 11/14/19.
//  Copyright © 2019 Tieu Thanh Liem. All rights reserved.
//

import Foundation

struct TodoItem : Codable {
  var title:String
  var completed:Bool
  var createdAt:Date
  var itemIdentifier: UUID
  
  func saveItem() {
    DataManager.save(self, with: itemIdentifier.uuidString)
  }
  
  func deleteItem() {
    DataManager.delete(itemIdentifier.uuidString)
  }
  
  mutating func markAsCompleted() {
    self.completed = true
    DataManager.save(self, with: itemIdentifier.uuidString)
  }
  
  static func decode(_ data:Data) throws -> TodoItem{
    return try JSONDecoder().decode(TodoItem.self, from: data)
  }
  
  func encode() throws -> Data{
    return try JSONEncoder().encode(self)
  }
}
