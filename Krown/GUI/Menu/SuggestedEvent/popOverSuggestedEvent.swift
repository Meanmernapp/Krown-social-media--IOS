//
//  popOverSuggestedEvent.swift
//  Krown
//
//  Created by Anders Teglgaard on 22/02/2018.
//  Copyright © 2018 KrownUnity. All rights reserved.
//

import UIKit
import Koloda

class popOverSuggestedEvent: UIViewController {

    @IBAction func backgroundBtn(_ sender: Any) {
        dismissNavigationController()
    }
    @IBOutlet weak var kolodaView: KolodaView!
    var numberOfCards: Int = 1
    var menuSuggestedEventCard = MenuSuggestedEventCard()
    var event: EventObject!

    func dismissNavigationController() {
        // Dismiss navigation controller
        navigationController?.popViewController(animated: false)
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false

        // Setup of KolodaView
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.isHidden = true

    }

    override func viewDidAppear(_ animated: Bool) {
        // This just clears the current card index and reloads the view so the button can be clicked more than once
        kolodaView.resetCurrentCardIndex()
        kolodaView.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

}
extension popOverSuggestedEvent: KolodaViewDataSource {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        // Hides the view so it is possible to click again on the UI Below
        kolodaView.isHidden = true
        dismissNavigationController()
    }

    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return numberOfCards
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }

}
extension popOverSuggestedEvent: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        menuSuggestedEventCard = AppStoryboard.loadMenuSuggestedEventCard()
        menuSuggestedEventCard.setEvent(event: event)
        menuSuggestedEventCard.view.layer.cornerRadius = 20
        menuSuggestedEventCard.contentView.layer.cornerRadius = 20
        menuSuggestedEventCard.tableView.layer.cornerRadius = 20
        // TODO: Delete line below if it does not create errors
        // koloda.addSubview(menuSuggestedEventCard.view)
        /*addChildViewController(menuSuggestedEventCard)
        menuSuggestedEventCard.didMove(toParentViewController: self)
        menuSuggestedEventCard.view.translatesAutoresizingMaskIntoConstraints = false
        */

        return menuSuggestedEventCard.view
    }
}
