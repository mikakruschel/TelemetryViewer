//
//  LineChartView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.09.20.
//

import SwiftUI

struct LineChart: Shape {
    var data: ChartDataSet
    var shouldCloseShape: Bool
    
    func path(in rect: CGRect) -> Path {
        let numberOfTicks = data.data.count
        
        let xWidthConstant = rect.size.width / CGFloat(numberOfTicks - 1)
        let yHeightConstant = rect.size.height / CGFloat(data.highestValue)
        
        let bottomRight = CGPoint(x: rect.size.width, y: rect.size.height)
        let bottomleft = CGPoint(x: 0, y: rect.size.height)
        
        let pathPoints: [CGPoint] = {
            var pathPoints: [CGPoint] = []
            for (index, data) in self.data.data.enumerated() {
                let dayOffset = xWidthConstant * CGFloat(index)
                let valueOffset = CGFloat(data.yAxisValue) * yHeightConstant
                
                pathPoints.append(CGPoint(x: dayOffset, y: rect.size.height - valueOffset))
            }
            return pathPoints
        }()
        
        var path = Path()
        
        if shouldCloseShape {
            path.move(to: bottomleft)
        } else {
            if let firstPoint = pathPoints.first {
                path.move(to: firstPoint)
            }
        }
        
        for point in pathPoints {
            path.addLine(to: point)
        }
        
        if shouldCloseShape {
            path.addLine(to: bottomRight)
            path.addLine(to: bottomleft)
            
            if let firstPoint = pathPoints.first {
                path.addLine(to: firstPoint)
            }
        }
        
        return path
    }
}

struct LineChartView: View {
    var insightDataID: UUID
    @EnvironmentObject var api: APIRepresentative
    private var insightData: InsightDataTransferObject? { api.insightData[insightDataID] }
    private var chartDataSet: ChartDataSet? {
        guard let insightData = insightData else { return nil }
        return try? ChartDataSet(data: insightData.data)
    }
    
    var body: some View {
        if let chartDataSet = chartDataSet {
            VStack {
                HStack {
                    ZStack {
                        LineChart(data: chartDataSet, shouldCloseShape: true).fill(
                            LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.0)]), startPoint: .top, endPoint: .bottom)
                        )
                        LineChart(data: chartDataSet, shouldCloseShape: false).stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }
                    

                    GeometryReader { reader in
                        let lastValue = chartDataSet.data.last!.yAxisValue
                        let percentage = 1 - (lastValue / (chartDataSet.highestValue - chartDataSet.lowestValue))


                        ZStack {
                            if lastValue != chartDataSet.lowestValue {
                                Text(chartDataSet.lowestValue.stringValue)
                                    .position(x: 10, y: reader.size.height)
                            }

                            if lastValue != chartDataSet.highestValue {
                                Text(chartDataSet.highestValue.stringValue)
                                    .position(x: 10, y: 0)
                            }
                            
                            if !percentage.isNaN {
                                Text(lastValue.stringValue)
                                    .frame(width: 30)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.accentColor)
                                    .position(x: 10, y: reader.size.height * CGFloat(percentage))
                            }
                        }
                    }
                    .frame(width: 30)
                }
                
                
                ChartBottomView(insightData: insightData)
                    .padding(.trailing, 35)
            }
            .font(.footnote)
            .foregroundColor(Color.grayColor)
        } else {
            Text("Cannot display this as a Chart")
        }
    }
}


//struct LineChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        let chartData = try! ChartDataSet(data: [
//            .init(date: Date(timeIntervalSinceNow: -3600*24*9), value: 1),
//            .init(date: Date(timeIntervalSinceNow: -3600*24*8), value: 20),
//            .init(date: Date(timeIntervalSinceNow: -3600*24*7), value: 30),
//            .init(date: Date(timeIntervalSinceNow: -3600*24*6), value: 40),
//            .init(date: Date(timeIntervalSinceNow: -3600*24*4), value: 30),
//            .init(date: Date(timeIntervalSinceNow: -3600*24*3), value: 80),
//            .init(date: Date(timeIntervalSinceNow: -3600*24*2), value: 24),
//            .init(date: Date(timeIntervalSinceNow: -3600*24*1), value: 60),
//        ])
//        
//        LineChartView(data: chartData)
//        .padding()
//        .previewLayout(.fixed(width: 400, height: 200))
//    }
//}
//
