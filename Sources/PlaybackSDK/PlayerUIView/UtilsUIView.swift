//
//  SwiftUIView.swift
//  
//
//  Created by Franco Driansetti on 27/02/2024.
//

import SwiftUI

internal struct ErrorUIView: View {
    let errorMessage: String
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
                .font(.system(size: 32))
                .padding(.bottom, 8)
            
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .padding()
    }
}

#Preview {
    ErrorUIView(errorMessage: "Error message")
}
