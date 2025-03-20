//
//  AAChartUIView.swift
//  AAInfographics
//
//  Created by Fred Silva on 09/05/2024.
//  Copyright © 2024 An An. All rights reserved.
//

import SwiftUI
import WebKit

extension AASeriesElement: Equatable {
    public static func == (lhs: AASeriesElement, rhs: AASeriesElement) -> Bool {
        lhs.data?.count == rhs.data?.count
    }
}

extension AAOptions: Equatable {
    public static func == (lhs: AAOptions, rhs: AAOptions) -> Bool {
        lhs.series as? [AASeriesElement] == rhs.series as? [AASeriesElement]
    }
}

@available(iOS 13.0, macOS 10.15, *)
public struct AAChartUIView : UIViewRepresentable {
    
    @State private var isTooltipOpen: Bool = false
    
    @Binding private var options: AAOptions
    @Binding private var selectedIndex: Int?
    
    public init(options: Binding<AAOptions>, selectedPoint: Binding<Int?> = .constant(nil)) {
        _options = options
        _selectedIndex = selectedPoint
    }
    
    public func makeUIView(context: Context) -> UIView {
        let coordinator = context.coordinator

        coordinator.chartView.aa_drawChartWithChartOptions(options)
        
        return coordinator.chartView
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        let coordinator = context.coordinator

        coordinator.chartView.aa_refreshChartWholeContentWithChartOptions(options)
        
        if let selectedPoint = self.selectedIndex {
            self.openTooltip(position: selectedPoint, coordinator: coordinator)
        } else if self.isTooltipOpen {
            self.closeTooltip(coordinator: coordinator)
        }
    }
    
    //-- MARK: coordinator
    
    public func makeCoordinator() -> AAChartCoordinator {
        AAChartCoordinator(self, selectedIndex: $selectedIndex)
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

    public class AAChartCoordinator : NSObject, AAChartViewDelegate {
        
        let parent: AAChartUIView
        @Binding var selectedIndex: Int?
        
        public init(_ parent: AAChartUIView, selectedIndex: Binding<Int?>) {
            self.parent = parent
            _selectedIndex = selectedIndex
            
            super.init()
            
            let contentController = WKUserContentController()
            contentController.add(self, name: "chartZoom")
            
            let config = WKWebViewConfiguration()
            config.userContentController = contentController
        }
        
        lazy var chartView: AAChartView = {
            let view = AAChartView()
            view.delegate = self
            view.isClearBackgroundColor = true
            view.isScrollEnabled = false
            view.aa_drawChartWithChartOptions(parent.options)
            
            
            return view
        }()
        
        public func aaChartView(_ aaChartView: AAChartView, clickEventMessage: AAClickEventMessageModel) {
            self.selectedIndex = Int(clickEventMessage.index?.description ?? "")
        }
    }
    
    
}

@available(iOS 13.0, *)
extension AAChartUIView.AAChartCoordinator: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "chartZoom" {
            let messageBody = message.body as! [String: Any]
            let min = messageBody["min"] as? Double
            let max = messageBody["max"] as? Double
            
            print(
                    """
                    
                     🔍🔍🔍-------------------------------------------------------------------------------------------
                     Chart zoom detected!
                     message = {
                            min: \(min ?? 0),
                            max: \(max ?? 0),
                        };
                     🔍🔍🔍-------------------------------------------------------------------------------------------
                    
                    """
            )
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
