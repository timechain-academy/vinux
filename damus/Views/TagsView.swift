//
//  TagsView.swift
//  damus
//
//  Created by William Casarin on 2022-05-04.
//

import SwiftUI

struct TagsView: View {
    let tags: [[String]]

    var body: some View {
        HStack {
            ForEach(tags, id: \.self) { tag in
                if tag.count > 1 {
                    Text("\(tag[0]): \(tag[1])")
                        .font(.footnote)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
    }
}
