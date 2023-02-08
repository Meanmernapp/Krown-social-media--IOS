//
//  CategoryVC.swift
//  Krown
//
//  Created by Mac Mini 2020 on 18/05/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
typealias v2CB = (_ infoToReturn :[String]) ->()
class CategoryVC: UIViewController {
    
    @IBOutlet weak var tblCategory: UITableView!
    @IBOutlet weak var btnSubmit: UIButton!
    var categoryArr = ["Login", "Matches", "My Events", "Discover-People", "Discover Nearby", "Discover Events", "Profile","Chat","Others"]
    var selectCategory = Array<String>()
    var completionBlock:v2CB?
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup(){
        btnSubmit.isUserInteractionEnabled = false
        btnSubmit.backgroundColor = UIColor.darkWinterSky
        btnSubmit.layer.cornerRadius = 25
        tblCategory.reloadData()
        tblCategory.tableFooterView = UIView()
        self.tblCategory.allowsMultipleSelection = true
        self.tblCategory.allowsMultipleSelectionDuringEditing = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        guard let cb = completionBlock else {return}
        cb(selectCategory)
        dismiss(animated: true, completion: nil)
        // self.dismiss(animated: true)
    }
}

extension CategoryVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = self.categoryArr[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryArr.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark{
                cell.accessoryType = .none
                
                let index = selectCategory.firstIndex(of: self.categoryArr[indexPath.row])
                selectCategory.remove(at: index!)
                if selectCategory.count == 0 {
                    btnSubmit.isUserInteractionEnabled = false
                    btnSubmit.backgroundColor = UIColor.darkWinterSky
                }
            }
            else{
                cell.accessoryType = .checkmark
                selectCategory.append(self.categoryArr[indexPath.row])
                btnSubmit.isUserInteractionEnabled = true
                btnSubmit.backgroundColor = UIColor.royalPurple
            }
        }
        
    }
}
