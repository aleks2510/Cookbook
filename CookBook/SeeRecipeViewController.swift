//
//  SeeRecipeViewController.swift
//  CookBook
//
//  Created by Alejandro Lopez on 10/26/16.
//  Copyright © 2016 Aleks. All rights reserved.
//

import UIKit
import CoreData

class SeeRecipeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableViewHeightConstrain: NSLayoutConstraint!
    var recipeIngredients = [NSManagedObject]()
    var ingredients =  [NSManagedObject]()
    var specificIngredients = [NSManagedObject]()
    var selectedId : String = ""
    var recipeIdString = ""
    var selectedRecipe = recipeStructure()
    @IBOutlet var recipeTitleLabel: UILabel!
    @IBOutlet var recipeInstructionsLabel: UILabel!
    @IBOutlet var recipeIngredientListTableView: UITableView!
    @IBOutlet var recipeImageView: DesignableImageView!
//    var interactor : Interactor? = nil

    @IBAction func editButtonDidTouch(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "EditViewSegue", sender: self)
    }
    
    func getIngredientRecipe(name: String){
        for ingre in ingredients {
            if(String(describing: ingre.value(forKey: "name")) == name){
                if(String(describing: ingre.objectID) == selectedId ){
                    
                }
                
            }
        }
    }
    
    //MARK: DidSelectRowAtIndexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        getIngredientRecipe(name: String(describing: specificIngredients[indexPath.row].value(forKey: "name")))
    }
    
    //MARK: LoadIngredientFunctions
    func loadIngredients(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ingredient")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            ingredients = results as! [NSManagedObject]
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    func loadRecipeIngredients(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecipeIngredient")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            recipeIngredients = results as! [NSManagedObject]
            try managedContext.save()
            
            
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        

    }
    func loadSpecificIngredients(){
        selectedId = selectedRecipe.selectedId!
        let index = selectedId.index(selectedId.startIndex, offsetBy: 11)
        selectedId = selectedId.substring(from: index)
        for id in recipeIngredients{
            recipeIdString = id.value(forKey: "recipeId") as! String
            recipeIdString = recipeIdString.substring(from: index)
            if( recipeIdString == selectedId){
                
                for ingredient in ingredients{
                    var ingredientId = String(describing:ingredient.objectID)
                    ingredientId = ingredientId.substring(from: index)
                    if(ingredientId == (id.value(forKey: "ingredientId") as! String).substring(from: index)){
                        specificIngredients.append(ingredient)
                    }
                }
            }
            
            
        }
        
    }

    
    //MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        specificIngredients.removeAll()
        loadIngredients()
        loadRecipeIngredients()
        loadSpecificIngredients()
        
        self.recipeIngredientListTableView.reloadData()
        if (selectedRecipe.recipeTitle != nil){
            recipeTitleLabel.text = selectedRecipe.recipeTitle
        }
        if (selectedRecipe.recipeDescription != nil){
            recipeInstructionsLabel.text = selectedRecipe.recipeDescription
        }

        if (selectedRecipe.recipeImageViewData != nil){
            recipeImageView?.image = UIImage(data: selectedRecipe.recipeImageViewData!)
            recipeImageView?.layer.cornerRadius = 50.0
        }
        else {
            recipeImageView?.image = (#imageLiteral(resourceName: "NoImageIcon"))
        }

        /*
         If no ingredients in the recipe the TableView Will dissapear

         */
        if(specificIngredients.count == 0){
            tableViewHeightConstrain.constant = 0
        }
        self.recipeIngredientListTableView.reloadData()
    }
    
    //MARK: TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return specificIngredients.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.recipeIngredientListTableView.dequeueReusableCell(withIdentifier: "Cell") as UITableViewCell!

        
        let ingredient = specificIngredients[indexPath.row]
        cell?.textLabel?.text = ingredient.value(forKey: "name") as? String
        return cell! as UITableViewCell

    }
    
    
    //MARK: PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "EditViewSegue"){
            let nextScene = segue.destination as? EditRecipeViewController
            nextScene?.selectedRecipe = selectedRecipe
            //nextScene?.currentIngredients = specificIngredients
            

            
        }
    }
    
    //MARK: CancelButton
    @IBAction func cancelButtonDidTouch(_ sender: AnyObject) {
        performSegue(withIdentifier: "backToMainSegue", sender: self)
    }
   
    //MARK:UnwindToMain
    @IBAction func unwindToSeeRecipe(_ segue: UIStoryboardSegue) {
        loadView()
        self.recipeIngredientListTableView.reloadData()
        
    }

 
    /*
     
     @IBAction func gestureHandler(_ sender: UIPanGestureRecognizer) {
     let percentThreshold:CGFloat = 0.3
     
     //Convert y-positionto downward pull progress(percentage)
     
     let translation = sender.translation(in: view)
     let verticalMovement = translation.y / view.bounds.height
     let downwardMovement = fmax(Float(verticalMovement), 0.0)
     let downwardMovementPercent = fmin(downwardMovement, 1.0)
     let progress = CGFloat(downwardMovementPercent)
     
     guard let interactor = interactor else { return }
     
     switch sender.state {
     case .began:
     interactor.hasStarted = true
     dismiss(animated: true, completion: nil)
     case .changed:
     interactor.shouldFinish = progress > percentThreshold
     interactor.update(progress)
     case .cancelled:
     interactor.hasStarted = false
     interactor.cancel()
     case .ended:
     interactor.hasStarted = false
     interactor.shouldFinish
     ? interactor.finish()
     : interactor.cancel()
     default:
     break
     }
     
     
     
     }
     
     */
 
    
    
}
