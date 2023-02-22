//
//  Caret.swift
//  FieldWork
//
//  Created by iain on 16/08/2022.
//

import SwiftUI

struct Caret: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 100))
        }
        .stroke(.pink)
    }
}

struct Caret_Previews: PreviewProvider {
    static var previews: some View {
        Caret()
    }
}
