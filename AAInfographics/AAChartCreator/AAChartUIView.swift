//
//  AAChartUIView.swift
//  AAInfographics
//
//  Created by Fred Silva on 09/05/2024.
//  Copyright © 2024 An An. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, macOS 10.15, *)
public struct AAChartUIView : UIViewRepresentable {
    
    private var model: AAChartModel
    private var options: AAOptions?
    
    public init(model: AAChartModel, options: AAOptions? = nil) {
        self.options = options
        self.model = model
    }
    
    public func makeUIView(context: Context) -> UIView {
        let coordinator = context.coordinator
        
        if let options = options {
            coordinator.chartView.aa_drawChartWithChartOptions(options)
        } else {
            coordinator.chartView.aa_drawChartWithChartModel(self.model)
        }
        
        return coordinator.chartView
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    //-- MARK: coordinator
    public func makeCoordinator() -> AAChartCoordinator {
        AAChartCoordinator(self)
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension AAChartUIView {
    
    public class AAChartCoordinator : NSObject {
        
        let parent: AAChartUIView
        
        lazy var chartView: AAChartView = {
            let view = AAChartView()
            view.isClearBackgroundColor = true
            view.isScrollEnabled = false
            view.aa_drawChartWithChartModel(parent.model)
            return view
        }()
        
        init(_ parent: AAChartUIView) {
            self.parent = parent
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
#Preview {
    let model = AAChartModel()
        .chartType(.spline)
        .markerSymbolStyle(.borderBlank)
        .markerRadius(6)
        .categories(["Java", "Swift", "Python", "Ruby", "PHP", "Go","C", "C#", "C++", "Perl", "R", "MATLAB", "SQL"])
        .animationType(.swingFromTo)
        .series([
            AASeriesElement()
                .name("Tokyo")
                .data([50, 320, 230, 370, 230, 400,])
            ,
            AASeriesElement()
                .name("New York")
                .data([80, 390, 210, 340, 240, 350,])
            ,
            AASeriesElement()
                .name("Berlin")
                .data([100, 370, 180, 280, 260, 300,])
            ,
            AASeriesElement()
                .name("London")
                .data([130, 350, 160, 310, 250, 268,])
            ,
        ])
    return AAChartUIView(model: model)
}
