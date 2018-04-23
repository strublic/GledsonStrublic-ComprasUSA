//
//  StatesViewController.swift
//  GledsonStrublic
//
//  Created by Mobile2you on 18/04/18.
//  Copyright © 2018 Mobile2you. All rights reserved.
//

import UIKit
import CoreData

enum StateType {
    case add
    case edit
}

class StatesViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
    var fetchedResultController: NSFetchedResultsController<State>!
    
    // MARK: - Properties
    var dataSource: [State] = []
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadStates()
//        tableView.delegate = self
//        tableView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 106
        tableView.rowHeight = UITableViewAutomaticDimension
        label.text = "Lista de estados vazia."
        label.textAlignment = .center
        label.textColor = .darkGray
        loadStates()
    }
    
    // MARK: - Methods
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
//        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultController.delegate = self as? NSFetchedResultsControllerDelegate
        
        do {
            dataSource = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func showAlert(type: StateType, state: State?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do Estado"
            if let name = state?.title {
                textField.text = name
            }
        }
        
        alert.addTextField { (textField2: UITextField) in
            textField2.placeholder = "Imposto"
            if let tax = state?.tax {
                textField2.text = "\(tax)"
            }
        }
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state = state ?? State(context: self.context)
            state.title = alert.textFields?[0].text
            state.tax = Double(alert.textFields![1].text!)!
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                print(error.localizedDescription)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
//    @IBAction func close(_ sender: UIBarButtonItem) {
//        dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func addState(_ sender: UIButton) {
        showAlert(type: .add, state: nil)
    }
//    @IBAction func add(_ sender: UIBarButtonItem) {
//
//    }
}


// MARK: - UITableViewDelegate
extension StatesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = dataSource[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)!
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            product.addToStates(state)
        } else {
            cell.accessoryType = .none
            product.removeFromStates(state)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.dataSource[indexPath.row]
            self.context.delete(state)
            try! self.context.save()
            self.dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Editar") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.dataSource[indexPath.row]
            tableView.setEditing(false, animated: true)
            self.showAlert(type: .edit, state: state)
        }
        editAction.backgroundColor = .blue
        return [editAction, deleteAction]
    }
}

// MARK: - UITableViewDelegate
extension StatesViewController: UITableViewDataSource {
    
    //Método que define a quantidade de seções de uma tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
//        if let count = fetchedResultController.fetchedObjects?.count {
//            tableView.backgroundView = (count == 0) ? label : nil
//            tableView.separatorStyle = .none
//            return count
//        } else {
//            tableView.backgroundView = label
//            return 0
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let state = dataSource[indexPath.row]
        cell.textLabel?.text = state.title
        cell.accessoryType = .none
        if product != nil {
            if let states = product.states, states.contains(state) {
                cell.accessoryType = .checkmark
            }
        }
        return cell
    }
}

