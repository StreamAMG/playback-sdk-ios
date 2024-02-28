//
//  LoadHlsStreamTutorial.swift
//  
//
//  Created by Franco Driansetti on 27/02/2024.
//

import Foundation

import SwiftUI

internal struct ContentView: View {
    let entryId = "YOUR_ENTRY_ID"
    let authorizationToken = "YOUR_AUTHORIZATION_TOKEN" // optional


    var body: some View {
        PlaybackUIView(entryId: entryId, authorizationToken: authorizationToken)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
