//
//  TestSwiftUIView.swift
//  Krown
//
//  Created by Ivan Kodrnja on 19.09.2021..
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI

struct TestSwiftUIView: View {
    var body: some View {
        
        VStack{
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .font(.custom("Avenir-LightOblique", fixedSize: 18))
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .font(.custom("AvenirNext-BoldItalic", fixedSize: 24))
        }
    }
}

struct TestSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        TestSwiftUIView()
    }
}
