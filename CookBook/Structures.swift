//
//  Structures.swift
//  CookBook
//
//  Created by Alejandro Lopez on 10/27/16.
//  Copyright © 2016 Aleks. All rights reserved.
//

import UIKit
//MARK:RecipeStructureClass
class recipeStructure {
    var recipeTitle:String?
    var recipeDescription : String?
    var recipeImageViewData : Data?
    var selectedId : String?
    var recipeIndexPath : Int?

}
//MARK:IngredientInterfaceClass
class I_Ingredient {
    var name:String?
    var id:String?
}

extension String{
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
