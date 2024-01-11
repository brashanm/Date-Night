//
//  TorontoButtons.swift
//  Map
//
//  Created by Brashan Mohanakumar on 2023-12-04.
//
import MapKit
import SwiftUI

struct TorontoButtons: View {
    @Binding var searchResults: [MKMapItem]
    @Binding var position: MapCameraPosition
    
    var visibleRegion: MKCoordinateRegion?
    
    var body: some View {
        HStack {
            Button {
                search(for: "cafe")
            } label: {
                Label("Cafe", systemImage: "cup.and.saucer")
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(.borderedProminent)
            
            
            Button {
                search(for: "beach")
            } label: {
                Label("Beaches", systemImage: "beach.umbrella")
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                position = .region(.toronto)
            } label: {
                Label("Toronto", systemImage: "building.2.crop.circle")
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                position = .region(.harbour)
            } label: {
                Label("Lake Ontario", systemImage: "water.waves")
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(.borderedProminent)
        }
        .labelStyle(.iconOnly)
        .padding(.top)
    }
    
    func search(for query: String) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        
        guard let region = visibleRegion else { return }
        request.region = region
        
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
        }
    }
}

#Preview {
    ContentView()
}
