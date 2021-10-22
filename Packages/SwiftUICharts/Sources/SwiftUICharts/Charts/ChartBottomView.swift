//
//  ChartBottomView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 23.11.20.
//

import SwiftUI
import WidgetKit

struct ChartBottomView: View {
    var insightData: ChartDataSet?

    let isSelected: Bool

    private let widthPerLabel: CGFloat = 160

    @Environment(\.widgetFamily) var family: WidgetFamily

    var body: some View {
        GeometryReader { geometry in
            HStack {
                if let firstDate = insightData?.data.first?.xAxisDate {
                    if family == .systemSmall {
                        Text(firstDate.dateString(ofStyle: .short))
                    } else {
                        Text(firstDate, style: .date)
                    }

                } else if let firstEntry = insightData?.data.first {
                    Text(firstEntry.xAxisValue)
                }

                Spacer()

                let numberOfLabels = Int(geometry.size.width / widthPerLabel)

                if numberOfLabels > 1 && (insightData?.data.count ?? 0) > 0 {
                    ForEach(1 ..< numberOfLabels, id: \.self) { number in
                        let index: Int = (insightData?.data.count ?? 0) * number / numberOfLabels
                        let indexInsightData = insightData?.data[index]
                        if let indexDate: Date = indexInsightData?.xAxisDate {
                            Text(indexDate, style: .date)
                        }

                        Spacer()
                    }
                }

                if geometry.size.width > widthPerLabel {
                    if let lastDate = insightData?.data.last?.xAxisDate {
                        if family == .systemSmall {
                            Text(lastDate.dateString(ofStyle: .short))
                        } else {
                            Text(lastDate, style: .date)
                        }
                    } else if let lastEntry = insightData?.data.last {
                        Text(lastEntry.xAxisValue)
                    }
                }
            }
        }
        .frame(maxHeight: 12)
        .font(.footnote)
        .foregroundColor(isSelected ? .cardBackground : .grayColor)
    }
}
