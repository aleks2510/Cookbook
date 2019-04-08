//
//  AddIngredientViewController.swift
//  CookBook
//
//  Created by Alejandro Lopez on 10/24/16.
//  Copyright © 2016 Aleks. All rights reserved.
//

import UIKit
import CoreData


class AddIngredientViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    @IBOutlet var tableView: UITableView!
    var ingredientList = [I_Ingredient]()
    var Ingredients = [NSManagedObject]()
    var arrayOfIndex = [Int]()
    var previousSegue = ""
    @IBAction func cancelButtonDidTouch(_ sender: AnyObject) {
        if(previousSegue != "AddIngredientsSegue"){
            self.performSegue(withIdentifier: "DoneSegue", sender: self)
        }
        else{
            self.performSegue(withIdentifier: "DoneEditingSegue", sender: self)
        }
        
    }
    @IBAction func addIngredientButtonDidTouch(_ sender: AnyObject) {
                viewWillAppear(true)
                let alert = UIAlertController(title: "New Ingredient", message: "Add a new Ingredient", preferredStyle: .alert)
                let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                    (action:UIAlertAction) -> Void in
                    let textField = alert.textFields!.first
                    self.saveIngredient(name: (textField!.text!).lowercased().capitalizingFirstLetter())
                    self.tableView.reloadData()
                    self.viewWillAppear(true)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                    (action: UIAlertAction) -> Void in
                })
                alert.addTextField(configurationHandler: {
                    (textField: UITextField) -> Void in
                })
                alert.addAction(saveAction)
                alert.addAction(cancelAction)
        
                present(alert,animated: true, completion: nil)
        
                viewWillAppear(true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = (appDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ingredient")
        let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do{
            let results = try managedContext.fetch(fetchRequest)
            Ingredients = results as! [NSManagedObject]
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        print(Ingredients.count)
        // Do any additional setup after loading the view.
    }
    
    //MARK:SaveIngredientsFunction
    func saveIngredient(name: String){
        //1
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        //2
        let entity = NSEntityDescription.entity(forEntityName: "Ingredient", in: managedContext)
        
        let ingredient = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        //3
        ingredient.setValue(name, forKey: "name")
        
        //4
        do{
            try managedContext.save()
            //5
            Ingredients.append(ingredient)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        
     }
    //MARK: NumberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Ingredients.count
    }
    //MARK: CellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as UITableViewCell!
        let ingredient = Ingredients[indexPath.row]
        cell?.textLabel?.text = ingredient.value(forKey: "name") as! String!
        cell?.accessoryType = .none
        return cell!
    }
    //MARK: DidSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.tableView.cellForRow(at: indexPath)?.accessoryType != .checkmark){
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            let ingr = Ingredients[indexPath.row]
            let i_Ingredient = I_Ingredient()
            let ingredientId = String(describing: ingr.objectID)
            let ingredientName = ingr.value(forKey: "name")
            i_Ingredient.id = ingredientId
            i_Ingredient.name = ingredientName as? String
            ingredientList.append(i_Ingredient)

        }
        else {
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .none 
        }
                tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DoneSegue"{
            let nextScene = segue.destination as? AddRecipeViewController
            nextScene?.ingredients = ingredientList
        }
        else if(segue.identifier == "DoneEditingSegue"){
            let nextScene = segue.destination as? EditRecipeViewController
            nextScene?.listOfIngredients = ingredientList

        }
    }
    //MARK: EditingStyle
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.Ingredients.remove(at: indexPath.row)
            deleteSpecificingredient(indexPath.row)
            self.tableView.reloadData()
            self.viewWillAppear(true)
        }
        
    }
    //MARK: DeleteSpecificRecipe
    func deleteSpecificingredient( _ i: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ingredient")
        let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let results = try managedContext.fetch(fetchRequest)
            Ingredients = results as! [NSManagedObject]
            managedContext.delete(Ingredients[i])
            try managedContext.save()
            Ingredients.remove(at: i)
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
    }
    
      
}
