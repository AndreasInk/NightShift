//
//  View+Ext.swift
//  OnCall
//
//  Created by Andreas Ink on 9/2/23.
//

import SwiftUI

extension View {
    @ViewBuilder
    func fancyScroll() -> some View {
        if #available(iOS 17, *) {
            self
                .scrollTransition { effect, phase in
                    effect
                        .blur(radius: phase.isIdentity ? 0 : 10)
                        .opacity(phase.isIdentity ? 1 : 0)
                }
        } else {
            self
        }
    }
}
