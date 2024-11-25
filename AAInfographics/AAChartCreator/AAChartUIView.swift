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
    
    @State private var isTooltipOpen: Bool = false
    
    @Binding private var model: AAChartModel
    @Binding private var series: [AASeriesElement]
    @Binding private var options: AAOptions?
    @Binding private var selectedPoint: Int?
    
    public init(model: Binding<AAChartModel>, series: Binding<[AASeriesElement]>, options: Binding<AAOptions?> = .constant(nil), selectedPoint: Binding<Int?> = .constant(nil)) {
        _options = options
        _series = series
        _model = model
        _selectedPoint = selectedPoint
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
        
        let coordinator = context.coordinator

        if let options = options {
            coordinator.chartView.aa_refreshChartWholeContentWithChartOptions(options)
        } else {
            coordinator.chartView.aa_refreshChartWholeContentWithChartModel(self.model)
        }
        
        if let selectedPoint = self.selectedPoint {
            self.openTooltip(position: selectedPoint, coordinator: coordinator)
        } else if self.isTooltipOpen {
            self.closeTooltip(coordinator: coordinator)
        }
    }
    
    //-- MARK: coordinator
    
    public func makeCoordinator() -> AAChartCoordinator {
        AAChartCoordinator(self)
    }
    
    private func openTooltip(position: Int, coordinator: AAChartCoordinator) {
        self.safeEvaluate(javascript: "aaGlobalChart.series[0].points[\(position)].onMouseOver();", coordinator: coordinator)
        
        
        if self.isTooltipOpen == false {
            DispatchQueue.main.async {
                self.isTooltipOpen = true
            }
        }
    }
    
    private func closeTooltip(coordinator: AAChartCoordinator) {
        self.safeEvaluate(javascript: "aaGlobalChart.onMouseOut();", coordinator: coordinator)
            
        DispatchQueue.main.async {
            self.isTooltipOpen = false
        }
    }
    
    public func safeEvaluate(javascript: String, coordinator: AAChartCoordinator) {
        coordinator.chartView.evaluateJavaScript(javascript) { _, error in
            if let error = error {
                print("Error evaluating JavaScript: \(error.localizedDescription)")
            }
        }
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

//@available(iOS 13.0, macOS 10.15, *)
//#Preview {
//
//    let elements = [
//            AASeriesElement()
//                .name("Tokyo")
//                .data([50, 320, 230, 370, 230, 400,])
//            ,
//            AASeriesElement()
//                .name("New York")
//                .data([80, 390, 210, 340, 240, 350,])
//            ,
//            AASeriesElement()
//                .name("Berlin")
//                .data([100, 370, 180, 280, 260, 300,])
//            ,
//            AASeriesElement()
//                .name("London")
//                .data([130, 350, 160, 310, 250, 268,])
//            ,
//        ]
//
//    let model = AAChartModel()
//        .chartType(.spline)
//        .markerSymbolStyle(.borderBlank)
//        .markerRadius(6)
//        .categories(["Java", "Swift", "Python", "Ruby", "PHP", "Go","C", "C#", "C++", "Perl", "R", "MATLAB", "SQL"])
//        .animationType(.swingFromTo)
//        .series(elements)
//        
//    return AAChartUIView(model: model)
//}
