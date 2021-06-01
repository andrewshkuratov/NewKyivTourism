//
//  TimerView.swift
//  NewKyivTourism
//
//  Created by Andrew on 30.05.2021.
//

import Foundation
import UIKit

class TimerView {
    private var label: UILabel = UILabel()
    private var timer = Timer()
    private var seconds = 0
    private var isTimerRunning = false
    
    init() {
        
    }
    
    func runTimer(label: UILabel) {
        self.label = label
        self.label.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: (#selector(updateTimer)),
                                     userInfo: nil, repeats: true)
    }
    
    @objc
    private func updateTimer() {
        seconds += 1
        label.text = timeString(time: TimeInterval(seconds))
    }
    
    private func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}
