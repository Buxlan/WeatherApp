//
//  CityDatabaseLoader.swift
//  WeatherApp
//
//  Created by  Buxlan on 9/29/21.
//

import Foundation

class CityDatabaseLoader {
    
    func copySnapshotIfNeeded() {
        if !AppController.shared.areCitiesLoaded {
            if self.perform() {
                AppController.shared.areCitiesLoaded = true
            }
        }
    }
    
    private func perform() -> Bool {
        do {
            try deleteExistingSnapshot()
            try copySnapshot()
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    private func deleteExistingSnapshot() throws {
        let fileManager = FileManager.default
        var url = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("database.sqlite")
        if fileManager.fileExists(atPath: url.path),
           fileManager.isDeletableFile(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        url = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("database.sqlite-shm")
        if fileManager.fileExists(atPath: url.path),
           fileManager.isDeletableFile(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        url = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("database.sqlite-wal")
        if fileManager.fileExists(atPath: url.path),
           fileManager.isDeletableFile(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    private func copySnapshot() throws {
        let fileManager = FileManager.default
        let url = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("database.sqlite")
        if fileManager.fileExists(atPath: url.path) {
            print("Database file already exists at path: \(url.path)")
            return
        }
        guard let bundleURL = Bundle.main.url(forResource: "database", withExtension: "sqlite") else {
            fatalError("Database file didn't find at main bundle")
        }
        try fileManager.copyItem(at: bundleURL, to: url)
    }
    
}
