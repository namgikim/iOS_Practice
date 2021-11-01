//
//  ChartsViewController.swift
//  PhotoSimple
//
//  Created by namgi on 2021/10/28.
//

import UIKit
import Charts

class ChartsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var combinedChartView: CombinedChartView!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.barChartView.noDataText = "데이터가 없습니다."
        self.barChartView.noDataFont = .systemFont(ofSize: 20)
        self.barChartView.noDataTextColor = .lightGray
        
        self.lineChartView.noDataText = "데이터가 없습니다."
        self.lineChartView.noDataFont = .systemFont(ofSize: 20)
        self.lineChartView.noDataTextColor = .lightGray
        
        self.pieChartView.noDataText = "데이터가 없습니다."
        self.pieChartView.noDataFont = .systemFont(ofSize: 20)
        self.pieChartView.noDataTextColor = .lightGray
        
        self.combinedChartView.noDataText = "데이터가 없습니다."
        self.combinedChartView.noDataFont = .systemFont(ofSize: 20)
        self.combinedChartView.noDataTextColor = .lightGray
        
        self.setChart()
    }
    
    private func setChart() {
        // 월 표기 텍스트
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        // 데이터 만들기
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<months.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double.random(in: 0...20))
            dataEntries.append(dataEntry)
        }
        
        // 1. Bar Chart
        // 데이터 설정
        let barChartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart")
        barChartDataSet.colors = [.systemBlue]
        barChartDataSet.highlightEnabled = false // 막대를 탭 했을 때 하이라이트 표시 차단
        barChartView.data = BarChartData(dataSet: barChartDataSet)
        
        // 보여지는 정보 설정하기
        barChartView.doubleTapToZoomEnabled = false // 더블 탭으로 확대기능 차단
        barChartView.backgroundColor = .systemGray6 // 배경색
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months) // x축 레이블 설정
        barChartView.xAxis.setLabelCount(months.count, force: false) // x축 레이블이 띄엄띄엄 나오지 않고 모두 나오도록 설정
        barChartView.xAxis.labelPosition = .bottom // x축 레이블 위치
        barChartView.rightAxis.enabled = false // 오른쪽 레이블 제거
        barChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5) // 애니메이션 적용
        barChartView.leftAxis.addLimitLine(ChartLimitLine(limit: 15.0, label: "Limit Line")) // 한계선 표시
        barChartView.leftAxis.axisMinimum = 0 // 최소치 표시
        barChartView.leftAxis.axisMaximum = 25 // 최대치 표시
        
        // 2. Line Chart
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "Line Chart")
        lineChartDataSet.colors = [.systemRed]
        lineChartDataSet.circleColors = [.systemRed]
        lineChartDataSet.highlightEnabled = false
        lineChartDataSet.lineWidth = 5.0 // 선 두께
        lineChartDataSet.circleHoleRadius = 5.0 // 원 반경
        lineChartView.data = LineChartData(dataSet: lineChartDataSet)
        lineChartView.doubleTapToZoomEnabled = false // 더블 탭으로 확대기능 차단
        lineChartView.backgroundColor = .systemGray6 // 배경색
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        lineChartView.xAxis.setLabelCount(months.count, force: false)
        lineChartView.xAxis.labelPosition = .bottom // x축 레이블 위치
        lineChartView.rightAxis.enabled = false // 오른쪽 레이블 제거
        lineChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5) // 애니메이션 적용
        lineChartView.leftAxis.addLimitLine(ChartLimitLine(limit: 15.0, label: "Limit Line")) // 한계선 표시
        lineChartView.leftAxis.axisMinimum = 0 // 최소치 표시
        lineChartView.leftAxis.axisMaximum = 25 // 최대치 표시
        
        // 3. Pie Chart
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "Pie Chart")
        pieChartDataSet.colors = [.systemOrange]
        pieChartDataSet.highlightEnabled = false
        pieChartView.data = PieChartData(dataSet: pieChartDataSet)
        pieChartView.backgroundColor = .systemGray6
        pieChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5) // 애니메이션 적용
        pieChartView.rotationEnabled = false
        
        // 데이터 재설정
        dataEntries = []
        for i in 0..<months.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double.random(in: 0...20))
            dataEntries.append(dataEntry)
        }
        let newLineChartDataSet = LineChartDataSet(entries: dataEntries, label: "Line Chart")
        newLineChartDataSet.mode = .cubicBezier // Line Chart 를 곡선으로 표현
        newLineChartDataSet.colors = [.systemRed]
        newLineChartDataSet.circleColors = [.systemRed]
        newLineChartDataSet.circleRadius = 2.0
        
        // 4. Combined Chart
        let combinedChartData = CombinedChartData()
        combinedChartData.barData = BarChartData(dataSet: barChartDataSet)
        combinedChartData.lineData = LineChartData(dataSet: newLineChartDataSet)
        combinedChartView.data = combinedChartData
        combinedChartView.doubleTapToZoomEnabled = false
        combinedChartView.backgroundColor = .systemGray6
        combinedChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        combinedChartView.xAxis.setLabelCount(months.count, force: false)
        combinedChartView.xAxis.labelPosition = .bottom // x축 레이블 위치
        combinedChartView.rightAxis.enabled = false // 오른쪽 레이블 제거
        combinedChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5) // 애니메이션 적용
        combinedChartView.leftAxis.addLimitLine(ChartLimitLine(limit: 15.0, label: "Limit Line")) // 한계선 표시
        combinedChartView.leftAxis.axisMinimum = 0 // 최소치 표시
        combinedChartView.leftAxis.axisMaximum = 25 // 최대치 표시
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
