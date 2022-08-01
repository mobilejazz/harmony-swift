//
//  ItemListView.swift
//  Harmony_Example
//
//  Created by Joan Martin on 25/7/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ItemListView: View {
    
    @StateObject var viewState: ItemListViewState
    
    var body: some View {
        if viewState.isLoading {
            ProgressView()
                .navigationTitle("Items")
                .navigationBarTitleDisplayMode(.inline)
        } else if let error = viewState.error {
            VStack {
                Text(error.localizedDescription)
                Button("Reload") {
                    viewState.presenter.onActionReloadList()
                }
            }
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            ZStack {
                EmptyNavigationLink(destination: { item in
                    ItemDetailView(item: item)
                }, selection: $viewState.selectedItem)
                List {
                    ForEach(viewState.items, id: \.id) { item in
                        Button {
                            viewState.presenter.onActionSelected(item: item)
                        } label: {
                            ZStack {
                                Color.white
                                HStack {
                                    KFImage(item.imageURL)
                                        .resizable()
                                        .frame(width: 68, height: 68)
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.system(size: 17, weight: .bold))
                                        Text("\(item.count) units")
                                            .font(.system(size: 14, weight: .light))
                                    }
                                    Spacer()
                                    Text("\(Int(item.price))€")
                                        .font(.system(size: 23, weight: .bold))
                                        .foregroundColor(Color(red: 0, green: 190.0/256.0, blue: 176.0/256.0))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.grouped)
                .navigationTitle("Items")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button {
                        viewState.presenter.onActionReloadList()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }

                }
            }
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItemListView(viewState: ItemListViewState())
        }
    }
}
