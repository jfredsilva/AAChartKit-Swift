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

// MARK: - Shared Chart Events
public enum ChartEvents: String {
    case zoom
}

// MARK: - iOS UIViewRepresentable
#if os(iOS)
@available(iOS 13.0, *)
public struct AAChartUIView: UIViewRepresentable {

    // MARK: - Backward Compatibility Typealias
    public typealias ChartEvents = AAInfographics.ChartEvents

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
    private let refreshOn: AnyPublisher<Void, Never>?

    public init(options: Binding<AAOptions>, selectedPoint: Binding<Int?> = .constant(nil), refreshOn: AnyPublisher<Void, Never>? = nil) {
        _options = options
        _selectedIndex = selectedPoint
        self.refreshOn = refreshOn
    }

    // The coordinator's lazy chartView already draws the initial options and
    // registers the zoom handler. A second draw here raced the page load, and
    // replacing configuration.userContentController on a live, navigating
    // web view can stall the navigation — leaving a chart that never loads.
    //
    // The refreshOn publisher repaints the canvas directly when the host's
    // data model rebuilds its options: SwiftUI does not reliably re-invoke
    // updateUIView when only a bound reference type mutates.
    public func makeUIView(context: Context) -> UIView {
        let coordinator = context.coordinator
        if let refreshOn, coordinator.refreshSubscription == nil {
            let binding = _options
            // Debounce: hosts may rebuild options several times per data event
            // (entries + visible-range updates) and bursts arrive together —
            // one repaint per settled burst is enough for a live chart.
            coordinator.refreshSubscription = refreshOn
                .debounce(for: .milliseconds(80), scheduler: RunLoop.main)
                .sink { [weak coordinator] in
                    guard let coordinator else { return }
                    coordinator.lastOptionsIdentity = ObjectIdentifier(binding.wrappedValue)
                    coordinator.chartView.aa_refreshChartWholeContentWithChartOptions(binding.wrappedValue)
                }
        }
        return coordinator.chartView
    }
    
    // SwiftUI calls updateUIView on every render pass because AAOptions is a
    // class (reference type) and SwiftUI cannot diff the binding value. Without
    // this identity guard, each call triggers a full chart redraw (JSON
    // serialization, JavaScript evaluation, plugin check) even when the options
    // haven't changed. We skip the redraw when the same AAOptions instance is
    // passed, and only refresh when a new instance is provided.
    public func updateUIView(_ uiView: UIView, context: Context) {
        let coordinator = context.coordinator
        let newIdentity = ObjectIdentifier(options)
        guard newIdentity != coordinator.lastOptionsIdentity else { return }
        coordinator.lastOptionsIdentity = newIdentity
        coordinator.chartView.aa_refreshChartWholeContentWithChartOptions(options)
    }
    
    public func makeCoordinator() -> AAChartCoordinator {
        AAChartCoordinator(self)
    }
}

@available(iOS 13.0, *)
extension AAChartUIView {

    public class AAChartCoordinator: NSObject, AAChartViewDelegate, WKScriptMessageHandler {

        let parent: AAChartUIView
        var lastOptionsIdentity: ObjectIdentifier?
        var refreshSubscription: AnyCancellable?

        private var listeners = [AnyCancellable]()
        
        public init(_ parent: AAChartUIView) {
            self.parent = parent

            super.init()
            self.listeners.append(AAChartUIView.openTooltipEventPublisher
                .receive(on: RunLoop.main).sink { [weak self] in
                    self?.safeEvaluate(javascript: "aaGlobalChart.series[0].points[\($0)].onMouseOver();")
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
#endif

// MARK: - macOS NSViewRepresentable
#if os(macOS)
@available(macOS 10.15, *)
public struct AAChartNSView: NSViewRepresentable {
    
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
    private let refreshOn: AnyPublisher<Void, Never>?

    public init(options: Binding<AAOptions>, selectedPoint: Binding<Int?> = .constant(nil), refreshOn: AnyPublisher<Void, Never>? = nil) {
        _options = options
        _selectedIndex = selectedPoint
        self.refreshOn = refreshOn
    }

    // Mirrors makeUIView: the coordinator's lazy chartView draws and wires the
    // zoom handler — no second draw, no userContentController swap mid-load.
    // refreshOn repaints the canvas directly on data-model rebuilds.
    public func makeNSView(context: Context) -> NSView {
        let coordinator = context.coordinator
        if let refreshOn, coordinator.refreshSubscription == nil {
            let binding = _options
            coordinator.refreshSubscription = refreshOn
                .debounce(for: .milliseconds(80), scheduler: RunLoop.main)
                .sink { [weak coordinator] in
                    coordinator?.chartView.aa_refreshChartWholeContentWithChartOptions(binding.wrappedValue)
                }
        }
        return coordinator.chartView
    }
    
    public func updateNSView(_ nsView: NSView, context: Context) {
        let coordinator = context.coordinator
        coordinator.chartView.aa_refreshChartWholeContentWithChartOptions(options)
    }
    
    public func makeCoordinator() -> AAChartCoordinator {
        AAChartCoordinator(self)
    }
}

@available(macOS 10.15, *)
extension AAChartNSView {

    public class AAChartCoordinator: NSObject, AAChartViewDelegate, WKScriptMessageHandler {
        
        let parent: AAChartNSView
        var refreshSubscription: AnyCancellable?

        private var listeners = [AnyCancellable]()
        
        public init(_ parent: AAChartNSView) {
            self.parent = parent

            super.init()
            self.listeners.append(AAChartNSView.openTooltipEventPublisher
                .receive(on: RunLoop.main).sink { [weak self] in
                    self?.safeEvaluate(javascript: "aaGlobalChart.series[0].points[\($0)].onMouseOver();")
                })
        }
        
        lazy var chartView: AAChartView = {
            let view = AAChartView()
            view.delegate = self
            view.isClearBackgroundColor = true
            view.aa_drawChartWithChartOptions(parent.options)
            
            view.configuration.userContentController.add(AALeakAvoider.init(delegate: self), name: ChartEvents.zoom.rawValue)
            
            return view
        }()
        
        public func aaChartView(_ aaChartView: AAChartView, clickEventMessage: AAClickEventMessageModel) {
            guard let selectedIndex = Int(clickEventMessage.index?.description ?? "") else { return }
            
            AAChartNSView.tooltipEventPublisher.send((selectedIndex, clickEventMessage.name))
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
#endif
