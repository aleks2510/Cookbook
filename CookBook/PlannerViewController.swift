//
//  PlannerViewController.swift
//  CookBook
//
//  Created by alejandro Lopez on 1/18/17.
//  Copyright © 2017 Aleks. All rights reserved.
//

import UIKit
import CoreData

class PlannerViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    var recipes = [NSManagedObject]()
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        
//        self.tableView.addSubview(self.refreshControl)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = (appDelegate).persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipes")
        fetchRequest.predicate = NSPredicate(format: "planner = %@", "one")
            let results = try! managedContext.fetch(fetchRequest)
            recipes = results as! [NSManagedObject]
        
        self.tableView.reloadData()
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! PlannerRecipeTableViewCell
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
        
        let removefromPlanner = UITableViewRowAction(style: .normal, title: "                ") {action, index in
            self.removeFromPlannerAction(indexPath: indexPath.row)
            
        }
        removefromPlanner.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Remove from Planner"))
        
        let addToShoppingCart = UITableViewRowAction(style: .normal, title: "                ") {action, index in
            
            
        }
        
        addToShoppingCart.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Send To Shopping Cart"))
        return [removefromPlanner,addToShoppingCart]
    }

    //MARK: DidSelectRowAtIndexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    /*----ACTIONFUNCTIONS----*/
    
    
    func removeFromPlannerAction(indexPath: Int){
        
        let currentRecipe = recipes[indexPath]
        currentRecipe.setValue("cero", forKey: "planner")
        do {
            try currentRecipe.managedObjectContext?.save()
        } catch{
            let error = error as NSError
            print(error)
        }
        self.recipes.remove(at: indexPath)
        self.tableView.reloadData()
    }
    
    
    
    
}
