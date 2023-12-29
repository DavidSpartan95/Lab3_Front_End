//
//  MachineCard.swift
//  Lab3
//
//  Created by David Ulvan on 2023-12-23.
//

import SwiftUI

struct MachineCard: View {
    let name: String
    let error: Bool
    let action: () -> Void
    
    var body: some View {
        let screen = UIScreen.main.bounds
        let width = (screen.width * 0.8)
        let height = (width * 0.2)
        
        Button(action: {
            self.action()
        }) {
            ZStack{
                Color.white
                HStack{
                    Text(name).bold().cornerRadius(5).font(.system(size: 20))
                    Spacer()
                    if !error{
                        Text("ERROR!").bold().foregroundColor(.white).background(.red).cornerRadius(5).font(.system(size: 20))
                    } else {
                        Text("No issue").bold().foregroundColor(.white).background(.green).cornerRadius(5).font(.system(size: 20))
                    }
                }.frame(width: width*0.9)
                
            }.frame(width: width, height: height ).cornerRadius(10).shadow(radius: 10)
        }
    }
}


#Preview {
    MachineCard(name:"Machine 1",error: true){
        print("")
    }
}
