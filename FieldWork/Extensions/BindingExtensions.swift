//
//  BindingExtensions.swift
//  FieldWork
//
//  Created by iain on 06/08/2022.
//

import Foundation
import SwiftUI

extension Binding {
    func didSet(execute: @escaping (Value) ->Void) -> Binding {
        return Binding(
            get: {
                return self.wrappedValue
            },
            set: {
                let snapshot = self.wrappedValue
                self.wrappedValue = $0
                execute(snapshot)
            }
        )
    }
}
