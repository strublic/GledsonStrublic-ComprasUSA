//
//  ProductRegisterViewController.swift
//  GledsonStrublic
//
//  Created by Mobile2you on 18/04/18.
//  Copyright © 2018 Mobile2you. All rights reserved.
//

import Foundation
import UIKit

class ProductRegisterViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var ivPicture: UIImageView!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var btAddUpdate: UIButton!
    
    // MARK: - Properties
    var product: Product!
    var smallImage: UIImage!

    // MARK:  Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if product != nil {
            tfTitle.text = product.title
            tfPrice.text = "(product.price)"
            btAddUpdate.setTitle("Atualizar", for: .normal)
            if let image = product.picture as? UIImage {
                ivPicture.image = image
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if product != nil {
            if let states = product.states {
                tfState.text = states.map({($0 as! State).title!}).joined(separator: " | ")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if product == nil {
            product = Product(context: context)
        }
        let vc = segue.destination as! StatesViewController
        vc.product = product
    }

    // MARK: - IBActions
    @IBAction func addPicture(_ sender: UIButton) {
        //Criando o alerta que será apresentado ao usuário
        let alert = UIAlertController(title: "Selecionar uma imagem", message: "De onde você quer escolher a imagem?", preferredStyle: .actionSheet)

        //Verificamos se o device possui câmera. Se sim, adicionamos a devida UIAlertAction
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }

        //As UIAlertActions de Biblioteca de fotos e Álbum de fotos também são criadas e adicionadas
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)

        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)

        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    @IBAction func close(_ sender: UIButton?) {
        if product != nil && product.title == nil {
            context.delete(product)
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addUpdateProduct(_ sender: UIButton) {
        print("Salvando produto")
        if product == nil {
            product = Product(context: context)
        }
        product.title = tfTitle.text!
        product.price = Double(tfPrice.text!)!
        if smallImage != nil {
            product.picture = smallImage
        }
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        close(nil)
        print("Produto salvo")
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
}

// MARK: - UIImagePickerControllerDelegate
extension ProductRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //O método abaixo nos trará a imagem selecionada pelo usuário em seu tamanho original
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        //Iremos usar o código abaixo para criar uma versão reduzida da imagem escolhida pelo usuário
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        
        //Atribuímos a versão reduzida da imagem à variável smallImage
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivPicture.image = smallImage //Atribuindo a imagem à ivPoster
        
        //Aqui efetuamos o dismiss na UIImagePickerController, para retornar à tela anterior
        dismiss(animated: true, completion: nil)
    }
}
