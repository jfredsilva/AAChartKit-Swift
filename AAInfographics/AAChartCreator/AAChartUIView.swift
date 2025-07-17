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
    static let tooltipEvent = PassthroughSubject<(Int, String?), Never>()
    static let openTooltipEvent = PassthroughSubject<Int, Never>()
}

@available(iOS 13.0, macOS 10.15, *)
public struct AAChartUIView : UIViewRepresentable {
    
    public enum ChartEvents: String {
        case zoom
    }
    
    public static var zoomEventPublisher: PassthroughSubject<Void, Never> {
        AAChartEventsPublisher.zoomEvent
    }
    
    public static var tooltipEventPublisher: PassthroughSubject<(Int, String?), Never> {
        AAChartEventsPublisher.tooltipEvent
    }
    
    public static var openTooltipEventPublisher: PassthroughSubject<Int, Never> {
        AAChartEventsPublisher.openTooltipEvent
    }
    
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
    }
    
    //-- MARK: coordinator
    
    public func makeCoordinator() -> AAChartCoordinator {
        AAChartCoordinator(self)
    }
}



@available(iOS 13.0, macOS 10.15, *)
extension AAChartUIView {

    public class AAChartCoordinator : NSObject, AAChartViewDelegate, WKScriptMessageHandler {
        
        let parent: AAChartUIView
        
        private var listeners = [AnyCancellable]()
        
        public init(_ parent: AAChartUIView) {
            self.parent = parent
            
            super.init()
            self.listeners.append(AAChartUIView.openTooltipEventPublisher
                .receive(on: RunLoop.main).sink {
                    self.safeEvaluate(javascript: "aaGlobalChart.series[0].points[\($0)].onMouseOver();")
                })
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
            guard let selectedIndex = Int(clickEventMessage.index?.description ?? "") else { return }
            
            AAChartUIView.tooltipEventPublisher.send((selectedIndex, clickEventMessage.name))
        }
        
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == ChartEvents.zoom.rawValue {
                AAChartEventsPublisher.zoomEvent.send()
            }
        }
        
        public func safeEvaluate(javascript: String) {
            self.chartView.evaluateJavaScript(javascript) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                }
            }
        }
    }
}
