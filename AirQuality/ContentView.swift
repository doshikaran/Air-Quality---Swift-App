//
//  ContentView.swift
//  AirQuality
//
//  Created by Karan Doshi on 10/1/23.
//

import SwiftUI
import MapKit
import XCAAQI

struct ContentView: View {
    
    @State var vm = ViewModel()
    
    var body: some View {
        Map(position: $vm.position, selection: $vm.selection) {
            ForEach(vm.annotations) {
                aqi in Annotation(aqi.aqiDisplay, coordinate: aqi.coordinate) {
                    CircleView(aqi:aqi, isSelected: aqi == vm.selection)
                }
                .tag(aqi)
                .annotationTitles(.hidden)
            }
            Marker("My Location", coordinate: vm.currentLocation!)
        }
        .mapStyle(.hybrid(
            elevation: .flat, pointsOfInterest: .all, showsTraffic: false
        ))
        .mapControls{
            MapUserLocationButton()
            MapCompass()
        }
        .sheet(isPresented: .constant(true)) {
            ScrollView {
                VStack {
                    if let selection = vm.selection {
                        selectedAQIView(aqi: selection)
                    } else {
                        if vm.locationStatus == .requestingAQIConditions {
                            ProgressView("Requesting current Air Quality")
                        }
                        if vm.locationStatus == .requstingLocation {
                            ProgressView("Requesting current Location")
                        }
                        if case let .locationNotAuthorized(text) = vm.locationStatus {
                            Text(text)
                        }
                        if case let .error(text) = vm.locationStatus {
                            Text(text)
                        }
                    }
                }
                
            }
            .padding()
            .safeAreaPadding(.top)
            .presentationDetents([.height(20), .height(170)], selection: $vm.presentationDetent)
            .presentationBackground(.ultraThinMaterial)
            .presentationBackgroundInteraction(.enabled(upThrough: .height(170)))
            .interactiveDismissDisabled()
        }
        .onChange(of: vm.selection) { oldValue,
                newValue in
            if oldValue ==  nil && newValue != nil {
                vm.presentationDetent = .height(170)
            }
        }
        .navigationTitle("Air Quality Around Me")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        
    }
    
    func selectedAQIView(aqi: AQIResponse) -> some View {
        HStack(spacing: 20) {
            CircleView(aqi: aqi, size:CGSize(width: 50, height: 50))
            VStack(alignment: .leading) {
                Text("Coordinate: \(aqi.coordinate.latitude),\(aqi.coordinate.longitude) ")
                Text(aqi.category)
                Text("Dominant Pollutant: \(aqi.dominantPollutant)")
                Text(aqi.displayName)
            }
        }
        .padding(.top)
        .padding(.horizontal)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
    
    @ViewBuilder
    var locationFormView: some View {
        Text("Current Air Quality around a coordinate:")
            .font(.headline)
            .padding(.bottom,10)
        HStack {
            Text("Lat")
            TextField("Enter your Latitude", value: $vm.lat, format: .number)
            Text("Long")
            TextField("Enter your Longitude", value: $vm.long, format: .number)
        }
        .keyboardType(.decimalPad)
        .textFieldStyle(.roundedBorder)
        .padding(.bottom, 10)
        
        HStack {
            Button("Use Current Location") {
                vm.lat = vm.currentLocation?.latitude ?? 0
                vm.long = vm.currentLocation?.longitude ?? 0
                Task {
                    await vm.handleCoordinateChange(.init(latitude: vm.lat, longitude: vm.long))
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Refresh") {
                Task {
                    await vm.handleCoordinateChange(.init(latitude: vm.lat, longitude: vm.long))
                }
            }.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
