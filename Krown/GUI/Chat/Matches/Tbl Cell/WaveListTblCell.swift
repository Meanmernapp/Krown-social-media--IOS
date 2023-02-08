//
//  WaveListTblCell.swift
//  Krown
//
//  Created by macOS on 11/02/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit
/*protocol CollectionViewCellDelegate: class {
    func collectionView(collectionviewcell: InterestCollCell?, index: Int, didTappedInTableViewCell: WaveListTblCell)
    // other delegate methods that you can define to perform action in viewcontroller
}*/
class WaveListTblCell: UITableViewCell {//}, UICollectionViewDelegate, UICollectionViewDataSource  {
   // weak var cellDelegate: CollectionViewCellDelegate?
    @IBOutlet weak var imgUser: UIImageView! {
        didSet {
            imgUser.layer.cornerRadius = 40
            imgUser.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var btnCheckMark: UIButton!
    @IBOutlet weak var interestCollection: UICollectionView!
    @IBOutlet weak var lbl_user_name: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var viewBg: UIView! {
        didSet {
            viewBg.clipsToBounds = false
            viewBg.layer.cornerRadius = 13
            viewBg.layer.shadowColor = UIColor.lightGray.cgColor
            viewBg.layer.shadowOpacity = 1
            viewBg.layer.shadowRadius = 5
            viewBg.layer.shadowOffset = CGSize(width: -3, height: 3)
            viewBg.layer.bounds = viewBg.bounds
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Comment if you set Datasource and delegate in .xib
       // self.interestCollection.dataSource = self
       // self.interestCollection.delegate = self
        
        // Register the xib for collection view cell
      //  let cellNib = UINib(nibName: "InterestCollCell", bundle: nil)
      //  self.interestCollection.register(cellNib, forCellWithReuseIdentifier: "cell")
      //  self.interestCollection.dataSource = self
       // self.interestCollection.delegate = self
        self.interestCollection.register(UINib.init(nibName: "InterestCollCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 /*   func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! InterestCollCell
        cell.lblName.text = "sfsfsfs"
      //  cell.lblName.tintColor = .black
    //    cell.lblName.textColor = .black
      //  cell.lblName.layer.cornerRadius = 10
       // cell.backgroundColor = .clear
        return cell
    }*/
}

extension WaveListTblCell {

    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {

        interestCollection.delegate = dataSourceDelegate
        interestCollection.dataSource = dataSourceDelegate
        interestCollection.tag = row
        interestCollection.setContentOffset(interestCollection.contentOffset, animated:false) // Stops collection view if it was scrolling.
        interestCollection.reloadData()
    }

    var collectionViewOffset: CGFloat {
        set { interestCollection.contentOffset.x = newValue }
        get { return interestCollection.contentOffset.x }
    }
}


