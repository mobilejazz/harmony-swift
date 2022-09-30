//
//  SplashView.swift
//  Harmony_Example
//
//  Created by Joan Martin on 25/7/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(red: 0, green: 190.0/256.0, blue: 176.0/256.0)
                .ignoresSafeArea()
            VStack {
                Text("Splash")
                    .foregroundColor(.white)
                    .font(.system(size: 32, weight: .bold))
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            }

        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
