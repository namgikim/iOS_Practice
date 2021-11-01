//
//  CalendarViewController.swift
//  PhotoSimple
//
//  Created by namgi on 2021/10/28.
//

import UIKit

class CalendarViewController: UIViewController {
    
    typealias dayArrayType = (year: Int, month: Int, day: Int, isCurrent: Bool)
    
    // MARK: - Properties
    var standardDate: Date = Date() // 오늘을 기준으로 동작하며, 스크롤로 날짜를 변경할 때마다 갱신된다.
    let numberOfItems: CGFloat = 7.0
    var totalDayArray: [dayArrayType] = []
    var cellCount: Int = 0
    
    let myCalendar = Calendar.init(identifier: .gregorian)
    var year: Int = 0
    var month: Int = 0
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var monthStackView: UIStackView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.calendarCollectionView.delegate = self
        self.calendarCollectionView.dataSource = self
        self.calendarCollectionView.scrollsToTop = false
        self.calendarCollectionView.showsVerticalScrollIndicator = false
        
        self.setFlowLayout(row: 6)
        
        self.setDatas()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.calendarCollectionView.scrollToItem(at: IndexPath(row: 42, section: 0), at: .top, animated: false)
    }
    
}

extension CalendarViewController {
    
    // MARK: - Methods
    private func setFlowLayout(row: CGFloat) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 0 // 아이템 간 최소거리
        flowLayout.minimumLineSpacing = 0 // 행 간 최소거리
        
        // (UIScreen.main.bounds.width / self.numberOfItems)
        let halfWidth: CGFloat = (self.calendarCollectionView.frame.size.width / self.numberOfItems) - ((flowLayout.minimumInteritemSpacing * (self.numberOfItems - 1)) / self.numberOfItems)
        
        let halfHeight: CGFloat = self.calendarCollectionView.frame.size.height / row
        
        flowLayout.itemSize = CGSize(width: halfWidth, height: halfHeight)
//        flowLayout.footerReferenceSize = CGSize(width: halfWidth * 3, height: 70)
//        flowLayout.sectionFootersPinToVisibleBounds = true
        self.calendarCollectionView.collectionViewLayout = flowLayout
    }
    
    private func setDatas() {
        let yearText: String = String(self.myCalendar.component(.year, from: self.standardDate))
        let monthText: String = String(self.myCalendar.component(.month, from: self.standardDate))
        self.dateLabel.text = yearText + ". " + monthText
        self.setTotalDayArray()
    }
    
    private func getDayArray(date: Date) -> [dayArrayType] {
        let year: Int = self.myCalendar.component(.year, from: date)
        let month: Int = self.myCalendar.component(.month, from: date)
        let date1day: Date = self.myCalendar.date(from: DateComponents(year: year, month: month, day: 1))!
        
        // 1일의 요일 (1~7: 일~토)
        let weekday: Int = self.myCalendar.component(.weekday, from: date1day)
        
        // 마지막 일
        var dateForLastday: Date
        dateForLastday = self.myCalendar.date(byAdding: .month, value: 1, to: date1day)!
        dateForLastday = self.myCalendar.date(byAdding: .day, value: -1, to: dateForLastday)!
        let lastday: Int = self.myCalendar.component(.day, from: dateForLastday) // 현재 달 마지막 일
        
        // 이전 달의 마지막 일
        var dateForPrevLastday: Date
        dateForPrevLastday = self.myCalendar.date(byAdding: .day, value: -1, to: date1day)!
        let prevYear: Int = self.myCalendar.component(.year, from: dateForPrevLastday)
        let prevMonth: Int = self.myCalendar.component(.month, from: dateForPrevLastday)
        let prevLastday: Int = self.myCalendar.component(.day, from: dateForPrevLastday) // 이전 달 마지막 일
        
        // 다음 달 정보
        let dateForNextMonth = self.myCalendar.date(byAdding: .month, value: 1, to: date1day)!
        let nextYear: Int = self.myCalendar.component(.year, from: dateForNextMonth)
        let nextMonth: Int = self.myCalendar.component(.month, from: dateForNextMonth)
        
        let currentCellCount: Int = 42
        
        // 현재 달의 시작 요일에 따라 35 혹은 42 형태로 설정
        //  if lastday + (weekday-1) <= 35 { currentCellCount = 35 }
        //  else { currentCellCount = 42 }
        
        // 달력 배열 생성
        var result: [dayArrayType] = []
        var day: Int = 0
        var nextMonthDay: Int = 0
        for i in 1...currentCellCount {
            if i < weekday { // 이전 달 표시
                result.append((year: prevYear, month: prevMonth, day: prevLastday - (weekday-1-i), isCurrent: false))
                
            } else if day == lastday { // 다음 달 표시
                nextMonthDay += 1
                result.append((year: nextYear, month: nextMonth, day: nextMonthDay, isCurrent: false))
                
            } else { // 현재 달 표시 (메인)
                day += 1
                result.append((year: year, month: month, day: day, isCurrent: true))
            }
        }
        
        return result
    }
    
    private func setTotalDayArray() {
        let prevMonthDayArray: [dayArrayType] = self.getDayArray(date: myCalendar.date(byAdding: .month,
                                                                                       value: -1,
                                                                                       to: self.standardDate)!)
        let todayDayArray: [dayArrayType] = self.getDayArray(date: self.standardDate)
        let nextMonthDayArray: [dayArrayType] = self.getDayArray(date: myCalendar.date(byAdding: .month,
                                                                                       value: 1,
                                                                                       to: self.standardDate)!)
        self.totalDayArray = []
        self.totalDayArray.append(contentsOf: prevMonthDayArray)
        self.totalDayArray.append(contentsOf: todayDayArray)
        self.totalDayArray.append(contentsOf: nextMonthDayArray)
        
        self.cellCount = self.totalDayArray.count
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
        
        let dateInfo: dayArrayType = self.totalDayArray[indexPath.row]
        cell.year = dateInfo.year
        cell.month = dateInfo.month
        cell.day = dateInfo.day
        
        cell.dayLabel.text = String(cell.day)
        cell.infoLabel.text = "정보 표시"
        
        if self.totalDayArray[indexPath.row].isCurrent == true {
         
            if (indexPath.row+1) % 7 == 1 { cell.dayLabel.textColor = .systemRed }
            else { cell.dayLabel.textColor = .black }
            
            cell.infoLabel.textColor = .black
            
        } else {
            cell.dayLabel.textColor = .lightGray
            cell.infoLabel.textColor = .lightGray
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page: Int = Int(scrollView.contentOffset.y) / Int(scrollView.frame.height)
//        print("page: \(page)")
        
        switch page {
        case 0, 2:
            self.standardDate = self.myCalendar.date(byAdding: .month,
                                                     value: page == 0 ? -1 : 1,
                                                     to: self.standardDate)!
            self.setDatas()
            self.calendarCollectionView.reloadData()
            self.calendarCollectionView.scrollToItem(at: IndexPath(row: 42, section: 0),
                                                     at: .top,
                                                     animated: false)
        case 1:
            return
        default:
            return
        }
    }
}
