//
//  InfoView.swift
//  FieldWork
//
//  Created by iain on 17/07/2022.
//

import SwiftUI

struct InfoView: View {
    var name: String? = nil
    
    var body: some View {
        if (name == nil) {
            Text("Select a recording")
                .font(.title)
                .frame(maxWidth:.infinity,
                       minHeight:0,
                       idealHeight:250,
                       maxHeight:.infinity)
                .background(Color.blue)
        } else {
            let name = name!
            Text("Info: \(name)")
                .frame(maxWidth:.infinity,
                       minHeight:0,
                       idealHeight:250,
                       maxHeight:.infinity)
                .background(Color.blue)
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InfoView(name: nil)
            InfoView(name: "Test Recording")
        }
    }
}
