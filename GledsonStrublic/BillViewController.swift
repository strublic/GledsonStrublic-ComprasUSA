//
//  BillViewController.swift
//  GledsonStrublic
//
//  Created by Mobile2you on 25/04/18.
//  Copyright © 2018 Mobile2you. All rights reserved.
//

import UIKit
import CoreData

class BillViewController: UIViewController {
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    @IBOutlet weak var lbTotalUS: UILabel!
    @IBOutlet weak var lbTotalBR: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    //Faz o calculo depois que as taxas sao salvas na tla de ajustes
    override func viewDidAppear(_ animated: Bool) {
        load()
    }
    
    func load() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
            calculate()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func calculate() {
        if let objects = fetchedResultController.fetchedObjects {
            var dolarTotal = 0.0
            var dResult = 0.0;
            let dolar = UserDefaults.standard.double(forKey: "dolar")
            let iof = UserDefaults.standard.double(forKey: "iof")
            
            for product in objects {
                var total = product.price
                //Total do dolar
                dolarTotal += product.price
                //
                if let state = product.state, state.tax != 0 {
                    total *= ((state.tax / 100) + 1)
                    
                }
                if product.card && iof != 0 {
                    total *= ((iof / 100) + 1)
                }
                dResult += total
            }
            let realResult = dResult * dolar
            lbTotalBR.text = String(format: "%.2f", realResult)
            lbTotalUS.text = String(format: "%.2f", dolarTotal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension BillViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        calculate()
    }
}
