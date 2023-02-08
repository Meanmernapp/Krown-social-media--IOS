//
//  LaunchScreenNew.swift
//  Krown
//
//  Created by Akshay Devkate on 03/11/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI

struct LaunchScreenSwiftUI: View {
    var body: some View {
       
            
            // Using ZStack https://stackoverflow.com/questions/59102889/how-to-add-background-image-to-complete-view-in-swiftui
            
            ZStack{
                Image("LaunchScreen")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width,
                                              height: UIScreen.main.bounds.height+1, alignment: .top)
                    .offset(x: 0, y: -1)
                    .edgesIgnoringSafeArea(.all)
        }
    }
}

struct LaunchScreenNew_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenSwiftUI()
    }
}
