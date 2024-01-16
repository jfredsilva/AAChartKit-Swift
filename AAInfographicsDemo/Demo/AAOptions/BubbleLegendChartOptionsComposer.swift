//
// Created by AnAn on 2024/1/16.
// Copyright (c) 2024 An An. All rights reserved.
//

import Foundation
import AAInfographics


class BubbleLegendChartOptionsComposer {
    //Highcharts.chart('container', {
    //
    //    chart: {
    //        type: 'bubble'
    //    },
    //
    //    legend: {
    //        enabled: true,
    //        floating: true,
    //        align: 'right',
    //        y: -40,
    //        bubbleLegend: {
    //            enabled: true,
    //            borderColor: '#000000',
    //            borderWidth: 3,
    //            color: '#8bbc21',
    //            connectorColor: '#000000'
    //        }
    //    },
    //
    //    series: [{
    //        color: '#8bbc21',
    //        showInLegend: false,
    //        marker: {
    //            fillOpacity: 1,
    //            lineWidth: 3,
    //            lineColor: '#000000'
    //        },
    //        data: [
    //            { x: 95, y: 95, z: 13.8 },
    //            { x: 86.5, y: 102.9, z: 14.7 },
    //            { x: 80.8, y: 91.5, z: 15.8 },
    //            { x: 80.4, y: 102.5, z: 12 },
    //            { x: 80.3, y: 86.1, z: 11.8 },
    //            { x: 78.4, y: 70.1, z: 16.6 },
    //            { x: 74.2, y: 68.5, z: 14.5 },
    //            { x: 73.5, y: 83.1, z: 10 },
    //            { x: 71, y: 93.2, z: 24.7 },
    //            { x: 69.2, y: 57.6, z: 10.4 },
    //            { x: 68.6, y: 20, z: 16 },
    //            { x: 65.5, y: 126.4, z: 35.3 },
    //            { x: 65.4, y: 50.8, z: 28.5 },
    //            { x: 63.4, y: 51.8, z: 15.4 },
    //            { x: 64, y: 82.9, z: 31.3 }
    //        ]
    //    }]
    //
    //});

    class func bubbleLegendChart() -> AAOptions {
        let aaChart = AAChart()
            .type(.bubble)

        let aaTitle = AATitle()
            .text("Highcharts Bubble Chart With Legend")

        let aaLegend = AALegend()
            .enabled(true)
            .floating(true)
            .align(.right)
            .y(-40)
            .bubbleLegend(AABubbleLegend()
                .enabled(true)
                .borderColor("#000000")
                .borderWidth(3)
                .color("#8bbc21")
                .connectorColor("#000000"))

        let aaSeriesElement = AASeriesElement()
            .color("#8bbc21")
            .showInLegend(false)
            .marker(AAMarker()
//                .fillOpacity(1.0)
                .lineWidth(3)
                .lineColor("#000000"))
            .data([
                [95, 95, 13.8],
                [86.5, 102.9, 14.7],
                [80.8, 91.5, 15.8],
                [80.4, 102.5, 12],
                [80.3, 86.1, 11.8],
                [78.4, 70.1, 16.6],
                [74.2, 68.5, 14.5],
                [73.5, 83.1, 10],
                [71, 93.2, 24.7],
                [69.2, 57.6, 10.4],
                [68.6, 20, 16],
                [65.5, 126.4, 35.3],
                [65.4, 50.8, 28.5],
                [63.4, 51.8, 15.4],
                [64, 82.9, 31.3]
            ])

        let aaOptions = AAOptions()
            .chart(aaChart)
            .title(aaTitle)
            .legend(aaLegend)
            .series([aaSeriesElement])

        return aaOptions
    }


    //Highcharts.chart('container', {
    //
    //    chart: {
    //        type: 'bubble'
    //    },
    //
    //    legend: {
    //        enabled: true,
    //        y: -40,
    //        bubbleLegend: {
    //            enabled: true,
    //            borderWidth: 2,
    //            ranges: [{
    //                borderColor: '#1aadce',
    //                connectorColor: '#1aadce'
    //            }, {
    //                borderColor: '#0d233a',
    //                connectorColor: '#0d233a'
    //            }, {
    //                borderColor: '#f28f43',
    //                connectorColor: '#f28f43'
    //            }]
    //        }
    //    },
    //
    //    series: [{
    //        data: [
    //            { x: 95, y: 95, z: 13.8 },
    //            { x: 86.5, y: 102.9, z: 14.7 },
    //            { x: 80.8, y: 91.5, z: 15.8 }
    //        ]
    //    }, {
    //        data: [
    //            { x: 74.2, y: 68.5, z: 14.5 },
    //            { x: 73.5, y: 83.1, z: 10 },
    //            { x: 71, y: 93.2, z: 24.7 },
    //            { x: 69.2, y: 57.6, z: 10.4 }
    //        ]
    //    }, {
    //        data: [
    //            { x: 80.4, y: 102.5, z: 12 },
    //            { x: 80.3, y: 86.1, z: 11.8 },
    //            { x: 78.4, y: 70.1, z: 16.6 }
    //        ]
    //    }, {
    //        data: [
    //            { x: 68.6, y: 20, z: 16 },
    //            { x: 65.5, y: 126.4, z: 35.3 },
    //            { x: 65.4, y: 50.8, z: 28.5 },
    //            { x: 63.4, y: 51.8, z: 15.4 },
    //            { x: 64, y: 82.9, z: 31.3 }
    //        ]
    //    }]
    //
    //});

    class func customBubbleLegendChart() -> AAOptions {
        let aaChart = AAChart()
            .type(.bubble)

        let aaTitle = AATitle()
            .text("Highcharts Bubble Chart With Custom Legend")

        let aaLegend = AALegend()
            .enabled(true)
            .y(-40)
            .bubbleLegend(AABubbleLegend()
                .enabled(true)
                .borderWidth(2)
                .ranges([
                    AARange()
                        .borderColor("#1aadce")
                        .connectorColor("#1aadce"),
                    AARange()
                        .borderColor("#0d233a")
                        .connectorColor("#0d233a"),
                    AARange()
                        .borderColor("#f28f43")
                        .connectorColor("#f28f43"),
                ]))

        let aaSeriesElement1 = AASeriesElement()
            .data([
                [95, 95, 13.8],
                [86.5, 102.9, 14.7],
                [80.8, 91.5, 15.8]
            ])

        let aaSeriesElement2 = AASeriesElement()
            .data([
                [74.2, 68.5, 14.5],
                [73.5, 83.1, 10],
                [71, 93.2, 24.7],
                [69.2, 57.6, 10.4]
            ])

        let aaSeriesElement3 = AASeriesElement()
            .data([
                [80.4, 102.5, 12],
                [80.3, 86.1, 11.8],
                [78.4, 70.1, 16.6]
            ])

        let aaSeriesElement4 = AASeriesElement()
            .data([
                [68.6, 20, 16],
                [65.5, 126.4, 35.3],
                [65.4, 50.8, 28.5],
                [63.4, 51.8, 15.4],
                [64, 82.9, 31.3]
            ])

        let aaOptions = AAOptions()
            .chart(aaChart)
            .title(aaTitle)
            .legend(aaLegend)
            .series([
                aaSeriesElement1,
                aaSeriesElement2,
                aaSeriesElement3,
                aaSeriesElement4,
            ])

        return aaOptions
        }
}
