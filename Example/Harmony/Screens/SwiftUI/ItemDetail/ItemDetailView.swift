//
//  ItemDetailView.swift
//  Harmony_Example
//
//  Created by Joan Martin on 25/7/22.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ItemDetailView: View {
    var item: Item
    
    var body: some View {
        VStack {
            KFImage(item.imageURL)
                .resizable()
                .frame(height: 180)
            Text(item.name)
                .font(.system(size: 24, weight: .bold))
            Text("\(item.count) units")
                .font(.system(size: 20, weight: .light))
            Spacer()
            Text("\(Int(item.price))€")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(Color(red: 0, green: 190.0/256.0, blue: 176.0/256.0))
            Spacer()
        }.navigationTitle(item.name)
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItemDetailView(item: Item(id: "1", name: "Macbook Pro", price: 1234.56, count: 12, imageURL: URL(string: "(https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/mbp-spacegray-select-202206_GEO_ES?wid=904&hei=840&fmt=jpeg&qlt=90&.v=1654014007395")))
        }
    }
}
