//
//  AAChartUIView.swift
//  AAInfographics
//
//  Created by Fred Silva on 09/05/2024.
//  Copyright © 2024 An An. All rights reserved.
//

import Combine
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
fileprivate enum AAChartEventsPublisher {
    static let zoomEvent = PassthroughSubject<Void, Never>()
}

@available(iOS 13.0, macOS 10.15, *)
public struct AAChartUIView : UIViewRepresentable {
    
    public enum ChartEvents: String {
        case zoom
    }
    
    public static var zoomEventPublisher: PassthroughSubject<Void, Never> {
        AAChartEventsPublisher.zoomEvent
    }
    
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
        
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: ChartEvents.zoom.rawValue)
        coordinator.chartView.configuration.userContentController = userContentController
        
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

    public class AAChartCoordinator : NSObject, AAChartViewDelegate, WKScriptMessageHandler {
        
        let parent: AAChartUIView
        @Binding var selectedIndex: Int?
        
        public init(_ parent: AAChartUIView, selectedIndex: Binding<Int?>) {
            self.parent = parent
            _selectedIndex = selectedIndex
        }
        
        lazy var chartView: AAChartView = {
            let view = AAChartView()
            view.delegate = self
            view.isClearBackgroundColor = true
            view.isScrollEnabled = false
            view.aa_drawChartWithChartOptions(parent.options)
            
            view.configuration.userContentController.add(AALeakAvoider.init(delegate: self), name: ChartEvents.zoom.rawValue)
            
            return view
        }()
        
        public func aaChartView(_ aaChartView: AAChartView, clickEventMessage: AAClickEventMessageModel) {
            self.selectedIndex = Int(clickEventMessage.index?.description ?? "")
        }
        
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == ChartEvents.zoom.rawValue {
                AAChartEventsPublisher.zoomEvent.send()
            }
        }
    }
}
