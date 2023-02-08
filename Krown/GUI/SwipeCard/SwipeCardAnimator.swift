//
//  SwipeCardAnimator.swift
//  Krown
//
//  Created by Anders Teglgaard on 27/09/2017.
//  Copyright © 2017 KrownUnity. All rights reserved.
//

import Foundation
import Koloda

class BackgroundKolodaAnimator: KolodaViewAnimator {
    // This makes the card pop up animation different in the background -> Basically just adds a bit more springyness
    override func applyScaleAnimation(_ card: DraggableCardView, scale: CGSize, frame: CGRect, duration: TimeInterval, completion: AnimationCompletionBlock) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: []) {
            card.transform = CGAffineTransform(scaleX: scale.width, y: scale.height)
            card.frame = frame
        } completion: { position in
            completion?(position == .end)
        }
    }
    
}
