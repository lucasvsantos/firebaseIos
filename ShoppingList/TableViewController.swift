//
//  TableViewController.swift
//  ShoppingList
//
//  Created by Usuário Convidado on 25/08/2018.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class TableViewController: UITableViewController {
    
    var firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        settings.isPersistenceEnabled = true
        
        let firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    
    var firestoreListener: ListenerRegistration!
    let shoppingListCollection = "shoppingList"
    var shoppingList: [ShoppingItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    func loadItems(){
        firestoreListener = firestore.collection(shoppingListCollection).order(by: "name").addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                guard let snapshot = snapshot else { return }
                
                if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                    self.showItems(snapshot: snapshot)
                }
            }
        })
    }
    
    func showItems(snapshot: QuerySnapshot){
        shoppingList.removeAll()
        for document in snapshot.documents {
            let data = document.data()
            let name = data["name"] as! String
            let quantity = data["quantity"] as! Int
            let shoppingItem = ShoppingItem(name: name, quantity: quantity, id: document.documentID)
            
            shoppingList.append(shoppingItem)
        }
        tableView.reloadData()
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        let data: [String: Any] = [
            "name":"Arthur2TDSR",
            "quantity":1
        ]
        firestore.collection(shoppingListCollection).addDocument(data: data) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Adicionado com sucesso!")
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let shoppingItem = shoppingList[indexPath.row]
        cell.textLabel?.text = shoppingItem.name
        cell.detailTextLabel?.text = shoppingItem.quantity.description

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let shoppingItem = shoppingList[indexPath.row]
            firestore.collection(shoppingListCollection).document(shoppingItem.id).delete()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shoppingItem = shoppingList[indexPath.row]
        let randomQuantity = Int(arc4random_uniform(30)+1)
        let data: [String: Any] = [
            "name":shoppingItem.name,
            "quantity": randomQuantity
        ]
        
        firestore.collection(shoppingListCollection).document(shoppingItem.id).updateData(data)
        tableView.deselectRow(at: indexPath, animated: true)
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
