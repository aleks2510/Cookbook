//
//  AddRecipeViewController.swift
//  CookBook
//
//  Created by Alejandro Lopez on 10/7/16.
//  Copyright © 2016 Aleks. All rights reserved.
//

import UIKit
import CoreData

class AddRecipeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource{
    var dataImage = Data()
    var ingredients = [I_Ingredient]()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleIdTextBox: UITextField!
    @IBOutlet var recipeInstructionsTextView: UITextView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var recipeImage: UIImageView!
    
    let controller = MainViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        recipeInstructionsTextView.delegate = self
        titleIdTextBox.delegate = self
        self.hideKeyboard()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        if (dataImage.isEmpty){
            dataImage = #imageLiteral(resourceName: "NoImageIcon").jpegData(compressionQuality: 1.0)!
        }
    }
    //MARK: cancelButtonDidTouch
    @IBAction func cancelButtonDidTouch(_ sender: AnyObject) {
    performSegue(withIdentifier: "backToMainSegue", sender: self)
    }
    
    //MARK:UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleIdTextBox.text = textField.text
    }
    
    //MARK:textViewDidBeginEditing
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint.init(x: 0, y: 250), animated: true)
    }
    
    //MARK:textViewDidEndEditing
    func textViewDidEndEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
    }
    
    //MARK: HideKeyboard
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: SelectImage
    @IBAction func selectImageButtonDidTouch(_ sender: AnyObject) {
       selectPicture()
     }
    
    func selectPicture() {
        titleIdTextBox.resignFirstResponder()
        recipeInstructionsTextView.resignFirstResponder()
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    
    //MARK: PickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        // do something interesting here!
        print(newImage.size)
        dataImage = newImage.jpegData(compressionQuality: 1.0)!
        // Set photoImageView to display the selected image.
        recipeImage.image = UIImage(data: dataImage)
        dismiss(animated: true)
    }

    
    //MARK: Save Button
    @IBAction func saveButtonDidTouch(_ sender: AnyObject) {
        let titleName = titleIdTextBox.text
        let preparation = recipeInstructionsTextView.text
        controller.saveRecipe(name: titleName!, preparation: preparation!, image: dataImage as NSData!, array: ingredients )
        self.performSegue(withIdentifier: "ReturnSegue", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: NumberOfRowInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    //MARK: CellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as UITableViewCell!
        
        let ingredient = ingredients[indexPath.row]
        
        cell?.textLabel?.text = ingredient.name as String!
                return cell! as UITableViewCell
    }
    //MARK: DidSelectRowAtIndexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK:UnwindToAddRecipe
    @IBAction func unwindToAddRecipe(_ segue: UIStoryboardSegue) {
        
    }
    //MARK: EditingStyle
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.ingredients.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    

    
    
}
