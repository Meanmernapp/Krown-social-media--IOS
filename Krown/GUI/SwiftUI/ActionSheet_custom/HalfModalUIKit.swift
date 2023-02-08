//
//  HalfModalViewUIKit.swift
//  HalfModalView
//
//  Created by Christopher Guirguis on 3/11/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
// https://www.youtube.com/watch?v=gMCjz0o7aNM

import SwiftUI



struct HalfModalViewUIKit/*<Content: View>*/ : View {
    @GestureState private var dragState = DragStateUIKit.inactive
    @State var isShown = true
    var color:Color = .white
    
    // will be used to dismiss itself
    @Environment(\.presentationMode) var presentationMode
    
    private func onDragEnded(drag: DragGesture.Value) {
        let dragThreshold = modalHeight * (2/3)
        if drag.predictedEndTranslation.height > dragThreshold || drag.translation.height > dragThreshold{
            isShown = false
        }
    }
    
    var modalHeight:CGFloat = 200
    
    
//    var content: () -> Content
    var body: some View {
        
        Color.clear
            .ignoresSafeArea()
            .opacity(0)
        
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
        }
        .onEnded(onDragEnded)
        return Group {
            ZStack {
                //Background
//                Spacer()
//                    .edgesIgnoringSafeArea(.all)
//                    .frame(width: UIScreen.main.bounds.size.width)
//                    .frame(maxHeight: UIScreen.main.bounds.size.height)
//                    .background(isShown ? Color.black.opacity( 0.5 * fraction_progressUIKit(lowerLimit: 0, upperLimit: Double(modalHeight), current: Double(dragState.translation.height), inverted: true)) : Color.clear)
//                    .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
//        .gesture(
//                        TapGesture()
//                            .onEnded { _ in
//                                UIApplication.shared.endEditing()
//                                self.isShown = false
//                        }
//                )
                
                //Foreground
                VStack{
                    Spacer()
                    ZStack{
                        color.opacity(1.0)
                            .frame(width: UIScreen.main.bounds.size.width, height:modalHeight)
                            .cornerRadius(10)
                            .shadow(radius: 5)
//                        self.content()
                        VStack{
                            
                            Button(action: {
                                //TODO: implement report functionality
                                //print("Reported")
                                self.hideModal()
                                presentationMode.wrappedValue.dismiss()
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
                                presentationMode.wrappedValue.dismiss()
                                self.hideModal()
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
                            .padding()
                            .padding(.bottom, 5)
                            .frame(width: UIScreen.main.bounds.size.width, height:modalHeight)
                            .clipped()
                    }
                    .offset(y: isShown ? ((self.dragState.isDragging && dragState.translation.height >= 1) ? dragState.translation.height : 0) : modalHeight)
                    .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                    .gesture(drag)
                    
                }
            }.edgesIgnoringSafeArea(.all)
        }
    }
    
    func hideModal(_ emptyModal:Bool = true){
        
        self.isShown = false
        UIApplication.shared.endEditing()
        
    }
}

enum DragStateUIKit {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}



func fraction_progressUIKit(lowerLimit: Double = 0, upperLimit:Double, current:Double, inverted:Bool = false) -> Double{
    var val:Double = 0
    if current >= upperLimit {
        val = 1
    } else if current <= lowerLimit {
        val = 0
    } else {
        val = (current - lowerLimit)/(upperLimit - lowerLimit)
    }
    
    if inverted {
        return (1 - val)
        
    } else {
        return val
    }
    
}
