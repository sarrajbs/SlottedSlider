//
//  SlottedSlider.swift
//
//
//  Created by Sarah JEMAIEL on 09/07/2021.
//

import SwiftUI

public struct SlottedSlider<V>: View where V : BinaryFloatingPoint {

    // MARK: - Value
    // MARK: Private
    @Binding private var value: V
    private let bounds: ClosedRange<V>

    private let sizeThumb: CGFloat = 22
    private let lineWidth: CGFloat = 2

    @State private var ratio: CGFloat   = 0
    @State private var startX: CGFloat? = nil

    private let heightTrack: CGFloat = 4.0
    private let slotNumber: Int
    private let onEditing: (Bool) -> Void
    
    // MARK: - preferred Colors
    var trackBgColor = Color(red: 241/255, green: 110/255, blue: 0).opacity(0.4)
    var trackColor = Color(red: 241/255, green: 110/255, blue: 0)

    // MARK: - Initializer
    public init(value: Binding<V>, in bounds: ClosedRange<V>, slotNumber: Int = 0, onEditingChanged: @escaping (Bool) -> Void) {
        _value  = value
    
        self.bounds = bounds
        self.slotNumber = slotNumber
        self.onEditing = onEditingChanged
    }


    // MARK: - View
    // MARK: Public
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: heightTrack*0.5)
                    .foregroundColor(trackBgColor)
                    .frame(height: heightTrack)
            
                // Moving track
                RoundedRectangle(cornerRadius: heightTrack*0.5)
                    .foregroundColor(trackColor)
                    .frame(width: (proxy.size.width-sizeThumb) * ratio, height: heightTrack)
                
                // slotted points
                if slotNumber > 1 {
                    ForEach(1..<slotNumber, id: \.self) {
                        if $0 != slotNumber-1 {
                            let slotPadding = self.slotXPosition(value: $0, width: proxy.size.width)
                            Circle()
                                .fill(slotColor(width: proxy.size.width, slotPadding: slotPadding))
                                .frame(width: heightTrack, height: heightTrack)
                                .padding(.leading, slotPadding)
                        }
                    }
                }
                
                // Thumb
                Circle()
                    .foregroundColor(trackColor)
                    .frame(width: sizeThumb, height: sizeThumb)
                    .padding(.leading, (proxy.size.width-sizeThumb) * ratio)
                    .gesture(DragGesture(minimumDistance: 0)
                                .onChanged({ updateStatus(value: $0, proxy: proxy) })
                                .onEnded { _ in
                                    onEditing(true)
                                    startX = nil
                                })
            }
            .frame(height: sizeThumb)
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                                    .onChanged({ update(value: $0, proxy: proxy) }))
            .onAppear {
                ratio = min(1, max(0,CGFloat(value / bounds.upperBound)))
            }
        }
    }

       
    // MARK: - Function
    // MARK: Private
    private func updateStatus(value: DragGesture.Value, proxy: GeometryProxy) {
        guard startX == nil else { return }
    
        let delta = value.startLocation.x - (proxy.size.width - sizeThumb) * ratio

        startX = (sizeThumb < value.startLocation.x && 0 < delta) ? delta : value.startLocation.x
    }

    private func update(value: DragGesture.Value, proxy: GeometryProxy) {
        guard let x = startX else { return }

        startX = min(sizeThumb, max(0, x))
    
        var point = value.location.x - x
        let delta = proxy.size.width - sizeThumb
    
        // Check the boundary
        if point < 0 {
            startX = value.location.x
            point = 0
        
        } else if delta < point {
            startX = value.location.x - delta
            point = delta
        }

        self.ratio =  point / delta

        self.value = V(bounds.upperBound) * V(ratio)
        
    }
    
    // MARK: - Slots methods
    private func slotXPosition(value: Int,
                          width: CGFloat) -> CGFloat {

        let padding = (width/CGFloat(self.slotNumber)) * CGFloat(value)

        return padding + (sizeThumb*0.5)
    }
    
    private func slotColor(width: CGFloat,
                            slotPadding: CGFloat) -> Color {
        
        return (width-sizeThumb) * ratio < slotPadding ? trackColor : Color.white
    }
}
