//
//  ToDoTableViewCell.swift
//  ToDoApp
//
//  Created by Tieu Thanh Liem on 11/14/19.
//  Copyright © 2019 Tieu Thanh Liem. All rights reserved.
//

import UIKit

protocol TodoCellDelegate{
  func didRequestComplete(_ cell: TodoTableViewCell)
  func didRequestDelete(_ cell: TodoTableViewCell)
  func didRequestShare(_ cell: TodoTableViewCell)
}

class TodoTableViewCell: UITableViewCell {
  
  @IBOutlet weak var todoLabel: UILabel!
  
  var delegte: TodoCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  @IBAction func completeToDo(_ sender: Any) {
    delegte?.didRequestComplete(self)
  }
  
  @IBAction func deleteToDo(_ sender: Any) {
    delegte?.didRequestDelete(self)
  }
  
  @IBAction func shareTodo(_ sender: Any) {
    delegte?.didRequestShare(self)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
