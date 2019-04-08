//
//  ViewController.swift
//  CookBook
//
//  Created by Alejandro Lopez on 9/21/16.
//  Copyright © 2016 Aleks. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var recipes = [NSManagedObject]()
    var ingredientRecipes = [NSManagedObject]()
//    let interactor = Interactor()
    
    @IBOutlet var tableView: UITableView!

    //MARK: SaveRecipeFunctions
    func saveRecipe(name: String, preparation: String, image: NSData, array: [I_Ingredient]){
        //1
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        //2
        let entity = NSEntityDescription.entity(forEntityName: "Recipes", in: managedContext)
        
        let recipe = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        //3
        recipe.setValue(name, forKey: "name")
        recipe.setValue(preparation, forKey: "preparation")
        recipe.setValue(image, forKey: "image")
        recipe.setValue("cero", forKey: "planner")
        
        //4
        do{
            try managedContext.save()
            //5
            recipes.append(recipe)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        saveRecipeIngredient(arrayOfIngredients: array, recipe: recipe)
    }
    
    func saveRecipeIngredient(arrayOfIngredients: [I_Ingredient], recipe: NSManagedObject){
        
        for ingredients in arrayOfIngredients {

        //1
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        //2
        let entity = NSEntityDescription.entity(forEntityName: "RecipeIngredient", in: managedContext)
        
        let recipeIngredient = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        //3
            recipeIngredient.setValue(ingredients.id, forKey: "ingredientId")
            recipeIngredient.setValue(String(describing: recipe.objectID), forKey: "recipeId")
        //4
        do{
            try managedContext.save()
            //5
            ingredientRecipes.append(recipeIngredient)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
    }
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        
        tableView.addSubview(self.refreshControl)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipes")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            recipes = results as! [NSManagedObject]
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        

        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let ref = UIRefreshControl()
        ref.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControl.Event.valueChanged)
        
        return ref
    }()
    
    override func viewWillAppear(_ animated: Bool) {

        self.tableView.addSubview(self.refreshControl)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipes")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            recipes = results as! [NSManagedObject]
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }

    /*----TableViewDelegate----*/
    
    //MARK: DidSelectRowAtIndexPath
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "RecipeDetailed", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue ,sender: Any?){
        if segue.identifier == "RecipeDetailed"{
            let nextScene = segue.destination as? SeeRecipeViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let recipe = recipes[(indexPath as NSIndexPath).row]
                nextScene?.selectedRecipe.recipeTitle = recipe.value(forKey: "name") as! String!
                nextScene?.selectedRecipe.recipeDescription = recipe.value(forKey: "preparation") as! String!
                nextScene?.selectedRecipe.recipeImageViewData = recipe.value(forKey: "image") as! Data!
                nextScene?.selectedRecipe.selectedId = String(describing: recipe.objectID)
                nextScene?.selectedRecipe.recipeIndexPath = (indexPath as IndexPath).row
            }
            /*
            if let destinationViewController = segue.destination as? SeeRecipeViewController {
                destinationViewController.transitioningDelegate = self
                destinationViewController.interactor = interactor // new
            }
             */
            
            
        }
    }
    //MARK: NumberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    //MARK: CellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! RecipeTableViewCell
        let recipe = recipes[indexPath.row]
        cell.recipePictureimageView.image = UIImage(named: "NoImageIcon")
        cell.titleLabel?.text = (recipe.value(forKey: "name") as? String?)!
        cell.timeLabel?.text = (recipe.value(forKey: "preparation")as? String?)!
        if(recipe.value(forKey: "image") != nil){
            cell.recipePictureimageView?.image = (UIImage(data: recipe.value(forKey: "image") as! Data!))
            cell.recipePictureimageView?.layer.cornerRadius = 50.0
        }
        else {
            cell.recipePictureimageView?.image = (#imageLiteral(resourceName: "NoImageIcon"))
        }
        return cell
    }
    //MARK: EditActions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addToPlanner = UITableViewRowAction(style: .normal, title: "                ") {action, index in
            self.sendToPlannerAction(indexPath: indexPath.row)
        }
        addToPlanner.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Send To Planner"))

        
        let delete = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "                ") {action, index in
            
            self.deleteRecipeAction(indexPath.row)

        }
        delete.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Delete"))
        return [addToPlanner,delete]
    }
    //MARK: DeleteSpecificRecipe
    func deleteSpecificRecipes( _ i: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipes")
        
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
    //MARK:UnwindToMain
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) {
        //loadView()
    }
    
    
    /*----ACTIONFUNCTIONS----*/
    
    //MARK:DeleteRecipeAction
    func deleteRecipeAction(_ i:Int){
        self.recipes.remove(at: i)
        self.deleteSpecificRecipes(i)
        self.tableView.reloadData()
    }
    
    func sendToPlannerAction(indexPath: Int){
        
        let currentRecipe = recipes[indexPath]
        currentRecipe.setValue("one", forKey: "planner")
        
        
        
        do {
            try currentRecipe.managedObjectContext?.save()
        } catch{
            let error = error as NSError
            print(error)
        }
        self.tableView.reloadData()
    }
    
    
}
/*
extension MainViewController : UIViewControllerTransitioningDelegate {
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
}


*/
