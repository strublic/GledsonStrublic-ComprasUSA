//
//  ProductRegisterViewController.swift
//  GledsonStrublic
//
//  Created by Mobile2you on 18/04/18.
//  Copyright © 2018 Mobile2you. All rights reserved.
//

import UIKit
import CoreData

class ProductRegisterViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var ivPicture: UIImageView!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var btAddUpdate: UIButton!
    @IBOutlet weak var spCard: UISwitch!
    
    // MARK: - Properties
    var product: Product!
    var smallImage: UIImage!

    var pickerView: UIPickerView!
    var fetchedResultController: NSFetchedResultsController<State>!
    var dataSource: [String]!
    
    var currentState: State!
    
    // MARK:  Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if product != nil {
            tfTitle.text = product.title
            currentState = product.state
            tfState.text = currentState?.title
            tfPrice.text = String(format: "%.2f", product.price)
            spCard.isOn = product.card
            
            if let image = product.picture as? UIImage {
                ivPicture.image = image
                smallImage = image
            }
            
            btAddUpdate.setTitle("Atualizar", for: .normal)
        }
        
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfState.inputAccessoryView = toolbar
        tfState.inputView = pickerView
        
        loadStates()
    }
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
//            dataSource = fetchedResultController.fetchedObjects?.map({$0.title!})
        } catch {
            print(error.localizedDescription)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if product == nil {
//            product = Product(context: context)
//        }
//        let vc = segue.destination
//        vc.product = product
    }

    // MARK: - IBActions
    @IBAction func addPicture(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecionar uma imagem", message: "De onde você quer escolher a imagem?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.setNewImage(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.setNewImage(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
        //Criando o alerta que será apresentado ao usuário
//        let alert = UIAlertController(title: "Selecionar uma imagem", message: "De onde você quer escolher a imagem?", preferredStyle: .actionSheet)
//
//        //Verificamos se o device possui câmera. Se sim, adicionamos a devida UIAlertAction
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
//                self.selectPicture(sourceType: .camera)
//            })
//            alert.addAction(cameraAction)
//        }
//
//        //As UIAlertActions de Biblioteca de fotos e Álbum de fotos também são criadas e adicionadas
//        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
//            self.selectPicture(sourceType: .photoLibrary)
//        }
//        alert.addAction(libraryAction)
//
//        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action: UIAlertAction) in
//            self.selectPicture(sourceType: .savedPhotosAlbum)
//        }
//        alert.addAction(photosAction)
//
//        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
    }

    @IBAction func close(_ sender: UIButton?) {
        if product != nil && product.title == nil {
            context.delete(product)
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addUpdateProduct(_ sender: UIButton) {
        print("Salvando produto")
        product = product ?? Product(context: context)
        var errorMessage: String = ""
        
        if let title = tfTitle.text, title.count > 0 {
            product.title = title
        }
        else {
            errorMessage += "Digite o título do produto \n"
        }
        
        if let value = tfPrice.text, let dValue = Double(value), dValue >= 0 {
            product.price = dValue
        }
        else {
            errorMessage += "Digite o preço do produto \n"
        }
        
        product.card = spCard.isOn
        if currentState != nil {
            product.state = currentState
        }
        else {
            errorMessage += "Escolha um estado \n"
        }
        
        if smallImage != nil {
            product.picture = smallImage
        }
        else {
            errorMessage += "Escolha uma imagem"
        }
        
        if errorMessage.count > 1 {
            let alert = UIAlertController(title: "Atenção", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            context.undo()
            return
        }
        
        do {
            try context.save()
            dismiss(animated: true, completion: nil)
            navigationController?.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
        
        print("Produto salvo")
    }
    
    func setNewImage(sourceType: UIImagePickerControllerSourceType)
    {
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = sourceType
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK:  Methods
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        //Criando o objeto UIImagePickerController
        let imagePicker = UIImagePickerController()

        //Definimos seu sourceType através do parâmetro passado
        imagePicker.sourceType = sourceType

        //Definimos a MovieRegisterViewController como sendo a delegate do imagePicker
        imagePicker.delegate = self

        //Apresentamos a imagePicker ao usuário
        present(imagePicker, animated: true, completion: nil)
    }
    
    //O método cancel irá esconder o teclado e não irá atribuir a seleção ao textField
    @objc func cancel() {
        //O método resignFirstResponder() faz com que o campo deixe de ter o foco, fazendo assim
        //com que o teclado (pickerView) desapareça da tela
        tfState.resignFirstResponder()
    }
    
    //O método done irá atribuir ao textField a escolhe feita no pickerView
    @objc func done() {
        
        //Abaixo, recuperamos a linha selecionada na coluna (component) 0 (temos apenas um component
        //em nosso pickerView)
        currentState = fetchedResultController.object(at: IndexPath(row: pickerView.selectedRow(inComponent: 0), section: 0))
        tfState.text = currentState.title
        cancel()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ProductRegisterViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pickerView.reloadComponent(0)
    }
}

extension ProductRegisterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let path = IndexPath(row: row, section: 0)
        let state:State = fetchedResultController.object(at: path)
        if let title = state.title {
            return title
        }
        return ""
    }
}

extension ProductRegisterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            return count
        } else {
            return 0
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProductRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?){
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivPicture.image = smallImage
        
        dismiss(animated: true, completion: nil)
    }
}







// MARK: - UIImagePickerControllerDelegate
//extension ProductRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    //O método abaixo nos trará a imagem selecionada pelo usuário em seu tamanho original
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
//
//        //Iremos usar o código abaixo para criar uma versão reduzida da imagem escolhida pelo usuário
//        let smallSize = CGSize(width: 300, height: 280)
//        UIGraphicsBeginImageContext(smallSize)
//        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
//
//        //Atribuímos a versão reduzida da imagem à variável smallImage
//        smallImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        ivPicture.image = smallImage //Atribuindo a imagem à ivPoster
//
//        //Aqui efetuamos o dismiss na UIImagePickerController, para retornar à tela anterior
//        dismiss(animated: true, completion: nil)
//    }
//}
//extension ProductRegisterViewController: UIPickerViewDelegate {
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return dataSource[row]
//    }
//}

//extension ProductRegisterViewController: UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return dataSource.count
//    }
//}

// MARK: - NSFetchedResultsControllerDelegate
//extension ProductRegisterViewController: NSFetchedResultsControllerDelegate {
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        dataSource = fetchedResultController.fetchedObjects?.map({$0.title!})
//        pickerView.reloadComponent(0)
//    }
//}
