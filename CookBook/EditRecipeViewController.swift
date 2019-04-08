//
//  EditRecipeViewController.swift
//  CookBook
//
//  Created by alejandro Lopez on 11/28/16.
//  Copyright © 2016 Aleks. All rights reserved.
//

import UIKit
import CoreData

class EditRecipeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    var dataImage = Data()
    var recipes = [NSManagedObject]()
    var recipeIngredients = [NSManagedObject]()
    var ingredients =  [NSManagedObject]()
    var specificIngredients = [NSManagedObject]()
    var listOfIngredients = [I_Ingredient]()
    var selectedId : String = ""
    var recipeIdString = ""
    var selectedRecipe = recipeStructure()
    var currentIngredients = [NSManagedObject]()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recipeTitleLabel: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recipeInstructionTextView: UITextView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBAction func cancelButtonDidTouch(_ sender: Any) {
     self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipes")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            recipes = results as! [NSManagedObject]
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        if(selectedRecipe.recipeTitle != nil){
            recipeTitleLabel.placeholder = selectedRecipe.recipeTitle
            recipeTitleLabel.text = selectedRecipe.recipeTitle
        }
        if (selectedRecipe.recipeDescription != nil){
            recipeInstructionTextView.text = selectedRecipe.recipeDescription
        }
        
        if (selectedRecipe.recipeImageViewData != nil){
            recipeImageView?.image = UIImage(data: selectedRecipe.recipeImageViewData!)
            recipeImageView?.layer.cornerRadius = 50.0
        }
        else {
            recipeImageView?.image = (#imageLiteral(resourceName: "NoImageIcon"))
        }
        
        for ingred in currentIngredients {
            let newIngredient = I_Ingredient()
            newIngredient.id = String(describing: ingred.objectID)
            newIngredient.name = String(describing: ingred.value(forKey: "name")!)
            listOfIngredients.append(newIngredient)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    //MARK: UpdateButtonDidTouch
    @IBAction func updateButtonDidTouch(_ sender: Any) {
        if(dataImage.isEmpty){
            if(selectedRecipe.recipeImageViewData == nil){
                dataImage = #imageLiteral(resourceName: "NoImageIcon").jpegData(compressionQuality: 1.0)!
            }
            else{
                dataImage = selectedRecipe.recipeImageViewData!
            }
        }
        
        updateRecipe(name: recipeTitleLabel.text!, preparation: recipeInstructionTextView.text!, image:dataImage as NSData, array: listOfIngredients)
            performSegue(withIdentifier: "backToSeeRecipeSegue", sender: self)
    }
    //MARK:UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        recipeTitleLabel.text = textField.text
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
        recipeTitleLabel.resignFirstResponder()
        recipeInstructionTextView.resignFirstResponder()
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
        recipeImageView.image = UIImage(data: dataImage)
        dismiss(animated: true)
    }
    
    //MARK: NumberOfRowInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfIngredients.count
    }
    //MARK: CellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as UITableViewCell!
        
        let ingredient = listOfIngredients[indexPath.row]
        
        cell?.textLabel?.text = ingredient.name as String!
        return cell! as UITableViewCell
    }
    //MARK: DidSelectRowAtIndexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK:UnwindToAddRecipe
    @IBAction func unwindToEditRecipe(_ segue: UIStoryboardSegue) {
        
    }
    //MARK: EditingStyle
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.listOfIngredients.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    //MARK: PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue ,sender: Any?){
        if segue.identifier == "AddIngredientsSegue"{
            let nextScene = segue.destination as? AddIngredientViewController
            nextScene?.previousSegue = "AddIngredientsSegue"
        }
        else if(segue.identifier == "backToSeeRecipeSegue"){
            let nextScene = segue.destination as? SeeRecipeViewController
            nextScene?.selectedRecipe.recipeImageViewData = dataImage
            nextScene?.selectedRecipe.recipeDescription = recipeInstructionTextView.text
            nextScene?.selectedRecipe.recipeTitle = recipeTitleLabel.text
            
        }
    }
    //MARK: DeleteSpecificIngredient
    func deleteSpecificRecipes( _ i: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ingredients")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            recipes = results as! [NSManagedObject]
            managedContext.delete(recipes[i])
            try managedContext.save()
            recipes.remove(at: i)
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
    }

    
    //MARK: UpdateFunctions
    func updateRecipe(name: String, preparation: String, image: NSData, array:[I_Ingredient]){
        
        let currentRecipe = recipes[selectedRecipe.recipeIndexPath!]
        currentRecipe.setValue(name,forKey:"name")
        currentRecipe.setValue(image, forKey: "image")
        currentRecipe.setValue(preparation, forKey: "preparation")
        
        do {
            try currentRecipe.managedObjectContext?.save()
        } catch{
            let error = error as NSError
            print(error)
        }
        updateRecipeIngredient(arrayOfIngredients: array, recipe: currentRecipe)
    }
    func updateRecipeIngredient(arrayOfIngredients: [I_Ingredient], recipe: NSManagedObject){
        
        for ingredient in arrayOfIngredients{
            
            //1
            let appDelegate =
                UIApplication.shared.delegate as! AppDelegate
            
            let managedContext = (appDelegate).persistentContainer.viewContext
            //2
            let entity = NSEntityDescription.entity(forEntityName: "RecipeIngredient", in: managedContext)
            
            let recipeIngredient = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            //3
            recipeIngredient.setValue(ingredient.id, forKey: "ingredientId")
            recipeIngredient.setValue(String(describing: recipe.objectID), forKey: "recipeId")
            
            
            //4
            do{
                try managedContext.save()
                //5
                recipeIngredients.append(recipeIngredient)
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }

        }
    }
}
