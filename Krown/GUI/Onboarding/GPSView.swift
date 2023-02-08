//
//  GPSView.swift
//  KrownLoginScreen
//
//  Created by Rachit Prajapati on 24/10/21.
//

import SwiftUI

struct GPSView: View {
    
    @State private var isShowingAlert = false
//    @State private var isLogged = false
   
    var body: some View {
        NavigationView {
        VStack {
            Spacer(minLength: UIScreen.main.bounds.height * 19.19 / 100)
            Image("Place")
            Spacer(minLength: 74)
            
            VStack {
                Text("Enable location")
                    .foregroundColor(Color.royalPurple)
                    .font(MainFont.heavy.with(size: 24))
                Spacer(minLength: 28)
                Text("We use your location to show potential matches and suggest events in your area.")
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color.black)
                    .font(MainFont.medium.with(size: 16))
            }
            
            Spacer(minLength: 170)
            
//            NavigationLink(destination: HomeTabBarVC(), isActive: $isLogged) { EmptyView() }
            Button(action: {
                isShowingAlert = true
            }) {
                Text("Enable location")
                    .frame(width: UIScreen.main.bounds.width * 80.28 / 100, height: 23, alignment: .center)
                    .font(MainFont.medium.with(size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 40).foregroundColor(Color.royalPurple))
            }.alert(isPresented: $isShowingAlert) {
                Alert(title: Text("Show location popup"), primaryButton: .default(Text("I agree"), action: {
                    //print("Procced location")
       
//                    isLogged = true
                    
                }),
                      secondaryButton: .cancel(Text("Cancel")))
            }
            
            Spacer(minLength: 35)
                
                Button(action: {
                   
                }) {
                    Text("Not now")
                        .foregroundColor(.gray)
                        .font(MainFont.medium.with(size: 20))
                }
                
            Spacer(minLength: 40)
        }.offset(y: -62)
        .padding(.leading, UIScreen.main.bounds.width * 10.13 / 100)
        .padding(.trailing, UIScreen.main.bounds.width *  10.13 / 100)
        .frame(width: UIScreen.main.bounds.width , height:  UIScreen.main.bounds.height, alignment: .center)
        } .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

struct GPSView_Previews: PreviewProvider {
    static var previews: some View {
        GPSView()
    }
}
