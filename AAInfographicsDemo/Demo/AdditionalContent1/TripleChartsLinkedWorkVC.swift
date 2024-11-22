//
//  TripleChartsLinkedWorkVC.swift
//  AAInfographicsDemo
//
//  Created by AnAn on 2024/11/22.
//  Copyright © 2024 An An. All rights reserved.
//

import UIKit
import AAInfographics

class TripleChartsLinkedWorkVC: UIViewController {
    var aaChartView1: AAChartView!
    var aaChartView2: AAChartView!
    var aaChartView3: AAChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Triple Charts Linked Work---3表联动"
        self.view.backgroundColor = .white
        
        setUpTheAAChartView1()
        setUpTheAAChartView2()
        setUpTheAAChartView3()
    }
    
    // 配置第 1 个 AAChartView
    func setUpTheAAChartView1() {
        let chartViewWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let frame = CGRect(x: 0, y: 60, width: chartViewWidth, height: screenHeight / 3)
        let aaChartView1 = AAChartView(frame: frame)
        aaChartView1.isScrollEnabled = false
        self.view.addSubview(aaChartView1)
        self.aaChartView1 = aaChartView1
        self.aaChartView1.delegate = self
        
        let aaOptions1 = AAOptions()
            .chart(AAChart()
                .type(.column))
            .title(AATitle()
                .text("Speed")
                .align(.left))
            .tooltip(AATooltip()
                .shared(true))
            .xAxis(AAXAxis()
                .crosshair(AACrosshair()
                    .color(AAColor.green)
                    .width(2)
                    .dashStyle(.longDashDot)
                    .zIndex(5)))
            .yAxis(AAYAxis()
                .title(nil))
            .series([
                JSFunctionBeforeAndAfterRenderingComposer3.configureSeriesArray()[0]
            ])
        
        aaChartView1.aa_drawChartWithChartOptions(aaOptions1)
    }
    
    // 配置第 2 个 AAChartView
    func setUpTheAAChartView2() {
        let chartViewWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let frame = CGRect(x: 0, y: screenHeight / 3 + 60, width: chartViewWidth, height: screenHeight / 3 - 60)
        let aaChartView2 = AAChartView(frame: frame)
        aaChartView2.isScrollEnabled = false
        self.view.addSubview(aaChartView2)
        self.aaChartView2 = aaChartView2
        self.aaChartView2.delegate = self
        
        let aaOptions2 = AAOptions()
            .chart(AAChart()
                .type(.column))
            .title(AATitle()
                .text("Elevation")
                .align(.left))
            .tooltip(AATooltip()
                .shared(true))
            .xAxis(AAXAxis()
                .crosshair(AACrosshair()
                    .color(AAColor.green)
                    .width(2)
                    .dashStyle(.longDashDot)
                    .zIndex(5)))
            .yAxis(AAYAxis()
                .title(nil))
            .series([
                JSFunctionBeforeAndAfterRenderingComposer3.configureSeriesArray()[1]
            ])
        
        aaChartView2.aa_drawChartWithChartOptions(aaOptions2)
    }
    
    // 配置第 3 个 AAChartView
    func setUpTheAAChartView3() {
        let chartViewWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let frame = CGRect(x: 0, y: (screenHeight / 3) * 2 + 60, width: chartViewWidth, height: screenHeight / 3 - 60)
        let aaChartView3 = AAChartView(frame: frame)
        aaChartView3.isScrollEnabled = false
        self.view.addSubview(aaChartView3)
        self.aaChartView3 = aaChartView3
        self.aaChartView3.delegate = self
        
        let aaOptions3 = AAOptions()
            .chart(AAChart()
                .type(.column))
            .title(AATitle()
                .text("Heart Rate")
                .align(.left))
            .tooltip(AATooltip()
                .shared(true))
            .xAxis(AAXAxis()
                .crosshair(AACrosshair()
                    .color(AAColor.green)
                    .width(2)
                    .dashStyle(.longDashDot)
                    .zIndex(5)))
            .yAxis(AAYAxis()
                .title(nil))
            .series([
                JSFunctionBeforeAndAfterRenderingComposer3.configureSeriesArray()[2]
            ])
        
        aaChartView3.aa_drawChartWithChartOptions(aaOptions3)
    }
    
    
    func configureSyncRefreshTooltipJSString(message: AAMoveOverEventMessageModel) -> String {
        let defaultSelectedIndex = (message.index ?? 0) as Int
        let jsFunc = """
                     function syncRefreshTooltip() {
                            const points = [];
                            const chart = aaGlobalChart;
                            const series = chart.series;
                            const length = series.length;
                                       
                            for (let i = 0; i < length; i++) {
                                const pointElement = series[i].data[\(defaultSelectedIndex)];
                                points.push(pointElement);
                            }
                            chart.xAxis[0].drawCrosshair(null, points[0]);
                            chart.tooltip.refresh(points);
                     }
                     syncRefreshTooltip();
        """
        return jsFunc
    }
}


extension TripleChartsLinkedWorkVC: AAChartViewDelegate {
    func aaChartViewDidFinishLoad(_ aaChartView: AAChartView) {
        print("🚀🚀🚀 AAChartView content did finish load!!!")
    }
    
    func aaChartView(_ aaChartView: AAChartView, moveOverEventMessage: AAMoveOverEventMessageModel) {
        let message = moveOverEventMessage
        print("📊📊📊move over event message: \(message.name ?? "")")
        let jsFuncStr = configureSyncRefreshTooltipJSString(message: message)
        if aaChartView == aaChartView1 {
            aaChartView2.evaluateJavaScript(jsFuncStr)
            aaChartView3.evaluateJavaScript(jsFuncStr)
        } else if aaChartView == aaChartView2 {
            aaChartView1.evaluateJavaScript(jsFuncStr)
            aaChartView3.evaluateJavaScript(jsFuncStr)
        } else if aaChartView == aaChartView3 {
            aaChartView1.evaluateJavaScript(jsFuncStr)
            aaChartView2.evaluateJavaScript(jsFuncStr)
        }
    }
}
