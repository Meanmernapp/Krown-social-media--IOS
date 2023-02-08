//
//  CustomActionSheet.swift
//  Krown
//
//  Created by Ivan Kodrnja on 23.04.2022..
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import SwiftUI

struct CustomActionSheet: View {
    @State var isShown = true
    // will be used to dismiss itself
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        
        ZStack {
                    Color.clear
                        .ignoresSafeArea()
            
        HalfModalView(isShown: $isShown, color: .clear){
            VStack{
                
                Button(action: {
                    //TODO: implement report functionality
                    //print("Reported")
                    self.hideModal()
                }){
                    Text("Report")
                        .frame(height:60)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: (UIScreen.main.bounds.width * 0.9))
                .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                .font(MainFont.medium.with(size: 20))
                .foregroundColor(.black)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                Button(action: {
                    self.hideModal()
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("Dismiss")
                        .frame(height:60)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: (UIScreen.main.bounds.width * 0.9))
                .frame(minWidth: (UIScreen.main.bounds.width * 0.7))
                .font(MainFont.medium.with(size: 20))
                .foregroundColor(.black)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
            }
            
        }
        .background(Color.clear)// end of HalfModalView
        } // end of ZStack
        .frame(maxHeight: 200)
        .border(Color.red, width: 3)
    }
        
    
    func hideModal(_ emptyModal:Bool = true){
        
        self.isShown = false
        UIApplication.shared.endEditing()
        
    }

}

struct CustomActionSheet_Previews: PreviewProvider {
    static var previews: some View {
        CustomActionSheet()
    }
}
