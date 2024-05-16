//
//  BitmovinPlayerViewRepresentable.swift
//  PlayBackDemo
//
//  Created by Stefano Russello on 15/05/24.
//

import Foundation
import UIKit

struct BitmovinPlayerViewRepresentable: UIViewRepresentable {
    
//    @ObservedObject var playerView: PlayerViewRep
    
//    func makeCoordinator() -> PlayerViewRep.Coordinator {
//        Coordinator(playerView)
//    }
    
    @Binding var player: Player
//    @StateObject var fullscreenHandler = BitmovinPlayerCore.FullscreenHandler()
    
    func makeUIView(context: Context) -> PlayerView {
        var playerView = PlayerView(player: player, frame: .zero)
//        playerView.fullscreenHandler = context.coordinator
        return playerView
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.player = player
    }
    
//    class Coordinator: NSObject, FullscreenHandler {
//        var isFullscreen: Bool
//        
//        func onFullscreenRequested() {
//            <#code#>
//        }
//        
//        func onFullscreenExitRequested() {
//            <#code#>
//        }
//        
//        
//    }
    
}
