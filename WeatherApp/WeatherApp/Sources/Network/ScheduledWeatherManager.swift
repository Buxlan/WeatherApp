//
//  ScheduledWeatherManager.swift
//  WeatherApp
//
//  Created by  Buxlan on 10/3/21.
//
import Network
import UIKit
import CoreData

class ScheduledWeatherManager {
    
    private var manager = WeatherManager()
    private var timer: Timer?
    static var timerInterval = TimeInterval(150)
    // MARK: - Init
    
    init() {
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
        
    // MARK: - Helper methods
    
    func update() {
        // get cities
        manager.update()
    }
    
    func startTimer() {
        stopTimer()
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: Self.timerInterval,
                                              target: self,
                                              selector: #selector(self.timerHandle),
                                              userInfo: nil,
                                              repeats: true)
        }
    }

    func stopTimer() {
        guard timer != nil else { return }
        DispatchQueue.main.sync {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    @objc
    private func timerHandle() {
        print("update by timer")
        update()
    }
    
}

extension ScheduledWeatherManager {
    
}
