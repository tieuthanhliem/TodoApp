//
//  TodoTableViewController.swift
//  TodoApp
//
//  Created by Tieu Thanh Liem on 11/14/19.
//  Copyright © 2019 Tieu Thanh Liem. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class TodoTableViewController: UITableViewController {
  
  var todoItems: [TodoItem]!
  
  var peerID: MCPeerID!
  var mcSession: MCSession!
  var mcAdvertiserAssistant: MCAdvertiserAssistant!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupConectivity()
    loadData()
  }
  
  func setupConectivity(){
    peerID = MCPeerID(displayName: UIDevice.current.name)
    mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
    mcSession.delegate = self
  }
  
  func loadData(){
    todoItems = [TodoItem]()
    todoItems = DataManager.loadAll(with: TodoItem.self).sorted(by: { (first, second) -> Bool in
      first.createdAt < second.createdAt
    })
    tableView.reloadData()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return todoItems.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TodoTableViewCell
    
    cell.delegate = self
    
    let todoItem = todoItems[indexPath.row]
    cell.todoLabel.text = todoItem.title
    
    if todoItem.completed {
      cell.todoLabel.attributedText = strikeThroughText(todoItem.title)
    }
    
    return cell
  }
  
  func strikeThroughText(_ text: String) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(string: text)
    attributedString.addAttribute(.strikethroughStyle, value: 1, range: NSMakeRange(0, text.count))
    return attributedString
  }
}

// MARK - Define Actions
//
extension TodoTableViewController{
  @IBAction func showConnectivityActions(_ sender: Any) {
    let actionSheet = UIAlertController(title: "Todo Exchange", message: "Do you want to host or join a section?", preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Host a section", style: .default, handler: { (_) in
      self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "ba-td", discoveryInfo: nil, session: self.mcSession)
      self.mcAdvertiserAssistant.start()
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Join a section", style: .default, handler: { (_) in
      let mcBrowser = MCBrowserViewController(serviceType: "ba-td", session: self.mcSession)
      mcBrowser.delegate = self
      self.present(mcBrowser, animated: true, completion: nil)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    self.present(actionSheet, animated: true, completion: nil)
  }
  
  
  
  @IBAction func addTodo(_ sender: Any) {
    let addAlert = UIAlertController(title: "New Todo", message: "Enter the title", preferredStyle: .alert)
    addAlert.addTextField { (textfield) in
      textfield.placeholder = "Todo Item Title"
    }
    
    addAlert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (_) in
      guard let title = addAlert.textFields?.first?.text else {return}
      let newItem = TodoItem(title: title, completed: false, createdAt: Date(), itemIdentifier: UUID())
      newItem.saveItem()
      self.todoItems.append(newItem)
      let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)
      self.tableView.insertRows(at: [indexPath], with: .automatic)
    }))
    
    addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(addAlert, animated: true, completion: nil)
  }
}

// TodoTableViewController implement TodoCellDelegate
//
extension TodoTableViewController: TodoCellDelegate {
  
  func didRequestComplete(_ cell: TodoTableViewCell) {
    guard let indexPath = self.tableView.indexPath(for: cell) else { return }
    
    todoItems[indexPath.row].markAsCompleted()
    self.tableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  func didRequestDelete(_ cell: TodoTableViewCell) {
    guard let indexPath = self.tableView.indexPath(for: cell) else { return }
    
    todoItems[indexPath.row].deleteItem()
    todoItems.remove(at: indexPath.row)
    self.tableView.deleteRows(at: [indexPath], with: .automatic)
  }
  
  func didRequestShare(_ cell: TodoTableViewCell) {
    if let indexPath = self.tableView.indexPath(for: cell) {
      sendTodo(todoItems[indexPath.row])
    }
  }
  
  func sendTodo(_ todoItem: TodoItem) {
    guard mcSession.connectedPeers.count > 0 else {
      return
    }
    do {
      let data = try todoItem.encode()
      
      try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
    } catch {
      fatalError("Could not send Item")
    }
  }
}




// MARK - MC Delegates
extension TodoTableViewController: MCSessionDelegate, MCBrowserViewControllerDelegate{
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    switch state {
    case .connected:
      print("Connected: \(peerID.displayName)")
    case .connecting:
      print("Connecting: \(peerID.displayName)")
    case .notConnected:
      print("Not Connected: \(peerID.displayName)")
    @unknown default:
      fatalError()
    }
  }
  
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    do {
      let todoItem = try TodoItem.decode(data)
      todoItem.saveItem()
      
      DispatchQueue.main.async {
        self.loadData()
      }
      
    } catch {
      fatalError("Unable to process the received data")
    }
  }
  
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    
  }
  
  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    
  }
  
  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    
  }
  
  func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
    dismiss(animated: true, completion: nil)
  }
}
