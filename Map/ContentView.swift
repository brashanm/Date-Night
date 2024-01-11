//
//  ContentView.swift
//  Map
//
//  Created by Brashan Mohanakumar on 2023-12-04.
//
//
import os
import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static let parking: CLLocationCoordinate2D = (CLLocationCoordinate2D(latitude: 43.644057891091336, longitude: -79.37691923578534))
}

extension MKCoordinateRegion {
    static let toronto = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    static let harbour = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6412, longitude: -79.3762),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
}

@MainActor class LocationsHandler: ObservableObject {
    
    static let shared = LocationsHandler()
    public let manager: CLLocationManager

    init() {
        self.manager = CLLocationManager()
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
    }
}

struct ContentView: View {
    let logger = Logger(subsystem: "net.appsird.multimap", category: "Demo")
    
    @ObservedObject var locationsHandler = LocationsHandler.shared

    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?
    @State private var route: MKRoute?
    
    
    var body: some View {
        
        Map(position: $position, selection: $selectedResult){
                        
            ForEach(searchResults, id: \.self) {result in
                Marker(item: result)
            }
            .annotationTitles(.hidden)
            
            if let route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }

            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic))
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                VStack(spacing:0) {
                    if let selectedResult {
                        ItemInfoView(selectedResult: selectedResult, route: route)
                            .frame(height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top, .horizontal])
                    }
                    TorontoButtons(searchResults: $searchResults, position: $position, visibleRegion: visibleRegion)
                        .padding(.top)
                }
                Spacer()
            }
            .background(.thinMaterial)
        }
        .onChange(of: searchResults) {
            withAnimation{
                position = .automatic
           }
        }
        .onChange(of: selectedResult) {
            getDirections()
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
    
    func getDirections() {
        route = nil
        guard let selectedResult else { return }
        
        let location = locationsHandler.manager.location
        guard let coordinate = location?.coordinate else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        request.destination = selectedResult
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
}


#Preview {
    ContentView()
}

