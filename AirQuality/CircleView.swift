//
//  CircleView.swift
//  AirQuality
//
//  Created by Karan Doshi on 10/2/23.
//

import SwiftUI
import XCAAQI

struct CircleView: View {
    
    let aqi: AQIResponse
    var isSelected: Bool = false
    var size: CGSize = .init(width: 40, height: 40)
    
    var body: some View {
        Circle()
            .stroke(Color(red:aqi.color.red, green:aqi.color.green,blue:aqi.color.blue), lineWidth: isSelected ? 3 : 2)
            .frame(width:size.width, height:size.height)
            .overlay {
                Text(aqi.aqiDisplay).foregroundStyle(.white)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            }
            .scaleEffect(isSelected ? CGSize(width: 1.25, height: 1.25) : CGSize(width: 1, height: 1))
    }
}

#Preview {
    CircleView(aqi: .init(aqiDisplay: "24", color: .init(red: 0.3, green: 0.3, blue: 0.5)), isSelected: true)
}
