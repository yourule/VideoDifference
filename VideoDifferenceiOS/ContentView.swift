//
//  ContentView.swift
//  VideoDifferenceiOS
//
//  Created by Frans-Jan Wind on 03/11/2020.
//

//import UIKit
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                //Video top padding
                Spacer().frame(width: geometry.size.width, height: 20)
                HStack{
                    //Video left padding
                    Spacer().frame(width: 234, height: 240)
                    //Video
                    ViewController()
                }
                
                Text("Width: \(geometry.size.width) Height: \(geometry.size.height)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
