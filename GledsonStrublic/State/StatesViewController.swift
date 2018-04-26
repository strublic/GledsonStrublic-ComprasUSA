//
//  StatesViewController.swift
//  GledsonStrublic
//
//  Created by Mobile2you on 18/04/18.
//  Copyright © 2018 Mobile2you. All rights reserved.
//

import UIKit
import CoreData

enum CategoryType {
    case add, edit
}

class StatesViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tfDolar: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let tableCellIdentifier = "stateCell"
    var fetchedResultController: NSFetchedResultsController<State>!
    var label: UILabel!
    var state: State!
    var alert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
        label.text = "Lista de estados vazia."
        label.textAlignment = .center
        
        loadStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tfDolar.text = String(format : "%.2f" ,UserDefaults.standard.double(forKey: "dolar"))
        tfIOF.text = String(format: "%.2f", UserDefaults.standard.double(forKey: "iof"))
    }
    
    //Sai da tela das taxas
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if let value = tfDolar.text, let dValue = Double(value), dValue > 0 {
//            UserDefaults.standard.set(dValue, forKey: "dolar")
//        }
//        if let value = tfIOF.text, let dValue = Double(value), dValue >= 0 {
//            UserDefaults.standard.set(dValue, forKey: "iof")
//        }
//    }
    
    
    @IBAction func dollarChanged(_ sender: UITextField) {
        if let value = tfDolar.text, let dValue = Double(value), dValue > 0 {
            UserDefaults.standard.set(dValue, forKey: "dolar")
        }
    }
    
    @IBAction func iofChanged(_ sender: UITextField) {
        if let value = tfIOF.text, let dValue = Double(value), dValue >= 0 {
            UserDefaults.standard.set(dValue, forKey: "iof")
        }
    }
    
    // MARK: - Methods
    func loadStates() {
        let fetchedRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchedRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func stateTextChange(sender: UITextField)
    {
        var allValid = true
        
        if let fields = alert.textFields {
            for field in fields {
                if let placeHolder = field.placeholder {
                    if placeHolder.range(of: "Estado") != nil {
                        if let text = field.text, text.count > 1 {
                            allValid = allValid && true
                        } else {
                            allValid = false
                        }
                    } else if placeHolder.range(of: "Imposto") != nil {
                        if let text = field.text, let dValue = Double(text), dValue >= 0.0 {
                            allValid = allValid && true
                        } else {
                            allValid = false
                        }
                    }
                }
            }
        }
        
        if let okButton = alert.actions.first {
            okButton.isEnabled = allValid
        }
    }
    
    func showDialog(type: CategoryType, state: State? )
    {
        let title = (type == .add) ? "Adicionar" : "Editar"
        alert = UIAlertController(title: "\(title) estado", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Estado"
            textField.addTarget(self, action: #selector(self.stateTextChange), for: .editingChanged)
            if let title = state?.title {
                textField.text = title
            }
        }
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Imposto"
            textField.addTarget(self, action: #selector(self.stateTextChange), for: .editingChanged)
            textField.keyboardType = .decimalPad
            if let tax = state?.tax {
                textField.text = String(format: "%.2f", tax)
            }
        }
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state = state ?? State(context: self.context)
            var errorMessage = ""
            if let title = self.alert.textFields?.first?.text, title.count > 0 {
                state.title = title
            }
            else {
                errorMessage += "Sem estado \n"
            }
            
            if let strTax = self.alert.textFields?.last?.text, let tax = Double(strTax) {
                state.tax = tax
            }
            else {
                errorMessage += "Sem taxa"
            }
            
            if errorMessage.count > 1 {
                print(errorMessage)
                self.context.delete(state)
                self.state = nil
            }
            
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                print(error.localizedDescription)
            }
        }))
        if let firstAction = alert.actions.first {
            firstAction.isEnabled = false
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - IBActions
    @IBAction func addState(_ sender: UIButton) {
        showDialog(type: .add, state: nil)
    }
}


extension StatesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

extension StatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = self.fetchedResultController.object(at: indexPath)
        tableView.setEditing(false, animated: true)
        self.showDialog(type: .edit, state: state)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.fetchedResultController.object(at: indexPath)
            self.context.delete(state)
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                print(error.localizedDescription)
            }
        }
        return [deleteAction]
    }
}

extension StatesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            tableView.backgroundView = (count == 0) ? label : nil
            return count
        } else {
            tableView.backgroundView = label
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StateTableViewCell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as! StateTableViewCell
        let state = fetchedResultController.object(at: indexPath)
        if let title = state.title {
            cell.lbStateTitle.text = title
        }
        cell.lbStateTax.text = String(format: "%.2F", state.tax)
        
        return cell
    }
}
